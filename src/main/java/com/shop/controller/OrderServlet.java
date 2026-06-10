package com.shop.controller;

import com.shop.dao.CartDao;
import com.shop.dao.OrderDao;
import com.shop.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

@WebServlet("/order/*")
public class OrderServlet extends HttpServlet {
    private final OrderDao orderDao = new OrderDao();
    private final CartDao cartDao = new CartDao();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/user/login");
            return;
        }

        String action = req.getPathInfo();
        if (action == null) action = "/list";

        switch (action) {
            case "/checkout" -> {
                List<CartItem> items = cartDao.findByUserId(user.getId());
                if (items.isEmpty()) {
                    resp.sendRedirect(req.getContextPath() + "/cart/list");
                    return;
                }
                BigDecimal total = items.stream()
                        .map(CartItem::getSubtotal)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);
                req.setAttribute("cartItems", items);
                req.setAttribute("totalAmount", total);
                req.setAttribute("user", user);
                req.getRequestDispatcher("/WEB-INF/views/order/checkout.jsp").forward(req, resp);
            }
            case "/list" -> {
                int page = getPage(req);
                List<Order> orders = orderDao.findByUserId(user.getId(), page, PAGE_SIZE);
                int total = orderDao.countByUserId(user.getId());
                int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

                // 加载每个订单的明细
                for (Order order : orders) {
                    order.setItems(orderDao.findItemsByOrderId(order.getId()));
                }

                req.setAttribute("orders", orders);
                req.setAttribute("currentPage", page);
                req.setAttribute("totalPages", totalPages);
                req.getRequestDispatcher("/WEB-INF/views/order/list.jsp").forward(req, resp);
            }
            case "/detail" -> {
                Long id = getLong(req, "id");
                if (id == null) {
                    resp.sendRedirect(req.getContextPath() + "/order/list");
                    return;
                }
                Order order = orderDao.findById(id);
                if (order == null || !order.getUserId().equals(user.getId())) {
                    resp.sendRedirect(req.getContextPath() + "/order/list");
                    return;
                }
                req.setAttribute("order", order);
                req.getRequestDispatcher("/WEB-INF/views/order/detail.jsp").forward(req, resp);
            }
            default -> resp.sendRedirect(req.getContextPath() + "/order/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        User user = getUser(req);
        if (user == null) {
            out.print("{\"success\":false,\"message\":\"请先登录\"}");
            return;
        }

        String action = req.getPathInfo();
        switch (action) {
            case "/create" -> {
                String receiver = req.getParameter("receiver");
                String phone = req.getParameter("phone");
                String address = req.getParameter("address");
                String remark = req.getParameter("remark");

                if (receiver == null || receiver.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"请填写收货人\",\"field\":\"receiver\"}");
                    return;
                }
                if (phone == null || phone.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"请填写联系电话\",\"field\":\"phone\"}");
                    return;
                }
                if (address == null || address.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"请填写收货地址\",\"field\":\"address\"}");
                    return;
                }

                List<CartItem> cartItems = cartDao.findByUserId(user.getId());
                if (cartItems.isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"购物车为空\"}");
                    return;
                }

                BigDecimal totalAmount = BigDecimal.ZERO;
                List<OrderItem> orderItems = new ArrayList<>();
                for (CartItem ci : cartItems) {
                    OrderItem oi = new OrderItem();
                    oi.setProductId(ci.getProductId());
                    oi.setProductName(ci.getProductName());
                    oi.setProductPrice(ci.getProductPrice());
                    oi.setProductImage(ci.getProductImage());
                    oi.setQuantity(ci.getQuantity());
                    orderItems.add(oi);
                    totalAmount = totalAmount.add(ci.getSubtotal());
                }

                Order order = new Order();
                order.setOrderNo(generateOrderNo());
                order.setUserId(user.getId());
                order.setTotalAmount(totalAmount);
                order.setReceiver(receiver.trim());
                order.setPhone(phone.trim());
                order.setAddress(address.trim());
                order.setRemark(remark);

                try {
                    orderDao.createOrder(order, orderItems);
                    cartDao.clearByUserId(user.getId());
                    out.print("{\"success\":true,\"message\":\"下单成功\",\"orderNo\":\"" + order.getOrderNo() + "\"}");
                } catch (Exception e) {
                    out.print("{\"success\":false,\"message\":\"下单失败: " + e.getMessage() + "\"}");
                }
            }
            case "/cancel" -> {
                Long id = getLong(req, "id");
                if (id == null) {
                    out.print("{\"success\":false,\"message\":\"参数错误\"}");
                    return;
                }
                Order order = orderDao.findById(id);
                if (order == null || !order.getUserId().equals(user.getId())) {
                    out.print("{\"success\":false,\"message\":\"订单不存在\"}");
                    return;
                }
                if (!"PENDING".equals(order.getStatus())) {
                    out.print("{\"success\":false,\"message\":\"该订单状态不允许取消\"}");
                    return;
                }
                if (orderDao.updateStatus(id, "CANCELLED")) {
                    out.print("{\"success\":true,\"message\":\"订单已取消\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"取消失败\"}");
                }
            }
            case "/pay" -> {
                Long id = getLong(req, "id");
                if (id == null) {
                    out.print("{\"success\":false,\"message\":\"参数错误\"}");
                    return;
                }
                Order order = orderDao.findById(id);
                if (order == null || !order.getUserId().equals(user.getId())) {
                    out.print("{\"success\":false,\"message\":\"订单不存在\"}");
                    return;
                }
                if (!"PENDING".equals(order.getStatus())) {
                    out.print("{\"success\":false,\"message\":\"该订单状态不允许付款\"}");
                    return;
                }
                if (orderDao.updateStatus(id, "PAID")) {
                    out.print("{\"success\":true,\"message\":\"付款成功\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"付款失败\"}");
                }
            }
            case "/confirm" -> {
                Long id = getLong(req, "id");
                if (id == null) {
                    out.print("{\"success\":false,\"message\":\"参数错误\"}");
                    return;
                }
                Order order = orderDao.findById(id);
                if (order == null || !order.getUserId().equals(user.getId())) {
                    out.print("{\"success\":false,\"message\":\"订单不存在\"}");
                    return;
                }
                if (!"SHIPPED".equals(order.getStatus())) {
                    out.print("{\"success\":false,\"message\":\"该订单状态不允许确认收货\"}");
                    return;
                }
                if (orderDao.updateStatus(id, "COMPLETED")) {
                    out.print("{\"success\":true,\"message\":\"已确认收货\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"操作失败\"}");
                }
            }
            default -> out.print("{\"success\":false,\"message\":\"未知操作\"}");
        }
    }

    private String generateOrderNo() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", ThreadLocalRandom.current().nextInt(10000));
    }

    private User getUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null ? (User) session.getAttribute("user") : null;
    }

    private int getPage(HttpServletRequest req) {
        try { return Math.max(1, Integer.parseInt(req.getParameter("page"))); } catch (Exception e) { return 1; }
    }

    private Long getLong(HttpServletRequest req, String name) {
        try { return Long.parseLong(req.getParameter(name)); } catch (Exception e) { return null; }
    }
}

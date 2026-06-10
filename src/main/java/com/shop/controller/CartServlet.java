package com.shop.controller;

import com.shop.dao.CartDao;
import com.shop.model.CartItem;
import com.shop.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/cart/*")
public class CartServlet extends HttpServlet {
    private final CartDao cartDao = new CartDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/user/login");
            return;
        }

        String action = req.getPathInfo();
        if (action == null || "/list".equals(action)) {
            List<CartItem> items = cartDao.findByUserId(user.getId());
            req.setAttribute("cartItems", items);
            req.getRequestDispatcher("/WEB-INF/views/cart/list.jsp").forward(req, resp);
        } else if ("/count".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            int count = cartDao.countByUserId(user.getId());
            resp.getWriter().print("{\"count\":" + count + "}");
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
            case "/add" -> {
                Long productId = getLong(req, "productId");
                int quantity = getInt(req, "quantity", 1);
                if (productId == null) {
                    out.print("{\"success\":false,\"message\":\"参数错误\"}");
                    return;
                }
                CartItem item = new CartItem();
                item.setUserId(user.getId());
                item.setProductId(productId);
                item.setQuantity(quantity);
                if (cartDao.insert(item)) {
                    int count = cartDao.countByUserId(user.getId());
                    out.print("{\"success\":true,\"message\":\"已添加到购物车\",\"count\":" + count + "}");
                } else {
                    out.print("{\"success\":false,\"message\":\"添加失败\"}");
                }
            }
            case "/update" -> {
                Long id = getLong(req, "id");
                int quantity = getInt(req, "quantity", 1);
                if (id == null || quantity < 1) {
                    out.print("{\"success\":false,\"message\":\"参数错误\"}");
                    return;
                }
                if (cartDao.updateQuantity(id, quantity, user.getId())) {
                    out.print("{\"success\":true,\"message\":\"数量已更新\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"更新失败\"}");
                }
            }
            case "/delete" -> {
                Long id = getLong(req, "id");
                if (id == null) {
                    out.print("{\"success\":false,\"message\":\"参数错误\"}");
                    return;
                }
                if (cartDao.delete(id, user.getId())) {
                    out.print("{\"success\":true,\"message\":\"已从购物车移除\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"删除失败\"}");
                }
            }
            case "/clear" -> {
                cartDao.clearByUserId(user.getId());
                out.print("{\"success\":true,\"message\":\"购物车已清空\"}");
            }
            default -> out.print("{\"success\":false,\"message\":\"未知操作\"}");
        }
    }

    private User getUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null ? (User) session.getAttribute("user") : null;
    }

    private Long getLong(HttpServletRequest req, String name) {
        try { return Long.parseLong(req.getParameter(name)); } catch (Exception e) { return null; }
    }

    private int getInt(HttpServletRequest req, String name, int defaultVal) {
        try { return Integer.parseInt(req.getParameter(name)); } catch (Exception e) { return defaultVal; }
    }
}

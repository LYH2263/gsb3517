package com.shop.controller;

import com.shop.dao.*;
import com.shop.model.*;
import com.shop.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {
    private final ProductDao productDao = new ProductDao();
    private final CategoryDao categoryDao = new CategoryDao();
    private final OrderDao orderDao = new OrderDao();
    private final UserDao userDao = new UserDao();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo();
        if (action == null) action = "/dashboard";

        switch (action) {
            case "/dashboard" -> {
                req.setAttribute("productCount", productDao.count());
                req.setAttribute("orderCount", orderDao.countAll());
                req.setAttribute("userCount", userDao.count());
                req.setAttribute("totalRevenue", orderDao.totalRevenue());
                req.setAttribute("orderStatusMap", orderDao.countByStatus());
                req.setAttribute("recentOrders", orderDao.findRecent(5));
                req.setAttribute("topProducts", productDao.findTopSelling(5));
                req.setAttribute("categoryStats", productDao.countGroupByCategory());
                req.setAttribute("lowStockProducts", productDao.findLowStock(20));
                req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
            }
            case "/products" -> {
                int page = getPage(req);
                String keyword = req.getParameter("keyword");
                Long categoryId = getLong(req, "categoryId");
                Integer status = getInteger(req, "status");
                List<Product> products = productDao.findAllAdmin(keyword, categoryId, status, page, PAGE_SIZE);
                int total = productDao.countAdmin(keyword, categoryId, status);
                req.setAttribute("products", products);
                req.setAttribute("categories", categoryDao.findAll());
                req.setAttribute("currentPage", page);
                req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
                req.setAttribute("keyword", keyword);
                req.setAttribute("filterCategoryId", categoryId);
                req.setAttribute("filterStatus", status);
                req.getRequestDispatcher("/WEB-INF/views/admin/products.jsp").forward(req, resp);
            }
            case "/product/edit" -> {
                Long id = getLong(req, "id");
                if (id != null) {
                    req.setAttribute("product", productDao.findById(id));
                }
                req.setAttribute("categories", categoryDao.findAll());
                req.getRequestDispatcher("/WEB-INF/views/admin/product-edit.jsp").forward(req, resp);
            }
            case "/categories" -> {
                req.setAttribute("categories", categoryDao.findAll());
                req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, resp);
            }
            case "/orders" -> {
                int page = getPage(req);
                String status = req.getParameter("status");
                String keyword = req.getParameter("keyword");
                List<Order> orders = orderDao.findAllFiltered(status, keyword, page, PAGE_SIZE);
                int total = orderDao.countAllFiltered(status, keyword);
                for (Order order : orders) {
                    order.setItems(orderDao.findItemsByOrderId(order.getId()));
                }
                req.setAttribute("orders", orders);
                req.setAttribute("currentPage", page);
                req.setAttribute("totalPages", (int) Math.ceil((double) total / PAGE_SIZE));
                req.setAttribute("filterStatus", status);
                req.setAttribute("keyword", keyword);
                req.getRequestDispatcher("/WEB-INF/views/admin/orders.jsp").forward(req, resp);
            }
            case "/order/detail" -> {
                Long id = getLong(req, "id");
                if (id != null) {
                    req.setAttribute("order", orderDao.findById(id));
                }
                req.getRequestDispatcher("/WEB-INF/views/admin/order-detail.jsp").forward(req, resp);
            }
            case "/users" -> {
                String keyword = req.getParameter("keyword");
                String role = req.getParameter("role");
                Integer status = getInteger(req, "status");
                req.setAttribute("users", userDao.findAllFiltered(keyword, role, status));
                req.setAttribute("keyword", keyword);
                req.setAttribute("filterRole", role);
                req.setAttribute("filterStatus", status);
                req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
            }
            default -> resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String action = req.getPathInfo();

        switch (action) {
            case "/product/save" -> {
                Long id = getLong(req, "id");
                String name = req.getParameter("name");
                String description = req.getParameter("description");
                BigDecimal price;
                try { price = new BigDecimal(req.getParameter("price")); } catch (Exception e) {
                    out.print("{\"success\":false,\"message\":\"价格格式错误\",\"field\":\"price\"}");
                    return;
                }
                int stock;
                try { stock = Integer.parseInt(req.getParameter("stock")); } catch (Exception e) {
                    out.print("{\"success\":false,\"message\":\"库存格式错误\",\"field\":\"stock\"}");
                    return;
                }
                Long categoryId = getLong(req, "categoryId");
                String image = req.getParameter("image");
                int status = getInt(req, "status", 1);

                if (name == null || name.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"商品名称不能为空\",\"field\":\"name\"}");
                    return;
                }

                Product product = new Product();
                product.setName(name.trim());
                product.setDescription(description);
                product.setPrice(price);
                product.setStock(stock);
                product.setCategoryId(categoryId);
                product.setImage(image);
                product.setStatus(status);

                boolean success;
                if (id != null) {
                    product.setId(id);
                    success = productDao.update(product);
                } else {
                    success = productDao.insert(product);
                }
                out.print("{\"success\":" + success + ",\"message\":\"" + (success ? "保存成功" : "保存失败") + "\"}");
            }
            case "/product/delete" -> {
                Long id = getLong(req, "id");
                if (id != null && productDao.delete(id)) {
                    out.print("{\"success\":true,\"message\":\"删除成功\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"删除失败\"}");
                }
            }
            case "/category/save" -> {
                Long id = getLong(req, "id");
                String name = req.getParameter("name");
                String description = req.getParameter("description");
                int sortOrder = getInt(req, "sortOrder", 0);

                if (name == null || name.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"分类名称不能为空\",\"field\":\"name\"}");
                    return;
                }

                Category category = new Category();
                category.setName(name.trim());
                category.setDescription(description);
                category.setSortOrder(sortOrder);

                boolean success;
                if (id != null) {
                    category.setId(id);
                    success = categoryDao.update(category);
                } else {
                    category.setParentId(0L);
                    success = categoryDao.insert(category);
                }
                out.print("{\"success\":" + success + ",\"message\":\"" + (success ? "保存成功" : "保存失败") + "\"}");
            }
            case "/category/delete" -> {
                Long id = getLong(req, "id");
                if (id != null && categoryDao.delete(id)) {
                    out.print("{\"success\":true,\"message\":\"删除成功\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"删除失败，该分类下可能存在商品\"}");
                }
            }
            case "/order/ship" -> {
                Long id = getLong(req, "id");
                if (id != null && orderDao.updateStatus(id, "SHIPPED")) {
                    out.print("{\"success\":true,\"message\":\"已发货\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"操作失败\"}");
                }
            }
            case "/order/updateStatus" -> {
                Long id = getLong(req, "id");
                String status = req.getParameter("status");
                if (id != null && status != null && orderDao.updateStatus(id, status)) {
                    out.print("{\"success\":true,\"message\":\"状态已更新\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"操作失败\"}");
                }
            }
            case "/user/toggleStatus" -> {
                Long id = getLong(req, "id");
                int status = getInt(req, "status", 1);
                if (id != null && userDao.updateStatus(id, status)) {
                    out.print("{\"success\":true,\"message\":\"操作成功\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"操作失败\"}");
                }
            }
            default -> out.print("{\"success\":false,\"message\":\"未知操作\"}");
        }
    }

    private int getPage(HttpServletRequest req) {
        try { return Math.max(1, Integer.parseInt(req.getParameter("page"))); } catch (Exception e) { return 1; }
    }

    private Long getLong(HttpServletRequest req, String name) {
        try { return Long.parseLong(req.getParameter(name)); } catch (Exception e) { return null; }
    }

    private int getInt(HttpServletRequest req, String name, int defaultVal) {
        try { return Integer.parseInt(req.getParameter(name)); } catch (Exception e) { return defaultVal; }
    }

    private Integer getInteger(HttpServletRequest req, String name) {
        try { return Integer.parseInt(req.getParameter(name)); } catch (Exception e) { return null; }
    }
}

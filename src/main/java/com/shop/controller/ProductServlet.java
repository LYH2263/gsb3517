package com.shop.controller;

import com.shop.dao.CategoryDao;
import com.shop.dao.ProductDao;
import com.shop.model.Category;
import com.shop.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/product/*")
public class ProductServlet extends HttpServlet {
    private final ProductDao productDao = new ProductDao();
    private final CategoryDao categoryDao = new CategoryDao();
    private static final int PAGE_SIZE = 12;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo();
        if (action == null) action = "/list";

        switch (action) {
            case "/list" -> {
                int page = getPage(req);
                Long categoryId = getLongParam(req, "categoryId");
                String keyword = req.getParameter("keyword");
                String sort = req.getParameter("sort");
                BigDecimal minPrice = getBigDecimalParam(req, "minPrice");
                BigDecimal maxPrice = getBigDecimalParam(req, "maxPrice");

                // 使用统一筛选方法
                String kw = (keyword != null && !keyword.trim().isEmpty()) ? keyword.trim() : null;
                List<Product> products = productDao.findFiltered(categoryId, kw, minPrice, maxPrice, sort, page, PAGE_SIZE);
                int total = productDao.countFiltered(categoryId, kw, minPrice, maxPrice);

                List<Category> categories = categoryDao.findAll();
                int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

                req.setAttribute("products", products);
                req.setAttribute("categories", categories);
                req.setAttribute("currentPage", page);
                req.setAttribute("totalPages", totalPages);
                req.setAttribute("total", total);
                if (kw != null) req.setAttribute("keyword", kw);
                if (categoryId != null) req.setAttribute("currentCategoryId", categoryId);
                if (sort != null) req.setAttribute("currentSort", sort);
                if (minPrice != null) req.setAttribute("currentMinPrice", minPrice);
                if (maxPrice != null) req.setAttribute("currentMaxPrice", maxPrice);
                req.getRequestDispatcher("/WEB-INF/views/product/list.jsp").forward(req, resp);
            }
            case "/detail" -> {
                Long id = getLongParam(req, "id");
                if (id == null) {
                    resp.sendRedirect(req.getContextPath() + "/product/list");
                    return;
                }
                Product product = productDao.findById(id);
                if (product == null) {
                    resp.sendRedirect(req.getContextPath() + "/product/list");
                    return;
                }
                // 推荐商品：同分类的其他商品
                List<Product> recommended = productDao.findByCategory(product.getCategoryId(), 1, 4);
                recommended.removeIf(p -> p.getId().equals(product.getId()));

                req.setAttribute("product", product);
                req.setAttribute("recommended", recommended);
                req.getRequestDispatcher("/WEB-INF/views/product/detail.jsp").forward(req, resp);
            }
            case "/search" -> {
                String keyword = req.getParameter("keyword");
                resp.sendRedirect(req.getContextPath() + "/product/list?keyword=" +
                        (keyword != null ? java.net.URLEncoder.encode(keyword, "UTF-8") : ""));
            }
            default -> resp.sendRedirect(req.getContextPath() + "/product/list");
        }
    }

    private int getPage(HttpServletRequest req) {
        try {
            int page = Integer.parseInt(req.getParameter("page"));
            return Math.max(1, page);
        } catch (Exception e) {
            return 1;
        }
    }

    private Long getLongParam(HttpServletRequest req, String name) {
        try {
            return Long.parseLong(req.getParameter(name));
        } catch (Exception e) {
            return null;
        }
    }

    private BigDecimal getBigDecimalParam(HttpServletRequest req, String name) {
        try {
            String val = req.getParameter(name);
            if (val == null || val.trim().isEmpty()) return null;
            BigDecimal bd = new BigDecimal(val.trim());
            return bd.compareTo(BigDecimal.ZERO) >= 0 ? bd : null;
        } catch (Exception e) {
            return null;
        }
    }
}

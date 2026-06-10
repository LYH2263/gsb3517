package com.shop.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Set;

@WebServlet("/page/*")
public class PageServlet extends HttpServlet {
    private static final Set<String> VALID_PAGES = Set.of("help", "return-policy", "delivery");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo();
        if (action == null) action = "/help";
        String page = action.substring(1);

        if (!VALID_PAGES.contains(page)) {
            resp.sendRedirect(req.getContextPath() + "/page/help");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/page/" + page + ".jsp").forward(req, resp);
    }
}

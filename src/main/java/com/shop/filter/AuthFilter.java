package com.shop.filter;

import com.shop.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebFilter("/*")
public class AuthFilter implements Filter {
    private static final List<String> PUBLIC_PATHS = Arrays.asList(
            "/index.jsp", "/assets/", "/common/",
            "/user/login", "/user/register",
            "/product/list", "/product/detail", "/product/search",
            "/category/list", "/page/"
    );

    private static final List<String> ADMIN_PATHS = Arrays.asList(
            "/admin/"
    );

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;
        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();
        String path = uri.substring(contextPath.length());

        // 静态资源和公共页面放行
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 管理后台权限检查
        if (isAdminPath(path)) {
            if (user == null || !"ADMIN".equals(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/user/login");
                return;
            }
        }

        // 需要登录的页面
        if (user == null && !isPublicPath(path)) {
            // AJAX 请求返回 JSON，而非重定向
            String xhr = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equals(xhr)) {
                response.setContentType("application/json;charset=UTF-8");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\":false,\"message\":\"请先登录\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/user/login");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isPublicPath(String path) {
        for (String publicPath : PUBLIC_PATHS) {
            if (publicPath.endsWith("/")) {
                if (path.startsWith(publicPath)) return true;
            } else {
                if (path.equals(publicPath) || path.startsWith(publicPath + "?") || path.startsWith(publicPath + "/")) return true;
            }
        }
        if (path.equals("/")) return true;
        return false;
    }

    private boolean isAdminPath(String path) {
        for (String adminPath : ADMIN_PATHS) {
            if (path.startsWith(adminPath)) {
                return true;
            }
        }
        return false;
    }
}

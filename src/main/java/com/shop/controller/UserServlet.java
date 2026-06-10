package com.shop.controller;

import com.shop.dao.UserDao;
import com.shop.model.User;
import com.shop.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/user/*")
public class UserServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo();
        if (action == null) action = "/";
        switch (action) {
            case "/login" -> req.getRequestDispatcher("/WEB-INF/views/user/login.jsp").forward(req, resp);
            case "/register" -> req.getRequestDispatcher("/WEB-INF/views/user/register.jsp").forward(req, resp);
            case "/profile" -> {
                HttpSession session = req.getSession(false);
                if (session == null || session.getAttribute("user") == null) {
                    resp.sendRedirect(req.getContextPath() + "/user/login");
                    return;
                }
                User user = userDao.findById(((User) session.getAttribute("user")).getId());
                req.setAttribute("userInfo", user);
                req.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(req, resp);
            }
            case "/logout" -> {
                HttpSession session = req.getSession(false);
                if (session != null) session.invalidate();
                resp.sendRedirect(req.getContextPath() + "/");
            }
            default -> resp.sendRedirect(req.getContextPath() + "/");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getPathInfo();
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        switch (action) {
            case "/login" -> {
                String username = req.getParameter("username");
                String password = req.getParameter("password");
                if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"用户名和密码不能为空\"}");
                    return;
                }
                User user = userDao.findByUsername(username.trim());
                if (user == null || !PasswordUtil.verify(password, user.getPassword())) {
                    out.print("{\"success\":false,\"message\":\"用户名或密码错误\"}");
                    return;
                }
                if (user.getStatus() == 0) {
                    out.print("{\"success\":false,\"message\":\"该账户已被禁用\"}");
                    return;
                }
                req.getSession().setAttribute("user", user);
                out.print("{\"success\":true,\"message\":\"登录成功\",\"role\":\"" + user.getRole() + "\"}");
            }
            case "/register" -> {
                String username = req.getParameter("username");
                String password = req.getParameter("password");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");

                if (username == null || username.trim().length() < 3) {
                    out.print("{\"success\":false,\"message\":\"用户名至少3个字符\",\"field\":\"username\"}");
                    return;
                }
                if (password == null || password.length() < 6) {
                    out.print("{\"success\":false,\"message\":\"密码至少6个字符\",\"field\":\"password\"}");
                    return;
                }
                if (userDao.findByUsername(username.trim()) != null) {
                    out.print("{\"success\":false,\"message\":\"用户名已存在\",\"field\":\"username\"}");
                    return;
                }

                User user = new User();
                user.setUsername(username.trim());
                user.setPassword(PasswordUtil.encrypt(password));
                user.setEmail(email);
                user.setPhone(phone);
                user.setRole("USER");

                if (userDao.insert(user)) {
                    out.print("{\"success\":true,\"message\":\"注册成功\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"注册失败，请稍后重试\"}");
                }
            }
            case "/update" -> {
                HttpSession session = req.getSession(false);
                User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
                if (currentUser == null) {
                    out.print("{\"success\":false,\"message\":\"请先登录\"}");
                    return;
                }
                currentUser.setEmail(req.getParameter("email"));
                currentUser.setPhone(req.getParameter("phone"));
                currentUser.setAddress(req.getParameter("address"));
                if (userDao.update(currentUser)) {
                    User updated = userDao.findById(currentUser.getId());
                    session.setAttribute("user", updated);
                    out.print("{\"success\":true,\"message\":\"信息更新成功\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"更新失败\"}");
                }
            }
            case "/changePassword" -> {
                HttpSession session = req.getSession(false);
                User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
                if (currentUser == null) {
                    out.print("{\"success\":false,\"message\":\"请先登录\"}");
                    return;
                }
                String oldPwd = req.getParameter("oldPassword");
                String newPwd = req.getParameter("newPassword");
                if (!PasswordUtil.verify(oldPwd, currentUser.getPassword())) {
                    out.print("{\"success\":false,\"message\":\"原密码错误\",\"field\":\"oldPassword\"}");
                    return;
                }
                if (newPwd == null || newPwd.length() < 6) {
                    out.print("{\"success\":false,\"message\":\"新密码至少6个字符\",\"field\":\"newPassword\"}");
                    return;
                }
                if (userDao.updatePassword(currentUser.getId(), PasswordUtil.encrypt(newPwd))) {
                    User updated = userDao.findById(currentUser.getId());
                    session.setAttribute("user", updated);
                    out.print("{\"success\":true,\"message\":\"密码修改成功\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"修改失败\"}");
                }
            }
            default -> out.print("{\"success\":false,\"message\":\"未知操作\"}");
        }
    }
}

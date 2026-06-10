<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.title != null ? param.title : '管理后台'} - 优品商城</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/style.css" rel="stylesheet">
</head>
<body>
<!-- 顶部导航 -->
<nav class="navbar navbar-dark admin-navbar">
    <div class="container-fluid">
        <a class="navbar-brand" href="${ctx}/admin/dashboard"><i class="bi bi-gear-wide-connected me-2"></i>管理后台</a>
        <div class="d-flex align-items-center">
            <span class="text-light me-3"><i class="bi bi-person-circle me-1"></i>${sessionScope.user.username}</span>
            <a href="${ctx}/" class="btn btn-sm btn-outline-light me-2"><i class="bi bi-house me-1"></i>前台</a>
            <a href="${ctx}/user/logout" class="btn btn-sm btn-outline-light"><i class="bi bi-box-arrow-right me-1"></i>退出</a>
        </div>
    </div>
</nav>
<div class="d-flex">
    <!-- 侧边栏 -->
    <div class="admin-sidebar" style="width:220px;flex-shrink:0">
        <nav class="nav flex-column">
            <a class="nav-link ${param.menu == 'dashboard' ? 'active' : ''}" href="${ctx}/admin/dashboard">
                <i class="bi bi-speedometer2"></i>控制台
            </a>
            <a class="nav-link ${param.menu == 'products' ? 'active' : ''}" href="${ctx}/admin/products">
                <i class="bi bi-box-seam"></i>商品管理
            </a>
            <a class="nav-link ${param.menu == 'categories' ? 'active' : ''}" href="${ctx}/admin/categories">
                <i class="bi bi-tags"></i>分类管理
            </a>
            <a class="nav-link ${param.menu == 'orders' ? 'active' : ''}" href="${ctx}/admin/orders">
                <i class="bi bi-receipt"></i>订单管理
            </a>
            <a class="nav-link ${param.menu == 'users' ? 'active' : ''}" href="${ctx}/admin/users">
                <i class="bi bi-people"></i>用户管理
            </a>
        </nav>
    </div>
    <!-- 主内容 -->
    <div class="flex-grow-1 p-4" style="min-height:calc(100vh - 56px);background:var(--bg-light)">

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.title != null ? param.title : '在线购物平台'}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${ctx}/assets/css/style.css" rel="stylesheet">
    <script>function handleImgError(img){img.onerror=null;img.src='${ctx}/assets/images/default-product.jpg';}</script>
</head>
<body>
<!-- 导航栏 -->
<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="${ctx}/"><i class="bi bi-shop"></i>优品商城</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item"><a class="nav-link" href="${ctx}/">首页</a></li>
                <li class="nav-item"><a class="nav-link" href="${ctx}/product/list">全部商品</a></li>
            </ul>
            <form class="d-flex search-box me-3" action="${ctx}/product/list" method="get">
                <input class="form-control" type="search" name="keyword" placeholder="搜索商品..." value="${keyword}">
                <button class="btn" type="submit"><i class="bi bi-search"></i></button>
            </form>
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link cart-badge" href="${ctx}/cart/list">
                        <i class="bi bi-cart3"></i> 购物车
                        <span class="badge bg-danger rounded-pill" id="cartCount" style="display:none">0</span>
                    </a>
                </li>
                <c:choose>
                    <c:when test="${sessionScope.user != null}">
                        <li class="nav-item dropdown">
                            <a class="nav-link" href="#" data-bs-toggle="dropdown">
                                <i class="bi bi-person-circle"></i> ${sessionScope.user.username}
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="${ctx}/user/profile"><i class="bi bi-person me-2"></i>个人中心</a></li>
                                <li><a class="dropdown-item" href="${ctx}/order/list"><i class="bi bi-bag me-2"></i>我的订单</a></li>
                                <c:if test="${sessionScope.user.role == 'ADMIN'}">
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="${ctx}/admin/dashboard"><i class="bi bi-gear me-2"></i>管理后台</a></li>
                                </c:if>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="${ctx}/user/logout"><i class="bi bi-box-arrow-right me-2"></i>退出登录</a></li>
                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item"><a class="nav-link" href="${ctx}/user/login"><i class="bi bi-box-arrow-in-right"></i> 登录</a></li>
                        <li class="nav-item"><a class="nav-link" href="${ctx}/user/register"><i class="bi bi-person-plus"></i> 注册</a></li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>
<script>
(function(){
    var path = location.pathname.replace(/\/$/, '') || '/';
    var links = document.querySelectorAll('.navbar-nav .nav-link');
    for(var i = 0; i < links.length; i++){
        var href = links[i].getAttribute('href');
        if(!href) continue;
        var linkPath = href.replace(/\/$/, '') || '/';
        if(path === linkPath || (linkPath !== '/' && path.indexOf(linkPath) === 0)){
            links[i].classList.add('active');
        }
    }
})();
</script>
<div class="main-content">

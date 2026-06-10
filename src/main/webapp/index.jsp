<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.shop.dao.ProductDao, com.shop.dao.CategoryDao, com.shop.model.*, java.util.*" %>
<%
    ProductDao productDao = new ProductDao();
    CategoryDao categoryDao = new CategoryDao();
    request.setAttribute("hotProducts", productDao.findHot(8));
    request.setAttribute("newProducts", productDao.findNew(8));
    request.setAttribute("categories", categoryDao.findAll());
%>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="优品商城 - 品质生活，从这里开始"/></jsp:include>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!-- Hero Banner -->
<div class="hero-banner">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-7">
                <h1 class="fade-in-up"><i class="bi bi-stars"></i> 优品商城，品质之选</h1>
                <p class="fade-in-up mb-1">海量正品好物，超值优惠，品质保障，快速配送</p>
                <p class="fade-in-up" style="opacity:0.8;font-size:0.95rem">每日上新 · 正品保障 · 极速物流 · 无忧售后</p>
                <a href="${ctx}/product/list" class="btn btn-light btn-lg mt-2 fade-in-up">
                    <i class="bi bi-grid me-1"></i>浏览全部商品
                </a>
            </div>
            <div class="col-lg-5 text-center d-none d-lg-block">
                <i class="bi bi-bag-heart" style="font-size:8rem;opacity:0.15"></i>
            </div>
        </div>
    </div>
</div>

<div class="container">
    <!-- 服务特色条 -->
    <div class="feature-bar">
        <div class="row g-0">
            <div class="col-3">
                <div class="feature-item">
                    <i class="bi bi-truck"></i>
                    <span>免费配送</span>
                </div>
            </div>
            <div class="col-3">
                <div class="feature-item">
                    <i class="bi bi-shield-check"></i>
                    <span>正品保障</span>
                </div>
            </div>
            <div class="col-3">
                <div class="feature-item">
                    <i class="bi bi-arrow-repeat"></i>
                    <span>7天退换</span>
                </div>
            </div>
            <div class="col-3">
                <div class="feature-item">
                    <i class="bi bi-headset"></i>
                    <span>专属客服</span>
                </div>
            </div>
        </div>
    </div>

    <!-- 商品分类 -->
    <div class="mb-4">
        <h5 class="section-title mb-3">商品分类</h5>
        <div class="row g-2">
            <c:forEach var="cat" items="${categories}" varStatus="st">
                <div class="col-4 col-md-2">
                    <a href="${ctx}/product/list?categoryId=${cat.id}" class="category-card">
                        <i class="bi ${st.index == 0 ? 'bi-phone' : st.index == 1 ? 'bi-laptop' : st.index == 2 ? 'bi-tv' : st.index == 3 ? 'bi-bag' : st.index == 4 ? 'bi-egg-fried' : 'bi-book'}"></i>
                        <span>${cat.name}</span>
                    </a>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- 热门商品 -->
    <div class="mb-5">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="section-title"><i class="bi bi-fire me-2 text-danger"></i>热门商品</h5>
            <a href="${ctx}/product/list" class="text-decoration-none small text-muted">查看更多 <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="row g-3">
            <c:forEach var="product" items="${hotProducts}">
                <div class="col-6 col-md-4 col-lg-3">
                    <div class="card product-card">
                        <div class="card-img-wrapper">
                            <a href="${ctx}/product/detail?id=${product.id}">
                                <img src="${ctx}${product.image}" class="card-img-top" alt="${product.name}"
                                     onerror="handleImgError(this)">
                            </a>
                        </div>
                        <div class="card-body">
                            <div class="product-name">
                                <a href="${ctx}/product/detail?id=${product.id}">${product.name}</a>
                            </div>
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="product-price"><small>¥</small>${product.price}</span>
                                <span class="product-sales">已售${product.sales}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- 新品上架 -->
    <div class="mb-5">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="section-title"><i class="bi bi-lightning me-2 text-warning"></i>新品上架</h5>
            <a href="${ctx}/product/list" class="text-decoration-none small text-muted">查看更多 <i class="bi bi-arrow-right"></i></a>
        </div>
        <div class="row g-3">
            <c:forEach var="product" items="${newProducts}">
                <div class="col-6 col-md-4 col-lg-3">
                    <div class="card product-card">
                        <div class="card-img-wrapper">
                            <a href="${ctx}/product/detail?id=${product.id}">
                                <img src="${ctx}${product.image}" class="card-img-top" alt="${product.name}"
                                     onerror="handleImgError(this)">
                            </a>
                        </div>
                        <div class="card-body">
                            <div class="product-name">
                                <a href="${ctx}/product/detail?id=${product.id}">${product.name}</a>
                            </div>
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="product-price"><small>¥</small>${product.price}</span>
                                <span class="product-sales">已售${product.sales}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp"/>

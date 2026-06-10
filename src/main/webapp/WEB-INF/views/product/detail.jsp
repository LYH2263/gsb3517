<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="${product.name}"/></jsp:include>

<div class="container py-4">
    <!-- 面包屑 -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">首页</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/product/list">全部商品</a></li>
            <c:if test="${not empty product.categoryName}">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/product/list?categoryId=${product.categoryId}">${product.categoryName}</a>
                </li>
            </c:if>
            <li class="breadcrumb-item active">${product.name}</li>
        </ol>
    </nav>

    <!-- 商品主信息 -->
    <div class="card border-0 shadow-sm detail-main-card">
        <div class="card-body p-4">
            <div class="row">
                <!-- 商品图片 -->
                <div class="col-md-5 mb-3">
                    <div class="detail-img-box">
                        <img src="${pageContext.request.contextPath}${product.image}" class="product-detail-img"
                             alt="${product.name}" onerror="handleImgError(this)" id="mainProductImg">
                    </div>
                </div>
                <!-- 商品信息 -->
                <div class="col-md-7">
                    <h3 class="detail-product-title">${product.name}</h3>
                    <p class="detail-product-desc text-muted">${product.description}</p>

                    <div class="detail-price-box">
                        <div class="detail-price-label">优品价</div>
                        <div class="detail-price-value">
                            <span class="detail-price-symbol">¥</span><span class="detail-price-num">${product.price}</span>
                        </div>
                    </div>

                    <div class="detail-info-rows">
                        <div class="detail-info-row">
                            <span class="detail-info-label">配送</span>
                            <span><i class="bi bi-truck me-1 text-primary"></i>全国包邮 · 预计3-5天送达</span>
                        </div>
                        <div class="detail-info-row">
                            <span class="detail-info-label">分类</span>
                            <span>
                                <a href="${pageContext.request.contextPath}/product/list?categoryId=${product.categoryId}" class="text-primary">${product.categoryName}</a>
                            </span>
                        </div>
                        <div class="detail-info-row">
                            <span class="detail-info-label">销量</span>
                            <span>已售 <strong>${product.sales}</strong> 件</span>
                        </div>
                        <div class="detail-info-row">
                            <span class="detail-info-label">库存</span>
                            <span>
                                <c:choose>
                                    <c:when test="${product.stock > 20}"><span class="text-success"><i class="bi bi-check-circle me-1"></i>充足 (${product.stock}件)</span></c:when>
                                    <c:when test="${product.stock > 0}"><span class="text-warning"><i class="bi bi-exclamation-circle me-1"></i>仅剩${product.stock}件</span></c:when>
                                    <c:otherwise><span class="text-danger"><i class="bi bi-x-circle me-1"></i>暂时缺货</span></c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>

                    <div class="detail-qty-row">
                        <span class="detail-info-label">数量</span>
                        <div class="quantity-control">
                            <button type="button" onclick="changeQty(-1)">-</button>
                            <input type="number" id="buyQuantity" value="1" min="1" max="${product.stock}">
                            <button type="button" onclick="changeQty(1)">+</button>
                        </div>
                    </div>

                    <div class="detail-actions">
                        <button class="btn btn-primary btn-lg" onclick="addToCart(${product.id}, document.getElementById('buyQuantity').value)" ${product.stock <= 0 ? 'disabled' : ''}>
                            <i class="bi bi-cart-plus me-1"></i>加入购物车
                        </button>
                        <button class="btn btn-outline-primary btn-lg" onclick="buyNow(${product.id})" ${product.stock <= 0 ? 'disabled' : ''}>
                            <i class="bi bi-bag me-1"></i>立即购买
                        </button>
                    </div>

                    <!-- 服务保障 -->
                    <div class="detail-service-tags">
                        <span><i class="bi bi-shield-check text-success"></i> 正品保障</span>
                        <span><i class="bi bi-arrow-repeat text-primary"></i> 7天退换</span>
                        <span><i class="bi bi-truck text-warning"></i> 免费配送</span>
                        <span><i class="bi bi-headset text-info"></i> 售后无忧</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Tab: 商品详情 / 规格参数 / 购买须知 -->
    <div class="card border-0 shadow-sm mt-4 detail-tab-card">
        <div class="card-body p-0">
            <ul class="nav nav-tabs detail-tabs" role="tablist">
                <li class="nav-item">
                    <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tabDesc">
                        <i class="bi bi-file-text me-1"></i>商品详情
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tabSpecs">
                        <i class="bi bi-list-check me-1"></i>规格参数
                    </button>
                </li>
                <li class="nav-item">
                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tabNotice">
                        <i class="bi bi-info-circle me-1"></i>购买须知
                    </button>
                </li>
            </ul>
            <div class="tab-content p-4">
                <div class="tab-pane fade show active" id="tabDesc">
                    <div class="detail-desc-content">
                        <h5 class="mb-3">${product.name}</h5>
                        <p>${product.description}</p>
                        <div class="text-center py-3">
                            <img src="${pageContext.request.contextPath}${product.image}" class="detail-desc-img"
                                 alt="${product.name}" onerror="handleImgError(this)">
                        </div>
                    </div>
                </div>
                <div class="tab-pane fade" id="tabSpecs">
                    <table class="table table-bordered detail-spec-table">
                        <tbody>
                            <tr><th>商品名称</th><td>${product.name}</td></tr>
                            <tr><th>商品分类</th><td>${product.categoryName}</td></tr>
                            <tr><th>商品价格</th><td>¥${product.price}</td></tr>
                            <tr><th>累计销量</th><td>${product.sales} 件</td></tr>
                            <tr><th>当前库存</th><td>${product.stock} 件</td></tr>
                            <tr><th>上架时间</th><td>${product.createdAt}</td></tr>
                        </tbody>
                    </table>
                </div>
                <div class="tab-pane fade" id="tabNotice">
                    <div class="detail-notice">
                        <div class="notice-item">
                            <h6><i class="bi bi-truck me-2 text-primary"></i>配送说明</h6>
                            <p>全国大部分地区支持配送，下单后预计1-3天发货，3-5天送达。偏远地区可能需要5-7天。</p>
                        </div>
                        <div class="notice-item">
                            <h6><i class="bi bi-arrow-repeat me-2 text-success"></i>退换货政策</h6>
                            <p>商品签收后7天内支持无理由退换货，商品需保持原包装完整。详情请查看
                                <a href="${pageContext.request.contextPath}/page/return-policy" class="text-primary">退换货政策</a>。</p>
                        </div>
                        <div class="notice-item">
                            <h6><i class="bi bi-credit-card me-2 text-warning"></i>支付方式</h6>
                            <p>支持在线支付，加入购物车后在结算页面选择支付方式完成付款。</p>
                        </div>
                        <div class="notice-item">
                            <h6><i class="bi bi-shield-check me-2 text-danger"></i>正品保障</h6>
                            <p>优品商城所售商品均为正品，支持品牌授权验证，假一赔十。</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 推荐商品 -->
    <c:if test="${not empty recommended}">
        <div class="mt-4">
            <h5 class="section-title mb-3">同类推荐</h5>
            <div class="row g-3">
                <c:forEach var="p" items="${recommended}">
                    <div class="col-6 col-md-3">
                        <div class="card product-card">
                            <div class="card-img-wrapper">
                                <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}">
                                    <img src="${pageContext.request.contextPath}${p.image}" class="card-img-top"
                                         alt="${p.name}" onerror="handleImgError(this)">
                                </a>
                            </div>
                            <div class="card-body">
                                <div class="product-name">
                                    <a href="${pageContext.request.contextPath}/product/detail?id=${p.id}">${p.name}</a>
                                </div>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="product-price"><small>¥</small>${p.price}</span>
                                    <span class="product-sales">已售${p.sales}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:if>
</div>

<jsp:include page="/common/footer.jsp"/>
<script>
function changeQty(delta) {
    var input = document.getElementById('buyQuantity');
    var val = parseInt(input.value) + delta;
    var max = parseInt(input.max);
    if (val < 1) val = 1;
    if (val > max) val = max;
    input.value = val;
}

function buyNow(productId) {
    var qty = document.getElementById('buyQuantity').value;
    ajaxPost(contextPath + '/cart/add', {productId: productId, quantity: qty}, function(resp) {
        if (resp.success) {
            window.location.href = contextPath + '/order/checkout';
        } else {
            if (resp.message === '请先登录') {
                window.location.href = contextPath + '/user/login';
            } else {
                showToast(resp.message, 'error');
            }
        }
    });
}
</script>

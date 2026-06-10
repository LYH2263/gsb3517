<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="全部商品"/></jsp:include>

<div class="container py-4">
    <!-- 筛选工具栏 -->
    <div class="filter-toolbar card mb-4">
        <div class="card-body">
            <!-- 分类筛选 -->
            <div class="filter-row">
                <span class="filter-label">商品分类</span>
                <div class="filter-options category-tags">
                    <a href="javascript:void(0)" onclick="applyFilter('categoryId', '')"
                       class="filter-tag ${empty currentCategoryId ? 'active' : ''}">全部</a>
                    <c:forEach var="cat" items="${categories}">
                        <a href="javascript:void(0)" onclick="applyFilter('categoryId', '${cat.id}')"
                           class="filter-tag ${currentCategoryId == cat.id ? 'active' : ''}">${cat.name}</a>
                    </c:forEach>
                </div>
            </div>

            <!-- 价格区间 -->
            <div class="filter-row">
                <span class="filter-label">价格区间</span>
                <div class="filter-options">
                    <div class="price-range-group">
                        <a href="javascript:void(0)" onclick="applyPriceRange('', '')"
                           class="filter-tag ${empty currentMinPrice && empty currentMaxPrice ? 'active' : ''}">全部</a>
                        <a href="javascript:void(0)" onclick="applyPriceRange('', '100')"
                           class="filter-tag ${empty currentMinPrice && currentMaxPrice == 100 ? 'active' : ''}">¥100以下</a>
                        <a href="javascript:void(0)" onclick="applyPriceRange('100', '500')"
                           class="filter-tag ${currentMinPrice == 100 && currentMaxPrice == 500 ? 'active' : ''}">¥100-500</a>
                        <a href="javascript:void(0)" onclick="applyPriceRange('500', '2000')"
                           class="filter-tag ${currentMinPrice == 500 && currentMaxPrice == 2000 ? 'active' : ''}">¥500-2000</a>
                        <a href="javascript:void(0)" onclick="applyPriceRange('2000', '5000')"
                           class="filter-tag ${currentMinPrice == 2000 && currentMaxPrice == 5000 ? 'active' : ''}">¥2000-5000</a>
                        <a href="javascript:void(0)" onclick="applyPriceRange('5000', '')"
                           class="filter-tag ${currentMinPrice == 5000 && empty currentMaxPrice ? 'active' : ''}">¥5000以上</a>
                        <div class="price-custom-input">
                            <input type="number" id="customMinPrice" class="form-control form-control-sm"
                                   placeholder="最低价" value="${currentMinPrice}">
                            <span class="price-separator">-</span>
                            <input type="number" id="customMaxPrice" class="form-control form-control-sm"
                                   placeholder="最高价" value="${currentMaxPrice}">
                            <button type="button" class="btn btn-outline-primary btn-sm" onclick="applyCustomPrice()">确定</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 排序方式 -->
            <div class="filter-row">
                <span class="filter-label">排序方式</span>
                <div class="filter-options">
                    <a href="javascript:void(0)" onclick="applyFilter('sort', '')"
                       class="filter-tag ${empty currentSort || currentSort == 'default' ? 'active' : ''}">
                        <i class="bi bi-stars me-1"></i>默认
                    </a>
                    <a href="javascript:void(0)" onclick="applyFilter('sort', 'sales_desc')"
                       class="filter-tag ${currentSort == 'sales_desc' ? 'active' : ''}">
                        <i class="bi bi-fire me-1"></i>销量优先
                    </a>
                    <a href="javascript:void(0)" onclick="applyFilter('sort', 'price_asc')"
                       class="filter-tag ${currentSort == 'price_asc' ? 'active' : ''}">
                        <i class="bi bi-sort-numeric-up me-1"></i>价格低到高
                    </a>
                    <a href="javascript:void(0)" onclick="applyFilter('sort', 'price_desc')"
                       class="filter-tag ${currentSort == 'price_desc' ? 'active' : ''}">
                        <i class="bi bi-sort-numeric-down-alt me-1"></i>价格高到低
                    </a>
                    <a href="javascript:void(0)" onclick="applyFilter('sort', 'newest')"
                       class="filter-tag ${currentSort == 'newest' ? 'active' : ''}">
                        <i class="bi bi-clock me-1"></i>最新上架
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- 搜索结果 / 筛选状态栏 -->
    <div class="result-bar mb-3 d-flex justify-content-between align-items-center">
        <div class="result-info">
            <c:choose>
                <c:when test="${not empty keyword}">
                    <span>搜索 "<strong class="text-primary">${keyword}</strong>" 共找到
                        <strong class="text-primary">${total}</strong> 个结果</span>
                    <a href="${pageContext.request.contextPath}/product/list" class="btn btn-outline-secondary btn-sm ms-2">
                        <i class="bi bi-x-lg me-1"></i>清除搜索
                    </a>
                </c:when>
                <c:otherwise>
                    <span class="text-muted">共 <strong class="text-dark">${total}</strong> 件商品</span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- 商品列表 -->
    <c:choose>
        <c:when test="${not empty products}">
            <div class="row g-3">
                <c:forEach var="product" items="${products}">
                    <div class="col-6 col-md-4 col-lg-3">
                        <div class="card product-card">
                            <div class="card-img-wrapper">
                                <a href="${pageContext.request.contextPath}/product/detail?id=${product.id}">
                                    <img src="${pageContext.request.contextPath}${product.image}" class="card-img-top"
                                         alt="${product.name}" onerror="handleImgError(this)">
                                </a>
                            </div>
                            <div class="card-body">
                                <div class="product-name">
                                    <a href="${pageContext.request.contextPath}/product/detail?id=${product.id}">${product.name}</a>
                                </div>
                                <div class="small text-muted mb-2">${product.categoryName}</div>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="product-price"><small>¥</small>${product.price}</span>
                                    <span class="product-sales">已售${product.sales}</span>
                                </div>
                                <button class="btn btn-primary btn-sm w-100 mt-2" onclick="addToCart(${product.id})">
                                    <i class="bi bi-cart-plus me-1"></i>加入购物车
                                </button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- 分页 -->
            <c:if test="${totalPages > 1}">
                <nav class="mt-4">
                    <ul class="pagination justify-content-center">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage - 1})">
                                <i class="bi bi-chevron-left"></i>
                            </a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="javascript:void(0)" onclick="goToPage(${i})">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage + 1})">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <i class="bi bi-inbox d-block"></i>
                <h5>暂无商品</h5>
                <p>没有找到符合条件的商品，请调整筛选条件</p>
                <a href="${pageContext.request.contextPath}/product/list" class="btn btn-primary">
                    <i class="bi bi-arrow-counterclockwise me-1"></i>重置筛选
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
// 当前筛选状态
var filterState = {
    categoryId: '${currentCategoryId}',
    keyword: '${keyword}',
    sort: '${currentSort}',
    minPrice: '${currentMinPrice}',
    maxPrice: '${currentMaxPrice}'
};

function buildUrl(params) {
    var base = '${pageContext.request.contextPath}/product/list';
    var parts = [];
    for (var key in params) {
        if (params[key] !== '' && params[key] !== null && params[key] !== undefined) {
            parts.push(encodeURIComponent(key) + '=' + encodeURIComponent(params[key]));
        }
    }
    return base + (parts.length > 0 ? '?' + parts.join('&') : '');
}

function applyFilter(name, value) {
    filterState[name] = value;
    filterState.page = '';
    window.location.href = buildUrl(filterState);
}

function applyPriceRange(min, max) {
    filterState.minPrice = min;
    filterState.maxPrice = max;
    filterState.page = '';
    window.location.href = buildUrl(filterState);
}

function applyCustomPrice() {
    var min = document.getElementById('customMinPrice').value;
    var max = document.getElementById('customMaxPrice').value;
    applyPriceRange(min, max);
}

function goToPage(page) {
    filterState.page = page;
    window.location.href = buildUrl(filterState);
}
</script>

<jsp:include page="/common/footer.jsp"/>

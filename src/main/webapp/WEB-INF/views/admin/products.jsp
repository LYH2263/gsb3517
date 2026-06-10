<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/admin/header.jsp"><jsp:param name="title" value="商品管理"/><jsp:param name="menu" value="products"/></jsp:include>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h4>商品管理</h4>
    <a href="${pageContext.request.contextPath}/admin/product/edit" class="btn btn-primary">
        <i class="bi bi-plus-circle me-1"></i>添加商品
    </a>
</div>

<!-- 筛选栏 -->
<div class="card border-0 shadow-sm mb-3" style="border-radius:12px">
    <div class="card-body py-3">
        <form class="admin-filter-form" method="get" action="${pageContext.request.contextPath}/admin/products">
            <div class="d-flex flex-wrap gap-2 align-items-end">
                <div style="min-width:180px;flex:1">
                    <label class="form-label mb-1 small text-muted">搜索关键字</label>
                    <input type="text" class="form-control form-control-sm" name="keyword" value="${keyword}" placeholder="商品名称/描述">
                </div>
                <div style="min-width:140px">
                    <label class="form-label mb-1 small text-muted">商品分类</label>
                    <select class="form-select form-select-sm" name="categoryId">
                        <option value="">全部分类</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}" ${filterCategoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div style="min-width:120px">
                    <label class="form-label mb-1 small text-muted">状态</label>
                    <select class="form-select form-select-sm" name="status">
                        <option value="">全部状态</option>
                        <option value="1" ${filterStatus != null && filterStatus == 1 ? 'selected' : ''}>上架</option>
                        <option value="0" ${filterStatus != null && filterStatus == 0 ? 'selected' : ''}>下架</option>
                    </select>
                </div>
                <div class="d-flex gap-1">
                    <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-search me-1"></i>搜索</button>
                    <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-counterclockwise me-1"></i>重置</a>
                </div>
            </div>
        </form>
    </div>
</div>

<div class="card border-0 shadow-sm" style="border-radius:12px">
    <div class="table-responsive">
        <table class="table mb-0 align-middle">
            <thead class="table-light">
                <tr>
                    <th>ID</th>
                    <th>图片</th>
                    <th>商品名称</th>
                    <th>分类</th>
                    <th>价格</th>
                    <th>库存</th>
                    <th>销量</th>
                    <th>状态</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="p" items="${products}">
                    <tr>
                        <td>${p.id}</td>
                        <td>
                            <img src="${pageContext.request.contextPath}${p.image}" style="width:50px;height:50px;object-fit:cover;border-radius:6px"
                                 onerror="handleImgError(this)">
                        </td>
                        <td>${p.name}</td>
                        <td>${p.categoryName}</td>
                        <td class="text-danger">¥${p.price}</td>
                        <td>${p.stock}</td>
                        <td>${p.sales}</td>
                        <td>
                            <span class="badge ${p.status == 1 ? 'bg-success' : 'bg-secondary'}">
                                ${p.status == 1 ? '上架' : '下架'}
                            </span>
                        </td>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/product/edit?id=${p.id}" class="btn btn-sm btn-outline-primary me-1">
                                <i class="bi bi-pencil"></i>
                            </a>
                            <button class="btn btn-sm btn-outline-danger" onclick="deleteProduct(${p.id})">
                                <i class="bi bi-trash"></i>
                            </button>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty products}">
                    <tr><td colspan="9" class="text-center text-muted py-4">暂无匹配的商品</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<!-- 分页 -->
<c:if test="${totalPages > 1}">
    <nav class="mt-3">
        <ul class="pagination justify-content-center">
            <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${currentPage == i ? 'active' : ''}">
                    <a class="page-link" href="${pageContext.request.contextPath}/admin/products?page=${i}&keyword=${keyword}&categoryId=${filterCategoryId}&status=${filterStatus}">${i}</a>
                </li>
            </c:forEach>
        </ul>
    </nav>
</c:if>

<jsp:include page="/WEB-INF/views/admin/footer.jsp"/>
<script>
function deleteProduct(id) {
    showConfirm('确定要删除该商品吗？', function() {
        ajaxPost(contextPath + '/admin/product/delete', {id: id}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    });
}
</script>

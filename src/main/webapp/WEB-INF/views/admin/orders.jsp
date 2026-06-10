<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/admin/header.jsp"><jsp:param name="title" value="订单管理"/><jsp:param name="menu" value="orders"/></jsp:include>

<h4 class="mb-3">订单管理</h4>

<!-- 筛选栏 -->
<div class="card border-0 shadow-sm mb-3" style="border-radius:12px">
    <div class="card-body py-3">
        <form class="admin-filter-form" method="get" action="${pageContext.request.contextPath}/admin/orders">
            <div class="d-flex flex-wrap gap-2 align-items-end">
                <div style="min-width:180px;flex:1">
                    <label class="form-label mb-1 small text-muted">搜索</label>
                    <input type="text" class="form-control form-control-sm" name="keyword" value="${keyword}" placeholder="订单号/用户名">
                </div>
                <div style="min-width:140px">
                    <label class="form-label mb-1 small text-muted">订单状态</label>
                    <select class="form-select form-select-sm" name="status">
                        <option value="">全部状态</option>
                        <option value="PENDING" ${filterStatus == 'PENDING' ? 'selected' : ''}>待付款</option>
                        <option value="PAID" ${filterStatus == 'PAID' ? 'selected' : ''}>待发货</option>
                        <option value="SHIPPED" ${filterStatus == 'SHIPPED' ? 'selected' : ''}>已发货</option>
                        <option value="COMPLETED" ${filterStatus == 'COMPLETED' ? 'selected' : ''}>已完成</option>
                        <option value="CANCELLED" ${filterStatus == 'CANCELLED' ? 'selected' : ''}>已取消</option>
                    </select>
                </div>
                <div class="d-flex gap-1">
                    <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-search me-1"></i>搜索</button>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-counterclockwise me-1"></i>重置</a>
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
                    <th>订单号</th>
                    <th>用户</th>
                    <th>金额</th>
                    <th>状态</th>
                    <th>下单时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="order" items="${orders}">
                    <tr>
                        <td><small>${order.orderNo}</small></td>
                        <td>${order.username}</td>
                        <td class="text-danger fw-bold">¥${order.totalAmount}</td>
                        <td><span class="status-badge status-${order.status}">${order.statusText}</span></td>
                        <td>
                            <small>
                                <fmt:parseDate value="${order.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both"/>
                                <fmt:formatDate value="${parsedDate}" pattern="yyyy-MM-dd HH:mm"/>
                            </small>
                        </td>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/order/detail?id=${order.id}" class="btn btn-sm btn-outline-primary me-1">
                                <i class="bi bi-eye"></i>
                            </a>
                            <c:if test="${order.status == 'PAID'}">
                                <button class="btn btn-sm btn-success" onclick="shipOrder(${order.id})">
                                    <i class="bi bi-truck me-1"></i>发货
                                </button>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty orders}">
                    <tr><td colspan="6" class="text-center text-muted py-4">暂无匹配的订单</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<c:if test="${totalPages > 1}">
    <nav class="mt-3">
        <ul class="pagination justify-content-center">
            <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${currentPage == i ? 'active' : ''}">
                    <a class="page-link" href="${pageContext.request.contextPath}/admin/orders?page=${i}&status=${filterStatus}&keyword=${keyword}">${i}</a>
                </li>
            </c:forEach>
        </ul>
    </nav>
</c:if>

<jsp:include page="/WEB-INF/views/admin/footer.jsp"/>
<script>
function shipOrder(id) {
    showConfirm('确认发货吗？', function() {
        ajaxPost(contextPath + '/admin/order/ship', {id: id}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    });
}
</script>

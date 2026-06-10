<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="我的订单"/></jsp:include>

<div class="container py-4">
    <h4 class="mb-4"><i class="bi bi-bag me-2"></i>我的订单</h4>

    <c:choose>
        <c:when test="${not empty orders}">
            <c:forEach var="order" items="${orders}">
                <div class="card border-0 shadow-sm mb-3" style="border-radius:12px">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <span class="text-muted small">订单号：${order.orderNo}</span>
                            <span class="text-muted small ms-3">
                                <fmt:parseDate value="${order.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both"/>
                                <fmt:formatDate value="${parsedDate}" pattern="yyyy-MM-dd HH:mm"/>
                            </span>
                        </div>
                        <span class="status-badge status-${order.status}">${order.statusText}</span>
                    </div>
                    <div class="card-body">
                        <c:forEach var="item" items="${order.items}">
                            <div class="d-flex align-items-center mb-2">
                                <img src="${pageContext.request.contextPath}${item.productImage}"
                                     class="cart-item-img me-3" alt="${item.productName}"
                                     onerror="handleImgError(this)" style="width:60px;height:60px">
                                <div class="flex-grow-1">
                                    <div>${item.productName}</div>
                                    <small class="text-muted">¥${item.productPrice} x ${item.quantity}</small>
                                </div>
                                <div class="text-end">
                                    <span class="text-danger">¥${item.subtotal}</span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    <div class="card-footer bg-white d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <span class="text-muted">合计：</span>
                            <strong class="text-danger fs-5">¥${order.totalAmount}</strong>
                        </div>
                        <div class="d-flex gap-2">
                            <a href="${pageContext.request.contextPath}/order/detail?id=${order.id}" class="btn btn-sm btn-outline-secondary">
                                查看详情
                            </a>
                            <c:if test="${order.status == 'PENDING'}">
                                <button class="btn btn-sm btn-primary" onclick="payOrder(${order.id})">去付款</button>
                                <button class="btn btn-sm btn-outline-danger" onclick="cancelOrder(${order.id})">取消订单</button>
                            </c:if>
                            <c:if test="${order.status == 'SHIPPED'}">
                                <button class="btn btn-sm btn-success" onclick="confirmReceive(${order.id})">确认收货</button>
                            </c:if>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <!-- 分页 -->
            <c:if test="${totalPages > 1}">
                <nav class="mt-4">
                    <ul class="pagination justify-content-center">
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/order/list?page=${currentPage-1}">
                                <i class="bi bi-chevron-left"></i>
                            </a>
                        </li>
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                <a class="page-link" href="${pageContext.request.contextPath}/order/list?page=${i}">${i}</a>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/order/list?page=${currentPage+1}">
                                <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <i class="bi bi-bag-x d-block"></i>
                <h5>暂无订单</h5>
                <p>您还没有任何订单，快去购物吧～</p>
                <a href="${pageContext.request.contextPath}/product/list" class="btn btn-primary mt-2">去购物</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/common/footer.jsp"/>
<script>
function payOrder(id) {
    showConfirm('确认付款吗？', function() {
        ajaxPost(contextPath + '/order/pay', {id: id}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    }, '确认付款');
}

function cancelOrder(id) {
    showConfirm('确定要取消该订单吗？取消后不可恢复。', function() {
        ajaxPost(contextPath + '/order/cancel', {id: id}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    }, '取消订单');
}

function confirmReceive(id) {
    showConfirm('确认已收到商品吗？', function() {
        ajaxPost(contextPath + '/order/confirm', {id: id}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    }, '确认收货');
}
</script>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/admin/header.jsp"><jsp:param name="title" value="订单详情"/><jsp:param name="menu" value="orders"/></jsp:include>

<div class="d-flex align-items-center mb-3">
    <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline-secondary me-3">
        <i class="bi bi-arrow-left"></i>
    </a>
    <h4 class="mb-0">订单详情</h4>
</div>

<c:if test="${not empty order}">
    <div class="row">
        <div class="col-md-8">
            <div class="card border-0 shadow-sm mb-3" style="border-radius:12px">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">订单信息</h5>
                    <span class="status-badge status-${order.status}">${order.statusText}</span>
                </div>
                <div class="card-body">
                    <div class="row mb-2"><div class="col-3 text-muted">订单号</div><div class="col-9">${order.orderNo}</div></div>
                    <div class="row mb-2"><div class="col-3 text-muted">用户</div><div class="col-9">${order.username}</div></div>
                    <div class="row mb-2"><div class="col-3 text-muted">收货人</div><div class="col-9">${order.receiver}</div></div>
                    <div class="row mb-2"><div class="col-3 text-muted">电话</div><div class="col-9">${order.phone}</div></div>
                    <div class="row mb-2"><div class="col-3 text-muted">地址</div><div class="col-9">${order.address}</div></div>
                    <div class="row mb-2">
                        <div class="col-3 text-muted">下单时间</div>
                        <div class="col-9">
                            <fmt:parseDate value="${order.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both"/>
                            <fmt:formatDate value="${parsedDate}" pattern="yyyy-MM-dd HH:mm:ss"/>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card border-0 shadow-sm" style="border-radius:12px">
                <div class="card-header bg-white"><h5 class="mb-0">商品明细</h5></div>
                <div class="card-body p-0">
                    <table class="table mb-0 align-middle">
                        <thead class="table-light"><tr><th>商品</th><th>单价</th><th>数量</th><th>小计</th></tr></thead>
                        <tbody>
                            <c:forEach var="item" items="${order.items}">
                                <tr>
                                    <td>${item.productName}</td>
                                    <td>¥${item.productPrice}</td>
                                    <td>x${item.quantity}</td>
                                    <td class="text-danger">¥${item.subtotal}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm" style="border-radius:12px">
                <div class="card-body">
                    <div class="text-center mb-3">
                        <div class="text-muted">订单总额</div>
                        <div class="fs-3 fw-bold text-danger">¥${order.totalAmount}</div>
                    </div>
                    <hr>
                    <h6>修改状态</h6>
                    <div class="d-flex flex-wrap gap-2 mt-2">
                        <c:if test="${order.status == 'PAID'}">
                            <button class="btn btn-success btn-sm" onclick="updateStatus(${order.id}, 'SHIPPED')">
                                <i class="bi bi-truck me-1"></i>发货
                            </button>
                        </c:if>
                        <c:if test="${order.status == 'PENDING'}">
                            <button class="btn btn-danger btn-sm" onclick="updateStatus(${order.id}, 'CANCELLED')">取消订单</button>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>
</c:if>

<jsp:include page="/WEB-INF/views/admin/footer.jsp"/>
<script>
function updateStatus(id, status) {
    var text = {SHIPPED:'确认发货？', CANCELLED:'确认取消？'};
    showConfirm(text[status] || '确认操作？', function() {
        ajaxPost(contextPath + '/admin/order/updateStatus', {id:id, status:status}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    });
}
</script>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="订单详情"/></jsp:include>

<div class="container py-4">
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/">首页</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/order/list">我的订单</a></li>
            <li class="breadcrumb-item active">订单详情</li>
        </ol>
    </nav>

    <c:if test="${not empty order}">
        <div class="row">
            <div class="col-md-8">
                <!-- 订单信息 -->
                <div class="card border-0 shadow-sm mb-3" style="border-radius:12px">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">订单信息</h5>
                        <span class="status-badge status-${order.status}">${order.statusText}</span>
                    </div>
                    <div class="card-body">
                        <div class="row mb-2">
                            <div class="col-sm-3 text-muted">订单号</div>
                            <div class="col-sm-9">${order.orderNo}</div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-sm-3 text-muted">下单时间</div>
                            <div class="col-sm-9">
                                <fmt:parseDate value="${order.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both"/>
                                <fmt:formatDate value="${parsedDate}" pattern="yyyy-MM-dd HH:mm:ss"/>
                            </div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-sm-3 text-muted">收货人</div>
                            <div class="col-sm-9">${order.receiver}</div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-sm-3 text-muted">联系电话</div>
                            <div class="col-sm-9">${order.phone}</div>
                        </div>
                        <div class="row mb-2">
                            <div class="col-sm-3 text-muted">收货地址</div>
                            <div class="col-sm-9">${order.address}</div>
                        </div>
                        <c:if test="${not empty order.remark}">
                            <div class="row mb-2">
                                <div class="col-sm-3 text-muted">备注</div>
                                <div class="col-sm-9">${order.remark}</div>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- 商品明细 -->
                <div class="card border-0 shadow-sm" style="border-radius:12px">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">商品明细</h5>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table mb-0 align-middle">
                                <thead class="table-light">
                                    <tr><th>商品</th><th>单价</th><th>数量</th><th>小计</th></tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${order.items}">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <img src="${pageContext.request.contextPath}${item.productImage}"
                                                         style="width:50px;height:50px;object-fit:cover;border-radius:6px" class="me-2"
                                                         onerror="handleImgError(this)">
                                                    ${item.productName}
                                                </div>
                                            </td>
                                            <td>¥${item.productPrice}</td>
                                            <td>x${item.quantity}</td>
                                            <td class="text-danger fw-bold">¥${item.subtotal}</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card border-0 shadow-sm" style="border-radius:12px;position:sticky;top:80px">
                    <div class="card-body text-center">
                        <div class="text-muted mb-2">订单总额</div>
                        <div class="fs-3 fw-bold text-danger mb-3">¥${order.totalAmount}</div>
                        <c:if test="${order.status == 'PENDING'}">
                            <button class="btn btn-primary w-100 mb-2" onclick="payOrder(${order.id})">去付款</button>
                            <button class="btn btn-outline-danger w-100" onclick="cancelOrder(${order.id})">取消订单</button>
                        </c:if>
                        <c:if test="${order.status == 'SHIPPED'}">
                            <button class="btn btn-success w-100" onclick="confirmReceive(${order.id})">确认收货</button>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </c:if>
</div>

<jsp:include page="/common/footer.jsp"/>
<script>
function payOrder(id) {
    showConfirm('确认付款吗？', function() {
        ajaxPost(contextPath + '/order/pay', {id: id}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    });
}
function cancelOrder(id) {
    showConfirm('确定要取消该订单吗？', function() {
        ajaxPost(contextPath + '/order/cancel', {id: id}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    });
}
function confirmReceive(id) {
    showConfirm('确认已收到商品吗？', function() {
        ajaxPost(contextPath + '/order/confirm', {id: id}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    });
}
</script>

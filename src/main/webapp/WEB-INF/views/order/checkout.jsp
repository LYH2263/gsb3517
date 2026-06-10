<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="确认订单"/></jsp:include>

<div class="container py-4">
    <h4 class="mb-4"><i class="bi bi-receipt me-2"></i>确认订单</h4>

    <div class="row">
        <div class="col-md-8">
            <!-- 收货信息 -->
            <div class="card border-0 shadow-sm mb-3" style="border-radius:12px">
                <div class="card-header bg-white border-0 pt-3">
                    <h5><i class="bi bi-geo-alt me-2"></i>收货信息</h5>
                </div>
                <div class="card-body">
                    <form id="orderForm">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">收货人 <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" name="receiver" value="${user.username}">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">联系电话 <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" name="phone" value="${user.phone}">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">收货地址 <span class="text-danger">*</span></label>
                            <textarea class="form-control" name="address" rows="2">${user.address}</textarea>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">备注</label>
                            <textarea class="form-control" name="remark" rows="2" placeholder="选填，如有特殊要求请备注"></textarea>
                        </div>
                    </form>
                </div>
            </div>

            <!-- 商品清单 -->
            <div class="card border-0 shadow-sm" style="border-radius:12px">
                <div class="card-header bg-white border-0 pt-3">
                    <h5><i class="bi bi-bag me-2"></i>商品清单</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table mb-0 align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>商品</th>
                                    <th>单价</th>
                                    <th>数量</th>
                                    <th>小计</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${cartItems}">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <img src="${pageContext.request.contextPath}${item.productImage}"
                                                     class="cart-item-img me-3" alt="${item.productName}"
                                                     onerror="handleImgError(this)">
                                                <span>${item.productName}</span>
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

        <!-- 订单摘要 -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm" style="border-radius:12px;position:sticky;top:80px">
                <div class="card-body">
                    <h5 class="mb-3">订单摘要</h5>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">商品件数</span>
                        <span>${cartItems.size()}</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">商品总价</span>
                        <span>¥${totalAmount}</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">运费</span>
                        <span class="text-success">免运费</span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between mb-3">
                        <strong>应付总额</strong>
                        <strong class="fs-4 text-danger">¥${totalAmount}</strong>
                    </div>
                    <button class="btn btn-primary w-100 btn-lg" onclick="submitOrder()">
                        <i class="bi bi-check-circle me-1"></i>提交订单
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp"/>
<script>
function submitOrder() {
    var valid = validateForm('orderForm', {
        receiver: { required: true, requiredMsg: '请填写收货人' },
        phone: { required: true, requiredMsg: '请填写联系电话', pattern: /^1[3-9]\d{9}$/, patternMsg: '手机号格式不正确' },
        address: { required: true, requiredMsg: '请填写收货地址' }
    });
    if (!valid) return;

    showConfirm('确认提交订单吗？', function() {
        ajaxPost(contextPath + '/order/create', $('#orderForm').serialize(), function(resp) {
            if (resp.success) {
                showToast(resp.message, 'success');
                setTimeout(function() {
                    window.location.href = contextPath + '/order/list';
                }, 1000);
            } else {
                showToast(resp.message, 'error');
                if (resp.field) highlightField(resp.field);
            }
        });
    });
}
</script>

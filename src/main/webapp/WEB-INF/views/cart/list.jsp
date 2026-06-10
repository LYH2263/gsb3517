<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="购物车"/></jsp:include>

<div class="container py-4">
    <h4 class="mb-4"><i class="bi bi-cart3 me-2"></i>我的购物车</h4>

    <c:choose>
        <c:when test="${not empty cartItems}">
            <!-- 桌面端表格视图 -->
            <div class="card border-0 shadow-sm cart-desktop" style="border-radius:12px">
                <div class="table-responsive">
                    <table class="table cart-table mb-0 align-middle">
                        <thead>
                            <tr>
                                <th style="width:40px">
                                    <input type="checkbox" class="form-check-input" id="checkAll" checked>
                                </th>
                                <th>商品</th>
                                <th style="width:120px">单价</th>
                                <th style="width:150px">数量</th>
                                <th style="width:120px">小计</th>
                                <th style="width:80px">操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${cartItems}">
                                <tr data-id="${item.id}" data-price="${item.productPrice}" data-stock="${item.productStock}">
                                    <td>
                                        <input type="checkbox" class="form-check-input item-check" checked>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <img src="${pageContext.request.contextPath}${item.productImage}"
                                                 class="cart-item-img me-3" alt="${item.productName}"
                                                 onerror="handleImgError(this)">
                                            <a href="${pageContext.request.contextPath}/product/detail?id=${item.productId}"
                                               class="text-decoration-none text-dark">${item.productName}</a>
                                        </div>
                                    </td>
                                    <td class="text-danger fw-bold">¥${item.productPrice}</td>
                                    <td>
                                        <div class="quantity-control">
                                            <button onclick="updateQty(${item.id}, -1)">-</button>
                                            <input type="number" value="${item.quantity}" min="1" max="${item.productStock}"
                                                   onchange="setQty(${item.id}, this.value)" class="qty-input">
                                            <button onclick="updateQty(${item.id}, 1)">+</button>
                                        </div>
                                    </td>
                                    <td class="text-danger fw-bold item-subtotal">¥${item.subtotal}</td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-danger" onclick="removeItem(${item.id})">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- 移动端卡片视图 -->
            <div class="cart-mobile">
                <div class="cart-mobile-header">
                    <label class="d-flex align-items-center gap-2">
                        <input type="checkbox" class="form-check-input" id="checkAllMobile" checked>
                        <span>全选</span>
                    </label>
                </div>
                <c:forEach var="item" items="${cartItems}">
                    <div class="cart-mobile-card" data-id="${item.id}" data-price="${item.productPrice}" data-stock="${item.productStock}">
                        <div class="d-flex gap-3">
                            <div class="d-flex align-items-start pt-1">
                                <input type="checkbox" class="form-check-input item-check" checked>
                            </div>
                            <a href="${pageContext.request.contextPath}/product/detail?id=${item.productId}">
                                <img src="${pageContext.request.contextPath}${item.productImage}"
                                     class="cart-mobile-img" alt="${item.productName}"
                                     onerror="handleImgError(this)">
                            </a>
                            <div class="flex-fill min-width-0">
                                <a href="${pageContext.request.contextPath}/product/detail?id=${item.productId}"
                                   class="text-decoration-none text-dark d-block mb-1 cart-mobile-name">${item.productName}</a>
                                <div class="text-danger fw-bold mb-2">¥${item.productPrice}</div>
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="quantity-control quantity-control-sm">
                                        <button onclick="updateQty(${item.id}, -1)">-</button>
                                        <input type="number" value="${item.quantity}" min="1" max="${item.productStock}"
                                               onchange="setQty(${item.id}, this.value)" class="qty-input">
                                        <button onclick="updateQty(${item.id}, 1)">+</button>
                                    </div>
                                    <button class="btn btn-sm text-danger border-0 p-0" onclick="removeItem(${item.id})">
                                        <i class="bi bi-trash"></i> 删除
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- 结算栏 -->
            <div class="card border-0 shadow-sm mt-3 p-3" style="border-radius:12px">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <span class="text-muted">已选 <strong id="selectedCount">0</strong> 件商品</span>
                        <button class="btn btn-sm btn-outline-secondary ms-3" onclick="clearCart()">清空购物车</button>
                    </div>
                    <div class="d-flex align-items-center gap-3">
                        <div>
                            <span class="text-muted">合计：</span>
                            <span class="fs-4 fw-bold text-danger" id="totalPrice">¥0.00</span>
                        </div>
                        <a href="${pageContext.request.contextPath}/order/checkout" class="btn btn-primary btn-lg" id="checkoutBtn">
                            去结算
                        </a>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <i class="bi bi-cart-x d-block"></i>
                <h5>购物车空空如也</h5>
                <p>快去挑选心仪的商品吧～</p>
                <a href="${pageContext.request.contextPath}/product/list" class="btn btn-primary mt-2">去购物</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/common/footer.jsp"/>
<script>
// 全选/取消全选 (desktop)
$('#checkAll').on('change', function() {
    $('.cart-desktop .item-check').prop('checked', this.checked);
    calcTotal();
});
// 全选/取消全选 (mobile)
$('#checkAllMobile').on('change', function() {
    $('.cart-mobile .item-check').prop('checked', this.checked);
    calcTotal();
});

// 单个checkbox变化时同步全选状态
$(document).on('change', '.item-check', function() {
    // 同步desktop和mobile中相同data-id的checkbox
    var $container = $(this).closest('[data-id]');
    var id = $container.data('id');
    var checked = this.checked;
    $('[data-id="' + id + '"] .item-check').prop('checked', checked);

    // 更新全选状态
    var desktopTotal = $('.cart-desktop .item-check').length;
    var desktopChecked = $('.cart-desktop .item-check:checked').length;
    $('#checkAll').prop('checked', desktopTotal === desktopChecked);
    var mobileTotal = $('.cart-mobile .item-check').length;
    var mobileChecked = $('.cart-mobile .item-check:checked').length;
    $('#checkAllMobile').prop('checked', mobileTotal === mobileChecked);
    calcTotal();
});

function calcTotal() {
    var total = 0;
    var count = 0;
    // 只从desktop表格行计算(数据一致)
    $('tr[data-id]').each(function() {
        var $row = $(this);
        if ($row.find('.item-check').is(':checked')) {
            var price = parseFloat($row.data('price'));
            var qty = parseInt($row.find('.qty-input').val());
            total += price * qty;
            count += qty;
        }
    });
    // 如果desktop不可见,从mobile卡片计算
    if ($('tr[data-id]').length === 0 || !$('.cart-desktop').is(':visible')) {
        total = 0; count = 0;
        $('.cart-mobile-card[data-id]').each(function() {
            var $card = $(this);
            if ($card.find('.item-check').is(':checked')) {
                var price = parseFloat($card.data('price'));
                var qty = parseInt($card.find('.qty-input').val());
                total += price * qty;
                count += qty;
            }
        });
    }
    $('#totalPrice').text('¥' + total.toFixed(2));
    $('#selectedCount').text(count);
}

function updateQty(id, delta) {
    var $el = $('[data-id="' + id + '"]').first();
    var $input = $el.find('.qty-input');
    var val = parseInt($input.val()) + delta;
    var max = parseInt($el.data('stock'));
    if (val < 1) val = 1;
    if (val > max) { showToast('不能超过库存数量', 'warning'); val = max; }
    // 同步所有同id元素
    $('[data-id="' + id + '"] .qty-input').val(val);
    setQty(id, val);
}

function setQty(id, qty) {
    qty = parseInt(qty);
    if (qty < 1) qty = 1;
    $('[data-id="' + id + '"] .qty-input').val(qty);
    var $el = $('[data-id="' + id + '"]').first();
    var price = parseFloat($el.data('price'));
    $('[data-id="' + id + '"] .item-subtotal').text('¥' + (price * qty).toFixed(2));
    calcTotal();
    ajaxPost(contextPath + '/cart/update', {id: id, quantity: qty}, function(resp) {
        if (!resp.success) showToast(resp.message, 'error');
    });
}

function removeItem(id) {
    showConfirm('确定要从购物车中移除该商品吗？', function() {
        ajaxPost(contextPath + '/cart/delete', {id: id}, function(resp) {
            if (resp.success) {
                $('[data-id="' + id + '"]').fadeOut(300, function() {
                    $(this).remove();
                    calcTotal();
                    updateCartCount();
                    if ($('[data-id]').length === 0) location.reload();
                });
                showToast(resp.message, 'success');
            } else {
                showToast(resp.message, 'error');
            }
        });
    });
}

function clearCart() {
    showConfirm('确定要清空购物车吗？', function() {
        ajaxPost(contextPath + '/cart/clear', {}, function(resp) {
            if (resp.success) {
                showToast(resp.message, 'success');
                setTimeout(function() { location.reload(); }, 800);
            }
        });
    });
}

// 初始计算
calcTotal();
</script>

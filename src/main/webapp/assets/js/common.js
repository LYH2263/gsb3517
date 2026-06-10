/**
 * 在线购物平台 - 公共JS工具
 */

// ========== 自定义Toast ==========
function showToast(message, type, duration) {
    type = type || 'info';
    duration = duration || 2500;
    // 移除已有toast
    var existing = document.querySelectorAll('.custom-toast');
    existing.forEach(function(el) { el.remove(); });

    var toast = document.createElement('div');
    toast.className = 'custom-toast toast-' + type;
    toast.textContent = message;
    document.body.appendChild(toast);

    // 触发重排后显示
    setTimeout(function() { toast.classList.add('show'); }, 10);
    setTimeout(function() {
        toast.classList.remove('show');
        setTimeout(function() { toast.remove(); }, 300);
    }, duration);
}

// ========== 自定义Modal (替代原生confirm/alert) ==========
function showModal(options) {
    var title = options.title || '提示';
    var message = options.message || '';
    var confirmText = options.confirmText || '确定';
    var cancelText = options.cancelText || '取消';
    var showCancel = options.showCancel !== false;
    var onConfirm = options.onConfirm || function() {};
    var onCancel = options.onCancel || function() {};

    // 移除已有modal
    var existing = document.querySelectorAll('.custom-modal-overlay');
    existing.forEach(function(el) { el.remove(); });

    var overlay = document.createElement('div');
    overlay.className = 'custom-modal-overlay';

    var actionsHtml = '';
    if (showCancel) {
        actionsHtml += '<button class="btn-modal-cancel">' + cancelText + '</button>';
    }
    actionsHtml += '<button class="btn-modal-confirm">' + confirmText + '</button>';

    overlay.innerHTML =
        '<div class="custom-modal-box">' +
            '<div class="modal-title">' + title + '</div>' +
            '<div class="modal-message">' + message + '</div>' +
            '<div class="modal-actions">' + actionsHtml + '</div>' +
        '</div>';

    document.body.appendChild(overlay);
    setTimeout(function() { overlay.classList.add('show'); }, 10);

    var confirmBtn = overlay.querySelector('.btn-modal-confirm');
    var cancelBtn = overlay.querySelector('.btn-modal-cancel');

    confirmBtn.addEventListener('click', function() {
        closeModal(overlay);
        onConfirm();
    });

    if (cancelBtn) {
        cancelBtn.addEventListener('click', function() {
            closeModal(overlay);
            onCancel();
        });
    }

    // 点击遮罩关闭
    overlay.addEventListener('click', function(e) {
        if (e.target === overlay) {
            closeModal(overlay);
            onCancel();
        }
    });
}

function showAlert(message, title) {
    showModal({
        title: title || '提示',
        message: message,
        showCancel: false
    });
}

function showConfirm(message, onConfirm, title) {
    showModal({
        title: title || '确认操作',
        message: message,
        onConfirm: onConfirm
    });
}

function closeModal(overlay) {
    overlay.classList.remove('show');
    setTimeout(function() { overlay.remove(); }, 200);
}

// ========== 表单验证 ==========
function validateForm(formId, rules) {
    var form = document.getElementById(formId);
    if (!form) return false;
    var valid = true;

    // 清除之前的错误
    clearFormErrors(formId);

    for (var field in rules) {
        var input = form.querySelector('[name="' + field + '"]');
        if (!input) continue;

        var rule = rules[field];
        var value = input.value.trim();

        if (rule.required && !value) {
            showFieldError(input, rule.requiredMsg || '此项为必填项');
            valid = false;
            continue;
        }

        if (rule.minLength && value.length < rule.minLength) {
            showFieldError(input, rule.minLengthMsg || ('至少需要' + rule.minLength + '个字符'));
            valid = false;
            continue;
        }

        if (rule.pattern && !rule.pattern.test(value)) {
            showFieldError(input, rule.patternMsg || '格式不正确');
            valid = false;
            continue;
        }

        if (rule.match) {
            var matchInput = form.querySelector('[name="' + rule.match + '"]');
            if (matchInput && value !== matchInput.value.trim()) {
                showFieldError(input, rule.matchMsg || '两次输入不一致');
                valid = false;
                continue;
            }
        }
    }

    return valid;
}

function showFieldError(input, message) {
    input.classList.add('is-invalid');
    var feedback = document.createElement('div');
    feedback.className = 'invalid-feedback';
    feedback.textContent = message;
    input.parentNode.appendChild(feedback);

    // 输入时清除错误
    input.addEventListener('input', function handler() {
        input.classList.remove('is-invalid');
        var fb = input.parentNode.querySelector('.invalid-feedback');
        if (fb) fb.remove();
        input.removeEventListener('input', handler);
    }, {once: true});
}

function clearFormErrors(formId) {
    var form = document.getElementById(formId);
    if (!form) return;
    form.querySelectorAll('.is-invalid').forEach(function(el) {
        el.classList.remove('is-invalid');
    });
    form.querySelectorAll('.invalid-feedback').forEach(function(el) {
        el.remove();
    });
}

function highlightField(fieldName) {
    var input = document.querySelector('[name="' + fieldName + '"]');
    if (input) {
        input.classList.add('is-invalid');
        input.focus();
    }
}

// ========== AJAX 工具 ==========
function ajaxPost(url, data, callback) {
    $.ajax({
        url: url,
        type: 'POST',
        data: data,
        dataType: 'json',
        success: function(resp) {
            callback(resp);
        },
        error: function(xhr) {
            if (xhr.status === 401) {
                showModal({
                    title: '提示',
                    message: '请先登录后再操作',
                    confirmText: '去登录',
                    cancelText: '取消',
                    onConfirm: function() {
                        window.location.href = contextPath + '/user/login';
                    }
                });
            } else {
                showToast('网络请求失败，请稍后重试', 'error');
            }
        }
    });
}

// ========== 购物车数量更新 ==========
function updateCartCount() {
    $.get(contextPath + '/cart/count', function(resp) {
        var badge = document.getElementById('cartCount');
        if (badge) {
            badge.textContent = resp.count || 0;
            badge.style.display = resp.count > 0 ? 'inline' : 'none';
        }
    }).fail(function() {});
}

// ========== 添加到购物车 ==========
function addToCart(productId, quantity) {
    quantity = quantity || 1;
    ajaxPost(contextPath + '/cart/add', {productId: productId, quantity: quantity}, function(resp) {
        if (resp.success) {
            showToast(resp.message, 'success');
            updateCartCount();
        } else {
            if (resp.message === '请先登录') {
                window.location.href = contextPath + '/user/login.jsp';
            } else {
                showToast(resp.message, 'error');
            }
        }
    });
}

// ========== 商品图片错误处理 ==========
function handleImgError(img) {
    img.onerror = null;
    img.style.display = 'none';
    var placeholder = document.createElement('div');
    placeholder.className = 'product-img-placeholder';
    placeholder.innerHTML = '<i class="bi bi-image"></i>';
    placeholder.style.height = img.height ? img.height + 'px' : '200px';
    img.parentNode.insertBefore(placeholder, img);
}

// 页面加载完成后初始化
$(document).ready(function() {
    updateCartCount();
});

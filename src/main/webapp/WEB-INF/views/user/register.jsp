<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="用户注册"/></jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card border-0 shadow-sm" style="border-radius:12px">
                <div class="card-body p-4">
                    <h4 class="text-center mb-4"><i class="bi bi-person-plus me-2"></i>用户注册</h4>
                    <form id="registerForm">
                        <div class="mb-3">
                            <label class="form-label">用户名 <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-person"></i></span>
                                <input type="text" class="form-control" name="username" placeholder="至少3个字符">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">密码 <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                <input type="password" class="form-control" name="password" placeholder="至少6个字符">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">确认密码 <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                                <input type="password" class="form-control" name="confirmPassword" placeholder="再次输入密码">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">邮箱</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                <input type="email" class="form-control" name="email" placeholder="选填">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">手机号</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-phone"></i></span>
                                <input type="text" class="form-control" name="phone" placeholder="选填">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 py-2 mt-2">
                            <i class="bi bi-person-plus me-1"></i>注 册
                        </button>
                    </form>
                    <div class="text-center mt-3">
                        <span class="text-muted">已有账号？</span>
                        <a href="${pageContext.request.contextPath}/user/login">立即登录</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp"/>
<script>
$('#registerForm').on('submit', function(e) {
    e.preventDefault();
    var valid = validateForm('registerForm', {
        username: { required: true, requiredMsg: '请输入用户名', minLength: 3, minLengthMsg: '用户名至少3个字符' },
        password: { required: true, requiredMsg: '请输入密码', minLength: 6, minLengthMsg: '密码至少6个字符' },
        confirmPassword: { required: true, requiredMsg: '请确认密码', match: 'password', matchMsg: '两次密码输入不一致' }
    });
    if (!valid) return;

    ajaxPost(contextPath + '/user/register', $(this).serialize(), function(resp) {
        if (resp.success) {
            showToast(resp.message, 'success');
            setTimeout(function() { window.location.href = contextPath + '/user/login'; }, 1200);
        } else {
            showToast(resp.message, 'error');
            if (resp.field) highlightField(resp.field);
        }
    });
});
</script>

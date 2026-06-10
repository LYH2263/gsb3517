<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="用户登录"/></jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card border-0 shadow-sm" style="border-radius:12px">
                <div class="card-body p-4">
                    <h4 class="text-center mb-4"><i class="bi bi-person-circle me-2"></i>用户登录</h4>
                    <form id="loginForm">
                        <div class="mb-3">
                            <label class="form-label">用户名</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-person"></i></span>
                                <input type="text" class="form-control" name="username" placeholder="请输入用户名" autofocus>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">密码</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                <input type="password" class="form-control" name="password" placeholder="请输入密码">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 py-2 mt-2">
                            <i class="bi bi-box-arrow-in-right me-1"></i>登 录
                        </button>
                    </form>
                    <div class="text-center mt-3">
                        <span class="text-muted">还没有账号？</span>
                        <a href="${pageContext.request.contextPath}/user/register">立即注册</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp"/>
<script>
$('#loginForm').on('submit', function(e) {
    e.preventDefault();
    var valid = validateForm('loginForm', {
        username: { required: true, requiredMsg: '请输入用户名' },
        password: { required: true, requiredMsg: '请输入密码' }
    });
    if (!valid) return;

    ajaxPost(contextPath + '/user/login', $(this).serialize(), function(resp) {
        if (resp.success) {
            showToast(resp.message, 'success');
            setTimeout(function() {
                window.location.href = resp.role === 'ADMIN' ? contextPath + '/admin/dashboard' : contextPath + '/';
            }, 800);
        } else {
            showToast(resp.message, 'error');
            if (resp.field) highlightField(resp.field);
        }
    });
});
</script>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="个人中心"/></jsp:include>

<div class="container py-4">
    <div class="row">
        <div class="col-md-3 mb-3">
            <div class="card border-0 shadow-sm" style="border-radius:12px">
                <div class="card-body text-center">
                    <i class="bi bi-person-circle d-block mb-2" style="font-size:3rem;color:var(--primary)"></i>
                    <h5>${userInfo.username}</h5>
                    <span class="badge bg-light text-dark">${userInfo.role == 'ADMIN' ? '管理员' : '普通用户'}</span>
                </div>
                <div class="list-group list-group-flush">
                    <a href="#profile" class="list-group-item list-group-item-action active" data-bs-toggle="list">
                        <i class="bi bi-person me-2"></i>基本信息
                    </a>
                    <a href="#password" class="list-group-item list-group-item-action" data-bs-toggle="list">
                        <i class="bi bi-shield-lock me-2"></i>修改密码
                    </a>
                    <a href="${pageContext.request.contextPath}/order/list" class="list-group-item list-group-item-action">
                        <i class="bi bi-bag me-2"></i>我的订单
                    </a>
                </div>
            </div>
        </div>
        <div class="col-md-9">
            <div class="tab-content">
                <!-- 基本信息 -->
                <div class="tab-pane fade show active" id="profile">
                    <div class="card border-0 shadow-sm" style="border-radius:12px">
                        <div class="card-header bg-white border-0 pt-3">
                            <h5><i class="bi bi-person me-2"></i>基本信息</h5>
                        </div>
                        <div class="card-body">
                            <form id="profileForm">
                                <div class="row mb-3">
                                    <label class="col-sm-3 col-form-label">用户名</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" value="${userInfo.username}" disabled>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <label class="col-sm-3 col-form-label">邮箱</label>
                                    <div class="col-sm-9">
                                        <input type="email" class="form-control" name="email" value="${userInfo.email}">
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <label class="col-sm-3 col-form-label">手机号</label>
                                    <div class="col-sm-9">
                                        <input type="text" class="form-control" name="phone" value="${userInfo.phone}">
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <label class="col-sm-3 col-form-label">收货地址</label>
                                    <div class="col-sm-9">
                                        <textarea class="form-control" name="address" rows="2">${userInfo.address}</textarea>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-9 offset-sm-3">
                                        <button type="submit" class="btn btn-primary">保存修改</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <!-- 修改密码 -->
                <div class="tab-pane fade" id="password">
                    <div class="card border-0 shadow-sm" style="border-radius:12px">
                        <div class="card-header bg-white border-0 pt-3">
                            <h5><i class="bi bi-shield-lock me-2"></i>修改密码</h5>
                        </div>
                        <div class="card-body">
                            <form id="passwordForm">
                                <div class="row mb-3">
                                    <label class="col-sm-3 col-form-label">原密码</label>
                                    <div class="col-sm-9">
                                        <input type="password" class="form-control" name="oldPassword">
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <label class="col-sm-3 col-form-label">新密码</label>
                                    <div class="col-sm-9">
                                        <input type="password" class="form-control" name="newPassword" placeholder="至少6个字符">
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <label class="col-sm-3 col-form-label">确认新密码</label>
                                    <div class="col-sm-9">
                                        <input type="password" class="form-control" name="confirmNewPassword">
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-sm-9 offset-sm-3">
                                        <button type="submit" class="btn btn-primary">修改密码</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp"/>
<script>
$('#profileForm').on('submit', function(e) {
    e.preventDefault();
    ajaxPost(contextPath + '/user/update', $(this).serialize(), function(resp) {
        showToast(resp.message, resp.success ? 'success' : 'error');
    });
});

$('#passwordForm').on('submit', function(e) {
    e.preventDefault();
    var valid = validateForm('passwordForm', {
        oldPassword: { required: true, requiredMsg: '请输入原密码' },
        newPassword: { required: true, requiredMsg: '请输入新密码', minLength: 6, minLengthMsg: '新密码至少6个字符' },
        confirmNewPassword: { required: true, requiredMsg: '请确认新密码', match: 'newPassword', matchMsg: '两次密码不一致' }
    });
    if (!valid) return;

    ajaxPost(contextPath + '/user/changePassword', $(this).serialize(), function(resp) {
        if (resp.success) {
            showToast(resp.message, 'success');
            document.getElementById('passwordForm').reset();
        } else {
            showToast(resp.message, 'error');
            if (resp.field) highlightField(resp.field);
        }
    });
});
</script>

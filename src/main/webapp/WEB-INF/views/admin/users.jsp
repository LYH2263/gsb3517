<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/admin/header.jsp"><jsp:param name="title" value="用户管理"/><jsp:param name="menu" value="users"/></jsp:include>

<h4 class="mb-3">用户管理</h4>

<!-- 筛选栏 -->
<div class="card border-0 shadow-sm mb-3" style="border-radius:12px">
    <div class="card-body py-3">
        <form class="admin-filter-form" method="get" action="${pageContext.request.contextPath}/admin/users">
            <div class="d-flex flex-wrap gap-2 align-items-end">
                <div style="min-width:180px;flex:1">
                    <label class="form-label mb-1 small text-muted">搜索</label>
                    <input type="text" class="form-control form-control-sm" name="keyword" value="${keyword}" placeholder="用户名/邮箱/手机号">
                </div>
                <div style="min-width:120px">
                    <label class="form-label mb-1 small text-muted">角色</label>
                    <select class="form-select form-select-sm" name="role">
                        <option value="">全部角色</option>
                        <option value="ADMIN" ${filterRole == 'ADMIN' ? 'selected' : ''}>管理员</option>
                        <option value="USER" ${filterRole == 'USER' ? 'selected' : ''}>用户</option>
                    </select>
                </div>
                <div style="min-width:120px">
                    <label class="form-label mb-1 small text-muted">状态</label>
                    <select class="form-select form-select-sm" name="status">
                        <option value="">全部状态</option>
                        <option value="1" ${filterStatus != null && filterStatus == 1 ? 'selected' : ''}>正常</option>
                        <option value="0" ${filterStatus != null && filterStatus == 0 ? 'selected' : ''}>禁用</option>
                    </select>
                </div>
                <div class="d-flex gap-1">
                    <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-search me-1"></i>搜索</button>
                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-counterclockwise me-1"></i>重置</a>
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
                    <th>ID</th>
                    <th>用户名</th>
                    <th>邮箱</th>
                    <th>手机号</th>
                    <th>角色</th>
                    <th>状态</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="u" items="${users}">
                    <tr>
                        <td>${u.id}</td>
                        <td><strong>${u.username}</strong></td>
                        <td>${u.email}</td>
                        <td>${u.phone}</td>
                        <td>
                            <span class="badge ${u.role == 'ADMIN' ? 'bg-danger' : 'bg-primary'}">${u.role == 'ADMIN' ? '管理员' : '用户'}</span>
                        </td>
                        <td>
                            <span class="badge ${u.status == 1 ? 'bg-success' : 'bg-secondary'}">${u.status == 1 ? '正常' : '禁用'}</span>
                        </td>
                        <td>
                            <c:if test="${u.role != 'ADMIN'}">
                                <c:choose>
                                    <c:when test="${u.status == 1}">
                                        <button class="btn btn-sm btn-outline-warning" onclick="toggleUser(${u.id}, 0)">
                                            <i class="bi bi-slash-circle me-1"></i>禁用
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-sm btn-outline-success" onclick="toggleUser(${u.id}, 1)">
                                            <i class="bi bi-check-circle me-1"></i>启用
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty users}">
                    <tr><td colspan="7" class="text-center text-muted py-4">暂无匹配的用户</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<jsp:include page="/WEB-INF/views/admin/footer.jsp"/>
<script>
function toggleUser(id, status) {
    var msg = status === 0 ? '确定要禁用该用户吗？' : '确定要启用该用户吗？';
    showConfirm(msg, function() {
        ajaxPost(contextPath + '/admin/user/toggleStatus', {id: id, status: status}, function(resp) {
            showToast(resp.message, resp.success ? 'success' : 'error');
            if (resp.success) setTimeout(function() { location.reload(); }, 800);
        });
    });
}
</script>

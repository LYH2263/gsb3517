<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="页面未找到"/></jsp:include>
<div class="container py-5">
    <div class="empty-state">
        <i class="bi bi-emoji-frown d-block"></i>
        <h3>404 - 页面未找到</h3>
        <p>您访问的页面不存在或已被移除</p>
        <a href="${pageContext.request.contextPath}/" class="btn btn-primary mt-3">返回首页</a>
    </div>
</div>
<jsp:include page="/common/footer.jsp"/>

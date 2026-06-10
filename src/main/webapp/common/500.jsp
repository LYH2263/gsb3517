<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="服务器错误"/></jsp:include>
<div class="container py-5">
    <div class="empty-state">
        <i class="bi bi-exclamation-triangle d-block"></i>
        <h3>500 - 服务器错误</h3>
        <p>抱歉，服务器遇到了问题，请稍后再试</p>
        <a href="${pageContext.request.contextPath}/" class="btn btn-primary mt-3">返回首页</a>
    </div>
</div>
<jsp:include page="/common/footer.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
</div><!-- /.main-content -->
<!-- Footer -->
<footer class="site-footer">
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-3">
                <h5><i class="bi bi-shop"></i> 优品商城</h5>
                <p class="text-muted small">品质生活，从这里开始。为您精选优质好物，让购物更简单、更快乐。</p>
            </div>
            <div class="col-md-2 mb-3">
                <h6>快速链接</h6>
                <ul class="list-unstyled small">
                    <li><a href="${pageContext.request.contextPath}/">首页</a></li>
                    <li><a href="${pageContext.request.contextPath}/product/list">全部商品</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart/list">购物车</a></li>
                </ul>
            </div>
            <div class="col-md-3 mb-3">
                <h6>客户服务</h6>
                <ul class="list-unstyled small">
                    <li><a href="${pageContext.request.contextPath}/page/help">帮助中心</a></li>
                    <li><a href="${pageContext.request.contextPath}/page/return-policy">退换货政策</a></li>
                    <li><a href="${pageContext.request.contextPath}/page/delivery">配送说明</a></li>
                </ul>
            </div>
            <div class="col-md-3 mb-3">
                <h6>联系我们</h6>
                <ul class="list-unstyled small">
                    <li><i class="bi bi-telephone me-1"></i> 400-888-8888</li>
                    <li><i class="bi bi-envelope me-1"></i> service@shop.com</li>
                    <li><i class="bi bi-clock me-1"></i> 周一至周日 9:00-21:00</li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom text-center">
            &copy; 2024 优品商城 版权所有
        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>var contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/admin/header.jsp"><jsp:param name="title" value="控制台"/><jsp:param name="menu" value="dashboard"/></jsp:include>

<h4 class="mb-4"><i class="bi bi-speedometer2 me-2"></i>控制台</h4>

<!-- 核心数据卡片 -->
<div class="row g-3 mb-4">
    <div class="col-sm-6 col-xl-3">
        <div class="stat-card" style="background:linear-gradient(135deg,#e74c3c,#e67e22)">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <div class="stat-number">${productCount}</div>
                    <div class="stat-label">商品总数</div>
                </div>
                <i class="bi bi-box-seam" style="font-size:2.5rem;opacity:0.3"></i>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-xl-3">
        <div class="stat-card" style="background:linear-gradient(135deg,#2ecc71,#27ae60)">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <div class="stat-number">${orderCount}</div>
                    <div class="stat-label">订单总数</div>
                </div>
                <i class="bi bi-receipt" style="font-size:2.5rem;opacity:0.3"></i>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-xl-3">
        <div class="stat-card" style="background:linear-gradient(135deg,#3498db,#2980b9)">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <div class="stat-number">${userCount}</div>
                    <div class="stat-label">注册用户</div>
                </div>
                <i class="bi bi-people" style="font-size:2.5rem;opacity:0.3"></i>
            </div>
        </div>
    </div>
    <div class="col-sm-6 col-xl-3">
        <div class="stat-card" style="background:linear-gradient(135deg,#f39c12,#e67e22)">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <div class="stat-number">¥<fmt:formatNumber value="${totalRevenue}" pattern="#,##0.00"/></div>
                    <div class="stat-label">总销售额</div>
                </div>
                <i class="bi bi-currency-yen" style="font-size:2.5rem;opacity:0.3"></i>
            </div>
        </div>
    </div>
</div>

<!-- 订单状态分布 + 分类统计 -->
<div class="row g-3 mb-4">
    <div class="col-lg-6">
        <div class="card border-0 shadow-sm dash-card">
            <div class="card-body">
                <h6 class="dash-card-title"><i class="bi bi-pie-chart me-2"></i>订单状态分布</h6>
                <div class="order-status-chart">
                    <c:set var="totalOrders" value="${orderStatusMap.PENDING + orderStatusMap.PAID + orderStatusMap.SHIPPED + orderStatusMap.COMPLETED + orderStatusMap.CANCELLED}" />
                    <div class="status-bar-row">
                        <span class="status-label"><span class="status-dot" style="background:#f39c12"></span>待付款</span>
                        <div class="status-bar-track">
                            <div class="status-bar-fill" style="width:${totalOrders > 0 ? (orderStatusMap.PENDING * 100 / totalOrders) : 0}%;background:#f39c12"></div>
                        </div>
                        <span class="status-count">${orderStatusMap.PENDING}</span>
                    </div>
                    <div class="status-bar-row">
                        <span class="status-label"><span class="status-dot" style="background:#17a2b8"></span>待发货</span>
                        <div class="status-bar-track">
                            <div class="status-bar-fill" style="width:${totalOrders > 0 ? (orderStatusMap.PAID * 100 / totalOrders) : 0}%;background:#17a2b8"></div>
                        </div>
                        <span class="status-count">${orderStatusMap.PAID}</span>
                    </div>
                    <div class="status-bar-row">
                        <span class="status-label"><span class="status-dot" style="background:#007bff"></span>已发货</span>
                        <div class="status-bar-track">
                            <div class="status-bar-fill" style="width:${totalOrders > 0 ? (orderStatusMap.SHIPPED * 100 / totalOrders) : 0}%;background:#007bff"></div>
                        </div>
                        <span class="status-count">${orderStatusMap.SHIPPED}</span>
                    </div>
                    <div class="status-bar-row">
                        <span class="status-label"><span class="status-dot" style="background:#28a745"></span>已完成</span>
                        <div class="status-bar-track">
                            <div class="status-bar-fill" style="width:${totalOrders > 0 ? (orderStatusMap.COMPLETED * 100 / totalOrders) : 0}%;background:#28a745"></div>
                        </div>
                        <span class="status-count">${orderStatusMap.COMPLETED}</span>
                    </div>
                    <div class="status-bar-row">
                        <span class="status-label"><span class="status-dot" style="background:#6c757d"></span>已取消</span>
                        <div class="status-bar-track">
                            <div class="status-bar-fill" style="width:${totalOrders > 0 ? (orderStatusMap.CANCELLED * 100 / totalOrders) : 0}%;background:#6c757d"></div>
                        </div>
                        <span class="status-count">${orderStatusMap.CANCELLED}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="card border-0 shadow-sm dash-card">
            <div class="card-body">
                <h6 class="dash-card-title"><i class="bi bi-bar-chart me-2"></i>分类商品分布</h6>
                <div class="category-chart">
                    <c:set var="maxCatCount" value="1"/>
                    <c:forEach var="cs" items="${categoryStats}">
                        <c:if test="${cs.count > maxCatCount}"><c:set var="maxCatCount" value="${cs.count}"/></c:if>
                    </c:forEach>
                    <c:forEach var="cs" items="${categoryStats}">
                        <div class="cat-bar-row">
                            <span class="cat-label">${cs.name}</span>
                            <div class="cat-bar-track">
                                <div class="cat-bar-fill" style="width:${cs.count * 100 / maxCatCount}%">${cs.count}</div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- 销量TOP5 + 最近订单 -->
<div class="row g-3 mb-4">
    <div class="col-lg-6">
        <div class="card border-0 shadow-sm dash-card">
            <div class="card-body">
                <h6 class="dash-card-title"><i class="bi bi-trophy me-2"></i>销量排行 TOP 5</h6>
                <table class="table table-hover small mb-0 mt-2">
                    <thead>
                        <tr><th style="width:40px">排名</th><th>商品名称</th><th class="text-end">销量</th><th class="text-end">价格</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="tp" items="${topProducts}" varStatus="st">
                            <tr>
                                <td>
                                    <c:choose>
                                        <c:when test="${st.index == 0}"><span class="rank-badge rank-1">1</span></c:when>
                                        <c:when test="${st.index == 1}"><span class="rank-badge rank-2">2</span></c:when>
                                        <c:when test="${st.index == 2}"><span class="rank-badge rank-3">3</span></c:when>
                                        <c:otherwise><span class="rank-badge">${st.index + 1}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <img src="${pageContext.request.contextPath}${tp.image}" class="rounded me-2" style="width:32px;height:32px;object-fit:cover" onerror="this.src='${pageContext.request.contextPath}/assets/images/default-product.jpg'">
                                        <span class="text-truncate" style="max-width:160px">${tp.name}</span>
                                    </div>
                                </td>
                                <td class="text-end fw-bold">${tp.sales}</td>
                                <td class="text-end text-danger">¥${tp.price}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="card border-0 shadow-sm dash-card">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <h6 class="dash-card-title mb-0"><i class="bi bi-clock-history me-2"></i>最近订单</h6>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="small text-primary">查看全部 →</a>
                </div>
                <table class="table table-hover small mb-0 mt-2">
                    <thead>
                        <tr><th>订单号</th><th>用户</th><th class="text-end">金额</th><th>状态</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="ro" items="${recentOrders}">
                            <tr>
                                <td><a href="${pageContext.request.contextPath}/admin/order/detail?id=${ro.id}" class="text-primary">${ro.orderNo}</a></td>
                                <td>${ro.username}</td>
                                <td class="text-end">¥${ro.totalAmount}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${ro.status == 'PENDING'}"><span class="badge bg-warning text-dark">待付款</span></c:when>
                                        <c:when test="${ro.status == 'PAID'}"><span class="badge bg-info text-white">待发货</span></c:when>
                                        <c:when test="${ro.status == 'SHIPPED'}"><span class="badge bg-primary">已发货</span></c:when>
                                        <c:when test="${ro.status == 'COMPLETED'}"><span class="badge bg-success">已完成</span></c:when>
                                        <c:when test="${ro.status == 'CANCELLED'}"><span class="badge bg-secondary">已取消</span></c:when>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty recentOrders}">
                            <tr><td colspan="4" class="text-center text-muted">暂无订单</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 库存预警 + 快捷操作 + 系统信息 -->
<div class="row g-3 mb-4">
    <div class="col-lg-4">
        <div class="card border-0 shadow-sm dash-card">
            <div class="card-body">
                <h6 class="dash-card-title"><i class="bi bi-exclamation-triangle me-2 text-warning"></i>库存预警 <span class="badge bg-warning text-dark ms-1">${lowStockProducts.size()}</span></h6>
                <c:choose>
                    <c:when test="${not empty lowStockProducts}">
                        <div class="low-stock-list mt-2">
                            <c:forEach var="lp" items="${lowStockProducts}">
                                <div class="low-stock-item">
                                    <span class="text-truncate">${lp.name}</span>
                                    <span class="badge ${lp.stock <= 5 ? 'bg-danger' : 'bg-warning text-dark'}">${lp.stock}</span>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center text-muted py-4">
                            <i class="bi bi-check-circle d-block" style="font-size:2rem;color:#28a745"></i>
                            <small>库存充足，无需补货</small>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
    <div class="col-lg-4">
        <div class="card border-0 shadow-sm dash-card">
            <div class="card-body">
                <h6 class="dash-card-title"><i class="bi bi-lightning me-2"></i>快捷操作</h6>
                <div class="d-flex flex-wrap gap-2 mt-3">
                    <a href="${pageContext.request.contextPath}/admin/product/edit" class="btn btn-outline-primary btn-sm"><i class="bi bi-plus-circle me-1"></i>添加商品</a>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline-success btn-sm"><i class="bi bi-receipt me-1"></i>查看订单</a>
                    <a href="${pageContext.request.contextPath}/admin/categories" class="btn btn-outline-warning btn-sm"><i class="bi bi-tags me-1"></i>分类管理</a>
                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-info btn-sm"><i class="bi bi-people me-1"></i>用户管理</a>
                </div>
            </div>
        </div>
    </div>
    <div class="col-lg-4">
        <div class="card border-0 shadow-sm dash-card">
            <div class="card-body">
                <h6 class="dash-card-title"><i class="bi bi-info-circle me-2"></i>系统信息</h6>
                <table class="table table-borderless small mt-2 mb-0">
                    <tr><td class="text-muted" style="width:80px">系统版本</td><td>v1.0.0</td></tr>
                    <tr><td class="text-muted">运行环境</td><td>JDK 21 / Tomcat 10</td></tr>
                    <tr><td class="text-muted">数据库</td><td>MySQL 8.0</td></tr>
                    <tr><td class="text-muted">框架</td><td>Servlet / JSP / Bootstrap 5</td></tr>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/admin/footer.jsp"/>

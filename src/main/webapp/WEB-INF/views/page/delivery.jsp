<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="配送说明"/></jsp:include>

<div class="container py-4">
    <div class="row">
        <!-- 侧边导航 -->
        <div class="col-lg-3 mb-4">
            <div class="card help-sidebar">
                <div class="card-body p-0">
                    <div class="help-sidebar-title">
                        <i class="bi bi-headset me-2"></i>客户服务
                    </div>
                    <ul class="help-nav">
                        <li><a href="${pageContext.request.contextPath}/page/help"><i class="bi bi-question-circle me-2"></i>帮助中心</a></li>
                        <li><a href="${pageContext.request.contextPath}/page/return-policy"><i class="bi bi-arrow-repeat me-2"></i>退换货政策</a></li>
                        <li><a href="${pageContext.request.contextPath}/page/delivery" class="active"><i class="bi bi-truck me-2"></i>配送说明</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- 主内容 -->
        <div class="col-lg-9">
            <div class="card help-content">
                <div class="card-body">
                    <h3 class="help-page-title"><i class="bi bi-truck me-2"></i>配送说明</h3>
                    <p class="text-muted mb-4">了解优品商城的配送服务，让您购物更安心。</p>

                    <!-- 配送亮点 -->
                    <div class="row g-3 mb-4">
                        <div class="col-md-4">
                            <div class="delivery-feature-card">
                                <i class="bi bi-lightning-charge"></i>
                                <h6>极速发货</h6>
                                <p>订单确认后24小时内发货</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="delivery-feature-card">
                                <i class="bi bi-geo-alt"></i>
                                <h6>全国配送</h6>
                                <p>覆盖全国31个省市自治区</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="delivery-feature-card">
                                <i class="bi bi-box-seam"></i>
                                <h6>安全包装</h6>
                                <p>专业包装保障商品安全</p>
                            </div>
                        </div>
                    </div>

                    <!-- 配送方式 -->
                    <h5 class="help-section-title"><i class="bi bi-signpost-2 me-2"></i>配送方式</h5>
                    <table class="table table-bordered help-table">
                        <thead>
                            <tr>
                                <th>配送方式</th>
                                <th>配送范围</th>
                                <th>预计时效</th>
                                <th>运费标准</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><i class="bi bi-truck me-1 text-primary"></i>标准快递</td>
                                <td>全国</td>
                                <td>3-5个工作日</td>
                                <td>满99元包邮，不满99元收取10元运费</td>
                            </tr>
                            <tr>
                                <td><i class="bi bi-lightning me-1 text-warning"></i>加急快递</td>
                                <td>主要城市</td>
                                <td>1-2个工作日</td>
                                <td>15元/单（部分偏远地区不支持）</td>
                            </tr>
                            <tr>
                                <td><i class="bi bi-building me-1 text-success"></i>同城配送</td>
                                <td>部分城市</td>
                                <td>当日或次日达</td>
                                <td>满199元免运费，不满收取8元</td>
                            </tr>
                        </tbody>
                    </table>

                    <!-- 配送时效 -->
                    <h5 class="help-section-title mt-4"><i class="bi bi-clock-history me-2"></i>配送时效说明</h5>
                    <div class="info-box">
                        <ul class="mb-0">
                            <li><strong>发货时间：</strong>工作日订单在确认后24小时内发出，节假日顺延至下一工作日。</li>
                            <li><strong>配送时效：</strong>从发货到签收的预计时间，实际时效受目的地、天气等因素影响。</li>
                            <li><strong>签收确认：</strong>请在收到快递后当面验收，如有问题请拒收并联系客服。</li>
                            <li><strong>自动确认：</strong>签收后7天内如未申请售后，系统将自动确认收货并完成订单。</li>
                        </ul>
                    </div>

                    <!-- 配送区域 -->
                    <h5 class="help-section-title mt-4"><i class="bi bi-map me-2"></i>配送区域与运费</h5>
                    <table class="table table-bordered help-table">
                        <thead>
                            <tr>
                                <th>区域</th>
                                <th>覆盖范围</th>
                                <th>标准快递时效</th>
                                <th>包邮门槛</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><span class="badge bg-success">一线</span></td>
                                <td>北京、上海、广州、深圳</td>
                                <td>1-3天</td>
                                <td>满99元包邮</td>
                            </tr>
                            <tr>
                                <td><span class="badge bg-info text-white">二线</span></td>
                                <td>省会城市及主要城市</td>
                                <td>2-4天</td>
                                <td>满99元包邮</td>
                            </tr>
                            <tr>
                                <td><span class="badge bg-warning text-dark">三四线</span></td>
                                <td>其他地级市及县城</td>
                                <td>3-5天</td>
                                <td>满99元包邮</td>
                            </tr>
                            <tr>
                                <td><span class="badge bg-secondary">偏远地区</span></td>
                                <td>新疆、西藏、青海等</td>
                                <td>5-7天</td>
                                <td>满199元包邮，不满收取15元</td>
                            </tr>
                        </tbody>
                    </table>

                    <!-- 注意事项 -->
                    <h5 class="help-section-title mt-4"><i class="bi bi-exclamation-circle me-2"></i>注意事项</h5>
                    <div class="alert alert-light border">
                        <ol class="mb-0">
                            <li>请确保收货地址准确完整，包括省、市、区、详细地址及联系电话。</li>
                            <li>如需修改收货地址，请在商家发货前联系客服修改。</li>
                            <li>大促期间（如双11、618等）物流量大，配送时效可能延长1-3天。</li>
                            <li>贵重物品建议选择保价服务，如在运输过程中发生损坏，可获得相应赔偿。</li>
                            <li>如快递长时间未更新物流信息，请联系客服协助查询。</li>
                        </ol>
                    </div>

                    <!-- 联系客服 -->
                    <div class="help-contact-card mt-4">
                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <h5><i class="bi bi-headset me-2"></i>配送相关问题？</h5>
                                <p class="mb-0 text-muted">如有配送问题或需要查询物流，请联系我们。</p>
                            </div>
                            <div class="col-md-4 text-md-end mt-3 mt-md-0">
                                <div class="mb-1"><i class="bi bi-telephone me-1"></i> <strong>400-888-8888</strong></div>
                                <div class="small text-muted"><i class="bi bi-clock me-1"></i> 周一至周日 9:00-21:00</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp"/>

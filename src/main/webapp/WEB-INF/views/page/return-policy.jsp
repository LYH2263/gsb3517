<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="退换货政策"/></jsp:include>

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
                        <li><a href="${pageContext.request.contextPath}/page/return-policy" class="active"><i class="bi bi-arrow-repeat me-2"></i>退换货政策</a></li>
                        <li><a href="${pageContext.request.contextPath}/page/delivery"><i class="bi bi-truck me-2"></i>配送说明</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- 主内容 -->
        <div class="col-lg-9">
            <div class="card help-content">
                <div class="card-body">
                    <h3 class="help-page-title"><i class="bi bi-arrow-repeat me-2"></i>退换货政策</h3>
                    <p class="text-muted mb-4">优品商城承诺为您提供无忧的售后服务，请仔细阅读以下退换货政策。</p>

                    <!-- 7天无理由退换 -->
                    <div class="policy-card policy-highlight">
                        <div class="policy-card-icon">
                            <i class="bi bi-shield-check"></i>
                        </div>
                        <div class="policy-card-content">
                            <h5>7天无理由退换</h5>
                            <p>自签收之日起7天内，如商品未经使用且保持原包装完好，您可以申请无理由退换货。</p>
                        </div>
                    </div>

                    <!-- 退货条件 -->
                    <h5 class="help-section-title mt-4"><i class="bi bi-check-circle me-2"></i>退货条件</h5>
                    <div class="policy-conditions">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <div class="condition-card condition-yes">
                                    <h6><i class="bi bi-check-circle-fill text-success me-2"></i>可以退货的情况</h6>
                                    <ul>
                                        <li>商品存在质量问题</li>
                                        <li>收到的商品与描述不符</li>
                                        <li>商品在运输中损坏</li>
                                        <li>签收7天内未使用的商品</li>
                                        <li>商品配件、赠品齐全</li>
                                    </ul>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="condition-card condition-no">
                                    <h6><i class="bi bi-x-circle-fill text-danger me-2"></i>不支持退货的情况</h6>
                                    <ul>
                                        <li>超过7天退换期限</li>
                                        <li>人为损坏或使用痕迹明显</li>
                                        <li>缺少原包装、配件或赠品</li>
                                        <li>食品、个人护理等特殊商品</li>
                                        <li>定制或个性化商品</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 退货流程 -->
                    <h5 class="help-section-title mt-4"><i class="bi bi-diagram-3 me-2"></i>退货流程</h5>
                    <div class="return-steps">
                        <div class="return-step">
                            <div class="step-number">1</div>
                            <div class="step-content">
                                <h6>提交申请</h6>
                                <p>在"我的订单"中找到需要退货的订单，联系客服提交退货申请，说明退货原因。</p>
                            </div>
                        </div>
                        <div class="return-step">
                            <div class="step-number">2</div>
                            <div class="step-content">
                                <h6>审核确认</h6>
                                <p>客服会在1-2个工作日内审核您的申请，审核通过后会提供退货地址。</p>
                            </div>
                        </div>
                        <div class="return-step">
                            <div class="step-number">3</div>
                            <div class="step-content">
                                <h6>寄回商品</h6>
                                <p>请将商品妥善包装后寄回指定地址，建议使用可追踪的快递服务并保留快递单号。</p>
                            </div>
                        </div>
                        <div class="return-step">
                            <div class="step-number">4</div>
                            <div class="step-content">
                                <h6>退款处理</h6>
                                <p>我们收到商品并确认无误后，将在3-5个工作日内完成退款，退款金额将原路返回。</p>
                            </div>
                        </div>
                    </div>

                    <!-- 换货说明 -->
                    <h5 class="help-section-title mt-4"><i class="bi bi-arrow-left-right me-2"></i>换货说明</h5>
                    <div class="info-box">
                        <ul class="mb-0">
                            <li>换货流程与退货类似，提交申请时请选择"换货"并说明原因。</li>
                            <li>换货商品需与原商品相同，如需更换不同商品，请先退货后重新购买。</li>
                            <li>因质量问题换货，运费由商家承担；非质量问题换货，运费由买家承担。</li>
                            <li>换货商品将在收到退回商品后3个工作日内重新发出。</li>
                        </ul>
                    </div>

                    <!-- 退款说明 -->
                    <h5 class="help-section-title mt-4"><i class="bi bi-cash-stack me-2"></i>退款说明</h5>
                    <table class="table table-bordered help-table">
                        <thead>
                            <tr>
                                <th>退款情况</th>
                                <th>处理时间</th>
                                <th>退款方式</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>未发货取消订单</td>
                                <td>1-2个工作日</td>
                                <td>原路退回</td>
                            </tr>
                            <tr>
                                <td>已发货退货</td>
                                <td>收到商品后3-5个工作日</td>
                                <td>原路退回</td>
                            </tr>
                            <tr>
                                <td>质量问题退货</td>
                                <td>收到商品后1-3个工作日（优先处理）</td>
                                <td>原路退回</td>
                            </tr>
                        </tbody>
                    </table>

                    <!-- 联系客服 -->
                    <div class="help-contact-card mt-4">
                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <h5><i class="bi bi-headset me-2"></i>需要申请退换货？</h5>
                                <p class="mb-0 text-muted">请联系客服，我们将尽快为您处理。</p>
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

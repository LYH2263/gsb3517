<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/common/header.jsp"><jsp:param name="title" value="帮助中心"/></jsp:include>

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
                        <li><a href="${pageContext.request.contextPath}/page/help" class="active"><i class="bi bi-question-circle me-2"></i>帮助中心</a></li>
                        <li><a href="${pageContext.request.contextPath}/page/return-policy"><i class="bi bi-arrow-repeat me-2"></i>退换货政策</a></li>
                        <li><a href="${pageContext.request.contextPath}/page/delivery"><i class="bi bi-truck me-2"></i>配送说明</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- 主内容 -->
        <div class="col-lg-9">
            <div class="card help-content">
                <div class="card-body">
                    <h3 class="help-page-title"><i class="bi bi-question-circle me-2"></i>帮助中心</h3>
                    <p class="text-muted mb-4">在这里您可以找到常见问题的解答。如仍有疑问，请联系客服。</p>

                    <!-- 常见问题 -->
                    <div class="accordion" id="faqAccordion">
                        <!-- 账户相关 -->
                        <h5 class="help-section-title"><i class="bi bi-person-circle me-2"></i>账户相关</h5>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                                    如何注册账号？
                                </button>
                            </h2>
                            <div id="faq1" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <ol>
                                        <li>点击页面右上角的"注册"按钮。</li>
                                        <li>填写用户名、邮箱、手机号等基本信息。</li>
                                        <li>设置密码（至少6位字符）。</li>
                                        <li>点击"注册"按钮完成注册。</li>
                                    </ol>
                                    <p>注册成功后即可使用账号登录购物。</p>
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                                    忘记密码怎么办？
                                </button>
                            </h2>
                            <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <p>如果忘记密码，请联系客服进行密码重置：</p>
                                    <ul>
                                        <li>客服电话：<strong>400-888-8888</strong></li>
                                        <li>客服邮箱：<strong>service@shop.com</strong></li>
                                        <li>工作时间：周一至周日 9:00-21:00</li>
                                    </ul>
                                    <p>联系客服时请提供您的注册用户名和手机号码以便验证身份。</p>
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                                    如何修改个人信息？
                                </button>
                            </h2>
                            <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <p>登录后，点击右上角用户名，选择"个人中心"，即可修改以下信息：</p>
                                    <ul>
                                        <li>邮箱地址</li>
                                        <li>手机号码</li>
                                        <li>收货地址</li>
                                        <li>登录密码</li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <!-- 购物相关 -->
                        <h5 class="help-section-title mt-4"><i class="bi bi-cart3 me-2"></i>购物相关</h5>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq4">
                                    如何购买商品？
                                </button>
                            </h2>
                            <div id="faq4" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <ol>
                                        <li>浏览商品列表或使用搜索功能找到心仪的商品。</li>
                                        <li>进入商品详情页，选择数量后点击"加入购物车"。</li>
                                        <li>在购物车中确认商品和数量，点击"去结算"。</li>
                                        <li>填写收货地址等信息，确认订单后提交。</li>
                                    </ol>
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq5">
                                    如何使用筛选功能？
                                </button>
                            </h2>
                            <div id="faq5" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <p>在"全部商品"页面，您可以使用多种方式筛选商品：</p>
                                    <ul>
                                        <li><strong>分类筛选：</strong>点击顶部的分类标签（如手机数码、电脑办公等）。</li>
                                        <li><strong>价格区间：</strong>选择预设的价格范围，或输入自定义的最低/最高价。</li>
                                        <li><strong>排序方式：</strong>按销量、价格高低、最新上架等方式排序。</li>
                                        <li><strong>搜索：</strong>使用顶部搜索栏输入关键字搜索。</li>
                                    </ul>
                                    <p>所有筛选条件可以组合使用，帮助您更精准地找到需要的商品。</p>
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq6">
                                    购物车商品有数量限制吗？
                                </button>
                            </h2>
                            <div id="faq6" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <p>每种商品的购买数量取决于当前库存。如商品库存不足，系统会提示您调整数量。购物车中的商品没有数量上限，您可以添加多种不同的商品。</p>
                                </div>
                            </div>
                        </div>

                        <!-- 订单相关 -->
                        <h5 class="help-section-title mt-4"><i class="bi bi-bag-check me-2"></i>订单相关</h5>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq7">
                                    如何查看订单状态？
                                </button>
                            </h2>
                            <div id="faq7" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <p>登录后，点击右上角用户名 → "我的订单"，即可查看所有订单及其状态：</p>
                                    <ul>
                                        <li><span class="badge bg-warning text-dark">待付款</span> 订单已创建，等待支付</li>
                                        <li><span class="badge bg-info text-white">待发货</span> 已支付，等待商家发货</li>
                                        <li><span class="badge bg-primary">已发货</span> 商品已发出，正在配送中</li>
                                        <li><span class="badge bg-success">已完成</span> 交易完成</li>
                                        <li><span class="badge bg-secondary">已取消</span> 订单已取消</li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq8">
                                    如何取消订单？
                                </button>
                            </h2>
                            <div id="faq8" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                <div class="accordion-body">
                                    <p>在"我的订单"中，<strong>待付款</strong>状态的订单可以直接取消。已付款的订单如需取消，请联系客服处理。</p>
                                    <div class="alert alert-warning mt-2 mb-0">
                                        <i class="bi bi-exclamation-triangle me-2"></i>
                                        取消后的订单无法恢复，请谨慎操作。
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 联系客服 -->
                    <div class="help-contact-card mt-4">
                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <h5><i class="bi bi-headset me-2"></i>没有找到您要的答案？</h5>
                                <p class="mb-0 text-muted">请联系我们的客服团队，我们将竭诚为您服务。</p>
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

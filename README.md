# 优品商城（在线购物平台）

## 一、项目介绍

优品商城是一个基于 Java Web 技术栈开发的在线购物平台，覆盖用户端购物流程与管理后台运营流程。  
项目以 Servlet + JSP + JDBC 为核心，前端使用 Bootstrap 构建响应式页面，默认中文界面，支持本地 Docker 一键启动，便于开发、联调和演示。

---

## 二、项目功能

### 1) 用户端功能
- 用户注册、登录、退出登录
- 首页展示、商品列表、商品详情
- 商品分类筛选、价格区间筛选、排序
- 购物车增删改查
- 下单、订单列表、订单详情
- 帮助中心、退换货政策、配送说明

### 2) 管理后台功能
- 管理员登录与后台控制台
- 商品管理：新增、编辑、删除、上下架、图片上传
- 分类管理：新增、编辑、删除、前端筛选
- 订单管理：筛选、查看、状态处理
- 用户管理：筛选、查看、启用/禁用
- 控制台数据可视化（订单状态、分类分布、销量排行等）

---

## 三、技术细节

### 1) 前端
- HTML5 / CSS3 / JavaScript / jQuery
- Bootstrap 5 + Bootstrap Icons
- 响应式布局，兼容 Chrome / Safari

### 2) 后端
- JDK 21
- Servlet 6.0 / JSP / JSTL
- JDBC 直连 MySQL
- 分层结构：Controller / Service / DAO / Model

### 3) 数据库
- MySQL 8.0.42（容器运行）
- 初始化脚本：`sql/init.sql`
- 字符集：`utf8mb4`

### 4) 构建与运行
- Maven 打包 `war`
- Tomcat 10.1 运行
- Docker 多阶段构建（Maven 构建 + Tomcat 部署）

---

## 四、项目目录结构

```text
project/
├── Dockerfile                          # 多阶段镜像构建
├── docker-compose.yml                  # 本地编排（web + mysql）
├── pom.xml                             # Maven 构建配置
├── sql/
│   └── init.sql                        # 数据库初始化脚本
├── src/
│   └── main/
│       ├── java/com/shop/
│       │   ├── controller/             # Servlet 控制层
│       │   ├── service/                # 业务层
│       │   ├── dao/                    # 数据访问层
│       │   ├── model/                  # 实体模型
│       │   ├── filter/                 # 过滤器
│       │   ├── listener/               # 监听器
│       │   └── util/                   # 工具类
│       ├── resources/                  # 配置资源
│       └── webapp/
│           ├── assets/                 # 静态资源（css/js/images）
│           ├── common/                 # 公共 JSP 片段（header/footer）
│           ├── WEB-INF/views/          # JSP 页面（前台 + 后台）
│           └── index.jsp
└── target/                             # Maven 构建产物
```

---

## 五、项目部署

### 1) 环境要求
- Docker
- Docker Compose

### 2) 一键启动（本地开发）

在项目根目录执行：

```bash
docker compose up --build
```

启动后访问：
- 商城前台：`http://localhost:3000`
- 管理后台：`http://localhost:3000/admin/dashboard`
- MySQL 映射端口：`3307`

### 3) 常用命令

```bash
# 后台启动
docker compose up --build -d

# 停止并删除容器
docker compose down

# 停止并清理数据卷（谨慎）
docker compose down -v
```

### 4) 默认测试账号

| 角色 | 用户名 | 密码 |
|---|---|---|
| 管理员 | admin | admin123 |
| 普通用户 | testuser | 123456 |

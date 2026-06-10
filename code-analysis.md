# 代码分析报告

---

## 1. 未登录用户 AJAX 请求 `/cart/add` vs 浏览器直接访问 `/order/checkout`

### AJAX 请求 `/cart/add` 的结果

**返回：HTTP 401 + JSON `{"success":false,"message":"请先登录"}`**

代码路径：

1. 请求进入 `AuthFilter.doFilter()`（[AuthFilter.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/filter/AuthFilter.java#L27)）
2. 路径 `/cart/add` 不在 `PUBLIC_PATHS` 中，`isPublicPath()` 返回 `false`（第36行）
3. `session` 中无 `user`，`user == null` 且 `!isPublicPath(path)` 为 `true`（第53行）
4. 检查请求头 `X-Requested-With`，AJAX 请求该头值为 `"XMLHttpRequest"`（第55-56行）
5. 进入 AJAX 分支：设置 `Content-Type` 为 `application/json`，状态码设为 `401`，写入 JSON 错误信息后 `return`（第57-60行）
6. **请求不会到达 `CartServlet`**

### 浏览器直接访问 `/order/checkout` 的结果

**返回：HTTP 302 重定向到 `/user/login` 登录页**

代码路径：

1. 请求进入 `AuthFilter.doFilter()`（[AuthFilter.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/filter/AuthFilter.java#L27)）
2. 路径 `/order/checkout` 不在 `PUBLIC_PATHS` 中，`isPublicPath()` 返回 `false`（第36行）
3. `session` 中无 `user`，`user == null` 且 `!isPublicPath(path)` 为 `true`（第53行）
4. 检查请求头 `X-Requested-With`，普通浏览器请求不带此头，`xhr` 为 `null`（第55-56行）
5. 进入非 AJAX 分支：执行 `response.sendRedirect(contextPath + "/user/login")`（第62行），即 302 重定向到登录页
6. **请求不会到达 `OrderServlet`**

### 两者差异总结

| 维度 | AJAX `/cart/add` | 浏览器 `/order/checkout` |
|------|-----------------|------------------------|
| HTTP 状态码 | 401 (Unauthorized) | 302 (Found/Redirect) |
| 响应体 | JSON `{"success":false,"message":"请先登录"}` | 无（重定向） |
| 浏览器行为 | 前端 JS 可捕获 401 并处理 | 浏览器自动跳转到登录页 |
| 判断依据 | `X-Requested-With: XMLHttpRequest` 头 | 无该头 |
| 拦截位置 | 均在 `AuthFilter.doFilter()` 第53-63行 | 同左 |

---

## 2. POST `/order/create` 完整流程

### 2.1 校验阶段

依据：[OrderServlet.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/controller/OrderServlet.java#L89) `doPost()` 方法

1. **登录校验**（第92-96行）：从 `session` 获取 `user`，若为 `null` 返回 `{"success":false,"message":"请先登录"}`
2. **收货人校验**（第106-108行）：`receiver` 为 `null` 或空白，返回 `{"success":false,"message":"请填写收货人","field":"receiver"}`
3. **电话校验**（第110-112行）：`phone` 为 `null` 或空白，返回 `{"success":false,"message":"请填写联系电话","field":"phone"}`
4. **地址校验**（第114-116行）：`address` 为 `null` 或空白，返回 `{"success":false,"message":"请填写收货地址","field":"address"}`
5. **购物车非空校验**（第119-123行）：调用 `cartDao.findByUserId()` 查询购物车，若为空返回 `{"success":false,"message":"购物车为空"}`

### 2.2 订单明细的商品价格/名称来源

依据：[OrderServlet.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/controller/OrderServlet.java#L127) + [CartDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/CartDao.java#L12) `findByUserId()`

- 商品名称和价格**来自购物车查询时 JOIN products 表的实时数据**
- `CartDao.findByUserId()` 的 SQL（第14-15行）：`SELECT c.*, p.name as product_name, p.price as product_price ... FROM cart_items c JOIN products p ON c.product_id = p.id WHERE c.user_id = ? AND p.status = 1`
- 查询结果通过 `mapRow()`（第108-121行）将 `product_name`、`product_price` 映射到 `CartItem` 的 `productName`、`productPrice` 字段
- `OrderServlet` 第128-135行将 `CartItem` 的值复制到 `OrderItem`：
  - `oi.setProductName(ci.getProductName())` — 来自 products 表的 name 字段
  - `oi.setProductPrice(ci.getProductPrice())` — 来自 products 表的 price 字段
  - `oi.setProductImage(ci.getProductImage())` — 来自 products 表的 image 字段
  - `oi.setQuantity(ci.getQuantity())` — 来自 cart_items 表的 quantity 字段

> **注意**：价格取的是查询购物车那一瞬间的商品价格，而非下单时的最新价格。如果在查询购物车和执行 `createOrder` 之间商品价格发生了变化，订单中记录的仍是旧价格。

### 2.3 `createOrder` 事务里依次做的事

依据：[OrderDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/OrderDao.java#L13) `createOrder()` 方法

1. **获取连接并开启事务**（第16-17行）：`conn.setAutoCommit(false)`
2. **插入订单主记录**（第20-30行）：`INSERT INTO orders (order_no, user_id, total_amount, status, receiver, phone, address, remark) VALUES (...)`，状态固定为 `"PENDING"`
3. **获取自增主键**（第32-34行）：通过 `Statement.RETURN_GENERATED_KEYS` 获取新插入订单的 `id`
4. **批量插入订单明细**（第37-48行）：`INSERT INTO order_items (order_id, product_id, product_name, product_price, product_image, quantity) VALUES (...)`，使用 `addBatch()` + `executeBatch()` 批量执行
5. **批量更新商品库存和销量**（第51-60行）：`UPDATE products SET stock = stock - ?, sales = sales + ? WHERE id = ? AND stock >= ?`，使用 `addBatch()` + `executeBatch()` 批量执行
6. **提交事务**（第62行）：`conn.commit()`
7. **异常时回滚**（第64-68行）：`catch` 块中执行 `conn.rollback()`，然后抛出 `RuntimeException`

### 2.4 购物车变化

依据：[OrderServlet.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/controller/OrderServlet.java#L149)

- `createOrder` 成功后，调用 `cartDao.clearByUserId(user.getId())`
- [CartDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/CartDao.java#L83) `clearByUserId()` 执行 `DELETE FROM cart_items WHERE user_id = ?`
- **购物车被完全清空**，所有商品项删除

> **注意**：`clearByUserId` 不在 `createOrder` 的事务内，它使用的是新的数据库连接。如果清空购物车失败，订单已经创建成功但购物车未被清空，用户可能重复下单。

---

## 3. 库存不足（库存2件，下单5件）时的问题

### `UPDATE ... WHERE stock >= ?` 会怎样？

依据：[OrderDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/OrderDao.java#L51)

SQL：`UPDATE products SET stock = stock - ?, sales = sales + ? WHERE id = ? AND stock >= ?`

当库存=2、购买数量=5时：
- `WHERE stock >= 5` 条件不满足（2 < 5）
- **该 UPDATE 语句影响 0 行**，即库存不会被扣减，销量也不会增加

### 代码检查影响行数了吗？

**没有。** 第60行 `stockPs.executeBatch()` 的返回值（`int[]` 数组，每个元素表示对应 SQL 影响的行数）被完全忽略。代码直接执行 `conn.commit()` 提交事务。

### 会导致什么后果？

1. **订单创建成功但库存未扣减**：`orders` 表和 `order_items` 表的记录已插入，但 `products` 表的 `stock` 和 `sales` 未更新
2. **超卖防护形同虚设**：虽然 SQL 层面通过 `WHERE stock >= ?` 阻止了库存变为负数，但由于未检查影响行数，事务照常提交，用户成功下单了库存不足的商品
3. **数据不一致**：订单记录显示购买了5件，但实际库存只扣了0件，库存数据与订单数据矛盾

### 怎么修？

在 `executeBatch()` 之后检查返回的批次更新计数：

```java
int[] stockResults = stockPs.executeBatch();
for (int i = 0; i < stockResults.length; i++) {
    if (stockResults[i] == 0) {
        throw new RuntimeException("商品库存不足: " + items.get(i).getProductName());
    }
}
```

抛出异常后会被 `catch` 块捕获，执行 `conn.rollback()` 回滚整个事务（订单主记录和明细也会被回滚），确保数据一致性。

---

## 4. `/cart/add` 和 `/cart/update` 对 `quantity` 的校验差异

### 校验差异

依据：[CartServlet.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/controller/CartServlet.java) `doPost()` 方法

| 维度 | `/cart/add`（第53-69行） | `/cart/update`（第71-83行） |
|------|------------------------|---------------------------|
| 获取 quantity | `getInt(req, "quantity", 1)` — 解析失败默认为1 | `getInt(req, "quantity", 1)` — 解析失败默认为1 |
| 范围校验 | **无** — 不检查 quantity 是否 ≥ 1 | **有** — `if (id == null \|\| quantity < 1)` 拒绝 < 1 的值 |
| 负数处理 | 允许负数通过 | 拒绝负数，返回 `{"success":false,"message":"参数错误"}` |

### 传入负数与 `ON DUPLICATE KEY UPDATE` 的交互

依据：[CartDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/CartDao.java#L44) `insert()` 方法

SQL：`INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE quantity = quantity + ?`

**场景1：该商品首次加入购物车（INSERT 生效）**
- 传入 `quantity = -5`
- 执行 `INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, -5)`
- **结果：购物车中该商品数量为 -5**，直接出现负数

**场景2：该商品已在购物车中（ON DUPLICATE KEY UPDATE 生效）**
- 假设当前数量为 3，传入 `quantity = -5`
- 执行 `UPDATE quantity = quantity + (-5)`，即 `3 + (-5) = -2`
- **结果：购物车数量变为 -2**

### 安全隐患

1. `/cart/add` 缺少 `quantity >= 1` 的校验，攻击者可以传入负数
2. 配合 `ON DUPLICATE KEY UPDATE quantity = quantity + ?`，负数可以不断累加，使购物车数量变为负数甚至极小值
3. 负数数量进入下单流程后，`createOrder` 中的 `stock = stock - (-5)` 实际上是**增加库存**，`sales = sales + (-5)` 实际上是**减少销量**，造成数据篡改

### 修复建议

在 `/cart/add` 分支中增加与 `/cart/update` 一致的校验：

```java
case "/add" -> {
    Long productId = getLong(req, "productId");
    int quantity = getInt(req, "quantity", 1);
    if (productId == null || quantity < 1) {
        out.print("{\"success\":false,\"message\":\"参数错误\"}");
        return;
    }
    // ...
}
```

---

## 5. `createOrder` 中 PreparedStatement 的关闭问题

### 三个 PreparedStatement 的关闭情况

依据：[OrderDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/OrderDao.java#L13) `createOrder()` 方法

| 对象 | 声明位置 | 是否关闭 | 关闭方式 |
|------|---------|---------|---------|
| `ps`（订单插入） | 第21行 | **未关闭** | 无 try-with-resources，无 close() 调用 |
| `itemPs`（明细插入） | 第38行 | **未关闭** | 无 try-with-resources，无 close() 调用 |
| `stockPs`（库存更新） | 第52行 | **未关闭** | 无 try-with-resources，无 close() 调用 |
| `keys`（ResultSet） | 第32行 | **未关闭** | 无 try-with-resources，无 close() 调用 |
| `conn`（连接） | 第14行 | **已关闭** | finally 块中 `conn.close()`（第71行） |

### 与项目其他方法的对比

依据：[OrderDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/OrderDao.java) 和 [CartDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/CartDao.java)

项目中其他所有 DAO 方法都使用了 **try-with-resources** 语法：

```java
// CartDao.findByUserId() — 典型的 try-with-resources 用法
try (Connection conn = DBUtil.getConnection();
     PreparedStatement ps = conn.prepareStatement(sql)) {
    ps.setLong(1, userId);
    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) list.add(mapRow(rs));
    }
} catch (SQLException e) { ... }
```

而 `createOrder()` 使用了传统的 try-catch-finally 手动管理，只关闭了 `Connection`，遗漏了 `PreparedStatement` 和 `ResultSet`。

### 隐患分析

1. **资源泄漏**：`PreparedStatement` 和 `ResultSet` 未关闭，每个未关闭的对象都持有数据库资源（游标、句柄等），直到 GC 回收才会释放
2. **连接池耗尽风险**：虽然 `Connection` 在 finally 中关闭了，但未关闭的 `PreparedStatement` 可能阻止连接被正确回收至连接池。在 `conn.close()` 时，如果连接池实现为"归还连接"而非"关闭连接"，则未关闭的 statement 可能导致连接池中的连接处于脏状态
3. **数据库游标泄漏**：`ResultSet`（`keys`）未关闭，可能占用数据库服务端的游标资源，高并发时可能触发 `ORA-01000: maximum open cursors exceeded`（Oracle）或类似错误
4. **不可预测的关闭时机**：依赖 GC 的 `finalize()` 来关闭资源，时机不确定，在高负载下资源积累速度远快于 GC 回收速度

### 修复建议

将 `createOrder()` 改为 try-with-resources 风格，确保所有 `PreparedStatement` 和 `ResultSet` 都能自动关闭：

```java
public boolean createOrder(Order order, List<OrderItem> items) {
    try (Connection conn = DBUtil.getConnection()) {
        conn.setAutoCommit(false);
        try {
            try (PreparedStatement ps = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, order.getOrderNo());
                // ... 设置参数 ...
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (!keys.next()) throw new SQLException("创建订单失败");
                    long orderId = keys.getLong(1);
                    // ... 后续操作 ...
                }
            }
            // itemPs 和 stockPs 同理用 try-with-resources 包裹
            conn.commit();
            return true;
        } catch (SQLException e) {
            conn.rollback();
            throw new RuntimeException("创建订单失败", e);
        }
    } catch (SQLException e) {
        throw new RuntimeException("创建订单失败", e);
    }
}
```

---

## 总结

| 问题 | 核心缺陷 | 严重程度 |
|------|---------|---------|
| Q1 | AuthFilter 对 AJAX 和非 AJAX 请求分别返回 401 JSON 和 302 重定向，逻辑正确 | 无缺陷（设计如此） |
| Q2 | 商品价格取自查询购物车时的快照，非下单时实时价格；清空购物车不在事务内 | 中 |
| Q3 | `executeBatch()` 返回值未检查，库存不足时订单仍创建成功 | 高 |
| Q4 | `/cart/add` 缺少 `quantity >= 1` 校验，配合 `ON DUPLICATE KEY UPDATE` 可导致负数数量 | 高 |
| Q5 | 三个 `PreparedStatement` 和一个 `ResultSet` 未关闭，存在资源泄漏 | 高 |

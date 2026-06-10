# 代码分析报告

基于对 `AuthFilter`、`CartServlet`、`OrderServlet`、`CartDao`、`OrderDao` 五个文件的分析。

---

## 问题1：未登录用户 AJAX 请求 `/cart/add` vs 浏览器访问 `/order/checkout`

### 结果差异

| 请求方式 | 响应结果 | HTTP状态码 |
|---------|---------|-----------|
| AJAX 请求 `/cart/add` | 返回 JSON：`{"success":false,"message":"请先登录"}` | 401 Unauthorized |
| 浏览器直接访问 `/order/checkout` | 302 重定向到 `/user/login` 登录页面 | 302 Found |

### 代码路径说明

**依据文件**：[AuthFilter.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/filter/AuthFilter.java)

1. 两个请求都会首先经过 [AuthFilter.doFilter()](file:///d:/Agsb/gsb3517/src/main/java/com/shop/filter/AuthFilter.java#L27-L67)：
   - `/cart/add` 和 `/order/checkout` 都不在 `PUBLIC_PATHS` 列表中
   - `user == null` 未登录条件成立（第53行）

2. **AJAX 请求 `/cart/add` 的处理路径**（第55-60行）：
   - 检查请求头 `X-Requested-With` 是否为 `XMLHttpRequest`（AJAX特有标识）
   - 设置响应类型为 `application/json;charset=UTF-8`
   - 设置 HTTP 状态码为 `SC_UNAUTHORIZED` (401)
   - 直接输出 JSON 错误信息后返回
   - **不会继续执行到 CartServlet**

3. **浏览器访问 `/order/checkout` 的处理路径**（第62行）：
   - 没有 `X-Requested-With: XMLHttpRequest` 头
   - 执行 `response.sendRedirect()` 重定向到登录页
   - **不会继续执行到 OrderServlet**

> 注意：虽然 CartServlet.doPost()（第45-49行）和 OrderServlet.doGet()（第30-34行）内部也有用户登录检查，但由于 AuthFilter 是全局过滤器且优先级更高，这两处代码在未登录场景下实际不会被执行。

---

## 问题2：POST `/order/create` 完整下单流程

### 依据文件**：[OrderServlet.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/controller/OrderServlet.java)、[OrderDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/OrderDao.java)、[CartDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/CartDao.java)

### 1. 校验步骤（[OrderServlet.doPost() -> /create](file:///d:/Agsb/gsb3517/src/main/java/com/shop/controller/OrderServlet.java#L100-L154)）

按顺序进行以下校验，任一不通过即返回失败：
- 用户登录状态校验（第92-96行，AuthFilter 已校验，此处再次检查）
- 收货人 `receiver` 非空校验（第106-109行）
- 联系电话 `phone` 非空校验（第110-113行）
- 收货地址 `address` 非空校验（第114-117行）
- 购物车非空校验（第119-123行）：调用 `cartDao.findByUserId()` 查询购物车，空则返回"购物车为空"

### 2. 订单明细的商品价格/名称来源（[CartDao.findByUserId()](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/CartDao.java#L12-L26)）

订单明细的商品信息**直接从购物车数据中获取**，而不是重新查商品表：
- SQL 查询 JOIN 了 `products` 表：
  ```sql
  SELECT c.*, p.name as product_name, p.price as product_price, p.image as product_image, p.stock as product_stock 
  FROM cart_items c JOIN products p ON c.product_id = p.id 
  WHERE c.user_id = ? AND p.status = 1
  ```
- 在 OrderServlet 第127-136行遍历 `CartItem` 时，将 `ci.getProductName()`、`ci.getProductPrice()`、`ci.getProductImage()` 直接复制到 `OrderItem` 中
- 订单总金额也是通过购物车项的 `getSubtotal()` 累加得到

### 3. `createOrder` 事务内操作顺序（[OrderDao.createOrder()](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/OrderDao.java#L13-L74)）

```
1. 获取数据库连接，关闭自动提交（开启事务）
   ↓
2. 插入订单主表记录（orders表）
   - 设置订单号、用户ID、总金额、状态(PENDING)、收货信息等
   - ps.executeUpdate()
   ↓
3. 获取自增生成的订单ID
   - ResultSet keys = ps.getGeneratedKeys()
   ↓
4. 批量插入订单明细（order_items表）
   - 循环设置每个 OrderItem 的参数，addBatch()
   - itemPs.executeBatch() 批量执行
   ↓
5. 批量更新商品库存和销量（products表）
   - UPDATE products SET stock = stock - ?, sales = sales + ? WHERE id = ? AND stock >= ?
   - 循环设置参数，addBatch()
   - stockPs.executeBatch() 批量执行
   ↓
6. conn.commit() 提交事务
   ↓
7. 异常时 rollback() 回滚事务
```

### 4. 购物车变化

- 在 `orderDao.createOrder()` **成功返回后**（第149行）
- 调用 `cartDao.clearByUserId(user.getId())`
- 执行 SQL：`DELETE FROM cart_items WHERE user_id = ?`
- **用户购物车中所有商品被全部清空**

---

## 问题3：库存不足（库存2件买5件）问题

### 依据文件**：[OrderDao.createOrder()](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/OrderDao.java#L50-L60)

### SQL 语句行为

第51行的 UPDATE 语句：
```sql
UPDATE products SET stock = stock - ?, sales = sales + ? WHERE id = ? AND stock >= ?
```

当库存只有2件却买5件时：
- WHERE 条件 `stock >= 5` 不成立
- **该条 UPDATE 语句影响行数为 0**
- 但不会抛出 `SQLException`，SQL 正常执行完成，只是没有行被更新

### 代码是否检查影响行数？

**没有检查！**

第60行 `stockPs.executeBatch()` 返回值是 `int[]` 数组（每个元素代表对应批处理语句的影响行数），但代码：
- 没有接收返回值
- 没有遍历检查每个更新是否成功
- 直接继续执行 `conn.commit()` 提交事务

### 导致的后果

这是一个**严重的数据一致性 Bug**：

1. ✅ 订单主表 `orders` 记录插入成功
2. ✅ 订单明细表 `order_items` 记录插入成功（显示购买了5件）
3. ❌ 商品表 `products` 库存未扣减、销量未增加
4. ✅ 事务提交成功
5. ✅ 购物车被清空
6. ✅ 前端显示"下单成功"

最终结果：用户下单成功，订单显示买了5件，但数据库商品库存还是2件——**超卖成功，账实不符**。

### 修复方案

在第60行后增加批量执行结果检查：

```java
int[] stockResults = stockPs.executeBatch();
for (int result : stockResults) {
    if (result != 1) {  // 每条应该影响且仅影响1行
        throw new SQLException("库存不足，更新失败");
    }
}
```

如果有任何一条更新失败（返回0或Statement.EXECUTE_FAILED），抛出异常触发事务回滚，整个下单失败。

---

## 问题4：`/cart/add` 与 `/cart/update` 的 quantity 校验差异

### 依据文件**：[CartServlet.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/controller/CartServlet.java)、[CartDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/CartDao.java)

### 校验差异对比

| 接口 | quantity 校验 | 代码位置 |
|-----|-------------|---------|
| `/cart/add` | **无校验**。通过 `getInt(req, "quantity", 1)` 获取，解析失败默认值1，但解析成功后没有判断是否 ≥ 1 | [CartServlet.java 第55行](file:///d:/Agsb/gsb3517/src/main/java/com/shop/controller/CartServlet.java#L55) |
| `/cart/update` | **有校验**：`if (id == null || quantity < 1)`，明确要求 quantity 必须 ≥ 1，否则返回参数错误 | [CartServlet.java 第74行](file:///d:/Agsb/gsb3517/src/main/java/com/shop/controller/CartServlet.java#L74) |

### 传入负数的后果

[CartDao.insert()](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/CartDao.java#L44-L56) 的 SQL：
```sql
INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?) 
ON DUPLICATE KEY UPDATE quantity = quantity + ?
```
注意第4个参数也是 `item.getQuantity()`（第51行），即插入和更新用的是同一个值。

**分两种情况**：

1. **购物车中该商品尚不存在**：
   - 执行 INSERT 分支
   - quantity 被设置为传入的负数（如 -5）
   - 购物车中出现数量为负数的商品项
   - 计算 subtotal = price × (-5) 会是负数，总金额被异常扣减

2. **购物车中已有该商品**：
   - 执行 ON DUPLICATE KEY UPDATE 分支
   - `quantity = quantity + (负数)`，相当于在原有数量上做减法
   - 原有数量够减：数量减少（相当于"加负数"等于减）
   - 原有数量不够减：数量变为 0 或负数，同样出现异常数据

**这是一个业务逻辑漏洞**：恶意用户可以通过传入负数来减少购物车商品数量，甚至制造负数金额。

---

## 问题5：`createOrder` 中 PreparedStatement 资源关闭问题

### 依据文件**：[OrderDao.java](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/OrderDao.java)

### 是否被关闭？

**没有被关闭！**

在 [createOrder()](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/OrderDao.java#L13-L74) 方法中创建了：
1. `ps` (第21行) - 插入订单的 PreparedStatement
2. `keys` (第32行) - 获取自增ID的 ResultSet
3. `itemPs` (第38行) - 批量插入明细的 PreparedStatement
4. `stockPs` (第52行) - 批量更新库存的 PreparedStatement

这四个 JDBC 资源：
- 没有在 finally 块中关闭
- 也没有使用 try-with-resources 语法
- 只有 Connection 在 finally 中被关闭了（第71行）

### 与项目中其他方法的对比

项目中其他 DAO 方法**都正确使用了 try-with-resources**，例如：
- [CartDao.findByUserId()](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/CartDao.java#L16-L21)：Connection、PreparedStatement、ResultSet 全部在 try-with-resources 中声明
- [CartDao.insert()](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/CartDao.java#L46-L52)：Connection、PreparedStatement 自动关闭
- [OrderDao.findByUserId()](file:///d:/Agsb/gsb3517/src/main/java/com/shop/dao/OrderDao.java#L79-L86)：同样使用 try-with-resources

try-with-resources 会在代码块退出时（无论正常还是异常）自动调用 `close()` 方法，确保资源释放。

### 存在的隐患

1. **JDBC 资源泄漏**：
   - PreparedStatement 和 ResultSet 没有被关闭
   - 这些对象在数据库端会持有游标、句柄等资源
   - 如果数据库连接池不彻底清理这些资源，会导致数据库侧资源泄漏

2. **连接池耗尽风险**：
   - 虽然 Connection 在 finally 中关闭归还到连接池
   - 但未关闭的 Statement/ResultSet 可能导致连接处于"半关闭"状态
   - 高并发下单场景下，可能导致连接池资源耗尽、应用无响应

3. **游标泄漏**：
   - ResultSet `keys` 未关闭，可能导致数据库游标泄漏
   - 某些数据库（如 Oracle）对游标数量有严格限制，超出会报错

4. **异常场景下更严重**：
   - 如果在第30行 `ps.executeUpdate()` 就抛出异常
   - itemPs 和 stockPs 可能还没创建，但 ps 和 keys 也不会被关闭
   - 每次失败请求都泄漏资源

### 修复建议

将 createOrder 改写为 try-with-resources 嵌套结构：

```java
public boolean createOrder(Order order, List<OrderItem> items) {
    Connection conn = null;
    try {
        conn = DBUtil.getConnection();
        conn.setAutoCommit(false);

        String orderSql = "INSERT INTO orders ...";
        try (PreparedStatement ps = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
            // 设置参数并执行
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                // 获取 orderId
            }
        }

        String itemSql = "INSERT INTO order_items ...";
        try (PreparedStatement itemPs = conn.prepareStatement(itemSql)) {
            // 批量插入
            itemPs.executeBatch();
        }

        String stockSql = "UPDATE products ...";
        try (PreparedStatement stockPs = conn.prepareStatement(stockSql)) {
            // 批量更新并检查结果
            int[] results = stockPs.executeBatch();
            // 检查每个结果...
        }

        conn.commit();
        return true;
    } catch (SQLException e) {
        // rollback...
        throw new RuntimeException("创建订单失败", e);
    } finally {
        // 关闭 connection...
    }
}
```

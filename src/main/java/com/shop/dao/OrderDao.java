package com.shop.dao;

import com.shop.model.Order;
import com.shop.model.OrderItem;
import com.shop.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDao {

    public boolean createOrder(Order order, List<OrderItem> items) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 插入订单
            String orderSql = "INSERT INTO orders (order_no, user_id, total_amount, status, receiver, phone, address, remark) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, order.getOrderNo());
            ps.setLong(2, order.getUserId());
            ps.setBigDecimal(3, order.getTotalAmount());
            ps.setString(4, "PENDING");
            ps.setString(5, order.getReceiver());
            ps.setString(6, order.getPhone());
            ps.setString(7, order.getAddress());
            ps.setString(8, order.getRemark());
            ps.executeUpdate();

            ResultSet keys = ps.getGeneratedKeys();
            if (!keys.next()) throw new SQLException("创建订单失败");
            long orderId = keys.getLong(1);

            // 插入订单明细
            String itemSql = "INSERT INTO order_items (order_id, product_id, product_name, product_price, product_image, quantity) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement itemPs = conn.prepareStatement(itemSql);
            for (OrderItem item : items) {
                itemPs.setLong(1, orderId);
                itemPs.setLong(2, item.getProductId());
                itemPs.setString(3, item.getProductName());
                itemPs.setBigDecimal(4, item.getProductPrice());
                itemPs.setString(5, item.getProductImage());
                itemPs.setInt(6, item.getQuantity());
                itemPs.addBatch();
            }
            itemPs.executeBatch();

            // 更新商品库存和销量
            String stockSql = "UPDATE products SET stock = stock - ?, sales = sales + ? WHERE id = ? AND stock >= ?";
            PreparedStatement stockPs = conn.prepareStatement(stockSql);
            for (OrderItem item : items) {
                stockPs.setInt(1, item.getQuantity());
                stockPs.setInt(2, item.getQuantity());
                stockPs.setLong(3, item.getProductId());
                stockPs.setInt(4, item.getQuantity());
                stockPs.addBatch();
            }
            stockPs.executeBatch();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignored) {}
            }
            throw new RuntimeException("创建订单失败", e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ignored) {}
            }
        }
    }

    public List<Order> findByUserId(Long userId, int page, int pageSize) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, pageSize);
            ps.setInt(3, (page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询订单列表失败", e);
        }
        return list;
    }

    public List<Order> findAll(int page, int pageSize) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.username FROM orders o LEFT JOIN users u ON o.user_id = u.id ORDER BY o.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pageSize);
            ps.setInt(2, (page - 1) * pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRow(rs);
                    try { order.setUsername(rs.getString("username")); } catch (SQLException ignored) {}
                    list.add(order);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询所有订单失败", e);
        }
        return list;
    }

    public Order findById(Long id) {
        String sql = "SELECT o.*, u.username FROM orders o LEFT JOIN users u ON o.user_id = u.id WHERE o.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = mapRow(rs);
                    try { order.setUsername(rs.getString("username")); } catch (SQLException ignored) {}
                    order.setItems(findItemsByOrderId(id));
                    return order;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询订单详情失败", e);
        }
        return null;
    }

    public Order findByOrderNo(String orderNo) {
        String sql = "SELECT * FROM orders WHERE order_no = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = mapRow(rs);
                    order.setItems(findItemsByOrderId(order.getId()));
                    return order;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询订单详情失败", e);
        }
        return null;
    }

    public List<OrderItem> findItemsByOrderId(Long orderId) {
        List<OrderItem> list = new ArrayList<>();
        String sql = "SELECT * FROM order_items WHERE order_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setId(rs.getLong("id"));
                    item.setOrderId(rs.getLong("order_id"));
                    item.setProductId(rs.getLong("product_id"));
                    item.setProductName(rs.getString("product_name"));
                    item.setProductPrice(rs.getBigDecimal("product_price"));
                    item.setProductImage(rs.getString("product_image"));
                    item.setQuantity(rs.getInt("quantity"));
                    list.add(item);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询订单明细失败", e);
        }
        return list;
    }

    public boolean updateStatus(Long id, String status) {
        String sql = "UPDATE orders SET status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("更新订单状态失败", e);
        }
    }

    public int countByUserId(Long userId) {
        String sql = "SELECT COUNT(*) FROM orders WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("统计订单数失败", e);
        }
        return 0;
    }

    public int countAll() {
        return countAllFiltered(null, null);
    }

    /** 管理后台：带筛选的订单列表 */
    public List<Order> findAllFiltered(String status, String keyword, int page, int pageSize) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT o.*, u.username FROM orders o LEFT JOIN users u ON o.user_id = u.id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            sql.append(" AND o.status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (o.order_no LIKE ? OR u.username LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        sql.append(" ORDER BY o.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize); params.add((page - 1) * pageSize);
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof String) ps.setString(i + 1, (String) v);
                else if (v instanceof Integer) ps.setInt(i + 1, (Integer) v);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRow(rs);
                    try { order.setUsername(rs.getString("username")); } catch (SQLException ignored) {}
                    list.add(order);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询订单失败", e);
        }
        return list;
    }

    public int countAllFiltered(String status, String keyword) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM orders o LEFT JOIN users u ON o.user_id = u.id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isEmpty()) {
            sql.append(" AND o.status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (o.order_no LIKE ? OR u.username LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, (String) params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("统计订单数失败", e);
        }
        return 0;
    }

    /** 按状态统计订单数 */
    public java.util.Map<String, Integer> countByStatus() {
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        map.put("PENDING", 0);
        map.put("PAID", 0);
        map.put("SHIPPED", 0);
        map.put("COMPLETED", 0);
        map.put("CANCELLED", 0);
        String sql = "SELECT status, COUNT(*) as cnt FROM orders GROUP BY status";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("status"), rs.getInt("cnt"));
            }
        } catch (SQLException e) {
            throw new RuntimeException("统计订单状态失败", e);
        }
        return map;
    }

    /** 统计总销售额 */
    public java.math.BigDecimal totalRevenue() {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE status NOT IN ('CANCELLED')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getBigDecimal(1);
        } catch (SQLException e) {
            throw new RuntimeException("统计销售额失败", e);
        }
        return java.math.BigDecimal.ZERO;
    }

    /** 最近N条订单 */
    public List<Order> findRecent(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.username FROM orders o LEFT JOIN users u ON o.user_id = u.id ORDER BY o.created_at DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRow(rs);
                    try { order.setUsername(rs.getString("username")); } catch (SQLException ignored) {}
                    list.add(order);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询最近订单失败", e);
        }
        return list;
    }

    private Order mapRow(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setId(rs.getLong("id"));
        order.setOrderNo(rs.getString("order_no"));
        order.setUserId(rs.getLong("user_id"));
        order.setTotalAmount(rs.getBigDecimal("total_amount"));
        order.setStatus(rs.getString("status"));
        order.setReceiver(rs.getString("receiver"));
        order.setPhone(rs.getString("phone"));
        order.setAddress(rs.getString("address"));
        order.setRemark(rs.getString("remark"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) order.setCreatedAt(ts.toLocalDateTime());
        ts = rs.getTimestamp("updated_at");
        if (ts != null) order.setUpdatedAt(ts.toLocalDateTime());
        return order;
    }
}

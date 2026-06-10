package com.shop.dao;

import com.shop.model.Product;
import com.shop.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDao {

    public List<Product> findAll(int page, int pageSize) {
        return findFiltered(null, null, null, null, null, page, pageSize);
    }

    public List<Product> findByCategory(Long categoryId, int page, int pageSize) {
        return findFiltered(categoryId, null, null, null, null, page, pageSize);
    }

    public List<Product> search(String keyword, int page, int pageSize) {
        return findFiltered(null, keyword, null, null, "sales_desc", page, pageSize);
    }

    /**
     * 通用筛选查询：支持分类、关键字、价格区间、排序
     */
    public List<Product> findFiltered(Long categoryId, String keyword,
                                       java.math.BigDecimal minPrice, java.math.BigDecimal maxPrice,
                                       String sort, int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, c.name as category_name FROM products p " +
            "LEFT JOIN categories c ON p.category_id = c.id WHERE p.status = 1");
        List<Object> params = new ArrayList<>();

        if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.description LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (minPrice != null) {
            sql.append(" AND p.price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
        }

        // 排序
        sql.append(switch (sort != null ? sort : "default") {
            case "price_asc"  -> " ORDER BY p.price ASC";
            case "price_desc" -> " ORDER BY p.price DESC";
            case "sales_desc" -> " ORDER BY p.sales DESC";
            case "newest"     -> " ORDER BY p.created_at DESC";
            default           -> " ORDER BY p.created_at DESC";
        });

        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof Long) ps.setLong(i + 1, (Long) v);
                else if (v instanceof String) ps.setString(i + 1, (String) v);
                else if (v instanceof java.math.BigDecimal) ps.setBigDecimal(i + 1, (java.math.BigDecimal) v);
                else if (v instanceof Integer) ps.setInt(i + 1, (Integer) v);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询商品列表失败", e);
        }
        return list;
    }

    /**
     * 通用计数：支持分类、关键字、价格区间
     */
    public int countFiltered(Long categoryId, String keyword,
                              java.math.BigDecimal minPrice, java.math.BigDecimal maxPrice) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products p WHERE p.status = 1");
        List<Object> params = new ArrayList<>();

        if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.description LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (minPrice != null) {
            sql.append(" AND p.price >= ?");
            params.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND p.price <= ?");
            params.add(maxPrice);
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof Long) ps.setLong(i + 1, (Long) v);
                else if (v instanceof String) ps.setString(i + 1, (String) v);
                else if (v instanceof java.math.BigDecimal) ps.setBigDecimal(i + 1, (java.math.BigDecimal) v);
                else if (v instanceof Integer) ps.setInt(i + 1, (Integer) v);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("统计商品数失败", e);
        }
        return 0;
    }

    public int countSearch(String keyword) {
        return countFiltered(null, keyword, null, null);
    }

    public List<Product> findHot(int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.status = 1 ORDER BY p.sales DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询热门商品失败", e);
        }
        return list;
    }

    public List<Product> findNew(int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.status = 1 ORDER BY p.created_at DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询新品失败", e);
        }
        return list;
    }

    public Product findById(Long id) {
        String sql = "SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询商品详情失败", e);
        }
        return null;
    }

    public boolean insert(Product product) {
        String sql = "INSERT INTO products (name, description, price, stock, category_id, image, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getDescription());
            ps.setBigDecimal(3, product.getPrice());
            ps.setInt(4, product.getStock());
            ps.setLong(5, product.getCategoryId());
            ps.setString(6, product.getImage());
            ps.setInt(7, product.getStatus() != null ? product.getStatus() : 1);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("添加商品失败", e);
        }
    }

    public boolean update(Product product) {
        String sql = "UPDATE products SET name=?, description=?, price=?, stock=?, category_id=?, image=?, status=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, product.getName());
            ps.setString(2, product.getDescription());
            ps.setBigDecimal(3, product.getPrice());
            ps.setInt(4, product.getStock());
            ps.setLong(5, product.getCategoryId());
            ps.setString(6, product.getImage());
            ps.setInt(7, product.getStatus());
            ps.setLong(8, product.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("更新商品失败", e);
        }
    }

    public boolean delete(Long id) {
        String sql = "DELETE FROM products WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("删除商品失败", e);
        }
    }

    /** 管理后台：带筛选的商品列表（不限status） */
    public List<Product> findAllAdmin(String keyword, Long categoryId, Integer status, int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.description LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }
        if (status != null) {
            sql.append(" AND p.status = ?");
            params.add(status);
        }
        sql.append(" ORDER BY p.id DESC LIMIT ? OFFSET ?");
        params.add(pageSize); params.add((page - 1) * pageSize);
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof Long) ps.setLong(i + 1, (Long) v);
                else if (v instanceof String) ps.setString(i + 1, (String) v);
                else if (v instanceof Integer) ps.setInt(i + 1, (Integer) v);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询商品失败", e);
        }
        return list;
    }

    public int countAdmin(String keyword, Long categoryId, Integer status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products p WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.name LIKE ? OR p.description LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw); params.add(kw);
        }
        if (categoryId != null) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }
        if (status != null) {
            sql.append(" AND p.status = ?");
            params.add(status);
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object v = params.get(i);
                if (v instanceof Long) ps.setLong(i + 1, (Long) v);
                else if (v instanceof String) ps.setString(i + 1, (String) v);
                else if (v instanceof Integer) ps.setInt(i + 1, (Integer) v);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("统计商品数失败", e);
        }
        return 0;
    }

    public boolean updateStock(Long id, int quantity) {
        String sql = "UPDATE products SET stock = stock - ?, sales = sales + ? WHERE id = ? AND stock >= ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, quantity);
            ps.setLong(3, id);
            ps.setInt(4, quantity);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("更新库存失败", e);
        }
    }

    public int count() {
        String sql = "SELECT COUNT(*) FROM products";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            throw new RuntimeException("统计商品数失败", e);
        }
        return 0;
    }

    public int countByCategory(Long categoryId) {
        String sql = "SELECT COUNT(*) FROM products WHERE category_id = ? AND status = 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("统计分类商品数失败", e);
        }
        return 0;
    }

    /** 各分类商品数量统计 */
    public java.util.List<java.util.Map<String, Object>> countGroupByCategory() {
        java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT c.name, COUNT(p.id) as cnt FROM categories c LEFT JOIN products p ON c.id = p.category_id AND p.status = 1 GROUP BY c.id, c.name ORDER BY cnt DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> m = new java.util.LinkedHashMap<>();
                m.put("name", rs.getString("name"));
                m.put("count", rs.getInt("cnt"));
                list.add(m);
            }
        } catch (SQLException e) {
            throw new RuntimeException("统计分类商品数失败", e);
        }
        return list;
    }

    /** 销量前N商品 */
    public List<Product> findTopSelling(int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.status = 1 ORDER BY p.sales DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询热销商品失败", e);
        }
        return list;
    }

    /** 库存不足商品(stock < threshold) */
    public List<Product> findLowStock(int threshold) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, c.name as category_name FROM products p LEFT JOIN categories c ON p.category_id = c.id WHERE p.status = 1 AND p.stock < ? ORDER BY p.stock ASC LIMIT 10";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("查询低库存商品失败", e);
        }
        return list;
    }

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getLong("id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getBigDecimal("price"));
        p.setStock(rs.getInt("stock"));
        p.setCategoryId(rs.getLong("category_id"));
        try {
            p.setCategoryName(rs.getString("category_name"));
        } catch (SQLException ignored) {}
        p.setImage(rs.getString("image"));
        p.setStatus(rs.getInt("status"));
        p.setSales(rs.getInt("sales"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) p.setCreatedAt(ts.toLocalDateTime());
        ts = rs.getTimestamp("updated_at");
        if (ts != null) p.setUpdatedAt(ts.toLocalDateTime());
        return p;
    }
}

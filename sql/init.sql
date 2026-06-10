-- ============================================
-- 在线购物平台 数据库初始化脚本
-- ============================================

USE online_shop;

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(128) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    avatar VARCHAR(255) DEFAULT '/assets/images/default-avatar.png',
    role ENUM('USER', 'ADMIN') DEFAULT 'USER',
    address VARCHAR(500),
    status TINYINT DEFAULT 1 COMMENT '1-正常 0-禁用',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 商品分类表
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    parent_id BIGINT DEFAULT 0,
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 商品表
CREATE TABLE IF NOT EXISTS products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    category_id BIGINT,
    image VARCHAR(255),
    status TINYINT DEFAULT 1 COMMENT '1-上架 0-下架',
    sales INT DEFAULT 0 COMMENT '销量',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 购物车表
CREATE TABLE IF NOT EXISTS cart_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_product (user_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 订单表
CREATE TABLE IF NOT EXISTS orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_no VARCHAR(50) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('PENDING','PAID','SHIPPED','COMPLETED','CANCELLED') DEFAULT 'PENDING'
        COMMENT 'PENDING-待付款 PAID-待发货 SHIPPED-待收货 COMPLETED-已完成 CANCELLED-已取消',
    receiver VARCHAR(50),
    phone VARCHAR(20),
    address VARCHAR(500),
    remark VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 订单明细表
CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id BIGINT,
    product_name VARCHAR(200) NOT NULL,
    product_price DECIMAL(10,2) NOT NULL,
    product_image VARCHAR(255),
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 初始数据
-- ============================================

-- 管理员账户 (密码: admin123, SHA-256加密)
INSERT INTO users (username, password, email, role) VALUES
('admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'admin@shop.com', 'ADMIN');

-- 测试用户 (密码: 123456)
INSERT INTO users (username, password, email, phone, address, role) VALUES
('testuser', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'test@shop.com', '13800138000', '北京市朝阳区建国路88号', 'USER');

-- 商品分类
INSERT INTO categories (name, description, sort_order) VALUES
('手机数码', '手机、平板、数码配件', 1),
('电脑办公', '笔记本、台式机、办公设备', 2),
('家用电器', '电视、冰箱、洗衣机、空调', 3),
('服装鞋包', '男装、女装、鞋靴、箱包', 4),
('食品生鲜', '零食、饮料、水果、生鲜', 5),
('图书文具', '图书、文具、办公用品', 6);

-- 商品数据
INSERT INTO products (name, description, price, stock, category_id, image, sales) VALUES
-- 手机数码
('智能手机 Pro Max', '6.7英寸OLED屏幕，A17芯片，4800万像素三摄系统，256GB存储', 7999.00, 100, 1, '/assets/images/products/phone1.jpg', 520),
('无线蓝牙耳机', '主动降噪，30小时续航，空间音频，IPX4防水', 1299.00, 200, 1, '/assets/images/products/earphone1.jpg', 1280),
('智能运动手表', '血氧检测，GPS定位，100+运动模式，14天超长续航', 1599.00, 150, 1, '/assets/images/products/watch1.jpg', 860),
('平板电脑 Air', '10.9英寸Liquid视网膜屏，M1芯片，64GB，支持手写笔', 4599.00, 80, 1, '/assets/images/products/tablet1.jpg', 340),
-- 电脑办公
('轻薄笔记本电脑', '14英寸2.8K OLED屏，i7-13700H，16GB+512GB，雷电4接口', 6499.00, 50, 2, '/assets/images/products/laptop1.jpg', 230),
('机械键盘', 'Cherry轴，RGB背光，全键热插拔，PBT键帽', 499.00, 300, 2, '/assets/images/products/keyboard1.jpg', 1560),
('无线鼠标', '人体工学设计，4000DPI，静音按键，双模连接', 199.00, 500, 2, '/assets/images/products/mouse1.jpg', 2300),
('4K显示器 27英寸', 'IPS面板，HDR400，Type-C一线连，旋转升降支架', 2799.00, 60, 2, '/assets/images/products/monitor1.jpg', 180),
-- 家用电器
('智能空气净化器', 'CADR值800m³/h，HEPA滤网，APP远程控制，静音模式', 2199.00, 40, 3, '/assets/images/products/purifier1.jpg', 90),
('全自动咖啡机', '一键萃取，自动奶泡，15Bar压力，可拆卸水箱', 3299.00, 30, 3, '/assets/images/products/coffee1.png', 120),
('扫地机器人', 'LDS激光导航，自动集尘，拖扫一体，APP智控', 2599.00, 45, 3, '/assets/images/products/robot1.jpg', 210),
-- 服装鞋包
('经典休闲双肩包', '防泼水面料，大容量，减压背带，USB充电口', 259.00, 200, 4, '/assets/images/products/bag1.jpg', 780),
('男士商务皮鞋', '头层牛皮，橡胶底，经典款式，舒适透气', 599.00, 100, 4, '/assets/images/products/shoes1.jpg', 430),
-- 食品生鲜
('进口车厘子 2斤装', '智利进口，JJ级，果径28-30mm，新鲜直达', 128.00, 500, 5, '/assets/images/products/cherry1.jpg', 3200),
('有机坚果礼盒', '6种坚果混合，每日坚果，原味无添加，750g', 168.00, 300, 5, '/assets/images/products/nuts1.png', 1500),
-- 图书文具
('Java编程思想（第5版）', '经典Java编程指南，深入理解面向对象编程，适合进阶学习', 108.00, 200, 6, '/assets/images/products/book1.png', 670),
('多功能文具套装', '包含钢笔、中性笔、荧光笔、笔记本、便签等，学生办公必备', 59.00, 400, 6, '/assets/images/products/stationery1.jpg', 950);

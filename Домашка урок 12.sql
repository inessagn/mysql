CREATE TABLE customers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  email VARCHAR(255),
  password VARCHAR(255),
  address VARCHAR(255),
  phone VARCHAR(20)
);

CREATE TABLE orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  customer_id INT,
  order_date DATETIME,
  total_price DECIMAL(10, 2),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE order_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT,
  product_id INT,
  quantity INT,
  price DECIMAL(10, 2),
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE products (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  description TEXT,
  price DECIMAL(10, 2),
  image VARCHAR(255),
  quantity INT
);

CREATE TABLE categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255)
);

CREATE TABLE product_categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT,
  category_id INT,
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE product_prices (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT,
  price DECIMAL(10, 2),
  series VARCHAR(255),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE PROCEDURE sp_create_customer (
  IN p_name VARCHAR(255),
  IN p_email VARCHAR(255),
  IN p_password VARCHAR(255),
  IN p_address VARCHAR(255),
  IN p_phone VARCHAR(20)
)
BEGIN
  INSERT INTO customers (name, email, password, address, phone)
  VALUES (p_name, p_email, p_password, p_address, p_phone);
END;

CREATE PROCEDURE sp_create_order (
  IN p_customer_id INT,
  IN p_order_date DATETIME,
  IN p_total_price DECIMAL(10, 2)
)
BEGIN
  INSERT INTO orders (customer_id, order_date, total_price)
  VALUES (p_customer_id, p_order_date, p_total_price);
END;

CREATE PROCEDURE sp_create_order_item (
  IN p_order_id INT,
  IN p_product_id INT,
  IN p_quantity INT,
  IN p_price DECIMAL(10, 2)
)
BEGIN
  INSERT INTO order_items (order_id, product_id, quantity, price)
  VALUES (p_order_id, p_product_id, p_quantity, p_price);
END;

CREATE PROCEDURE sp_create_product (
  IN p_name VARCHAR(255),
  IN p_description TEXT,
  IN p_price DECIMAL(10, 2),
  IN p_image VARCHAR(255),
  IN p_quantity INT
)
BEGIN
  INSERT INTO products (name, description, price, image, quantity)
  VALUES (p_name, p_description, p_price, p_image, p_quantity);
END;

CREATE PROCEDURE sp_create_category (
  IN p_name VARCHAR(255)
)
BEGIN
  INSERT INTO categories (name)
  VALUES (p_name);
END;

CREATE PROCEDURE sp_add_product_to_category (
  IN p_product_id INT,
  IN p_category_id INT
)
BEGIN
  INSERT INTO product_categories (product_id, category_id)
  VALUES (p_product_id, p_category_id);
END;

CREATE PROCEDURE sp_create_product_price (
  IN p_product_id INT,
  IN p_price DECIMAL(10, 2),
  IN p_series VARCHAR(255)
)
BEGIN
  INSERT INTO product_prices (product_id, price, series)
  VALUES (p_product_id, p_price, p_series);
END;


-- Insert test customers
INSERT INTO customers (name, email, password, address, phone)
VALUES
  ('John Doe', 'johndoe@example.com', 'password123', '123 Main St', '555-1234'),
  ('Jane Smith', 'janesmith@example.com', 'password456', '456 Oak St', '555-5678'),
  ('Bob Johnson', 'bobjohnson@example.com', 'password789', '789 Maple St', '555-9012');

-- Insert test products
INSERT INTO products (name, description, price, image, quantity)
VALUES
  ('Product 1', 'Description of product 1', 10.99, 'product1.jpg', 100),
  ('Product 2', 'Description of product 2', 19.99, 'product2.jpg', 50),
  ('Product 3', 'Description of product 3', 5.99, 'product3.jpg', 200);

-- Insert test categories
INSERT INTO categories (name)
VALUES
  ('Category 1'),
  ('Category 2'),
  ('Category 3');

-- Add products to categories
INSERT INTO product_categories (product_id, category_id)
VALUES
  (1, 1),
  (1, 2),
  (2, 2),
  (3, 3);

-- Insert test product prices
INSERT INTO product_prices (product_id, price, series)
VALUES
  (1, 1010.99, 'Series A'),
  (1, 109.99, 'Series B'),
  (2, 19.99, 'Series A'),
  (3, 505.99, 'Series A');

-- Insert test orders
INSERT INTO orders (customer_id, order_date, total_price)
VALUES
  (1, '2021-01-01 10:00:00', 10.99),
  (2, '2021-01-02 11:00:00', 39.98),
  (3, '2021-01-03 12:00:00', 5.99);

-- Insert test order items
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES
  (1, 1, 1, 10.99),
  (2, 1, 2, 9.99),
  (2, 2, 1, 19.99),
  (3, 3, 1, 5.99);

CALL sp_create_customer('John Smith', 'johnsmith@example.com', 'password123', '456 Elm St', '555-1234');
CALL sp_create_customer('Jane Smith', 'janesmith@example.com', 'password456', '456 Oak St', '555-5678'),
CALL sp_create_customer('Bob Johnson', 'bobjohnson@example.com', 'password789', '789 Maple St', '555-9012');

CALL sp_create_order(1, '2021-01-04 13:00:00', 29.98);

CALL sp_create_order_item(1, 2, 1, 19.99);    

CALL sp_create_product('Product 4', 'Description of product 4', 7.99, 'product4.jpg', 150);

CALL sp_create_product('Product 4', 'Description of product 4', 7.99, 'product4.jpg', 150);

CALL sp_create_category('Category 4');

CALL sp_create_category('Category 4');

CALL sp_add_product_to_category(4, 4);

CALL sp_create_product_price(4, 7.99, 'Series A');

CREATE VIEW orders_with_customer_info AS
SELECT o.id AS order_id, o.order_date, o.total_price, c.name AS customer_name, c.email, c.address, c.phone
FROM orders o
JOIN customers c ON o.customer_id = c.id;

CREATE VIEW products_with_categories AS
SELECT p.id AS product_id, p.name AS product_name, p.description, p.price, p.image, p.quantity, c.name AS category_name
FROM products p
JOIN product_categories pc ON p.id = pc.product_id
JOIN categories c ON pc.category_id = c.id;

CREATE VIEW revenue_by_month AS
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month, SUM(o.total_price) AS revenue
FROM orders o
GROUP BY month;

CREATE VIEW top_5_products AS
SELECT p.name AS product_name, SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id
ORDER BY total_quantity_sold DESC
LIMIT 5;
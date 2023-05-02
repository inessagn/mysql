DROP DATABASE IF EXISTS online_shop;
CREATE DATABASE online_shop;

USE online_shop;

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL COMMENT 'Имя пользователя',
  email VARCHAR(255) NOT NULL COMMENT 'Электронная почта',
  password_hash VARCHAR(100) NOT NULL COMMENT 'Хеш-код пароля',
  phone VARCHAR(20) COMMENT 'Номер телефона'
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL COMMENT 'Название товара',
  description TEXT NOT NULL COMMENT 'Описание товара',
  image VARCHAR(255) COMMENT 'URL к картинке'
);

CREATE TABLE warehouse (
  id SERIAL PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL COMMENT 'Id товара',
  quantity INT NOT NULL COMMENT 'Количество на остатке',
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE product_price (
  id SERIAL PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL COMMENT 'Id товара',
  price DECIMAL(10, 2) NOT NULL COMMENT 'Цена со скидкой',
  base_price DECIMAL(10, 2) COMMENT 'Цена без скидки (может не быть)',
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE shopping_cart (
  id SERIAL PRIMARY KEY,
  customer_id BIGINT UNSIGNED NOT NULL COMMENT 'Id пользователя',
  updated_date DATETIME NOT NULL COMMENT 'Время последнего обновления',
  total_quantity INT NOT NULL COMMENT 'Общее количество товаров в корзине',
  FOREIGN KEY (customer_id) REFERENCES customers(id)
); 

CREATE TABLE cart_items (
  id SERIAL PRIMARY KEY,
  cart_id BIGINT UNSIGNED NOT NULL COMMENT 'Id корзины',
  product_id BIGINT UNSIGNED NOT NULL COMMENT 'Id товара',
  quantity INT NOT NULL COMMENT 'Количество товаров в позиции',
  FOREIGN KEY (cart_id) REFERENCES shopping_cart(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id BIGINT UNSIGNED NOT NULL COMMENT 'Id пользователя',
  order_date DATETIME NOT NULL COMMENT 'Дата совершения заказа',
  total_price DECIMAL(10, 2) NOT NULL COMMENT 'Общая сумма заказа',
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL COMMENT 'Id заказа',
  product_id BIGINT UNSIGNED NOT NULL COMMENT 'Id товара',
  quantity INT NOT NULL COMMENT 'Количество товаров в позиции',
  price DECIMAL(10, 2) NOT NULL COMMENT 'Цена единицы товара в позиции',
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL COMMENT 'Название категории',
  order_number INT NOT NULL COMMENT 'Порядковый номер категории'
);

CREATE TABLE product_categories (
  id SERIAL PRIMARY KEY,
  product_id BIGINT UNSIGNED NOT NULL COMMENT 'Id товара',
  category_id BIGINT UNSIGNED NOT NULL COMMENT 'Id категории',
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- наполняем БД данными
-- customers
INSERT INTO customers (name, email, password_hash, phone)
VALUES
  ('Иванов Петр', 'ivanov@mail.ru', '34553424SDE34', '+79023454444'),
  ('Свиридова Сетлана', 'sviridsvet@example.ru', 'DFGY345HFD6DFG', '8-906-435-8473'),
  ('Серпантинов А', 'serp@gmail.com', 'FG4656456GFHDF', NULL);

-- products
INSERT INTO products (name, description, image)
VALUES
  ('Конструктор магнитный', 'Откройте с ребенком увлекательный мир грузовых и гоночных машин вместе с Pengo TRANSPORT.', '2344243.jpg'),
  ('Сухой бассейн', 'Использовать на мелководье под присмотром взрослых. ', 'product2.jpg'),
  ('Спортивный костюм FACTURIA', 'Стильный женский костюм от бренда Facturia', NULL);

-- categories
INSERT INTO categories (name, order_number)
VALUES
  ('Конструкторы', 20),
  ('Одежда и обувь', 1),
  ('Детские товары', 10);

-- Add products to categories
INSERT INTO product_categories (product_id, category_id)
VALUES
  (1, 1),
  (1, 3),
  (2, 3),
  (3, 2);

-- product price
INSERT INTO product_price (product_id, price, base_price)
VALUES
  (1, 2876, 5659),
  (2, 1779, 2560),
  (3, 2490, 3700);

-- warehouse
INSERT INTO warehouse (product_id, quantity)
VALUES
  (1, 234),
  (2, 10),
  (3, 2);
  
 
CREATE VIEW orders_with_customer_info AS
SELECT o.id AS order_id, 
       o.order_date, 
       o.total_price, 
       c.name AS customer_name, 
       c.email, 
       c.phone
FROM orders o
JOIN customers c ON o.customer_id = c.id;

CREATE VIEW products_with_categories AS
SELECT p.id AS product_id, 
	   p.name AS product_name, 
	   p.description,
	   pr.price, 
	   pr.base_price, 
	   p.image, 
	   w.quantity, 
	   c.name AS category_name
FROM products p
JOIN product_price pr ON pr.product_id = p.id
JOIN warehouse w ON w.product_id = p.id
JOIN product_categories pc ON p.id = pc.product_id
JOIN categories c ON pc.category_id = c.id;

CREATE VIEW revenue_by_month AS
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month, 
       SUM(o.total_price) AS revenue
FROM orders o
GROUP BY month;

CREATE VIEW top_5_products AS
SELECT p.name AS product_name, 
       SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- stored procudures
DELIMITER //

CREATE PROCEDURE add_to_cart(
    IN p_customer_id BIGINT UNSIGNED,
    IN p_product_id BIGINT UNSIGNED,
    IN p_quantity INT
)
BEGIN
    DECLARE customer_cart_id BIGINT UNSIGNED;
    DECLARE existing_quantity INT;
    DECLARE new_quantity INT;
    DECLARE warehouse_quantity INT;
    DECLARE total INT;

    START TRANSACTION;

    INSERT INTO shopping_cart (customer_id, updated_date, total_quantity)
      SELECT id, NOW(), 0 
      FROM customers 
      WHERE id = p_customer_id
        AND NOT EXISTS (SELECT * FROM shopping_cart 
                        WHERE customer_id = p_customer_id);

    SELECT id INTO customer_cart_id FROM shopping_cart WHERE customer_id = p_customer_id;                   
                      
    -- Проверить есть ли этот продукт уже в корзине
    SELECT quantity INTO existing_quantity 
    FROM cart_items
    WHERE cart_id = customer_cart_id
      AND product_id = p_product_id;
     
    SELECT COALESCE(quantity, 0) INTO warehouse_quantity
    FROM warehouse 
    WHERE product_id = p_product_id;
  
    IF existing_quantity IS NOT NULL THEN
        -- Обновляем количество в существующей строчке
        SET new_quantity = existing_quantity + p_quantity;
        IF new_quantity > warehouse_quantity THEN
        	SET new_quantity = warehouse_quantity;
        END IF;
       
        UPDATE cart_items 
        SET quantity = new_quantity 
        WHERE cart_id = customer_cart_id 
          AND product_id = p_product_id;
    ELSE
        -- Добавляем новую строчку в корзину
        SET new_quantity = p_quantity;
        IF new_quantity > warehouse_quantity THEN
        	SET new_quantity = warehouse_quantity;
        END IF;
       
        INSERT INTO cart_items (cart_id, product_id, quantity) 
        VALUES (customer_cart_id, p_product_id, new_quantity);
    END IF;
  

    -- обновляем кол-во товара в корзине
    SELECT SUM(ci.quantity) INTO total 
    FROM cart_items ci 
    WHERE ci.cart_id = customer_cart_id;
   
    UPDATE shopping_cart
    SET updated_date = NOW(),
        total_quantity = total
    WHERE id = customer_cart_id;
   
    COMMIT;
END //

DELIMITER ;


DELIMITER //
CREATE PROCEDURE create_order(
    IN p_cart_id BIGINT UNSIGNED
)
BEGIN
    DECLARE total_price DECIMAL(10, 2);
    DECLARE order_id BIGINT UNSIGNED;
    DECLARE product_id BIGINT UNSIGNED;
    DECLARE cust_id BIGINT UNSIGNED;
    DECLARE quantity INT;
    DECLARE price DECIMAL(10, 2);
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR
      SELECT ci.product_id, ci.quantity, pp.price 
      FROM cart_items ci 
      JOIN product_price pp ON ci.product_id = pp.product_id
      WHERE ci.cart_id = cart_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    START TRANSACTION;

    SELECT customer_id INTO cust_id
    FROM shopping_cart
    WHERE id = p_cart_id;
   
    -- Вычисляем общую стоимость заказа
    SELECT SUM(ci.quantity * pp.price) INTO total_price 
    FROM cart_items ci 
    JOIN product_price pp ON ci.product_id = pp.product_id 
    WHERE ci.cart_id = p_cart_id;

    INSERT INTO orders (customer_id, order_date, total_price) 
    VALUES (cust_id, NOW(), total_price);
   
    SET order_id = LAST_INSERT_ID();

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO product_id, quantity, price;
        IF done THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO order_items (order_id, product_id, quantity, price) 
        VALUES (order_id, product_id, quantity, price);
       
        -- убираем заказ из остатков
        UPDATE warehouse w
        SET w.quantity = w.quantity - quantity
        WHERE w.product_id = product_id;
    END LOOP;
    CLOSE cur;

    DELETE FROM cart_items WHERE cart_id = p_cart_id;
    DELETE FROM shopping_cart WHERE id = p_cart_id;
   
   
    COMMIT;
END //

DELIMITER ;

call add_to_cart(1, 1, 10);

-- т.к. на остатках только 10, он в корзину добавит только 10, а не 20
call add_to_cart(1, 2, 20);

SELECT * from shopping_cart;
select * from cart_items;

-- сделаем заказ, и убедимся, что остаток станет 0
call create_order(1);

select * from warehouse;
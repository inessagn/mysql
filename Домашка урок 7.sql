DROP DATABASE IF EXISTS lesson7;
CREATE DATABASE lesson7;
USE lesson7;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) COMMENT 'Имя',
	birthdate_at DATE NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
	id SERIAL PRIMARY KEY,
	name VARCHAR(200) NOT NULL
);

DROP TABLE IF EXISTS products;
CREATE TABLE products (
	id SERIAL PRIMARY KEY,
	name VARCHAR(200) NOT NULL,
	price DECIMAL NOT NULL,
	catalog_id BIGINT UNSIGNED,
	FOREIGN KEY (catalog_id) REFERENCES catalogs(id)
);

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
	id SERIAL PRIMARY KEY,
	order_id BIGINT UNSIGNED NOT NULL,
	product_id BIGINT UNSIGNED NOT NULL,
	total INT UNSIGNED,
	FOREIGN KEY (order_id) REFERENCES orders(id),
	FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO users (name, birthdate_at)
VALUES 
	('Сергей', '2000-01-20'),
	('Мария', '1983-02-23'),
	('Александр', '1990-03-30'),
	('Гузель', '1999-06-12'),
	('Толя', '1989-04-26'),
	('Арсений', '1979-05-31'),
	('Любовь', '1955-02-27');

INSERT INTO catalogs (id, name)
VALUES
 	(1, 'Процессоры'),
 	(2, 'Мат. платы'), 
 	(3, 'Видеокарты');

INSERT INTO products (name, price, catalog_id) 
VALUES 
	('Intel Core i3-8100', 7890, 1),
	('Intel Core i5-7400', 12700, 1),
	('AMD FX-8320E', 4780, 1), 
	('AMD FX-8320', 7120, 1), 
	('ASUS ROG MAXIMUS X HERO', 19310, 2),
	('Gigabyte H310M S2H', 4790, 2),
	('MSI B250M GAMING PRO', 5060, 2);

INSERT INTO orders (user_id)
SELECT id FROM users WHERE name = 'Александр';

INSERT INTO orders_products (order_id, product_id, total)
SELECT LAST_INSERT_ID(), id, 2 FROM products
WHERE name = 'Intel Core i5-7400';

INSERT INTO orders (user_id)
SELECT id FROM users WHERE name = 'Гузель';

INSERT INTO orders_products (order_id, product_id, total)
SELECT LAST_INSERT_ID(), id, 1 FROM products
WHERE name IN ('Intel Core i5-7400', 'Gigabyte H310M S2H');

INSERT INTO orders (user_id)
SELECT id FROM users WHERE name = 'Толя';

INSERT INTO orders_products (order_id, product_id, total)
SELECT LAST_INSERT_ID(), id, 1 FROM products
WHERE name IN ('AMD FX-8320', 'ASUS ROG MAXIMUS X HERO');

-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
SELECT 
	u.id,
	u.name,
	u.birthdate_at
FROM users u
JOIN orders o ON o.user_id = u.id;

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.
SELECT 
	p.id,
	p.name,
	p.price,
	c.name
FROM products p
LEFT JOIN catalogs c ON p.catalog_id = c.id;

-- 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. 
-- Выведите список рейсов flights с русскими названиями городов.

-- Практическое задание по теме “Транзакции, переменные, представления”
DROP DATABASE IF EXISTS shop;
CREATE DATABASE shop;

USE shop;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) COMMENT 'Имя',
	birthdate_at DATE NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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

DROP DATABASE IF EXISTS sample;
CREATE DATABASE sample;

USE sample;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) COMMENT 'Имя',
	birthdate_at DATE NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;

INSERT INTO sample.users (id, name, birthdate_at, created_at, updated_at)
SELECT id, name, birthdate_at, created_at, updated_at
FROM shop.users
WHERE id = 1;

DELETE FROM shop.users
WHERE id = 1;

COMMIT;


-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products и
-- соответствующее название каталога name из таблицы catalogs.
USE shop;

CREATE VIEW cat AS
SELECT p.id,
	p.name,
	c.name AS catalog_name
FROM products p
JOIN catalogs c ON p.catalog_id = c.id
ORDER BY p.id;

SELECT * FROM cat;

-- Практическое задание по теме «Операторы, фильтрация, сортировка и ограничение»
DROP DATABASE IF EXISTS lesson5;
CREATE DATABASE lesson5;
USE lesson5;

-- 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) COMMENT 'Имя',
	created_at DATETIME,
	updated_at DATETIME
);

INSERT INTO users (name)
VALUES 
	('Сергей'),
	('Мария'),
	('Александр'),
	('Гузель'),
	('Толя'),
	('Арсений'),
	('Любовь');

UPDATE users 
SET
	created_at = NOW(),
	updated_at = NOW();

-- 2. Таблица users была неудачно спроектирована.
-- Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. 
-- Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) COMMENT 'Имя',
	created_at VARCHAR(20) NOT NULL,
	updated_at VARCHAR(20) NOT NULL
);

INSERT INTO users (name, created_at, updated_at)
VALUES 
	('Сергей', '20.10.2017 8:10', '20.10.2000 8:10'),
	('Мария', '21.11.2018 8:10', '20.10.2017 11:23'),
	('Александр', '21.01.2019 8:10', '20.10.2017 8:10'),
	('Гузель', '22.02.2020 8:10', '20.10.2017 8:10'),
	('Толя', '23.03.2021 8:10', '20.10.2017 10:10'),
	('Арсений', '24.05.2022 8:10', '20.10.2017 8:10'),
	('Любовь', '25.06.2023 8:10', '20.10.2017 8:10');

UPDATE users 
SET
	created_at = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i'),
	updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');

ALTER TABLE users 
CHANGE
	created_at created_at DATETIME DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE users 
CHANGE
	updated_at updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
-- 0, если товар закончился и выше нуля, если на складе имеются запасы. 
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
-- Однако нулевые запасы должны выводиться в конце, после всех записей.
DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
	id SERIAL PRIMARY KEY,
	storehouse_id INT UNSIGNED,
	product_id INT UNSIGNED,
	value INT UNSIGNED,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO storehouses_products (storehouse_id, product_id, value)
VALUES 
	(1, 200, 0),
	(1, 234, 2500),
	(1, 2345, 0),
	(1, 4444, 30),
	(1, 23498, 5),
	(1, 999, 0);

SELECT id, value, IF(value > 0, 0, 1) AS sort
FROM storehouses_products 
ORDER BY sort ASC, value ASC;

-- 4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
-- Месяцы заданы в виде списка английских названий (may, august)

-- 5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса.
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.


-- Практическое задание теме «Агрегация данных»
-- 1. Подсчитайте средний возраст пользователей в таблице users.DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) COMMENT 'Имя',
	birthdate_at DATE NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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

SELECT AVG(TIMESTAMPDIFF(YEAR, birthdate_at, NOW())) AS average_age
FROM users;

-- 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.
SELECT DATE_FORMAT(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH(birthdate_at), DAY(birthdate_at))), '%W') AS weekday,
COUNT(*) AS total
FROM users
GROUP BY weekday
ORDER BY total DESC;

-- 3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.


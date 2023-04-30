/* Задача 1
 Установите СУБД MySQL. Создайте в домашней директории файл .my.cnf, задав в нем логин и пароль, который указывался при установке.
 
 СУБД MySQL Установлено.
 Файл my.cnf/.my.cnf создан и размещен в директорию с mysql server. Авторизуется без запроса пароля.
 */

/* Задача 2
 Создайте базу данных example, разместите в ней таблицу users, состоящую из двух столбцов, числового id и строкового name.
 */

-- создание базы
CREATE DATABASE example;

-- использование базы 
SHOW DATABASES;

--использование базы
USE example;

--создание таблицы
CREATE TABLE IF NOT EXISTS users (
 id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
 name VARCHAR(255)
);

/* Задача 3
Создайте дамп базы данных example из предыдущего задания, разверните содержимое дампа в новую базу данных sample
*/

-- создание базы
CREATE DATABASE sample;

-- в консоле ОС создание дампа
mysqldump example > D:\GeekBrains\sql\dump.SQL

-- разворачиваем дамп в базу
USE sample;

SOURCE D:\GeekBrains\sql\dump.SQL



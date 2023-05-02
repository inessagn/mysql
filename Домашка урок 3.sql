DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

-- пользователи
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(100) COMMENT 'Имя',
	lastname VARCHAR(100) COMMENT 'Фамилия',
	email VARCHAR(120) UNIQUE COMMENT 'Электронная почта',
	password_hash VARCHAR(100) COMMENT 'Хеш-код пароля',
	phone BIGINT UNSIGNED COMMENT 'Номер телефона',
	is_deleted BIT DEFAULT b'0' COMMENT 'Метка удаленной записи',
	INDEX users_lastname_firstname_idx(lastname, firstname)
);

-- 1-1
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	user_id SERIAL PRIMARY KEY,
	gender CHAR(1),
	birthdate DATE,
	photo_id BIGINT UNSIGNED,
	created_at DATETIME DEFAULT NOW(),
	CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 1-M
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL COMMENT 'Отправитель',
	to_user_id BIGINT UNSIGNED NOT NULL COMMENT 'Получатель',
	body TEXT NOT NULL,
	created_at DATETIME DEFAULT NOW(), 
	FOREIGN KEY (from_user_id) REFERENCES users(id),
	FOREIGN KEY (to_user_id) REFERENCES users(id)
);

-- 1-M
DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	initiator_user_id BIGINT UNSIGNED NOT NULL,
	target_user_id BIGINT UNSIGNED NOT NULL,
	status ENUM('requested', 'approved', 'declined', 'unfriended'),
	requested_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE NOW(),
	PRIMARY KEY (initiator_user_id, target_user_id),
	FOREIGN KEY (initiator_user_id) REFERENCES users(id),
	FOREIGN KEY (target_user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities (
	id SERIAL PRIMARY KEY,
	name VARCHAR(150) NOT NULL
);

-- M-M
DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities (
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (user_id, community_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (community_id) REFERENCES communities(id)
);

DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id SERIAL PRIMARY KEY,
	-- media_type_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	-- body VARCHAR(2000),
	-- filename VARCHAR(200),
	-- size INT, 
	-- metadata JSON,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	media_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (media_id) REFERENCES media(id)
);

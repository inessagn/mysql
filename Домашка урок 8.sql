-- Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение. Агрегация данных”
-- Задачи необходимо решить с использованием объединения таблиц (JOIN)
-- 1. Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, 
-- который больше всех общался с нашим пользователем.

USE vk;

SELECT friend_user.id, 
	CONCAT(friend_user.firstname, ' ', friend_user.lastname) AS friend_name,
	COUNT(m.id) AS msg_count
FROM messages m
JOIN (
	SELECT initiator_user_id AS user_id_1, target_user_id AS user_id_2, status
	FROM friend_requests 
	UNION ALL 
	SELECT target_user_id AS user_id_1, initiator_user_id AS user_id_2, status
	FROM friend_requests 
) fr ON fr.user_id_2 = m.from_user_id AND fr.status = 'approved'
JOIN users friend_user ON friend_user.id = fr.user_id_2
JOIN users target_user ON target_user.id = fr.user_id_1 AND target_user.id = 2
GROUP BY friend_user.id
ORDER BY msg_count DESC 
LIMIT 1;

-- 2. Подсчитать общее количество лайков, которые получили пользователи младше 11 лет.
SELECT COUNT(*)
FROM likes
JOIN media ON media.id = likes.media_id
JOIN profiles ON profiles.user_id = media.user_id
WHERE TIMESTAMPDIFF(YEAR, profiles.birthdate, NOW()) < 11;

-- 3. Определить кто больше поставил лайков (всего): мужчины или женщины.
SELECT profiles.gender, COUNT(*) as cnt
FROM likes
JOIN profiles ON profiles.user_id = likes.user_id
GROUP BY profiles.gender 
ORDER BY COUNT(*) DESC
LIMIT 1;

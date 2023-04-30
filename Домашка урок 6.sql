-- Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение. Агрегация данных”
-- 1. Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, 
-- который больше всех общался с нашим пользователем.
USE vk;

SELECT from_user_id AS user_id, 
	(SELECT CONCAT(firstname, ' ', lastname) FROM users WHERE users.id = messages.from_user_id) AS user_name,
	COUNT(*) AS msg_count
FROM messages
WHERE from_user_id IN (
	SELECT initiator_user_id 
	FROM friend_requests 
	WHERE status = 'approved' AND target_user_id = 2
	UNION ALL 
	SELECT target_user_id
	FROM friend_requests 
	WHERE status = 'approved' AND initiator_user_id = 2
)
GROUP BY from_user_id
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

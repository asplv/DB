-- ДОРАБОТКА БАЗЫ (команды, кот. применяются после сборки базы)

-- обновляем id в messages
UPDATE messages SET
  from_user_id = FLOOR(1 + (RAND() * 100)),
  to_user_id = FLOOR(1 + (RAND() * 100))
;


-- обновляем id в friendship
UPDATE friendship SET
  user_id = FLOOR(1 + (RAND() * 100)),
  friend_id = FLOOR(1 + (RAND() * 100))
;


-- обновляем id в friendship
UPDATE friendship SET status_id = FLOOR(1 + (RAND() * 3));


-- сокращаем список сообществ
DELETE FROM communities WHERE id > 20;


-- обновляем id в communities_users
UPDATE communities_users SET
  community_id = FLOOR(1 + (RAND() * 20)),
  user_id = FLOOR(1 + (RAND() * 100))
;


-- обновляем id в media
UPDATE media 
SET 
media_type_id = FLOOR(1 + (RAND() * 3)),
user_id = FLOOR(1 + (RAND() * 100));

-- дорабатываем колонку metadata
UPDATE media SET metadata = CONCAT(
  '{"', 
  'owner', 
  '":"', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id),
   '"}');

DESC media;   
ALTER TABLE media MODIFY COLUMN metadata JSON;


-- ЗАПРОСЫ ИЗ ВЕБИНАРА

SELECT * FROM users WHERE id = 4;

-- Получаем фото и гоород пользователя    
SELECT
  first_name,
  last_name,
  (SELECT filename FROM media WHERE id = 
    (SELECT photo_id FROM profiles WHERE user_id = users.id)
  ) AS filename,
  (SELECT hometown FROM profiles WHERE user_id = users.id) AS hometown
  FROM users
    WHERE id = 4;          

-- Получаем фотографии пользователя
SELECT filename FROM media
  WHERE user_id = 4
    AND media_type_id = (
      SELECT id FROM media_types WHERE name = 'photo'
    );
    
SELECT * FROM media_types;

-- Выбираем историю по добавлению фотографий пользователем
SELECT CONCAT(
  'Пользователь добавил фото ', 
  filename, 
  ' ', 
  created_at) AS news 
    FROM media 
    WHERE user_id = 4 
      AND media_type_id = (
        SELECT id FROM media_types WHERE name LIKE 'photo'
);

-- Улучшаем запрос
SELECT CONCAT(
  'Пользователь ', 
  (SELECT CONCAT(first_name, ' ', last_name)
    FROM users WHERE id = media.user_id),
  ' добавил фото ', 
  filename, ' ', 
  created_at) AS news 
    FROM media 
    WHERE user_id = 4 
      AND media_type_id = (
        SELECT id FROM media_types WHERE name LIKE 'photo'
);

-- Найдём кому принадлежат 10 самых больших медиафайлов
SELECT user_id, filename, size 
  FROM media 
  ORDER BY size DESC
  LIMIT 10;

-- Улучшим запрос, используем алиасы для имён таблиц
SELECT 
  (SELECT CONCAT(first_name, ' ', last_name) 
    FROM users u 
      WHERE u.id = m.user_id) AS owner,
  filename, 
  size 
    FROM media m
    ORDER BY size DESC
    LIMIT 10;
  
 -- Выбираем друзей пользователя с двух сторон отношения дружбы
(SELECT friend_id FROM friendship WHERE user_id = 4)
UNION
(SELECT user_id FROM friendship WHERE friend_id = 4);

-- Выбираем только друзей с активным статусом
SELECT * FROM friendship_statuses;

(SELECT friend_id 
  FROM friendship 
  WHERE user_id = 7
    AND confirmed_at IS NOT NULL 
    AND status_id IN (
      SELECT id FROM friendship_statuses 
        WHERE name = 'Confirmed'
    )
)
UNION
(SELECT user_id 
  FROM friendship 
  WHERE friend_id = 7
    AND confirmed_at IS NOT NULL 
    AND status_id IN (
      SELECT id FROM friendship_statuses 
        WHERE name = 'Confirmed'
    )
);


-- Выбираем медиафайлы друзей
SELECT filename FROM media WHERE user_id IN (
  (SELECT friend_id 
  FROM friendship 
  WHERE user_id = 7
    AND confirmed_at IS NOT NULL 
    AND status_id IN (
      SELECT id FROM friendship_statuses 
        WHERE name = 'Confirmed'
    )
  )
  UNION
  (SELECT user_id 
    FROM friendship 
    WHERE friend_id = 7
      AND confirmed_at IS NOT NULL 
      AND status_id IN (
      SELECT id FROM friendship_statuses 
        WHERE name = 'Confirmed'
    )
  )
);

-- Объединяем медиафайлы пользователя и его друзей для создания ленты новостей
SELECT filename, user_id, created_at FROM media WHERE user_id = 7
UNION
SELECT filename, user_id, created_at FROM media WHERE user_id IN (
  (SELECT friend_id 
  FROM friendship 
  WHERE user_id = 7
    AND confirmed_at IS NOT NULL 
    AND status_id IN (
      SELECT id FROM friendship_statuses 
        WHERE name = 'Confirmed'
    )
  )
  UNION
  (SELECT user_id 
    FROM friendship 
    WHERE friend_id = 7
      AND confirmed_at IS NOT NULL 
      AND status_id IN (
      SELECT id FROM friendship_statuses 
        WHERE name = 'Confirmed'
    )
  )
);

-- Определяем пользователей, общее занимаемое место медиафайлов которых 
-- превышает 100МБ

SELECT user_id, SUM(size) AS total
  FROM media
  GROUP BY user_id
  HAVING total > 100
  ORDER BY total DESC;

-- Подсчитываем лайки для медиафайлов пользователя и его друзей

SELECT target_id AS mediafile, COUNT(*) AS likes 
  FROM likes 
    WHERE target_id IN (
      SELECT id FROM media WHERE user_id = 7
        UNION
      (SELECT id FROM media WHERE user_id IN (
        SELECT friend_id 
          FROM friendship 
            WHERE user_id = 7
              AND status_id IN (
                SELECT id FROM friendship_statuses 
                  WHERE name = 'Confirmed'
              )))
        UNION
      (SELECT id FROM media WHERE user_id IN (
        SELECT user_id 
          FROM friendship 
            WHERE friend_id = 7
              AND status_id IN (
                SELECT id FROM friendship_statuses 
                  WHERE name = 'Confirmed'
              ))) 
    )
    AND target_type_id = (SELECT id FROM target_types WHERE name = 'media')
    GROUP BY target_id;


-- Начинаем создавать архив новостей для медиафайлов по месяцам
SELECT COUNT(id) AS arhive, MONTHNAME(created_at) AS month 
  FROM media
  GROUP BY month;
  
-- Архив с правильной сортировкой новостей по месяцам

SELECT COUNT(id) AS news, 
  MONTHNAME(created_at) AS month,
  MONTH(created_at) AS month_num 
    FROM media
    GROUP BY month_num, month
    ORDER BY month_num DESC;

-- Выбираем сообщения от пользователя и к пользователю
SELECT from_user_id, to_user_id, body, is_delivered, created_at 
  FROM messages
    WHERE from_user_id = 7
      OR to_user_id = 7
    ORDER BY created_at DESC;
    
-- Непрочитанные сообщения
SELECT from_user_id, 
  to_user_id, 
  body, 
  IF(is_delivered, 'delivered', 'not delivered') AS status 
    FROM messages
      WHERE (from_user_id = 4 OR to_user_id = 4)
        AND is_delivered IS NOT TRUE
    ORDER BY created_at DESC;
    
 -- Выводим друзей пользователя с преобразованием пола и возраста 
SELECT 
    (SELECT CONCAT(first_name, ' ', last_name) 
      FROM users 
      WHERE id = user_id) AS friend, 
      
    CASE (sex)
      WHEN 'm' THEN 'male'
      WHEN 'f' THEN 'female'
    END AS sex,
    
    TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age
     
  FROM profiles
  
  WHERE user_id IN (
    SELECT friend_id 
      FROM friendship
      WHERE user_id = 7
        AND confirmed_at IS NOT NULL
        AND status_id IN (
          SELECT id FROM friendship_statuses 
            WHERE name = 'Confirmed'
          )
      UNION
      SELECT user_id 
      FROM friendship
      WHERE friend_id = 7
        AND confirmed_at IS NOT NULL
        AND status_id IN (
          SELECT id FROM friendship_statuses 
            WHERE name = 'Confirmed'
          )
  );
    
-- Поиск пользователя по шаблонам имени  
SELECT CONCAT(first_name, ' ', last_name) AS fullname  
  FROM users
  WHERE first_name LIKE 'M%';
  
-- Используем регулярные выражения
SELECT CONCAT(first_name, ' ', last_name) AS fullname  
  FROM users
  WHERE last_name RLIKE '^M.*n$';
  



-- ДОМАШНЕЕ ЗАДАНИЕ

use vk;
-- 2. Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.

SELECT friend_id, count(*) AS msg_count
FROM (
	SELECT IF(from_user_id = 6, to_user_id, from_user_id) as friend_id
	FROM messages
	WHERE from_user_id = 6 or to_user_id = 6
) as messagesfriendid
WHERE friend_id IN (SELECT
  IF(user_id = 6, friend_id, user_id) as friend_id
  FROM friendship 
  WHERE confirmed_at IS NOT NULL 
    AND status_id IN (
      SELECT id FROM friendship_statuses 
        WHERE name = 'Confirmed')
    AND (friend_id = 6 OR user_id = 6))
GROUP BY friend_id
ORDER BY msg_count DESC
LIMIT 1;

    
-- 3. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

SELECT COUNT(*) as cnt
FROM likes
WHERE target_type_id = 2
	AND target_id IN (
		SELECT *
		FROM (
			SELECT user_id
			FROM profiles
			ORDER BY birthday DESC
			LIMIT 10
		) as youngest
	);


-- 4.Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT IF (sex = 'F', 'women_prevail', 'men_prevail') AS rslt
FROM profiles
WHERE user_id IN (select user_id from likes)
GROUP BY sex
ORDER BY COUNT(*) DESC
LIMIT 1;
 
-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
-- min активность = min выложенных медиа, min сообщений, min друзей (независимо от статуса), min лайков, 
-- min участий в сообществах,  min участий во встречах

SELECT user_id, count(*) FROM (
	(SELECT user_id, COUNT(*) as activity
	FROM media
	GROUP BY user_id)
	UNION ALL
	(SELECT from_user_id AS user_id, COUNT(*) as activity
	FROM messages
	GROUP BY from_user_id)
	UNION ALL
	(SELECT user_id, COUNT(*) as activity
	FROM friendship
	GROUP BY user_id)
	UNION ALL
	(SELECT user_id, COUNT(*) as activity
	FROM likes
	GROUP BY user_id)
	UNION ALL
	(SELECT user_id, COUNT(*) as activity
	FROM communities_users
	GROUP BY user_id)
	UNION ALL
	(SELECT user_id, COUNT(*) as activity
	FROM meetings_users
	GROUP BY user_id)
	UNION ALL
	(SELECT user_id, COUNT(*) as activity
	FROM posts
	GROUP BY user_id)
) AS user_activity
GROUP BY user_id
ORDER BY COUNT(*)
LIMIT 10;




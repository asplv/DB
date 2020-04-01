-- 1. Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить необходимые индексы.

-- Наиболее частые запросы: 
-- вывести сообщения от пользователей и пользователю 
-- вывести актуальное количество лайков к сущности
-- вывести обновления друзей пользователя для новостной ленты (по дате добавления постов)
 

-- индекс для оптимизации запроса переписки 
-- (например, SELECT * FROM messages WHERE from_user_id = x OR to_user_id = x)
CREATE INDEX from_user_id_idx ON messages(from_user_id);
CREATE INDEX to_user_id_idx ON messages(to_user_id);

-- индекс для оптимизации подсчета лайков сущности 
-- (SELECT * FROM likes WHERE target_type_id = x AND target_id = y)
CREATE INDEX target_type_id_target_id_idx ON likes(target_type_id, target_id);


-- НОВОСТИ:

-- индекс для оптимизации поиска пар друзей, в том числе чтобы потягивать их обновления в новости
-- (например, SELECT * FROM friendship WHERE user_id = x OR friend_id = x)
CREATE INDEX user_id_idx ON friendship(user_id);
CREATE INDEX friend_id_idx ON friendship(friend_id);

-- индекс для извлечения различных типов медиа (аудио, фото, видео) юзера
-- (SELECT * FROM media WHERE user_id = x and media_type_id = y)
CREATE INDEX user_id_media_type_id_idx ON media(user_id, media_type_id);


-- индекс для поиска самых свежих постов пользователя (например, друга) 
-- (SELECT * FROM posts WHERE user_id = x and updated_at BETWEEN NOW() AND X)
CREATE INDEX user_id_updated_at_idx ON posts(user_id, updated_at)


-- 2. Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый пожилой пользователь в группе
-- общее количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

SELECT DISTINCT communities.name,
   SUM(1) OVER () / (SELECT COUNT(DISTINCT community_id) FROM communities_users) AS average,
   MAX(profiles.birthday) OVER w AS youngest,
   MIN(profiles.birthday) OVER w AS oldest,
   SUM(1) OVER w AS total_community_users,
   SUM(1) OVER () AS total_users,
   SUM(1) OVER w / SUM(1) OVER () * 100 AS '%%'
  FROM communities_users
    JOIN communities
      ON communities_users.community_id = communities.id
    JOIN profiles
      ON communities_users.user_id = profiles.user_id
        WINDOW w AS (PARTITION BY communities.id);


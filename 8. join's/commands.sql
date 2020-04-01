USE vk;

-- 1 упр. из дз к УРОКУ 7. Вариант решения с JOIN
SELECT u.id, u.name, u.birthday_at
FROM
  users AS u
JOIN 
  orders AS o 
ON 
u.id = o.user_id
GROUP BY o.user_id;


-- доработанное решение задания 4 к уроку 6

SELECT (SELECT sex FROM profiles WHERE profiles.user_id = likes.user_id) AS sex, count(*) AS cnt FROM likes
GROUP BY sex
ORDER BY COUNT(*) DESC
LIMIT 1;



-- ЗАДАНИЯ К УРОКУ 6, ВЫПОЛНЕННЫЕ ПРИ ПОМОЩИ JOIN
-- 2. Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.

       
SELECT u.first_name, u.last_name, COUNT(*) AS total_msg
  FROM users as u 
    JOIN friendship as f
      ON u.id = f.user_id
        OR u.id = f.friend_id
    JOIN messages as m 
      ON (f.user_id = m.to_user_id AND f.friend_id = m.from_user_id)
        OR (f.friend_id = m.to_user_id AND f.user_id = m.from_user_id) 
    WHERE u.id = 2
    GROUP BY u.first_name, u.last_name;
   
     
-- 3. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.


SELECT SUM(cnt) as total FROM (SELECT profiles.user_id, COUNT(*) as cnt
   FROM profiles
   JOIN likes 
     ON profiles.user_id = likes.target_id AND likes.target_type_id = 2
   GROUP BY profiles.user_id
   ORDER BY profiles.birthday DESC
   LIMIT 10) as youngest_likes;

 
-- 4.Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT profiles.sex, COUNT(*) as cnt
  FROM profiles
  JOIN likes
    ON profiles.user_id = likes.user_id
  GROUP BY profiles.sex
 ORDER BY cnt DESC
 LIMIT 1;
 
 

-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.
-- min активность = min выложенных медиа, min сообщений, min друзей (независимо от статуса), min лайков, 
-- min участий в сообществах,  min участий во встречах

SELECT CONCAT(users.first_name, ' ', users.last_name) as users
  FROM users
  LEFT JOIN media ON media.user_id = users.id
  LEFT JOIN messages ON messages.from_user_id = users.id
  LEFT JOIN friendship ON friendship.user_id = users.id
  LEFT JOIN likes ON likes.user_id = users.id
  LEFT JOIN communities_users ON communities_users.user_id = users.id
  LEFT JOIN meetings_users ON meetings_users.user_id = users.id
  LEFT JOIN posts ON posts.user_id = users.id
GROUP BY users
ORDER BY COUNT(*)
LIMIT 10;



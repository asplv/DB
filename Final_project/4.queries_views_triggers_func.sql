-- Кинопоиск - самый обширный онлайн-сервис о кино в РФ. 
-- В данном проекте в 11 таблицах представлена модель хранении основных данных Кинопоиска: 
-- информации о пользователях (users и profiles), их друзьях (дружба в данном сервисе односторонняя), 
-- рецензиях и оценках пользователей (reviews и users_rates),
-- информации о кинокартинах (movies) и знаменитостях - актерах, режиссерах и т.д.(persons).
-- Также в базе описана логика хранения данных о жанрах и статьях о фильмах, размещенных на сайте,
-- описана схема хранения медиа-файлов.
-- В качестве тестовых данных сгенерировано по 100 записей для каждой таблицы, за исключением таблицы movies, - в ней 50 записей.

USE kinopoisk;

-- ХАРАКТЕРНЫЕ ВЫБОРКИ

-- JOIN'ы:
-- 1. Состав съемочной команды (актеров, режиссеров, т.д.) по фильму
SELECT first_name, last_name, position_type
  FROM film_crew AS f 
   JOIN persons AS p 
     ON f.person_id = p.id 
   JOIN movies AS m
     ON f.movie_id = m.id
WHERE movie_id = 7;


-- 2. Все негативные рецензии на фильмы
SELECT username, title, body, r.created_at 
  FROM reviews AS r
    JOIN movies AS m ON r.movie_id = m.id
    JOIN users AS u ON r.author_id = u.id
WHERE review_type = 'negative';


-- 3. Все фильмы 2016 года в жанре хорор
SELECT title, release_year, genre_type
 FROM movies AS m
   JOIN genres as g ON m.id = g.movie_id
WHERE release_year = '2016' AND genre_type = 'horror';
 

-- ГРУППИРОВКИ:
-- 1. Количество типов рецензий по каждому фильму (негативные, положительные, нестральные)
SELECT movie_id, review_type, COUNT(*) as total
  FROM reviews
   JOIN movies 
     ON reviews.movie_id = movies.id
GROUP BY review_type, movie_id
ORDER BY movie_id;

-- 2. Количество фильмов в каждом жанре за последнее десятилетие
SELECT genre_type, COUNT(movie_id) AS movies
  FROM genres
   JOIN movies 
     ON genres.movie_id = movies.id
WHERE release_year BETWEEN 2010 and 2020
GROUP BY genre_type
ORDER BY movies DESC;


-- ВЛОЖЕННЫЕ ЗАПРОСЫ:
-- 1. Оценки друзей пользователя
SELECT (SELECT CONCAT(first_name, ' ', last_name)
    FROM profiles WHERE user_id = users_rates.user_id) AS friend, movie_id, rate 
  FROM users_rates 
WHERE user_id IN (SELECT friend_id FROM friendship WHERE user_id = 1);


-- 2. 10 комедий с самым высоким рейтингом
SELECT movies.title, ROUND(AVG(rate),2) AS average_rate 
  FROM movies
   JOIN users_rates 
    ON movies.id = users_rates.movie_id
WHERE movies.id IN (
  SELECT movie_id 
    FROM genres 
  WHERE genre_type = 'comedy'
  )
GROUP BY movie_id
ORDER BY average_rate DESC
LIMIT 10;

 
-- ПРЕДСТАВЛЕНИЯ:
-- 1. Все актеры с фильмами
CREATE OR REPLACE VIEW actor_films AS 
SELECT p.id, first_name, last_name, title, release_year
FROM persons p
JOIN film_crew AS f ON p.id = f.person_id
JOIN movies AS m ON m.id = f.movie_id
WHERE position_type = 'actor';

SELECT * from actor_films;

-- 2. Имя и фамилия пользователя
CREATE OR REPLACE VIEW users_full_name AS 
SELECT users.id, username, first_name, last_name
  FROM users
    JOIN profiles
      ON users.id = profiles.user_id;

SELECT * FROM users_full_name;


-- ТРИГГЕРЫ:
-- 1. Ограничение на создание записи оценки одного и того же фильма одним пользователем

DROP TRIGGER IF EXISTS before_users_rates_insert;
DELIMITER $$
CREATE TRIGGER before_users_rates_insert BEFORE INSERT ON users_rates
FOR EACH ROW
BEGIN
  DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt 
      FROM users_rates 
    WHERE users_rates.user_id = NEW.user_id AND users_rates.movie_id = NEW.movie_id;
    IF cnt > 0 THEN 
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insert canceled.';
    END IF; 
END $$
DELIMITER ;

-- 2. Ограничение на создание записи в таблицы media, если owner_id не присутствует в таблицах  
-- users, persons, movies

DROP TRIGGER IF EXISTS before_media_insert;
DELIMITER $$
CREATE TRIGGER before_media_insert BEFORE INSERT ON media
FOR EACH ROW
BEGIN
   DECLARE owner_exist BOOLEAN DEFAULT False;
   IF NEW.owner_type = 'user' THEN select exists(select * from users where id = new.owner_id) into owner_exist;
   ELSEIF NEW.owner_type = 'person' THEN select exists(select * from users where id = new.owner_id) into owner_exist;
   ELSEIF NEW.owner_type = 'movie' THEN select exists(select * from users where id = new.owner_id) into owner_exist;
   END IF;
   IF NOT owner_exist THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insert canceled.';
   END IF; 
END $$
DELIMITER ;

 
-- ФУНКЦИИ:
-- 1. Расчет средней оценки фильма
DROP FUNCTION IF EXISTS avg_rate;
DELIMITER $$
CREATE FUNCTION avg_rate(m_id INT)
RETURNS FLOAT NO SQL
  BEGIN
    DECLARE avg_r FLOAT;
    SELECT ROUND(AVG(rate), 2) INTO avg_r FROM users_rates WHERE users_rates.movie_id = m_id;
    RETURN avg_r;
  END $$
DELIMITER ;

SELECT avg_rate(1);

-- 2. Общий рейтинг фильма (высчитывается по формуле Кинопоиска, где
-- V - количество голосов за фильм 
-- M - порог голосов, необходимый для участия в рейтинге Топ-250 (сейчас: 500) (беру 3)
-- R – среднее арифметическое всех голосов за фильм
-- С - среднее значение рейтинга всех фильмов (сейчас: 7.1385)

DROP FUNCTION IF EXISTS movie_rating;
DELIMITER $$
CREATE FUNCTION movie_rating(m_id INT)
RETURNS FLOAT READS SQL DATA
  BEGIN
    DECLARE V INT;
    DECLARE M INT;
    DECLARE R FLOAT;
    DECLARE C FLOAT;
    DECLARE total FLOAT;
    SET M = 3;
    SET C = 7.1385;
     SELECT COUNT(*) INTO V FROM users_rates WHERE users_rates.movie_id = m_id;
     SELECT ROUND(AVG(rate), 2) INTO R FROM users_rates WHERE users_rates.movie_id = m_id;
    SET total = V/(V+M)*R+M/(V+M)*C;
    RETURN total;  
  END $$
DELIMITER ;

SELECT movie_rating(42);

-- Создание БД для социальной сети ВКонтакте https://vk.com/
DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;

USE vk;

-- users

CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,  
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  phone VARCHAR(120) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

-- добавляем колонку обновления данных в профиле
CREATE TABLE profiles (
  user_id INT UNSIGNED NOT NULL PRIMARY KEY,
  sex CHAR(1) NOT NULL,
  birthday DATE,
  hometown VARCHAR(100),
  photo_id INT(10) UNSIGNED NOT NULL,
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);


-- messages

SELECT * FROM messages LIMIT 10;
CREATE TABLE messages (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  from_user_id INT UNSIGNED NOT NULL,
  to_user_id INT UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  is_important BOOLEAN,
  is_delivered BOOLEAN,
  created_at DATETIME DEFAULT NOW()
);

-- создаем рандомные id отправителя и получателя вместо сгенеренных последовательно
UPDATE messages SET
  from_user_id = FLOOR(1 + (RAND() * 100)),
  to_user_id = FLOOR(1 + (RAND() * 100))
;


-- friendship

SELECT * FROM friendship LIMIT 10;
CREATE TABLE friendship (
  user_id INT UNSIGNED NOT NULL,
  friend_id INT UNSIGNED NOT NULL,
  status_id INT UNSIGNED NOT NULL,
  requested_at DATETIME DEFAULT NOW(),
  confirmed_at DATETIME,
  PRIMARY KEY (user_id, friend_id)
);

-- заполняем колонку рандомными id для юзера и друга
UPDATE friendship SET
  user_id = FLOOR(1 + (RAND() * 100)),
  friend_id = FLOOR(1 + (RAND() * 100))
;

CREATE TABLE friendship_statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE
);

SELECT * FROM friendship_statuses;

-- заполняем колонку рандомными id по числу типов статуса дружбы
UPDATE friendship SET status_id = FLOOR(1 + (RAND() * 3));


-- communities

CREATE TABLE communities (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE
);

-- сокращаем список сообществ до 20
SELECT * FROM communities;
DELETE FROM communities WHERE id > 20;


CREATE TABLE communities_users (
  community_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (community_id, user_id)
);

-- заполняем колонки рандомными id сообщества и юзера
SELECT * FROM communities_users LIMIT 10;
UPDATE communities_users SET
  community_id = FLOOR(1 + (RAND() * 20)),
  user_id = FLOOR(1 + (RAND() * 100))
;


-- media

CREATE TABLE media (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  media_type_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  filename VARCHAR(255) NOT NULL,
  size INT NOT NULL,
  metadata JSON,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE media_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);


SELECT * FROM media LIMIT 10;
-- вставляем рандомные id от 1 до 3 
UPDATE media SET media_type_id = FLOOR(1 + (RAND() * 3));

-- вставляем рандомные id юзеров
UPDATE media SET user_id = FLOOR(1 + (RAND() * 100));

-- дорабатываем колонку metadata
UPDATE media SET metadata = CONCAT(
  '{"', 
  'owner', 
  '":"', 
  (SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id),
   '"}');
 
  
-- проверяем тип данных в таблице
DESC media;   
ALTER TABLE media MODIFY COLUMN metadata JSON;

--  создаем таблицу со встречами
CREATE TABLE meetings (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  scheduled_at DATETIME 
);

-- создаем таблицу с постами
CREATE TABLE posts (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
user_id INT UNSIGNED NOT NULL,
header VARCHAR(255),
body TEXT NOT NULL,
media_id INT,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- создаем таблицу с лайками
CREATE TABLE likes (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
liked_content_type_id INT UNSIGNED NOT NULL,
content_owner_id INT UNSIGNED NOT NULL,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- создаем справочник с типами контента, который можно лайкнуть
CREATE TABLE liked_content_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

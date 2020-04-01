-- Создание БД для социальной сети ВКонтакте https://vk.com/
DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;

USE vk;

-- users
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,  
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  phone VARCHAR(120) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);

--  profiles
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
  user_id INT UNSIGNED NOT NULL PRIMARY KEY,
  sex CHAR(1) NOT NULL,
  birthday DATE,
  hometown VARCHAR(100),
  photo_id INT(10) UNSIGNED NOT NULL,
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);


-- messages

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
  from_user_id INT UNSIGNED NOT NULL,
  to_user_id INT UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  is_important BOOLEAN,
  is_delivered BOOLEAN,
  created_at DATETIME DEFAULT NOW()
);

-- обновляем id в messages
UPDATE messages SET
  from_user_id = FLOOR(1 + (RAND() * 100)),
  to_user_id = FLOOR(1 + (RAND() * 100))
;

-- friendship
DROP TABLE IF EXISTS friendship;
CREATE TABLE friendship (
  user_id INT UNSIGNED NOT NULL,
  friend_id INT UNSIGNED NOT NULL,
  status_id INT UNSIGNED NOT NULL,
  requested_at DATETIME DEFAULT NOW(),
  confirmed_at DATETIME,
  PRIMARY KEY (user_id, friend_id)
);

-- обновляем id в friendship
UPDATE friendship SET
  user_id = FLOOR(1 + (RAND() * 100)),
  friend_id = FLOOR(1 + (RAND() * 100))
;

DROP TABLE IF EXISTS friendship_statuses;
CREATE TABLE friendship_statuses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE
);

-- обновляем id в friendship
UPDATE friendship SET status_id = FLOOR(1 + (RAND() * 3));


-- communities
DROP TABLE IF EXISTS communities;
CREATE TABLE communities (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE
);
-- сокращаем список сообществ
DELETE FROM communities WHERE id > 20;


DROP TABLE IF EXISTS communities_users;
CREATE TABLE communities_users (
  community_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (community_id, user_id)
);

-- обновляем id в communities_users
UPDATE communities_users SET
  community_id = FLOOR(1 + (RAND() * 20)),
  user_id = FLOOR(1 + (RAND() * 100))
;


-- media
DROP TABLE IF EXISTS media;
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

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

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

--  meetings
DROP TABLE IF EXISTS `meetings`;
CREATE TABLE `meetings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8_unicode_ci NOT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
);

-- posts
DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
user_id INT UNSIGNED NOT NULL,
header VARCHAR(255),
body TEXT NOT NULL,
media_id INT,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- likes
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- типы контента, который можно лайкать
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');

  

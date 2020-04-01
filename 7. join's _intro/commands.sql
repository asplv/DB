-- ДОМАШНЕЕ ЗАДАНИЕ 

use shop;

-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

SELECT id,name FROM users 
WHERE EXISTS (SELECT 1 FROM orders WHERE user_id = users.id GROUP BY user_id);



-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT
  p.id,
  p.name,
  c.name
FROM
  catalogs AS c
JOIN
  products AS p
WHERE
  c.id = p.catalog_id;
 
 
-- 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. 
-- Выведите список рейсов flights с русскими названиями городов.
 
DROP DATABASE IF EXISTS avia;
CREATE DATABASE avia;
USE avia;

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  where_from VARCHAR(255) NOT NULL,
  where_to VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  label VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL

);

INSERT INTO `cities` (`id`, `label`, `name`) VALUES (1, 'Moscow', 'Москва');
INSERT INTO `cities` (`id`, `label`, `name`) VALUES (2, 'London', 'Лондон');
INSERT INTO `cities` (`id`, `label`, `name`) VALUES (3, 'Berlin', 'Берлин');
INSERT INTO `cities` (`id`, `label`, `name`) VALUES (4, 'Tokyo', 'Токио');
INSERT INTO `cities` (`id`, `label`, `name`) VALUES (5, 'Volgograd', 'Волгоград');
INSERT INTO `cities` (`id`, `label`, `name`) VALUES (6, 'Omsk', 'Омск');
INSERT INTO `cities` (`id`, `label`, `name`) VALUES (7, 'Saint-Petersburg', 'Санкт-Петербург');
INSERT INTO `cities` (`id`, `label`, `name`) VALUES (8, 'Kazan', 'Казань');
INSERT INTO `cities` (`id`, `label`, `name`) VALUES (9, 'Sydney', 'Сидней');
INSERT INTO `cities` (`id`, `label`, `name`) VALUES (10, 'Oslo', 'Осло');


INSERT INTO `flights` (`id`, `where_from`, `where_to`) VALUES (1, 'Moscow', 'London');
INSERT INTO `flights` (`id`, `where_from`, `where_to`) VALUES (2, 'Berlin', 'Tokyo');
INSERT INTO `flights` (`id`, `where_from`, `where_to`) VALUES (3, 'Volgograd', 'Kazan');
INSERT INTO `flights` (`id`, `where_from`, `where_to`) VALUES (4, 'Saint-Petersburg', 'Oslo');
INSERT INTO `flights` (`id`, `where_from`, `where_to`) VALUES (5, 'London', 'Sydney');
INSERT INTO `flights` (`id`, `where_from`, `where_to`) VALUES (7, 'Tokyo', 'Oslo');
INSERT INTO `flights` (`id`, `where_from`, `where_to`) VALUES (8, 'Omsk', 'Moscow');
INSERT INTO `flights` (`id`, `where_from`, `where_to`) VALUES (9, 'Sydney', 'Moscow');
INSERT INTO `flights` (`id`, `where_from`, `where_to`) VALUES (10, 'Saint-Petersburg', 'Kazan');


SELECT 
   f.id, cf.name, ct.name
FROM flights as f
JOIN cities as cf ON f.where_from = cf.label
JOIN cities as ct ON f.where_to = ct.label
ORDER BY f.id;



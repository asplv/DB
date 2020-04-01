-- создаем базу данных интернет-магазина
DROP DATABASE IF EXISTS shop;
CREATE DATABASE shop;

USE shop;


DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

-- расширяем список позиций до 5 (к заданию 5)
INSERT INTO catalogs VALUES
  (DEFAULT, 'Процессоры'),
  (DEFAULT, 'Мат.платы'),
  (DEFAULT, 'Мониторы'),
  (DEFAULT, 'Клавиатуры'),
  (DEFAULT, 'Видеокарты');

 
 
-- Задание 5(операторы)
SELECT * FROM catalogs;
-- Применяем сортировку по заданному списку значений при помощи функции FIELD()
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2);





DROP TABLE IF EXISTS cat;
CREATE TABLE cat (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);

INSERT INTO
  cat
SELECT
  *
FROM
  catalogs;
SELECT * FROM cat;


-- убираем автоматическое заполнение даты в таблице (к Заданию 1)
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME,
  updated_at DATETIME
) COMMENT = 'Покупатели';


SELECT * FROM users;

-- заполняем поля имя и д.р.
INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');


-- Задание 1(операторы). Заполняем поля created_at и updated_at текущей датой и временем при помощи функции NOW()
UPDATE users 
SET created_at = NOW(), updated_at = NOW();



-- Задание 2(операторы)
-- проверяем и меням тип данных полей created_at, updated_at (чтобы смоделировать неудачное проектирование таблицы)
DESCRIBE users;
ALTER TABLE users MODIFY COLUMN created_at VARCHAR(120);
ALTER TABLE users MODIFY COLUMN updated_at VARCHAR(120);

-- очищаем таблицу
TRUNCATE users;

-- заполняем таблицу, в т.ч. датой в формате 20.10.2017 8:10 
INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Геннадий', '1990-10-05', '30.11.2017 5:23', '03.09.2019 12:45'),
  ('Наталья', '1984-11-12', '17.04.2011 11:15', '12.04.2019 6:20'),
  ('Александр', '1985-05-20', '29.07.2010 17:45', '08.10.2019 4:00'),
  ('Сергей', '1988-02-14', '05.07.2016 23:01', '16.12.2019 2:32'),
  ('Иван', '1998-01-12', '28.01.2018 19:55', '08.08.2019 5:11'),
  ('Мария', '1992-08-29','26.03.2019 20:00', '19.06.2019 15:14');

-- преобразовываем данные в дату при помощи функции STR_TO_DATE()
UPDATE users SET 
created_at = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i'), 
updated_at =STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');

-- меняем тип данных в таблице
ALTER TABLE users MODIFY COLUMN created_at DATETIME;
ALTER TABLE users MODIFY COLUMN updated_at DATETIME;
SELECT * FROM users;
DESCRIBE users;


-- Задание 4(операторы). Обновляем формат даты, в шаблоне оставляем только полное название месяца и извлекаем юзеров, 
-- родившихся в мае и августе
SELECT * from users WHERE DATE_FORMAT(birthday_at, '%M') IN ('may','august');


-- Задание 1(агрегация)
SELECT * FROM users;
-- средний возраст пользователей
SELECT FLOOR(AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW()))) as avg_age from users;



-- Задание 2(агрегация)
-- определяем день недели др юзера и группируем по кол-ву др
SELECT 
 DAYNAME(DATE_FORMAT(birthday_at,'2020-%m-%d')) as day_of_week, 
 COUNT(*) AS total_BDs 
FROM users 
GROUP BY DAYNAME(DATE_FORMAT(birthday_at,'2020-%m-%d'));





DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  desription TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id)
) COMMENT = 'Заказы';

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id INT UNSIGNED,
  product_id INT UNSIGNED,
  total INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Состав заказа';

DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  product_id INT UNSIGNED,
  discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  KEY index_of_product_id(product_id)
) COMMENT = 'Скидки';

DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Склады';


DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

SELECT * from storehouses_products;

-- Задание 3(операторы). Заполняем столбец value значениями
INSERT INTO storehouses_products (value) VALUES
  (0),
  (25),
  (456),
  (0),
  (35),
  (100);

-- упорядочиваем значения
SELECT * from storehouses_products ORDER BY value = 0, value;


-- Задание 3(агрегация)
-- находим произведение через свойство логарифмов (логарифм произведения равен сумме логарифмов) и далее получаем результат 
-- при помощи функции экспоненты EXP(), округляем

SELECT ROUND(EXP(SUM(LOG(value)))) as product_of_value from storehouses_products;


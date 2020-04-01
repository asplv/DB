
-- Практическое задание по теме “Транзакции, переменные, представления”

-- 1. В базе данных shop и sample присутствуют одни и те же таблицы учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
SELECT * FROM shop.users WHERE id = 1;
SAVEPOINT shop_users_1; 
INSERT INTO sample.users SELECT * FROM shop.users WHERE id = 1;
SELECT * FROM sample.users;
COMMIT; 

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.

CREATE OR REPLACE VIEW names AS 
SELECT p.name, c.name as 'catalog'
FROM products AS p 
JOIN catalogs AS c 
ON p.catalog_id = c.id;

SELECT * from names;

-- 3. (по желанию) Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, 
-- выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.

DROP TABLE IF EXISTS orders_sample;
CREATE TABLE orders_sample (
  id SERIAL PRIMARY KEY AUTO_INCREMENT,
  user_id INT UNSIGNED,
  created_at DATE
);

INSERT INTO orders_sample(user_id, created_at) VALUES
(12, '2018-08-01'),
(9, '2016-08-04'), 
(4, '2018-08-16'),
(7, '2018-08-17');


SELECT aug_date, id IS NOT NULL AS flag FROM (
WITH RECURSIVE numbers AS (
   SELECT 0 AS day_num
   UNION ALL
   SELECT day_num + 1
   FROM numbers
   WHERE day_num < 30)
SELECT DATE_ADD('2018-08-01', INTERVAL day_num DAY) AS aug_date FROM numbers
) AS aug_dates
LEFT JOIN orders_sample AS os 
  ON os.created_at = aug_dates.aug_date;


-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. 
-- Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

INSERT INTO orders_sample(user_id, created_at) VALUES
(1, '2019-09-01'),
(10, '2020-01-04'), 
(13, '2019-10-19'),
(23, '2019-07-19'),
(88, '2020-02-01');


PREPARE old_delete FROM "DELETE FROM orders_sample ORDER BY created_at LIMIT ?";
SET @CNT=(SELECT COUNT(*) - 5 FROM orders_sample);
EXECUTE old_delete USING @CNT;


-- Практическое задание по теме “Администрирование MySQL” 
-- 1. Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read должны быть доступны только запросы на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop.

CREATE USER shop_read IDENTIFIED BY '1234';
GRANT SELECT ON shop.* TO shop_read;


CREATE USER shop IDENTIFIED BY '12345';
GRANT ALL ON shop.* TO shop;


-- 2. (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username.

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
  id SERIAL PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(120),
  password VARCHAR(50)
);

INSERT INTO accounts VALUES
(1, 'Анастасия Иванова', '1234'),
(2, 'Олег Петров', 'ffwef123'), 
(3, 'Алиса Яблочкина', 'qwerty1'),
(4, 'Дмитрий Владимиров', '0000');

CREATE OR REPLACE VIEW username AS
SELECT id, name FROM accounts;

DROP USER shop_read;
CREATE USER shop_read IDENTIFIED BY '1234';
GRANT SELECT ON shop.username TO shop_read;

-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"
-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
-- с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".


DROP FUNCTION IF EXISTS hello;
DELIMITER $$
CREATE FUNCTION hello()
RETURNS VARCHAR(50) DETERMINISTIC
  BEGIN
   DECLARE time VARCHAR(50);
   SET time = CURRENT_TIME();
       IF (time BETWEEN '6:00:00' AND '11:59:00') THEN RETURN 'Доброе утро';
       ELSEIF (time BETWEEN '12:00:00' AND '17:59:00') THEN RETURN 'Добрый день';
       ELSE RETURN 'Добрый вечер';
       END IF;
    END $$
DELIMITER ;
   
   
-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. 
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.


-- триггер на вставку значений

DROP trigger IF EXISTS before_name_desc_insert;
DELIMITER $$
CREATE TRIGGER before_name_desc_insert BEFORE INSERT ON products
FOR EACH ROW
BEGIN
  IF new.name IS NULL AND new.description IS NULL THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insert canceled';
  END IF;
END $$
DELIMITER ;


-- триггер на обновление значений
DROP trigger IF EXISTS after_name_desc_update;
DELIMITER $$
CREATE TRIGGER after_name_desc_update AFTER UPDATE ON products
FOR EACH ROW
BEGIN
  DECLARE null_rows INT;
  SELECT COUNT(*) INTO null_rows FROM products WHERE name IS NULL AND description IS NULL;
  IF null_rows >= 1 THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Update canceled';
  END IF;
END $$
DELIMITER ;

-- 3.(по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
-- Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
-- Вызов функции FIBONACCI(10) должен возвращать число 55.

DROP FUNCTION IF EXISTS fibonacci;
DELIMITER $$
CREATE FUNCTION fibonacci(n INT)
RETURNS INT DETERMINISTIC
BEGIN
  DECLARE n1 INT;
    DECLARE n2 INT;
    DECLARE fib INT;
    DECLARE i INT;
  SET n1 = 0;
    SET n2 = 1;
    SET fib = 0;
    SET i = 0;
    WHILE (i < n - 1) DO
      SET fib = n1 + n2;
      SET n1 = n2;
      SET n2 = fib;
      SET i = i + 1;
    END WHILE;
RETURN fib;
END $$
DELIMITER ;


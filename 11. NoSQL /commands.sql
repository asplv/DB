-- Практическое задание по теме “Оптимизация запросов”
-- 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs 
-- помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

USE shop;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
  id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  tablename VARCHAR(255) NOT NULL,
  pk_id INT UNSIGNED NOT NULL,
  entry VARCHAR(255) NOT NULL 
) ENGINE=Archive;


-- триггер на вставку в таблицу users
DROP TRIGGER IF EXISTS after_users_insert;
DELIMITER $$
CREATE TRIGGER after_users_insert AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs SET tablename = 'users', pk_id = NEW.id, entry = NEW.name;
END $
DELIMITER ;


-- триггер на вставку в таблицу catalogs
DROP TRIGGER IF EXISTS after_catalogs_insert;
DELIMITER $$
CREATE TRIGGER after_catalogs_insert AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	INSERT INTO logs SET tablename = 'catalogs', pk_id = NEW.id, entry = NEW.name;
END $$
DELIMITER ;

-- триггер на вставку в таблицу products
DROP TRIGGER IF EXISTS after_products_insert;
DELIMITER $$
CREATE TRIGGER after_products_insert AFTER INSERT ON products
FOR EACH ROW
BEGIN
	INSERT INTO logs SET tablename = 'products', pk_id = NEW.id, entry = NEW.name;
END $$
DELIMITER ;

-- проверяем 
INSERT INTO users(name, birthday_at)  VALUES ('iamanewuser', '1992-12-20');
INSERT INTO catalogs(name)  VALUES ('Устройства ввода');
INSERT INTO products(name, description, price, catalog_id)  VALUES 
('ASRock FM2A68M-DG3+', 'Материнская плата ASRock FM2A68M-DG3+', 2750, 2);
SELECT * FROM logs;


-- Практическое задание по теме “NoSQL”
-- 1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.

-- создаем коллекцию
HINCRBY IP-address '200.16.208.255' 1
HINCRBY IP-address '200.16.208.255' 1
HINCRBY IP-address '71.40.181.16' 1

-- смотрим все значения коллекции
HGETALL IP-address

-- смотрим посещения конкретного адреса
HGET IP-address '200.16.208.255'


-- 2. При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот, 
-- поиск электронного адреса пользователя по его имени.
 
HSET e-mail 'Anna' 'qwerty@redis.qqq'
HSET name 'qwerty@redis.qqq' 'Anna'

HGET e-mail 'Anna' 
HGET name 'qwerty@redis.qqq'


-- 3.Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.


use shop


db.createCollection('catalogs')
db.createCollection('products')

db.catalogs.insert({name: 'Процессоры', id: new ObjectId()})
db.catalogs.insert({name: 'Мат.платы', id: new ObjectId()})
db.catalogs.insert({name: 'Видеокарты', id: new ObjectId()})

db.catalogs.find()

db.products.insert(
  {
    name: 'Intel Core i3-8100',
    description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
    price: 7890.00,
    catalog_id: ObjectId('5e3ff99aa644994f81bf4eb6')
  }
);

db.products.insert(
  {
    name: 'Intel Core i5-7400',
    description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
    price: 12700.00,
    catalog_id: ObjectId('5e3ff99aa644994f81bf4eb6')
  }
);

db.products.insert(
  {
    name: 'ASUS ROG MAXIMUS X HERO',
    description: 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX',
    price: 19310.00,
    catalog_id: ObjectId('5e3ff99aa644994f81bf4eb8')
  }
);

db.products.find()

-- создание базы данных кинопоиск 

DROP DATABASE IF EXISTS kinopoisk;
CREATE DATABASE kinopoisk;
USE kinopoisk;



-- users
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,  
  username VARCHAR(120) NOT NULL UNIQUE,
  email VARCHAR(120) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);


-- media
DROP TABLE IF EXISTS media;
CREATE TABLE media (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  media_type ENUM ('video', 'photo', 'audio'),
  owner_id INT UNSIGNED NOT NULL,
  owner_type ENUM ('user', 'person','movie'),
  filename VARCHAR(255) NOT NULL,
  size INT NOT NULL,
  metadata JSON,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
); 

CREATE INDEX owner_type_owner_id_idx ON media (owner_type, owner_id);


-- profiles
DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
  user_id INT UNSIGNED NOT NULL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone VARCHAR(120) NOT NULL UNIQUE,
  sex CHAR(1) NOT NULL,
  birthday DATE,
  hometown VARCHAR(100),
  photo_id INT UNSIGNED,
  bio VARCHAR(300),
  hobbies VARCHAR(300),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT profiles_photo_id_fk 
    FOREIGN KEY (photo_id) REFERENCES media(id) ON DELETE SET NULL
);


-- movies
DROP TABLE IF EXISTS movies;
CREATE TABLE movies (
   id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
   title VARCHAR(100) NOT NULL,
   title_original VARCHAR(100),
   release_year YEAR,
   country VARCHAR(255),
   tagline TINYTEXT,
   budget INT UNSIGNED,
   box_office_US INT UNSIGNED,
   box_office_world INT UNSIGNED,
   box_office_RU INT UNSIGNED,
   viewers INT UNSIGNED,
   release_date DATE,
   age_rate INT UNSIGNED,
   runtime INT UNSIGNED,
   storyline TEXT, 
   expectancy_rating VARCHAR(10)
);



-- reviews
DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  author_id INT UNSIGNED NOT NULL,
  movie_id INT UNSIGNED NOT NULL,
  header VARCHAR(255),
  body TEXT NOT NULL,
  review_type ENUM ('positive', 'negative', 'neutral'),
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT reviews_author_id_fk 
    FOREIGN KEY (author_id) REFERENCES users(id),
  CONSTRAINT reviews_movie_id_fk 
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);


-- users_rates
DROP TABLE IF EXISTS users_rates;
CREATE TABLE users_rates (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  movie_id INT UNSIGNED NOT NULL,
  rate INT UNSIGNED NOT NULL,
  CONSTRAINT users_rates_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT users_rates_movie_id_fk 
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);


-- friendship
DROP TABLE IF EXISTS friendship;
CREATE TABLE friendship (
  user_id INT UNSIGNED NOT NULL,
  friend_id INT UNSIGNED NOT NULL,
  status ENUM('added', 'removed'),
  requested_at DATETIME DEFAULT NOW(),
  PRIMARY KEY (user_id, friend_id), 
  CONSTRAINT friendship_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT friendship_friend_id_fk 
    FOREIGN KEY (friend_id) REFERENCES users(id)
);


-- persons 
DROP TABLE IF EXISTS persons;
CREATE TABLE persons (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  photo_id INT UNSIGNED,
  height INT UNSIGNED,
  birthday DATE,
  place_of_birth VARCHAR(100),
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT persons_photo_id_fk 
    FOREIGN KEY (photo_id) REFERENCES media(id) ON DELETE SET NULL  
);

-- film_crew
DROP TABLE IF EXISTS film_crew;
CREATE TABLE film_crew (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  movie_id INT UNSIGNED NOT NULL,
  person_id INT UNSIGNED NOT NULL,
  position_type ENUM('actor', 'director', 'screenwriter', 'producer', 'cameraman', 'composer', 'art director'),
  CONSTRAINT film_crew_movie_id_fk 
    FOREIGN KEY (movie_id) REFERENCES movies(id),
  CONSTRAINT film_crew_person_id_fk 
    FOREIGN KEY (person_id) REFERENCES persons(id)
);

-- genres 
DROP TABLE IF EXISTS genres;
CREATE TABLE genres (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  movie_id INT UNSIGNED NOT NULL,
  genre_type ENUM ('comedy', 'action', 'drama', 'thriller', 'romance', 'horror', 'sci-fi'),
  CONSTRAINT genres_movie_id_fk
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);

CREATE INDEX genre_type_idx ON genres(genre_type);


-- articles
DROP TABLE IF EXISTS articles;
CREATE TABLE articles (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  movie_id INT UNSIGNED NOT NULL,
  author_id INT UNSIGNED NOT NULL,
  header VARCHAR(255),
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  created_at DATETIME DEFAULT NOW(),
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  CONSTRAINT articles_movie_id_fk
    FOREIGN KEY (movie_id) REFERENCES movies(id),
  CONSTRAINT articles_author_id_fk
    FOREIGN KEY (author_id) REFERENCES users(id),
  CONSTRAINT articles_media_id_fk 
    FOREIGN KEY (media_id) REFERENCES media(id) ON DELETE SET NULL  
);



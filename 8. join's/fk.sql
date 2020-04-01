use vk;


ALTER TABLE profiles MODIFY photo_id INT UNSIGNED;

ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk
   FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE, 
  ADD CONSTRAINT profiles_photo_id_fk
   FOREIGN KEY (photo_id) REFERENCES media(id)
    ON DELETE SET NULL;


-- сообщения

DESC messages;

ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk 
    FOREIGN KEY (to_user_id) REFERENCES users(id);
   

-- друзья

DESC friendship;

ALTER TABLE friendship
  ADD CONSTRAINT friendship_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_friend_id_fk 
    FOREIGN KEY (friend_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_status_id_fk 
    FOREIGN KEY (status_id) REFERENCES friendship_statuses(id);
   

  
-- сообщества

DESC communities;
DESC communities_users;

ALTER TABLE communities_users
  ADD CONSTRAINT communities_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT communities_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id);
   

-- медиа
DESC media;
DESC media_types;  

ALTER TABLE media
  ADD CONSTRAINT media_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT media_type_id_fk 
    FOREIGN KEY (media_type_id) REFERENCES media_types(id);

-- встречи

DESC meetings;
DESC meetings_users;


ALTER TABLE meetings_users
  ADD CONSTRAINT meetings_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT meetings_id_fk 
    FOREIGN KEY (meeting_id) REFERENCES meetings(id);

-- лайки

DESC likes;
DESC target_types;

ALTER TABLE likes
  ADD CONSTRAINT likes_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT likes_target_type_id_fk 
    FOREIGN KEY (target_type_id) REFERENCES target_types(id);

-- посты
DESC posts;

ALTER TABLE posts
  ADD CONSTRAINT posts_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT media_id_fk 
    FOREIGN KEY (media_id) REFERENCES media(id);




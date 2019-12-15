DROP DATABASE IF EXISTS tg;
CREATE DATABASE tg;
USE tg;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id serial primary key,
	nick varchar(50) NOT NULL,
	username varchar(50) NOT NULL UNIQUE,
	bio varchar(255),
	phone BIGINT UNSIGNED NOT NULL,
	userpic_id BIGINT UNSIGNED,
	is_deleted BOOL DEFAULT false,

	INDEX users_phone_idx(phone),
	INDEX users_nick_idx(nick),
	INDEX users_username_idx(username)
);


DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
	id INT UNSIGNED PRIMARY KEY,
	name ENUM('photo', 'sticker', 'video', 'gif', 'audio_message', 'video_message', 'generic_file')
);

DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id SERIAL PRIMARY KEY,
	file_link varchar(255) NOT NULL,
	media_type_id int UNSIGNED NOT NULL,
	uploaded_by_user_id BIGINT UNSIGNED NOT NULL,
	created_at datetime default now(),
	FOREIGN KEY (uploaded_by_user_id) REFERENCES users(id),
	FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

DROP TABLE IF EXISTS conversations;
CREATE TABLE conversations (
	id serial primary key,
	name varchar(255) NOT NULL,
	link varchar(255) NOT NULL,
	description varchar(255),
	group_image BIGINT UNSIGNED,
	created_at datetime NOT NULL default now(),
	created_by BIGINT UNSIGNED NOT NULL, 
	type ENUM ('private', 'chat', 'channel'), -- подумать о приватных диалогах
	pinned_id BIGINT UNSIGNED,
	is_deleted BOOL DEFAULT false,

	INDEX conv_name_idx(name, is_deleted),
	FOREIGN KEY (group_image) REFERENCES media(id),
	FOREIGN KEY (created_by) REFERENCES users(id)
);

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	link varchar(255),
	content text,
	media_id BIGINT UNSIGNED,
	from_id BIGINT UNSIGNED NOT NULL,
	conversation_id BIGINT UNSIGNED NOT NULL,
	posted_at DATETIME DEFAULT now(),
	edited_at DATETIME,
	is_deleted BOOL DEFAULT false,
	forwarded_id BIGINT UNSIGNED DEFAULT NULL, 
	reply_to_id BIGINT UNSIGNED DEFAULT NULL,
	
	INDEX conversation(conversation_id, is_deleted),
	INDEX from_users(from_id, is_deleted),

	FOREIGN KEY (forwarded_id) REFERENCES messages(id),
	FOREIGN KEY (reply_to_id) REFERENCES messages(id),
	FOREIGN KEY (media_id) REFERENCES media(id),
	FOREIGN KEY (from_id) REFERENCES users(id),
	FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);


-- adding circular reference
ALTER TABLE conversations
ADD FOREIGN KEY (pinned_id) REFERENCES messages(id);


DROP TABLE IF EXISTS sticker_packs;
CREATE TABLE sticker_packs (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	created_at DATETIME default now(),
	created_by BIGINT UNSIGNED NOT NULL,

	INDEX packs_name_idx(name),
	FOREIGN KEY (created_by) REFERENCES users(id)
);

-- CROSS TABLES

DROP TABLE IF EXISTS users_x_conversations;
CREATE TABLE users_x_conversations (
	user_id BIGINT UNSIGNED NOT NULL,
	conversation_id BIGINT UNSIGNED NOT NULL,

	PRIMARY KEY (user_id, conversation_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);

DROP TABLE IF EXISTS conversations_x_admins;
CREATE TABLE conversations_x_admins (
	conversation_id BIGINT UNSIGNED NOT NULL,
	admin_id BIGINT UNSIGNED NOT NULL,

	PRIMARY KEY (conversation_id, admin_id),
	FOREIGN KEY (conversation_id) REFERENCES conversations(id),
	FOREIGN KEY (admin_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS users_x_contacts;
CREATE TABLE users_x_contacts (
	user_id BIGINT UNSIGNED NOT NULL,
	contact_id BIGINT UNSIGNED NOT NULL,

	PRIMARY KEY (user_id, contact_id),
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (contact_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS stickers_x_packs;
CREATE TABLE stickers_x_packs (
	pack_id BIGINT UNSIGNED NOT NULL,
	sticker_id BIGINT UNSIGNED NOT NULL,

	PRIMARY KEY (pack_id, sticker_id),
	FOREIGN KEY (pack_id) REFERENCES sticker_packs(id),
	FOREIGN KEY (sticker_id) REFERENCES media(id)
);

-- ???

DROP TABLE IF EXISTS hashtags_x_messages;
CREATE TABLE hashtags_x_messages (
	hashtag VARCHAR(255) NOT NULL,
	message_id BIGINT UNSIGNED NOT NULL,
	
	PRIMARY KEY (hashtag, message_id),
	FOREIGN KEY (message_id) REFERENCES messages(id)
);


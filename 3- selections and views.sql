USE tg;

CREATE OR REPLACE VIEW conversation_messages
AS
	SELECT conversation_id AS c_id, msg.id AS m_id, u.username as user, link AS link_to_post, content, md.file_link, md.media_type_id, media_id, posted_at, edited_at, forwarded_id, reply_to_id
	FROM messages msg
		JOIN media AS md ON msg.media_id = md.id
		JOIN users AS u ON msg.from_id = u.id
	WHERE msg.is_deleted = false
	ORDER BY msg.id;

SELECT *
FROM conversation_messages
WHERE c_id = 5;


CREATE OR REPLACE VIEW chat_photo_gallery
AS
	SELECT conversation_id AS c_id, u.username AS USER, md.file_link, media_id, posted_at
	FROM messages msg
		JOIN media AS md ON msg.media_id = md.id
		JOIN users AS u ON msg.from_id = u.id
	WHERE md.media_type_id = (SELECT id FROM media_types WHERE name = 'photo')
	AND msg.is_deleted = FALSE;

SELECT * FROM chat_photo_gallery
WHERE c_id = 4;


DELIMITER //
CREATE FUNCTION test_mutual(user_to_check BIGINT, contact_to_check BIGINT)
RETURNS BOOL READS SQL DATA
  BEGIN
	DECLARE is_mutual BOOL;
	SET is_mutual =
	  (SELECT COUNT(*)
		FROM users_x_contacts WHERE user_id = contact_to_check
		AND contact_id = user_to_check) > 0;
	RETURN is_mutual;
  END//
DELIMITER ;

CREATE OR REPLACE VIEW contact_list
AS
	SELECT user_id, contact_id, users.id, users.username, users.nick, users.phone
		FROM users_x_contacts
			JOIN users ON contact_id = users.id
	 	WHERE test_mutual(user_id, contact_id) = TRUE;
	 
SELECT * FROM contact_list
	WHERE user_id = 7; -- (7, 14), (17, 47), (28, 71) - âçàèìíûå ïàðû


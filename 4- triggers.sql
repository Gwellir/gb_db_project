USE tg;

DROP TRIGGER IF EXISTS check_pinned_message;
DELIMITER //

CREATE TRIGGER check_pinned_message BEFORE UPDATE ON conversations
FOR EACH ROW
begin
    IF NEW.pinned_id NOT IN (SELECT id FROM messages WHERE conversation_id = NEW.id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pin Denied. Message does not belong to this chat!';
    END IF;
END//

DELIMITER ;

UPDATE conversations
SET pinned_id = 58 -- 82, 707 òàêæå ïðèíàäëåæàò ïåðâîìó ÷àòó
WHERE id = 1;


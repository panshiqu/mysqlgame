SHOW VARIABLES LIKE 'event_scheduler'
SET GLOBAL event_scheduler = 1;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE game.user_information;
TRUNCATE game.user_treasure;
TRUNCATE log.user_treasure_log_20170621;
SET FOREIGN_KEY_CHECKS = 1;
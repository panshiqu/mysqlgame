/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 50716
 Source Host           : localhost
 Source Database       : log

 Target Server Type    : MySQL
 Target Server Version : 50716
 File Encoding         : utf-8

 Date: 12/20/2016 16:44:49 PM
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `user_treasure_log_20161220`
-- ----------------------------
DROP TABLE IF EXISTS `user_treasure_log_20161220`;
CREATE TABLE `user_treasure_log_20161220` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增编号',
  `user_id` int(10) unsigned NOT NULL COMMENT '用户编号',
  `cur_score` bigint(20) unsigned NOT NULL COMMENT '当前分数',
  `var_score` bigint(20) unsigned NOT NULL COMMENT '变化分数',
  `cur_diamond` bigint(20) unsigned NOT NULL COMMENT '当前钻石',
  `var_diamond` bigint(20) unsigned NOT NULL COMMENT '变化钻石',
  `change_type` enum('REGISTER','WINLOSE','SIGNIN') NOT NULL DEFAULT 'WINLOSE' COMMENT '类型',
  `change_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '时间戳',
  PRIMARY KEY (`id`),
  KEY `index_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `foreign_key_user_id_20161220` FOREIGN KEY (`user_id`) REFERENCES `game`.`user_information` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
--  Procedure structure for `procedure_create_user_treasure_log`
-- ----------------------------
DROP PROCEDURE IF EXISTS `procedure_create_user_treasure_log`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `procedure_create_user_treasure_log`(IN SuffixTime CHAR(8))
    DETERMINISTIC
BEGIN
SET @sql_create = CONCAT("CREATE TABLE `user_treasure_log_",SuffixTime,"` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增编号',
  `user_id` int(10) unsigned NOT NULL COMMENT '用户编号',
  `cur_score` bigint(20) unsigned NOT NULL COMMENT '当前分数',
  `var_score` bigint(20) unsigned NOT NULL COMMENT '变化分数',
  `cur_diamond` bigint(20) unsigned NOT NULL COMMENT '当前钻石',
  `var_diamond` bigint(20) unsigned NOT NULL COMMENT '变化钻石',
  `change_type` enum('REGISTER','WINLOSE','SIGNIN') NOT NULL DEFAULT 'WINLOSE' COMMENT '类型',
  `change_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '时间戳',
  PRIMARY KEY (`id`),
  KEY `index_user_id` (`user_id`) USING BTREE,
  CONSTRAINT `foreign_key_user_id_",SuffixTime,"` FOREIGN KEY (`user_id`) REFERENCES `game`.`user_information` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;");

PREPARE stmt_create FROM @sql_create;
EXECUTE stmt_create;
DEALLOCATE PREPARE stmt_create;
END
 ;;
delimiter ;

-- ----------------------------
--  Event structure for `event_create_user_treasure_log`
-- ----------------------------
DROP EVENT IF EXISTS `event_create_user_treasure_log`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` EVENT `event_create_user_treasure_log` ON SCHEDULE EVERY 1 DAY STARTS '2016-12-12 01:00:00' ON COMPLETION PRESERVE ENABLE DO CALL procedure_create_user_treasure_log(DATE_FORMAT(DATE_ADD(NOW(),INTERVAL 1 DAY),"%Y%m%d"))
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

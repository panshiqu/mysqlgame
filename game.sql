/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 50718
 Source Host           : localhost
 Source Database       : game

 Target Server Type    : MySQL
 Target Server Version : 50718
 File Encoding         : utf-8

 Date: 06/21/2017 22:24:37 PM
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `game_config`
-- ----------------------------
DROP TABLE IF EXISTS `game_config`;
CREATE TABLE `game_config` (
  `title` varchar(32) NOT NULL COMMENT '键',
  `content` varchar(64) NOT NULL COMMENT '值',
  `description` varchar(255) NOT NULL COMMENT '描述',
  PRIMARY KEY (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
--  Records of `game_config`
-- ----------------------------
BEGIN;
INSERT INTO `game_config` VALUES ('InitDiamond', '10', '新注册用户初始钻石'), ('InitScore', '10000', '新注册用户初始分数');
COMMIT;

-- ----------------------------
--  Table structure for `sign_in_record`
-- ----------------------------
DROP TABLE IF EXISTS `sign_in_record`;
CREATE TABLE `sign_in_record` (
  `user_id` int(10) unsigned NOT NULL COMMENT '用户编号',
  `continuous_days` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '连续天数',
  `latest_sign_in_time` timestamp NOT NULL DEFAULT '2016-01-01 00:00:00' COMMENT '最新的签到时间',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `foreign_key_user_id_sign_in_record` FOREIGN KEY (`user_id`) REFERENCES `user_information` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
--  Table structure for `sign_in_reward`
-- ----------------------------
DROP TABLE IF EXISTS `sign_in_reward`;
CREATE TABLE `sign_in_reward` (
  `day` tinyint(3) unsigned NOT NULL COMMENT '连续天数',
  `score` int(10) unsigned NOT NULL COMMENT '奖励分数',
  `diamond` int(10) unsigned NOT NULL COMMENT '奖励钻石',
  PRIMARY KEY (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
--  Records of `sign_in_reward`
-- ----------------------------
BEGIN;
INSERT INTO `sign_in_reward` VALUES ('1', '1000', '0'), ('2', '2000', '0'), ('3', '3000', '0'), ('4', '4000', '1'), ('5', '6000', '2'), ('6', '8000', '3'), ('7', '10000', '5');
COMMIT;

-- ----------------------------
--  Table structure for `user_information`
-- ----------------------------
DROP TABLE IF EXISTS `user_information`;
CREATE TABLE `user_information` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '用户编号',
  `user_account` varchar(64) NOT NULL COMMENT '账号',
  `user_password` varchar(32) NOT NULL DEFAULT '111111' COMMENT '密码',
  `user_name` varchar(24) NOT NULL COMMENT '名称',
  `user_icon` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '头像',
  `user_level` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT '等级',
  `user_gender` enum('MALE','FEMALE','UNKNOWN') NOT NULL DEFAULT 'FEMALE' COMMENT '性别',
  `bind_phone` char(11) NOT NULL DEFAULT '' COMMENT '手机号',
  `is_robot` tinyint(1) unsigned NOT NULL DEFAULT '0' COMMENT '是否机器人',
  `register_ip` varchar(48) NOT NULL COMMENT '注册IP',
  `register_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `register_machine` varchar(64) NOT NULL COMMENT '机器码',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10000000 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
--  Table structure for `user_treasure`
-- ----------------------------
DROP TABLE IF EXISTS `user_treasure`;
CREATE TABLE `user_treasure` (
  `user_id` int(10) unsigned NOT NULL COMMENT '用户编号',
  `user_score` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '分数',
  `user_diamond` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '钻石',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `foreign_key_user_id_user_treasure` FOREIGN KEY (`user_id`) REFERENCES `user_information` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
--  View structure for `view_information_treasure`
-- ----------------------------
DROP VIEW IF EXISTS `view_information_treasure`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_information_treasure` AS select `user_information`.`user_id` AS `user_id`,`user_information`.`user_account` AS `user_account`,`user_information`.`user_password` AS `user_password`,`user_information`.`user_name` AS `user_name`,`user_information`.`user_icon` AS `user_icon`,`user_information`.`user_level` AS `user_level`,`user_information`.`user_gender` AS `user_gender`,`user_information`.`bind_phone` AS `bind_phone`,`user_information`.`is_robot` AS `is_robot`,`user_information`.`register_ip` AS `register_ip`,`user_information`.`register_date` AS `register_date`,`user_information`.`register_machine` AS `register_machine`,`user_treasure`.`user_score` AS `user_score`,`user_treasure`.`user_diamond` AS `user_diamond` from (`user_information` join `user_treasure`) where (`user_information`.`user_id` = `user_treasure`.`user_id`);

-- ----------------------------
--  Procedure structure for `procedure_change_treasure`
-- ----------------------------
DROP PROCEDURE IF EXISTS `procedure_change_treasure`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `procedure_change_treasure`(IN UserID INT, IN VarScore BIGINT, IN VarDiamond BIGINT, IN ChangeType INT)
BEGIN
DECLARE UserScore BIGINT;
DECLARE UserDiamond BIGINT;

SET @UserScore = NULL;
SET @UserDiamond = NULL;

-- 查询指定用户财富
SELECT user_score, user_diamond INTO @UserScore, @UserDiamond FROM user_treasure WHERE user_id = UserID;

-- 插入用户财富日志
SET @sql_insert = CONCAT("INSERT INTO log.user_treasure_log_",DATE_FORMAT(NOW(),"%Y%m%d")," (user_id, cur_score, var_score, cur_diamond, var_diamond, change_type) VALUES (",UserID,", ?, ",VarScore,", ?, ",VarDiamond,", ",ChangeType,");");
PREPARE stmt_insert FROM @sql_insert;
EXECUTE stmt_insert USING @UserScore, @UserDiamond;
DEALLOCATE PREPARE stmt_insert;

-- 更新指定用户财富
UPDATE user_treasure SET user_score = user_score + VarScore, user_diamond = user_diamond + VarDiamond WHERE user_id = UserID;
END
 ;;
delimiter ;

-- ----------------------------
--  Procedure structure for `procedure_insert_information`
-- ----------------------------
DROP PROCEDURE IF EXISTS `procedure_insert_information`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `procedure_insert_information`(IN UserAccount VARCHAR(64), IN UserName VARCHAR(24), IN BindPhone CHAR(11), IN RegisterIP VARCHAR(48), IN RegisterMachine VARCHAR(64))
BEGIN
DECLARE UserID INT;
DECLARE InitScore VARCHAR(64);

SET @UserID = NULL;
SET @InitScore = NULL;

-- 插入用户信息
INSERT INTO user_information (user_account, user_name, bind_phone, register_ip, register_machine) VALUES (UserAccount, UserName, BindPhone, RegisterIP, RegisterMachine);

-- 获取用户编号
SET @UserID = LAST_INSERT_ID();

-- 插入签到记录
INSERT INTO sign_in_record (user_id) VALUES (@UserID);

-- 插入用户财富
INSERT INTO user_treasure (user_id) VALUES (@UserID);

-- 新注册用户初始分数
SELECT Content INTO @InitScore FROM game_config WHERE Title = "InitScore";

-- 调用财富变化存储过程
CALL procedure_change_treasure(@UserID, @InitScore, 0, 1);
END
 ;;
delimiter ;

-- ----------------------------
--  Procedure structure for `procedure_user_sign_in`
-- ----------------------------
DROP PROCEDURE IF EXISTS `procedure_user_sign_in`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `procedure_user_sign_in`(IN UserID INT, INOUT ErrNO INT, INOUT ErrDesc VARCHAR(255))
    DETERMINISTIC
SIGNIN:BEGIN
DECLARE TotalDays TINYINT;
DECLARE ContinuousDays TINYINT;
DECLARE LatestSignInTime TIMESTAMP;
DECLARE ScoreReward INT;
DECLARE DiamondReward INT;
DECLARE MaxDay TINYINT;

SET @TotalDays = NULL;
SET @ContinuousDays = NULL;
SET @LatestSignInTime = NULL;
SET @ScoreReward = NULL;
SET @DiamondReward = NULL;
SET @MaxDay = NULL;

-- 查询用户签到记录
SELECT continuous_days, latest_sign_in_time INTO @ContinuousDays, @LatestSignInTime FROM sign_in_record WHERE user_id = UserID;

-- 用户签到记录不存在
IF @LatestSignInTime IS NULL THEN
	SET ErrNO = 1, ErrDesc = "用户不存在";
	LEAVE SIGNIN;
END IF;

CASE TO_DAYS(NOW()) - TO_DAYS(@LatestSignInTime)
	-- 用户今天已经签过到
	WHEN 0 THEN
	BEGIN
		SET ErrNO = 2, ErrDesc = "今天已签过到";
		LEAVE SIGNIN;
	END;
	
	-- 昨天签到今天连续签到
	WHEN 1 THEN
	BEGIN
		-- 查询最大连续天数
		SELECT MAX(`day`) INTO @MaxDay FROM sign_in_reward;

		-- 更新用户签到记录
		IF @ContinuousDays + 1 > @MaxDay THEN
			SET @TotalDays = @ContinuousDays;
			UPDATE sign_in_record SET latest_sign_in_time = NOW() WHERE user_id = UserID;
		ELSE
			SET @TotalDays = @ContinuousDays + 1;
			UPDATE sign_in_record SET continuous_days = @ContinuousDays + 1, latest_sign_in_time = NOW() WHERE user_id = UserID;
		END IF;
	END;

	-- 昨天未签到重置连续天数
	ELSE
	BEGIN
		-- 更新用户签到记录
		SET @TotalDays = 1;
		UPDATE sign_in_record SET continuous_days = 1, latest_sign_in_time = NOW() WHERE user_id = UserID;
	END;
END CASE;

-- 查询签到奖励
SELECT score, diamond INTO @ScoreReward, @DiamondReward FROM sign_in_reward WHERE `day` = @TotalDays;

-- 发放签到奖励
CALL procedure_change_treasure(UserID, @ScoreReward, @DiamondReward, 3);
END
 ;;
delimiter ;

-- ----------------------------
--  Procedure structure for `procedure_user_sign_in_days`
-- ----------------------------
DROP PROCEDURE IF EXISTS `procedure_user_sign_in_days`;
delimiter ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `procedure_user_sign_in_days`(IN UserID INT, INOUT Can TINYINT, INOUT Days TINYINT)
    DETERMINISTIC
SIGNIN:BEGIN
DECLARE ContinuousDays TINYINT;
DECLARE LatestSignInTime TIMESTAMP;

SET @ContinuousDays = NULL;
SET @LatestSignInTime = NULL;

-- 查询用户签到记录
SELECT continuous_days, latest_sign_in_time INTO @ContinuousDays, @LatestSignInTime FROM sign_in_record WHERE user_id = UserID;

-- 用户签到记录不存在
IF @LatestSignInTime IS NULL THEN
	LEAVE SIGNIN;
END IF;

-- 能否签到及连续天数
CASE TO_DAYS(NOW()) - TO_DAYS(@LatestSignInTime)
	WHEN 1 THEN SET Can = TRUE, Days = @ContinuousDays;
	WHEN 0 THEN SET Can = FALSE, Days = @ContinuousDays;
	ELSE UPDATE sign_in_record SET continuous_days = 0 WHERE user_id = UserID;
END CASE;
END
 ;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;

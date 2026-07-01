CREATE database if NOT EXISTS `ddss` default character set utf8mb4 collate utf8mb4_unicode_ci;
use `ddss`;

SET NAMES utf8mb4;
/*
 Navicat Premium Dump SQL

 Source Server         : 192.168.52.100
 Source Server Type    : MySQL
 Source Server Version : 80034 (8.0.34)
 Source Host           : 192.168.52.100:3306
 Source Schema         : ddss

 Target Server Type    : MySQL
 Target Server Version : 80034 (8.0.34)
 File Encoding         : 65001

 Date: 24/06/2026 09:37:55
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ddss_resource
-- ----------------------------
DROP TABLE IF EXISTS `ddss_resource`;
CREATE TABLE `ddss_resource`  (
  `resource_id` bigint NOT NULL AUTO_INCREMENT COMMENT '璧勬簮ID',
  `resource_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璧勬簮鍚嶇О',
  `file_size` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏂囦欢澶у皬',
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏂囦欢绫诲瀷',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏂囦欢璺緞',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`resource_id`) USING BTREE,
  INDEX `idx_resource_name`(`resource_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '璧勬簮绠＄悊琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ddss_resource
-- ----------------------------

-- ----------------------------
-- Table structure for ddss_video
-- ----------------------------
DROP TABLE IF EXISTS `ddss_video`;
CREATE TABLE `ddss_video`  (
  `video_id` bigint NOT NULL AUTO_INCREMENT COMMENT '瑙嗛ID',
  `video_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙嗛鍚嶇О',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙嗛URL',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '灏侀潰鍥綰RL',
  `duration` int NULL DEFAULT NULL COMMENT '鏃堕暱(绉?',
  `file_size` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏂囦欢澶у皬',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?,
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`video_id`) USING BTREE,
  INDEX `idx_video_name`(`video_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瑙嗛绠＄悊琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ddss_video
-- ----------------------------

-- ----------------------------
-- 璐㈠姟绠＄悊琛?-- ----------------------------
DROP TABLE IF EXISTS `sys_finance`;
CREATE TABLE `sys_finance` (
  `finance_id` bigint NOT NULL AUTO_INCREMENT COMMENT '璁板綍ID',
  `creditor_name` varchar(100) NOT NULL COMMENT '娆犳鏂瑰悕绉?,
  `loan_amount` decimal(12,2) DEFAULT NULL COMMENT '鍊熸鎬婚',
  `loan_date` date DEFAULT NULL COMMENT '鍊熸鏃ユ湡',
  `repayment_start_date` date DEFAULT NULL COMMENT '杩樻寮€濮嬫棩鏈?,
  `repayment_end_date` date DEFAULT NULL COMMENT '杩樻缁撴潫鏃ユ湡',
  `loan_term` int DEFAULT NULL COMMENT '鍊熸鏈熼檺(鏈?',
  `repayment_day` int DEFAULT NULL COMMENT '姣忔湀杩樻鏃?鍑犲彿)',
  `monthly_payment` decimal(12,2) DEFAULT NULL COMMENT '鏈堣繕娆鹃',
  `interest_rate` decimal(5,2) DEFAULT NULL COMMENT '鍒╃巼(%)',
  `interest_amount` decimal(12,2) DEFAULT NULL COMMENT '鍒╂伅鎬婚',
  `early_settlement_amount` decimal(12,2) DEFAULT NULL COMMENT '鎻愬墠缁撴竻閲戦',
  `remaining_amount` decimal(12,2) DEFAULT NULL COMMENT '鍓╀綑鏈繕閲戦',
  `paid_amount` decimal(12,2) DEFAULT NULL COMMENT '宸茶繕閲戦',
  `status` char(1) DEFAULT '0' COMMENT '鐘舵€?0杩樻涓?1宸茬粨娓?2閫炬湡)',
  `remark` varchar(500) DEFAULT NULL COMMENT '澶囨敞',
  `create_by` varchar(64) DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`finance_id`),
  INDEX `idx_creditor_name`(`creditor_name`),
  INDEX `idx_status`(`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='璐㈠姟绠＄悊琛?;

-- ----------------------------
-- 鑿滃崟: 璐㈠姟绠＄悊
-- ----------------------------

INSERT INTO `ddss_video` VALUES (1, '1', '2', NULL, NULL, NULL, '0', NULL, 'admin', '2026-06-23 19:08:19', '', '2026-06-23 19:08:19');

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '缂栧彿',
  `table_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '琛ㄥ悕绉?,
  `table_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '琛ㄦ弿杩?,
  `sub_table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鍏宠仈瀛愯〃鐨勮〃鍚?,
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '瀛愯〃鍏宠仈鐨勫閿悕',
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '瀹炰綋绫诲悕绉?,
  `tpl_category` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'crud' COMMENT '浣跨敤鐨勬ā鏉匡紙crud鍗曡〃鎿嶄綔 tree鏍戣〃鎿嶄綔锛?,
  `tpl_web_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍓嶇妯℃澘绫诲瀷锛坋lement-ui妯＄増 element-plus妯＄増锛?,
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐢熸垚鍖呰矾寰?,
  `module_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐢熸垚妯″潡鍚?,
  `business_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐢熸垚涓氬姟鍚?,
  `function_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐢熸垚鍔熻兘鍚?,
  `function_author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐢熸垚鍔熻兘浣滆€?,
  `gen_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鐢熸垚浠ｇ爜鏂瑰紡锛?zip鍘嬬缉鍖?1鑷畾涔夎矾寰勶級',
  `gen_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '/' COMMENT '鐢熸垚璺緞锛堜笉濉粯璁ら」鐩矾寰勶級',
  `options` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鍏跺畠鐢熸垚閫夐」',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '浠ｇ爜鐢熸垚涓氬姟琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint NOT NULL AUTO_INCREMENT COMMENT '缂栧彿',
  `table_id` bigint NULL DEFAULT NULL COMMENT '褰掑睘琛ㄧ紪鍙?,
  `column_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鍒楀悕绉?,
  `column_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鍒楁弿杩?,
  `column_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鍒楃被鍨?,
  `java_type` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA绫诲瀷',
  `java_field` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA瀛楁鍚?,
  `is_pk` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏄惁涓婚敭锛?鏄級',
  `is_increment` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏄惁鑷锛?鏄級',
  `is_required` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏄惁蹇呭～锛?鏄級',
  `is_insert` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏄惁涓烘彃鍏ュ瓧娈碉紙1鏄級',
  `is_edit` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏄惁缂栬緫瀛楁锛?鏄級',
  `is_list` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏄惁鍒楄〃瀛楁锛?鏄級',
  `is_query` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏄惁鏌ヨ瀛楁锛?鏄級',
  `query_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'EQ' COMMENT '鏌ヨ鏂瑰紡锛堢瓑浜庛€佷笉绛変簬銆佸ぇ浜庛€佸皬浜庛€佽寖鍥达級',
  `html_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏄剧ず绫诲瀷锛堟枃鏈銆佹枃鏈煙銆佷笅鎷夋銆佸閫夋銆佸崟閫夋銆佹棩鏈熸帶浠讹級',
  `dict_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '瀛楀吀绫诲瀷',
  `sort` int NULL DEFAULT NULL COMMENT '鎺掑簭',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '浠ｇ爜鐢熸垚涓氬姟琛ㄥ瓧娈? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_blob_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE `qrtz_blob_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_name鐨勫閿?,
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_group鐨勫閿?,
  `blob_data` blob NULL COMMENT '瀛樻斁鎸佷箙鍖朤rigger瀵硅薄',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Blob绫诲瀷鐨勮Е鍙戝櫒琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_blob_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_calendars
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE `qrtz_calendars`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏃ュ巻鍚嶇О',
  `calendar` blob NOT NULL COMMENT '瀛樻斁鎸佷箙鍖朿alendar瀵硅薄',
  PRIMARY KEY (`sched_name`, `calendar_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鏃ュ巻淇℃伅琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_calendars
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_cron_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE `qrtz_cron_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_name鐨勫閿?,
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_group鐨勫閿?,
  `cron_expression` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'cron琛ㄨ揪寮?,
  `time_zone_id` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏃跺尯',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Cron绫诲瀷鐨勮Е鍙戝櫒琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_cron_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_fired_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE `qrtz_fired_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `entry_id` varchar(95) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍣ㄥ疄渚媔d',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_name鐨勫閿?,
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_group鐨勫閿?,
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍣ㄥ疄渚嬪悕',
  `fired_time` bigint NOT NULL COMMENT '瑙﹀彂鐨勬椂闂?,
  `sched_time` bigint NOT NULL COMMENT '瀹氭椂鍣ㄥ埗瀹氱殑鏃堕棿',
  `priority` int NOT NULL COMMENT '浼樺厛绾?,
  `state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐘舵€?,
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '浠诲姟鍚嶇О',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '浠诲姟缁勫悕',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏄惁骞跺彂',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏄惁鎺ュ彈鎭㈠鎵ц',
  PRIMARY KEY (`sched_name`, `entry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '宸茶Е鍙戠殑瑙﹀彂鍣ㄨ〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_fired_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_job_details
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE `qrtz_job_details`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浠诲姟鍚嶇О',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浠诲姟缁勫悕',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐩稿叧浠嬬粛',
  `job_class_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鎵ц浠诲姟绫诲悕绉?,
  `is_durable` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏄惁鎸佷箙鍖?,
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏄惁骞跺彂',
  `is_update_data` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏄惁鏇存柊鏁版嵁',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏄惁鎺ュ彈鎭㈠鎵ц',
  `job_data` blob NULL COMMENT '瀛樻斁鎸佷箙鍖杍ob瀵硅薄',
  PRIMARY KEY (`sched_name`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '浠诲姟璇︾粏淇℃伅琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_job_details
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_locks
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE `qrtz_locks`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `lock_name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鎮茶閿佸悕绉?,
  PRIMARY KEY (`sched_name`, `lock_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瀛樺偍鐨勬偛瑙傞攣淇℃伅琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_locks
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_paused_trigger_grps
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE `qrtz_paused_trigger_grps`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_group鐨勫閿?,
  PRIMARY KEY (`sched_name`, `trigger_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鏆傚仠鐨勮Е鍙戝櫒琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_paused_trigger_grps
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_scheduler_state
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE `qrtz_scheduler_state`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀹炰緥鍚嶇О',
  `last_checkin_time` bigint NOT NULL COMMENT '涓婃妫€鏌ユ椂闂?,
  `checkin_interval` bigint NOT NULL COMMENT '妫€鏌ラ棿闅旀椂闂?,
  PRIMARY KEY (`sched_name`, `instance_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '璋冨害鍣ㄧ姸鎬佽〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_scheduler_state
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simple_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE `qrtz_simple_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_name鐨勫閿?,
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_group鐨勫閿?,
  `repeat_count` bigint NOT NULL COMMENT '閲嶅鐨勬鏁扮粺璁?,
  `repeat_interval` bigint NOT NULL COMMENT '閲嶅鐨勯棿闅旀椂闂?,
  `times_triggered` bigint NOT NULL COMMENT '宸茬粡瑙﹀彂鐨勬鏁?,
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '绠€鍗曡Е鍙戝櫒鐨勪俊鎭〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simple_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simprop_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE `qrtz_simprop_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_name鐨勫閿?,
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers琛╰rigger_group鐨勫閿?,
  `str_prop_1` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String绫诲瀷鐨則rigger鐨勭涓€涓弬鏁?,
  `str_prop_2` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String绫诲瀷鐨則rigger鐨勭浜屼釜鍙傛暟',
  `str_prop_3` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String绫诲瀷鐨則rigger鐨勭涓変釜鍙傛暟',
  `int_prop_1` int NULL DEFAULT NULL COMMENT 'int绫诲瀷鐨則rigger鐨勭涓€涓弬鏁?,
  `int_prop_2` int NULL DEFAULT NULL COMMENT 'int绫诲瀷鐨則rigger鐨勭浜屼釜鍙傛暟',
  `long_prop_1` bigint NULL DEFAULT NULL COMMENT 'long绫诲瀷鐨則rigger鐨勭涓€涓弬鏁?,
  `long_prop_2` bigint NULL DEFAULT NULL COMMENT 'long绫诲瀷鐨則rigger鐨勭浜屼釜鍙傛暟',
  `dec_prop_1` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal绫诲瀷鐨則rigger鐨勭涓€涓弬鏁?,
  `dec_prop_2` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal绫诲瀷鐨則rigger鐨勭浜屼釜鍙傛暟',
  `bool_prop_1` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean绫诲瀷鐨則rigger鐨勭涓€涓弬鏁?,
  `bool_prop_2` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean绫诲瀷鐨則rigger鐨勭浜屼釜鍙傛暟',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鍚屾鏈哄埗鐨勮閿佽〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simprop_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE `qrtz_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冨害鍚嶇О',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙﹀彂鍣ㄧ殑鍚嶅瓧',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙﹀彂鍣ㄦ墍灞炵粍鐨勫悕瀛?,
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details琛╦ob_name鐨勫閿?,
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details琛╦ob_group鐨勫閿?,
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐩稿叧浠嬬粛',
  `next_fire_time` bigint NULL DEFAULT NULL COMMENT '涓婁竴娆¤Е鍙戞椂闂达紙姣锛?,
  `prev_fire_time` bigint NULL DEFAULT NULL COMMENT '涓嬩竴娆¤Е鍙戞椂闂达紙榛樿涓?1琛ㄧず涓嶈Е鍙戯級',
  `priority` int NULL DEFAULT NULL COMMENT '浼樺厛绾?,
  `trigger_state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙﹀彂鍣ㄧ姸鎬?,
  `trigger_type` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙﹀彂鍣ㄧ殑绫诲瀷',
  `start_time` bigint NOT NULL COMMENT '寮€濮嬫椂闂?,
  `end_time` bigint NULL DEFAULT NULL COMMENT '缁撴潫鏃堕棿',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏃ョ▼琛ㄥ悕绉?,
  `misfire_instr` smallint NULL DEFAULT NULL COMMENT '琛ュ伩鎵ц鐨勭瓥鐣?,
  `job_data` blob NULL COMMENT '瀛樻斁鎸佷箙鍖杍ob瀵硅薄',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  INDEX `sched_name`(`sched_name` ASC, `job_name` ASC, `job_group` ASC) USING BTREE,
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `qrtz_job_details` (`sched_name`, `job_name`, `job_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瑙﹀彂鍣ㄨ缁嗕俊鎭〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '鍙傛暟涓婚敭',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍙傛暟鍚嶇О',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍙傛暟閿悕',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍙傛暟閿€?,
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '绯荤粺鍐呯疆锛圷鏄?N鍚︼級',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鍙傛暟閰嶇疆琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '涓绘鏋堕〉-榛樿鐨偆鏍峰紡鍚嶇О', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '钃濊壊 skin-blue銆佺豢鑹?skin-green銆佺传鑹?skin-purple銆佺孩鑹?skin-red銆侀粍鑹?skin-yellow');
INSERT INTO `sys_config` VALUES (2, '鐢ㄦ埛绠＄悊-璐﹀彿鍒濆瀵嗙爜', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '鍒濆鍖栧瘑鐮?123456');
INSERT INTO `sys_config` VALUES (3, '涓绘鏋堕〉-渚ц竟鏍忎富棰?, 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '娣辫壊涓婚theme-dark锛屾祬鑹蹭富棰榯heme-light');
INSERT INTO `sys_config` VALUES (4, '璐﹀彿鑷姪-楠岃瘉鐮佸紑鍏?, 'sys.account.captchaEnabled', 'true', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '鏄惁寮€鍚獙璇佺爜鍔熻兘锛坱rue寮€鍚紝false鍏抽棴锛?);
INSERT INTO `sys_config` VALUES (5, '璐﹀彿鑷姪-鏄惁寮€鍚敤鎴锋敞鍐屽姛鑳?, 'sys.account.registerUser', 'false', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '鏄惁寮€鍚敞鍐岀敤鎴峰姛鑳斤紙true寮€鍚紝false鍏抽棴锛?);
INSERT INTO `sys_config` VALUES (6, '鐢ㄦ埛鐧诲綍-榛戝悕鍗曞垪琛?, 'sys.login.blackIPList', '', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '璁剧疆鐧诲綍IP榛戝悕鍗曢檺鍒讹紝澶氫釜鍖归厤椤逛互;鍒嗛殧锛屾敮鎸佸尮閰嶏紙*閫氶厤銆佺綉娈碉級');
INSERT INTO `sys_config` VALUES (7, '鐢ㄦ埛绠＄悊-鍒濆瀵嗙爜淇敼绛栫暐', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '0锛氬垵濮嬪瘑鐮佷慨鏀圭瓥鐣ュ叧闂紝娌℃湁浠讳綍鎻愮ず锛?锛氭彁閱掔敤鎴凤紝濡傛灉鏈慨鏀瑰垵濮嬪瘑鐮侊紝鍒欏湪鐧诲綍鏃跺氨浼氭彁閱掍慨鏀瑰瘑鐮佸璇濇');
INSERT INTO `sys_config` VALUES (8, '鐢ㄦ埛绠＄悊-璐﹀彿瀵嗙爜鏇存柊鍛ㄦ湡', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '瀵嗙爜鏇存柊鍛ㄦ湡锛堝～鍐欐暟瀛楋紝鏁版嵁鍒濆鍖栧€间负0涓嶉檺鍒讹紝鑻ヤ慨鏀瑰繀椤讳负澶т簬0灏忎簬365鐨勬鏁存暟锛夛紝濡傛灉瓒呰繃杩欎釜鍛ㄦ湡鐧诲綍绯荤粺鏃讹紝鍒欏湪鐧诲綍鏃跺氨浼氭彁閱掍慨鏀瑰瘑鐮佸璇濇');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '閮ㄩ棬id',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '鐖堕儴闂╥d',
  `ancestors` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '绁栫骇鍒楄〃',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '閮ㄩ棬鍚嶇О',
  `order_num` int NULL DEFAULT 0 COMMENT '鏄剧ず椤哄簭',
  `leader` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '璐熻矗浜?,
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鑱旂郴鐢佃瘽',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '閭',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '閮ㄩ棬鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?,
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鍒犻櫎鏍囧織锛?浠ｈ〃瀛樺湪 2浠ｈ〃鍒犻櫎锛?,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 200 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '閮ㄩ棬琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', 'DDSS绉戞妧', 0, 'DDSS', '15888888888', 'admin@ddss.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (101, 100, '0,100', '娣卞湷鎬诲叕鍙?, 1, 'DDSS', '15888888888', 'admin@ddss.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (102, 100, '0,100', '闀挎矙鍒嗗叕鍙?, 2, 'DDSS', '15888888888', 'admin@ddss.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (103, 101, '0,100,101', '鐮斿彂閮ㄩ棬', 1, 'DDSS', '15888888888', 'admin@ddss.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (104, 101, '0,100,101', '甯傚満閮ㄩ棬', 2, 'DDSS', '15888888888', 'admin@ddss.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (105, 101, '0,100,101', '娴嬭瘯閮ㄩ棬', 3, 'DDSS', '15888888888', 'admin@ddss.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (106, 101, '0,100,101', '璐㈠姟閮ㄩ棬', 4, 'DDSS', '15888888888', 'admin@ddss.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (107, 101, '0,100,101', '杩愮淮閮ㄩ棬', 5, 'DDSS', '15888888888', 'admin@ddss.com', '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL);
INSERT INTO `sys_dept` VALUES (108, 102, '0,100,102', '甯傚満閮ㄩ棬', 1, 'DDSS', '15888888888', 'admin@ddss.com', '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL);
INSERT INTO `sys_dept` VALUES (109, 102, '0,100,102', '璐㈠姟閮ㄩ棬', 2, 'DDSS', '15888888888', 'admin@ddss.com', '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '瀛楀吀缂栫爜',
  `dict_sort` int NULL DEFAULT 0 COMMENT '瀛楀吀鎺掑簭',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '瀛楀吀鏍囩',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '瀛楀吀閿€?,
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '瀛楀吀绫诲瀷',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏍峰紡灞炴€э紙鍏朵粬鏍峰紡鎵╁睍锛?,
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '琛ㄦ牸鍥炴樉鏍峰紡',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '鏄惁榛樿锛圷鏄?N鍚︼級',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瀛楀吀鏁版嵁琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '鐢?, '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鎬у埆鐢?);
INSERT INTO `sys_dict_data` VALUES (2, 2, '濂?, '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鎬у埆濂?);
INSERT INTO `sys_dict_data` VALUES (3, 3, '鏈煡', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鎬у埆鏈煡');
INSERT INTO `sys_dict_data` VALUES (4, 1, '鏄剧ず', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鏄剧ず鑿滃崟');
INSERT INTO `sys_dict_data` VALUES (5, 2, '闅愯棌', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '闅愯棌鑿滃崟');
INSERT INTO `sys_dict_data` VALUES (6, 1, '姝ｅ父', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '姝ｅ父鐘舵€?);
INSERT INTO `sys_dict_data` VALUES (7, 2, '鍋滅敤', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鍋滅敤鐘舵€?);
INSERT INTO `sys_dict_data` VALUES (8, 1, '姝ｅ父', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '姝ｅ父鐘舵€?);
INSERT INTO `sys_dict_data` VALUES (9, 2, '鏆傚仠', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鍋滅敤鐘舵€?);
INSERT INTO `sys_dict_data` VALUES (10, 1, '榛樿', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '榛樿鍒嗙粍');
INSERT INTO `sys_dict_data` VALUES (11, 2, '绯荤粺', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '绯荤粺鍒嗙粍');
INSERT INTO `sys_dict_data` VALUES (12, 1, '鏄?, 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '绯荤粺榛樿鏄?);
INSERT INTO `sys_dict_data` VALUES (13, 2, '鍚?, 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '绯荤粺榛樿鍚?);
INSERT INTO `sys_dict_data` VALUES (14, 1, '閫氱煡', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '閫氱煡');
INSERT INTO `sys_dict_data` VALUES (15, 2, '鍏憡', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鍏憡');
INSERT INTO `sys_dict_data` VALUES (16, 1, '姝ｅ父', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '姝ｅ父鐘舵€?);
INSERT INTO `sys_dict_data` VALUES (17, 2, '鍏抽棴', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鍏抽棴鐘舵€?);
INSERT INTO `sys_dict_data` VALUES (18, 99, '鍏朵粬', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鍏朵粬鎿嶄綔');
INSERT INTO `sys_dict_data` VALUES (19, 1, '鏂板', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鏂板鎿嶄綔');
INSERT INTO `sys_dict_data` VALUES (20, 2, '淇敼', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '淇敼鎿嶄綔');
INSERT INTO `sys_dict_data` VALUES (21, 3, '鍒犻櫎', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鍒犻櫎鎿嶄綔');
INSERT INTO `sys_dict_data` VALUES (22, 4, '鎺堟潈', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鎺堟潈鎿嶄綔');
INSERT INTO `sys_dict_data` VALUES (23, 5, '瀵煎嚭', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '瀵煎嚭鎿嶄綔');
INSERT INTO `sys_dict_data` VALUES (24, 6, '瀵煎叆', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '瀵煎叆鎿嶄綔');
INSERT INTO `sys_dict_data` VALUES (25, 7, '寮洪€€', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '寮洪€€鎿嶄綔');
INSERT INTO `sys_dict_data` VALUES (26, 8, '鐢熸垚浠ｇ爜', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鐢熸垚鎿嶄綔');
INSERT INTO `sys_dict_data` VALUES (27, 9, '娓呯┖鏁版嵁', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '娓呯┖鎿嶄綔');
INSERT INTO `sys_dict_data` VALUES (28, 1, '鎴愬姛', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '姝ｅ父鐘舵€?);
INSERT INTO `sys_dict_data` VALUES (29, 2, '澶辫触', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鍋滅敤鐘舵€?);

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '瀛楀吀涓婚敭',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '瀛楀吀鍚嶇О',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '瀛楀吀绫诲瀷',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瀛楀吀绫诲瀷琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '鐢ㄦ埛鎬у埆', 'sys_user_sex', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鐢ㄦ埛鎬у埆鍒楄〃');
INSERT INTO `sys_dict_type` VALUES (2, '鑿滃崟鐘舵€?, 'sys_show_hide', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鑿滃崟鐘舵€佸垪琛?);
INSERT INTO `sys_dict_type` VALUES (3, '绯荤粺寮€鍏?, 'sys_normal_disable', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '绯荤粺寮€鍏冲垪琛?);
INSERT INTO `sys_dict_type` VALUES (4, '浠诲姟鐘舵€?, 'sys_job_status', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '浠诲姟鐘舵€佸垪琛?);
INSERT INTO `sys_dict_type` VALUES (5, '浠诲姟鍒嗙粍', 'sys_job_group', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '浠诲姟鍒嗙粍鍒楄〃');
INSERT INTO `sys_dict_type` VALUES (6, '绯荤粺鏄惁', 'sys_yes_no', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '绯荤粺鏄惁鍒楄〃');
INSERT INTO `sys_dict_type` VALUES (7, '閫氱煡绫诲瀷', 'sys_notice_type', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '閫氱煡绫诲瀷鍒楄〃');
INSERT INTO `sys_dict_type` VALUES (8, '閫氱煡鐘舵€?, 'sys_notice_status', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '閫氱煡鐘舵€佸垪琛?);
INSERT INTO `sys_dict_type` VALUES (9, '鎿嶄綔绫诲瀷', 'sys_oper_type', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鎿嶄綔绫诲瀷鍒楄〃');
INSERT INTO `sys_dict_type` VALUES (10, '绯荤粺鐘舵€?, 'sys_common_status', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '鐧诲綍鐘舵€佸垪琛?);

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE `sys_job`  (
  `job_id` bigint NOT NULL AUTO_INCREMENT COMMENT '浠诲姟ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '浠诲姟鍚嶇О',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DEFAULT' COMMENT '浠诲姟缁勫悕',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冪敤鐩爣瀛楃涓?,
  `cron_expression` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'cron鎵ц琛ㄨ揪寮?,
  `misfire_policy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '3' COMMENT '璁″垝鎵ц閿欒绛栫暐锛?绔嬪嵆鎵ц 2鎵ц涓€娆?3鏀惧純鎵ц锛?,
  `concurrent` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '鏄惁骞跺彂鎵ц锛?鍏佽 1绂佹锛?,
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鐘舵€侊紙0姝ｅ父 1鏆傚仠锛?,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '澶囨敞淇℃伅',
  PRIMARY KEY (`job_id`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瀹氭椂浠诲姟璋冨害琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job
-- ----------------------------
INSERT INTO `sys_job` VALUES (1, '绯荤粺榛樿锛堟棤鍙傦級', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2026-06-14 21:43:55', '', NULL, '');
INSERT INTO `sys_job` VALUES (2, '绯荤粺榛樿锛堟湁鍙傦級', 'DEFAULT', 'ryTask.ryParams(\'ry\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2026-06-14 21:43:55', '', NULL, '');
INSERT INTO `sys_job` VALUES (3, '绯荤粺榛樿锛堝鍙傦級', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2026-06-14 21:43:55', '', NULL, '');

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE `sys_job_log`  (
  `job_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '浠诲姟鏃ュ織ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浠诲姟鍚嶇О',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浠诲姟缁勫悕',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璋冪敤鐩爣瀛楃涓?,
  `job_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏃ュ織淇℃伅',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鎵ц鐘舵€侊紙0姝ｅ父 1澶辫触锛?,
  `exception_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '寮傚父淇℃伅',
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瀹氭椂浠诲姟璋冨害鏃ュ織琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '璁块棶ID',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鐢ㄦ埛璐﹀彿',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鐧诲綍IP鍦板潃',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鐧诲綍鍦扮偣',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '娴忚鍣ㄧ被鍨?,
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鎿嶄綔绯荤粺',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鐧诲綍鐘舵€侊紙0鎴愬姛 1澶辫触锛?,
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鎻愮ず娑堟伅',
  `login_time` datetime NULL DEFAULT NULL COMMENT '璁块棶鏃堕棿',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 115 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '绯荤粺璁块棶璁板綍' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
INSERT INTO `sys_logininfor` VALUES (100, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-22 16:58:32');
INSERT INTO `sys_logininfor` VALUES (101, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-22 18:11:14');
INSERT INTO `sys_logininfor` VALUES (102, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-22 18:20:25');
INSERT INTO `sys_logininfor` VALUES (103, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-23 10:48:23');
INSERT INTO `sys_logininfor` VALUES (104, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-23 13:53:58');
INSERT INTO `sys_logininfor` VALUES (105, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-23 18:09:38');
INSERT INTO `sys_logininfor` VALUES (106, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-23 18:24:16');
INSERT INTO `sys_logininfor` VALUES (107, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-23 18:30:09');
INSERT INTO `sys_logininfor` VALUES (108, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '閫€鍑烘垚鍔?, '2026-06-23 18:54:40');
INSERT INTO `sys_logininfor` VALUES (109, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-23 18:54:43');
INSERT INTO `sys_logininfor` VALUES (110, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-23 19:01:23');
INSERT INTO `sys_logininfor` VALUES (111, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '閫€鍑烘垚鍔?, '2026-06-23 19:04:06');
INSERT INTO `sys_logininfor` VALUES (112, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-23 19:04:09');
INSERT INTO `sys_logininfor` VALUES (113, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-24 08:35:39');
INSERT INTO `sys_logininfor` VALUES (114, 'admin', '127.0.0.1', '鍐呯綉IP', 'Chrome 14', 'Windows 10', '0', '鐧诲綍鎴愬姛', '2026-06-24 09:16:18');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '鑿滃崟ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鑿滃崟鍚嶇О',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '鐖惰彍鍗旾D',
  `order_num` int NULL DEFAULT 0 COMMENT '鏄剧ず椤哄簭',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '璺敱鍦板潃',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '缁勪欢璺緞',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '璺敱鍙傛暟',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '璺敱鍚嶇О',
  `is_frame` int NULL DEFAULT 1 COMMENT '鏄惁涓哄閾撅紙0鏄?1鍚︼級',
  `is_cache` int NULL DEFAULT 0 COMMENT '鏄惁缂撳瓨锛?缂撳瓨 1涓嶇紦瀛橈級',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鑿滃崟绫诲瀷锛圡鐩綍 C鑿滃崟 F鎸夐挳锛?,
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鑿滃崟鐘舵€侊紙0鏄剧ず 1闅愯棌锛?,
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鑿滃崟鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?,
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏉冮檺鏍囪瘑',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '#' COMMENT '鑿滃崟鍥炬爣',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '澶囨敞',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3006 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鑿滃崟鏉冮檺琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '绯荤粺绠＄悊', 0, 1, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2026-06-14 21:43:54', '', NULL, '绯荤粺绠＄悊鐩綍');
INSERT INTO `sys_menu` VALUES (2, '绯荤粺鐩戞帶', 0, 2, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2026-06-14 21:43:54', '', NULL, '绯荤粺鐩戞帶鐩綍');
INSERT INTO `sys_menu` VALUES (3, '绯荤粺宸ュ叿', 0, 3, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2026-06-14 21:43:54', '', NULL, '绯荤粺宸ュ叿鐩綍');
INSERT INTO `sys_menu` VALUES (5, '瑙嗛绠＄悊', 0, 5, 'video', NULL, NULL, '', 1, 0, 'M', '0', '0', NULL, 'video', 'admin', '2026-06-23 18:58:10', '', NULL, '瑙嗛绠＄悊鐩綍');
INSERT INTO `sys_menu` VALUES (100, '鐢ㄦ埛绠＄悊', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2026-06-14 21:43:54', '', NULL, '鐢ㄦ埛绠＄悊鑿滃崟');
INSERT INTO `sys_menu` VALUES (101, '瑙掕壊绠＄悊', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2026-06-14 21:43:54', '', NULL, '瑙掕壊绠＄悊鑿滃崟');
INSERT INTO `sys_menu` VALUES (102, '鑿滃崟绠＄悊', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2026-06-14 21:43:54', '', NULL, '鑿滃崟绠＄悊鑿滃崟');
INSERT INTO `sys_menu` VALUES (103, '閮ㄩ棬绠＄悊', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2026-06-14 21:43:54', '', NULL, '閮ㄩ棬绠＄悊鑿滃崟');
INSERT INTO `sys_menu` VALUES (104, '宀椾綅绠＄悊', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2026-06-14 21:43:54', '', NULL, '宀椾綅绠＄悊鑿滃崟');
INSERT INTO `sys_menu` VALUES (105, '瀛楀吀绠＄悊', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2026-06-14 21:43:54', '', NULL, '瀛楀吀绠＄悊鑿滃崟');
INSERT INTO `sys_menu` VALUES (106, '鍙傛暟璁剧疆', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2026-06-14 21:43:54', '', NULL, '鍙傛暟璁剧疆鑿滃崟');
INSERT INTO `sys_menu` VALUES (107, '閫氱煡鍏憡', 1, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2026-06-14 21:43:54', '', NULL, '閫氱煡鍏憡鑿滃崟');
INSERT INTO `sys_menu` VALUES (108, '鏃ュ織绠＄悊', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2026-06-14 21:43:54', '', NULL, '鏃ュ織绠＄悊鑿滃崟');
INSERT INTO `sys_menu` VALUES (109, '鍦ㄧ嚎鐢ㄦ埛', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2026-06-14 21:43:54', '', NULL, '鍦ㄧ嚎鐢ㄦ埛鑿滃崟');
INSERT INTO `sys_menu` VALUES (110, '瀹氭椂浠诲姟', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2026-06-14 21:43:54', '', NULL, '瀹氭椂浠诲姟鑿滃崟');
INSERT INTO `sys_menu` VALUES (111, '鏁版嵁鐩戞帶', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', 'admin', '2026-06-14 21:43:54', '', NULL, '鏁版嵁鐩戞帶鑿滃崟');
INSERT INTO `sys_menu` VALUES (112, '鏈嶅姟鐩戞帶', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2026-06-14 21:43:54', '', NULL, '鏈嶅姟鐩戞帶鑿滃崟');
INSERT INTO `sys_menu` VALUES (113, '缂撳瓨鐩戞帶', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2026-06-14 21:43:54', '', NULL, '缂撳瓨鐩戞帶鑿滃崟');
INSERT INTO `sys_menu` VALUES (114, '缂撳瓨鍒楄〃', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2026-06-14 21:43:54', '', NULL, '缂撳瓨鍒楄〃鑿滃崟');
INSERT INTO `sys_menu` VALUES (115, '琛ㄥ崟鏋勫缓', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2026-06-14 21:43:54', '', NULL, '琛ㄥ崟鏋勫缓鑿滃崟');
INSERT INTO `sys_menu` VALUES (116, '浠ｇ爜鐢熸垚', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2026-06-14 21:43:54', '', NULL, '浠ｇ爜鐢熸垚鑿滃崟');
INSERT INTO `sys_menu` VALUES (117, '绯荤粺鎺ュ彛', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2026-06-14 21:43:54', '', NULL, '绯荤粺鎺ュ彛鑿滃崟');
INSERT INTO `sys_menu` VALUES (500, '鎿嶄綔鏃ュ織', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2026-06-14 21:43:54', '', NULL, '鎿嶄綔鏃ュ織鑿滃崟');
INSERT INTO `sys_menu` VALUES (501, '鐧诲綍鏃ュ織', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2026-06-14 21:43:54', '', NULL, '鐧诲綍鏃ュ織鑿滃崟');
INSERT INTO `sys_menu` VALUES (1000, '鐢ㄦ埛鏌ヨ', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '鐢ㄦ埛鏂板', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '鐢ㄦ埛淇敼', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '鐢ㄦ埛鍒犻櫎', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1004, '鐢ㄦ埛瀵煎嚭', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1005, '鐢ㄦ埛瀵煎叆', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1006, '閲嶇疆瀵嗙爜', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1007, '瑙掕壊鏌ヨ', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1008, '瑙掕壊鏂板', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1009, '瑙掕壊淇敼', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1010, '瑙掕壊鍒犻櫎', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1011, '瑙掕壊瀵煎嚭', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1012, '鑿滃崟鏌ヨ', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1013, '鑿滃崟鏂板', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1014, '鑿滃崟淇敼', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1015, '鑿滃崟鍒犻櫎', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1016, '閮ㄩ棬鏌ヨ', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1017, '閮ㄩ棬鏂板', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1018, '閮ㄩ棬淇敼', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1019, '閮ㄩ棬鍒犻櫎', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1020, '宀椾綅鏌ヨ', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1021, '宀椾綅鏂板', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1022, '宀椾綅淇敼', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1023, '宀椾綅鍒犻櫎', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1024, '宀椾綅瀵煎嚭', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1025, '瀛楀吀鏌ヨ', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1026, '瀛楀吀鏂板', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1027, '瀛楀吀淇敼', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1028, '瀛楀吀鍒犻櫎', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1029, '瀛楀吀瀵煎嚭', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1030, '鍙傛暟鏌ヨ', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1031, '鍙傛暟鏂板', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1032, '鍙傛暟淇敼', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1033, '鍙傛暟鍒犻櫎', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1034, '鍙傛暟瀵煎嚭', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1035, '鍏憡鏌ヨ', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1036, '鍏憡鏂板', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1037, '鍏憡淇敼', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1038, '鍏憡鍒犻櫎', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1039, '鎿嶄綔鏌ヨ', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1040, '鎿嶄綔鍒犻櫎', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1041, '鏃ュ織瀵煎嚭', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1042, '鐧诲綍鏌ヨ', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1043, '鐧诲綍鍒犻櫎', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1044, '鏃ュ織瀵煎嚭', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1045, '璐︽埛瑙ｉ攣', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1046, '鍦ㄧ嚎鏌ヨ', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1047, '鎵归噺寮洪€€', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1048, '鍗曟潯寮洪€€', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1049, '浠诲姟鏌ヨ', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1050, '浠诲姟鏂板', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1051, '浠诲姟淇敼', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1052, '浠诲姟鍒犻櫎', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1053, '鐘舵€佷慨鏀?, 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1054, '浠诲姟瀵煎嚭', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1055, '鐢熸垚鏌ヨ', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1056, '鐢熸垚淇敼', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1057, '鐢熸垚鍒犻櫎', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1058, '瀵煎叆浠ｇ爜', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1059, '棰勮浠ｇ爜', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1060, '鐢熸垚浠ｇ爜', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2000, '瑙嗛鍒楄〃', 5, 1, 'list', 'video/index', NULL, '', 1, 0, 'C', '0', '0', 'video:list', 'list', 'admin', '2026-06-23 18:58:10', '', NULL, '瑙嗛鍒楄〃鑿滃崟');
INSERT INTO `sys_menu` VALUES (2001, '瑙嗛鏌ヨ', 2000, 1, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:query', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2002, '瑙嗛鏂板', 2000, 2, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:add', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2003, '瑙嗛淇敼', 2000, 3, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:edit', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2004, '瑙嗛鍒犻櫎', 2000, 4, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:remove', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2005, '瑙嗛瀵煎嚭', 2000, 5, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:export', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2010, '璧勬簮绠＄悊', 5, 2, 'resource', 'video/resource', NULL, '', 1, 0, 'C', '0', '0', 'video:resource:list', 'folder', 'admin', '2026-06-24 09:01:27', '', NULL, '璧勬簮绠＄悊鑿滃崟');
INSERT INTO `sys_menu` VALUES (2011, '璧勬簮鏌ヨ', 2010, 1, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:query', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2012, '璧勬簮鏂板', 2010, 2, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:add', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2013, '璧勬簮淇敼', 2010, 3, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:edit', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2014, '璧勬簮鍒犻櫎', 2010, 4, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:remove', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2015, '璧勬簮瀵煎嚭', 2010, 5, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:export', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` int NOT NULL AUTO_INCREMENT COMMENT '鍏憡ID',
  `notice_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍏憡鏍囬',
  `notice_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍏憡绫诲瀷锛?閫氱煡 2鍏憡锛?,
  `notice_content` longblob NULL COMMENT '鍏憡鍐呭',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鍏憡鐘舵€侊紙0姝ｅ父 1鍏抽棴锛?,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '閫氱煡鍏憡琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES (1, '娓╅Θ鎻愰啋锛欴DSS 绠＄悊绯荤粺鏂扮増鏈彂甯冨暒', '2', 0xE696B0E78988E69CACE58685E5AEB9, '0', 'admin', '2026-06-14 21:43:55', '', NULL, '绠＄悊鍛?);
INSERT INTO `sys_notice` VALUES (2, '缁存姢閫氱煡锛欴DSS 绠＄悊绯荤粺鍑屾櫒缁存姢', '1', 0xE7BBB4E68AA4E58685E5AEB9, '0', 'admin', '2026-06-14 21:43:55', '', NULL, '绠＄悊鍛?);

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏃ュ織涓婚敭',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '妯″潡鏍囬',
  `business_type` int NULL DEFAULT 0 COMMENT '涓氬姟绫诲瀷锛?鍏跺畠 1鏂板 2淇敼 3鍒犻櫎锛?,
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏂规硶鍚嶇О',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '璇锋眰鏂瑰紡',
  `operator_type` int NULL DEFAULT 0 COMMENT '鎿嶄綔绫诲埆锛?鍏跺畠 1鍚庡彴鐢ㄦ埛 2鎵嬫満绔敤鎴凤級',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鎿嶄綔浜哄憳',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '閮ㄩ棬鍚嶇О',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '璇锋眰URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '涓绘満鍦板潃',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鎿嶄綔鍦扮偣',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '璇锋眰鍙傛暟',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '杩斿洖鍙傛暟',
  `status` int NULL DEFAULT 0 COMMENT '鎿嶄綔鐘舵€侊紙0姝ｅ父 1寮傚父锛?,
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '閿欒娑堟伅',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '鎿嶄綔鏃堕棿',
  `cost_time` bigint NULL DEFAULT 0 COMMENT '娑堣€楁椂闂?,
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 104 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鎿嶄綔鏃ュ織璁板綍' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (100, '鑿滃崟绠＄悊', 1, 'com.ddss.web.controller.system.SysMenuController.add()', 'POST', 1, 'admin', '鐮斿彂閮ㄩ棬', '/system/menu', '127.0.0.1', '鍐呯綉IP', '{\"children\":[],\"createBy\":\"admin\",\"icon\":\"bug\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuName\":\"瑙嗛绠＄悊\",\"menuType\":\"M\",\"orderNum\":5,\"params\":{},\"parentId\":0,\"path\":\"video\",\"status\":\"0\",\"visible\":\"0\"} ', '{\"msg\":\"鎿嶄綔鎴愬姛\",\"code\":200}', 0, NULL, '2026-06-23 18:10:51', 37);
INSERT INTO `sys_oper_log` VALUES (101, '瑙掕壊绠＄悊', 2, 'com.ddss.web.controller.system.SysRoleController.edit()', 'PUT', 1, 'admin', '鐮斿彂閮ㄩ棬', '/system/role', '127.0.0.1', '鍐呯綉IP', '{\"admin\":false,\"createTime\":\"2026-06-14 21:45:31\",\"dataScope\":\"2\",\"delFlag\":\"0\",\"deptCheckStrictly\":true,\"flag\":false,\"menuCheckStrictly\":true,\"menuIds\":[1,100,1000,1001,1002,1003,1004,1005,1006,101,1007,1008,1009,1010,1011,102,1012,1013,1014,1015,103,1016,1017,1018,1019,104,1020,1021,1022,1023,1024,105,1025,1026,1027,1028,1029,106,1030,1031,1032,1033,1034,107,1035,1036,1037,1038,108,500,1039,1040,1041,501,1042,1043,1044,1045,2,109,1046,1047,1048,110,1049,1050,1051,1052,1053,1054,111,112,113,114,3,115,116,1055,1056,1057,1058,1059,1060,117,4,2000],\"params\":{},\"remark\":\"鏅€氳鑹瞈",\"roleId\":2,\"roleKey\":\"common\",\"roleName\":\"鏅€氳鑹瞈",\"roleSort\":2,\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"鎿嶄綔鎴愬姛\",\"code\":200}', 0, NULL, '2026-06-23 18:57:05', 137);
INSERT INTO `sys_oper_log` VALUES (102, '瑙嗛绠＄悊', 1, 'com.ddss.web.controller.video.VideoController.add()', 'POST', 1, 'admin', '鐮斿彂閮ㄩ棬', '/video', '127.0.0.1', '鍐呯綉IP', '{\"createBy\":\"admin\",\"status\":\"0\",\"videoId\":1,\"videoName\":\"1\",\"videoUrl\":\"2\"} ', '{\"msg\":\"鎿嶄綔鎴愬姛\",\"code\":200}', 0, NULL, '2026-06-23 19:08:19', 35);
INSERT INTO `sys_oper_log` VALUES (103, '鑿滃崟绠＄悊', 3, 'com.ddss.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '鐮斿彂閮ㄩ棬', '/system/menu/4', '127.0.0.1', '鍐呯綉IP', '4 ', '{\"msg\":\"鑿滃崟宸插垎閰?涓嶅厑璁稿垹闄",\"code\":601}', 0, NULL, '2026-06-24 08:55:15', 24);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '宀椾綅ID',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '宀椾綅缂栫爜',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '宀椾綅鍚嶇О',
  `post_sort` int NOT NULL COMMENT '鏄剧ず椤哄簭',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '宀椾綅淇℃伅琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'ceo', '钁ｄ簨闀?, 1, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_post` VALUES (2, 'se', '椤圭洰缁忕悊', 2, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_post` VALUES (3, 'hr', '浜哄姏璧勬簮', 3, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_post` VALUES (4, 'user', '鏅€氬憳宸?, 4, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '瑙掕壊ID',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙掕壊鍚嶇О',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙掕壊鏉冮檺瀛楃涓?,
  `role_sort` int NOT NULL COMMENT '鏄剧ず椤哄簭',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '鏁版嵁鑼冨洿锛?锛氬叏閮ㄦ暟鎹潈闄?2锛氳嚜瀹氭暟鎹潈闄?3锛氭湰閮ㄩ棬鏁版嵁鏉冮檺 4锛氭湰閮ㄩ棬鍙婁互涓嬫暟鎹潈闄愶級',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '鑿滃崟鏍戦€夋嫨椤规槸鍚﹀叧鑱旀樉绀?,
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '閮ㄩ棬鏍戦€夋嫨椤规槸鍚﹀叧鑱旀樉绀?,
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙掕壊鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?,
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鍒犻櫎鏍囧織锛?浠ｈ〃瀛樺湪 2浠ｈ〃鍒犻櫎锛?,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瑙掕壊淇℃伅琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '瓒呯骇绠＄悊鍛?, 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL, '瓒呯骇绠＄悊鍛?);
INSERT INTO `sys_role` VALUES (2, '鏅€氳鑹?, 'common', 2, '2', 1, 1, '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL, '鏅€氳鑹?);

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint NOT NULL COMMENT '瑙掕壊ID',
  `dept_id` bigint NOT NULL COMMENT '閮ㄩ棬ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瑙掕壊鍜岄儴闂ㄥ叧鑱旇〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO `sys_role_dept` VALUES (2, 100);
INSERT INTO `sys_role_dept` VALUES (2, 101);
INSERT INTO `sys_role_dept` VALUES (2, 105);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '瑙掕壊ID',
  `menu_id` bigint NOT NULL COMMENT '鑿滃崟ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瑙掕壊鍜岃彍鍗曞叧鑱旇〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (1, 5);
INSERT INTO `sys_role_menu` VALUES (1, 2000);
INSERT INTO `sys_role_menu` VALUES (1, 2001);
INSERT INTO `sys_role_menu` VALUES (1, 2002);
INSERT INTO `sys_role_menu` VALUES (1, 2003);
INSERT INTO `sys_role_menu` VALUES (1, 2004);
INSERT INTO `sys_role_menu` VALUES (1, 2005);
INSERT INTO `sys_role_menu` VALUES (1, 2010);
INSERT INTO `sys_role_menu` VALUES (1, 2011);
INSERT INTO `sys_role_menu` VALUES (1, 2012);
INSERT INTO `sys_role_menu` VALUES (1, 2013);
INSERT INTO `sys_role_menu` VALUES (1, 2014);
INSERT INTO `sys_role_menu` VALUES (1, 2015);
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 3);
INSERT INTO `sys_role_menu` VALUES (2, 4);
INSERT INTO `sys_role_menu` VALUES (2, 100);
INSERT INTO `sys_role_menu` VALUES (2, 101);
INSERT INTO `sys_role_menu` VALUES (2, 102);
INSERT INTO `sys_role_menu` VALUES (2, 103);
INSERT INTO `sys_role_menu` VALUES (2, 104);
INSERT INTO `sys_role_menu` VALUES (2, 105);
INSERT INTO `sys_role_menu` VALUES (2, 106);
INSERT INTO `sys_role_menu` VALUES (2, 107);
INSERT INTO `sys_role_menu` VALUES (2, 108);
INSERT INTO `sys_role_menu` VALUES (2, 109);
INSERT INTO `sys_role_menu` VALUES (2, 110);
INSERT INTO `sys_role_menu` VALUES (2, 111);
INSERT INTO `sys_role_menu` VALUES (2, 112);
INSERT INTO `sys_role_menu` VALUES (2, 113);
INSERT INTO `sys_role_menu` VALUES (2, 114);
INSERT INTO `sys_role_menu` VALUES (2, 115);
INSERT INTO `sys_role_menu` VALUES (2, 116);
INSERT INTO `sys_role_menu` VALUES (2, 117);
INSERT INTO `sys_role_menu` VALUES (2, 500);
INSERT INTO `sys_role_menu` VALUES (2, 501);
INSERT INTO `sys_role_menu` VALUES (2, 1000);
INSERT INTO `sys_role_menu` VALUES (2, 1001);
INSERT INTO `sys_role_menu` VALUES (2, 1002);
INSERT INTO `sys_role_menu` VALUES (2, 1003);
INSERT INTO `sys_role_menu` VALUES (2, 1004);
INSERT INTO `sys_role_menu` VALUES (2, 1005);
INSERT INTO `sys_role_menu` VALUES (2, 1006);
INSERT INTO `sys_role_menu` VALUES (2, 1007);
INSERT INTO `sys_role_menu` VALUES (2, 1008);
INSERT INTO `sys_role_menu` VALUES (2, 1009);
INSERT INTO `sys_role_menu` VALUES (2, 1010);
INSERT INTO `sys_role_menu` VALUES (2, 1011);
INSERT INTO `sys_role_menu` VALUES (2, 1012);
INSERT INTO `sys_role_menu` VALUES (2, 1013);
INSERT INTO `sys_role_menu` VALUES (2, 1014);
INSERT INTO `sys_role_menu` VALUES (2, 1015);
INSERT INTO `sys_role_menu` VALUES (2, 1016);
INSERT INTO `sys_role_menu` VALUES (2, 1017);
INSERT INTO `sys_role_menu` VALUES (2, 1018);
INSERT INTO `sys_role_menu` VALUES (2, 1019);
INSERT INTO `sys_role_menu` VALUES (2, 1020);
INSERT INTO `sys_role_menu` VALUES (2, 1021);
INSERT INTO `sys_role_menu` VALUES (2, 1022);
INSERT INTO `sys_role_menu` VALUES (2, 1023);
INSERT INTO `sys_role_menu` VALUES (2, 1024);
INSERT INTO `sys_role_menu` VALUES (2, 1025);
INSERT INTO `sys_role_menu` VALUES (2, 1026);
INSERT INTO `sys_role_menu` VALUES (2, 1027);
INSERT INTO `sys_role_menu` VALUES (2, 1028);
INSERT INTO `sys_role_menu` VALUES (2, 1029);
INSERT INTO `sys_role_menu` VALUES (2, 1030);
INSERT INTO `sys_role_menu` VALUES (2, 1031);
INSERT INTO `sys_role_menu` VALUES (2, 1032);
INSERT INTO `sys_role_menu` VALUES (2, 1033);
INSERT INTO `sys_role_menu` VALUES (2, 1034);
INSERT INTO `sys_role_menu` VALUES (2, 1035);
INSERT INTO `sys_role_menu` VALUES (2, 1036);
INSERT INTO `sys_role_menu` VALUES (2, 1037);
INSERT INTO `sys_role_menu` VALUES (2, 1038);
INSERT INTO `sys_role_menu` VALUES (2, 1039);
INSERT INTO `sys_role_menu` VALUES (2, 1040);
INSERT INTO `sys_role_menu` VALUES (2, 1041);
INSERT INTO `sys_role_menu` VALUES (2, 1042);
INSERT INTO `sys_role_menu` VALUES (2, 1043);
INSERT INTO `sys_role_menu` VALUES (2, 1044);
INSERT INTO `sys_role_menu` VALUES (2, 1045);
INSERT INTO `sys_role_menu` VALUES (2, 1046);
INSERT INTO `sys_role_menu` VALUES (2, 1047);
INSERT INTO `sys_role_menu` VALUES (2, 1048);
INSERT INTO `sys_role_menu` VALUES (2, 1049);
INSERT INTO `sys_role_menu` VALUES (2, 1050);
INSERT INTO `sys_role_menu` VALUES (2, 1051);
INSERT INTO `sys_role_menu` VALUES (2, 1052);
INSERT INTO `sys_role_menu` VALUES (2, 1053);
INSERT INTO `sys_role_menu` VALUES (2, 1054);
INSERT INTO `sys_role_menu` VALUES (2, 1055);
INSERT INTO `sys_role_menu` VALUES (2, 1056);
INSERT INTO `sys_role_menu` VALUES (2, 1057);
INSERT INTO `sys_role_menu` VALUES (2, 1058);
INSERT INTO `sys_role_menu` VALUES (2, 1059);
INSERT INTO `sys_role_menu` VALUES (2, 1060);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐢ㄦ埛ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '閮ㄩ棬ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐢ㄦ埛璐﹀彿',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐢ㄦ埛鏄电О',
  `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '00' COMMENT '鐢ㄦ埛绫诲瀷锛?0绯荤粺鐢ㄦ埛锛?,
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鐢ㄦ埛閭',
  `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鎵嬫満鍙风爜',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鐢ㄦ埛鎬у埆锛?鐢?1濂?2鏈煡锛?,
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '澶村儚鍦板潃',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '瀵嗙爜',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '璐﹀彿鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?,
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鍒犻櫎鏍囧織锛?浠ｈ〃瀛樺湪 2浠ｈ〃鍒犻櫎锛?,
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏈€鍚庣櫥褰旾P',
  `login_date` datetime NULL DEFAULT NULL COMMENT '鏈€鍚庣櫥褰曟椂闂?,
  `pwd_update_date` datetime NULL DEFAULT NULL COMMENT '瀵嗙爜鏈€鍚庢洿鏂版椂闂?,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鐢ㄦ埛淇℃伅琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 103, 'admin', '绠＄悊鍛?, '00', 'admin@ddss.com', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-06-24 09:16:18', '2026-06-14 21:43:54', 'admin', '2026-06-14 21:43:54', '', NULL, '绠＄悊鍛?);
INSERT INTO `sys_user` VALUES (2, 105, 'test', '娴嬭瘯鍛?, '00', 'test@ddss.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-06-14 21:43:54', '2026-06-14 21:43:54', 'admin', '2026-06-14 21:43:54', '', NULL, '娴嬭瘯鍛?);

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `post_id` bigint NOT NULL COMMENT '宀椾綅ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鐢ㄦ埛涓庡矖浣嶅叧鑱旇〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES (1, 1);
INSERT INTO `sys_user_post` VALUES (2, 2);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `role_id` bigint NOT NULL COMMENT '瑙掕壊ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鐢ㄦ埛鍜岃鑹插叧鑱旇〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 2);

-- ----------------------------
-- Table structure for sys_video_resource
-- ----------------------------
DROP TABLE IF EXISTS `sys_video_resource`;
CREATE TABLE `sys_video_resource`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '瑙嗛璧勬簮ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瑙嗛鍚嶇О',
  `file_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏂囦欢鍚?,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏂囦欢璺緞',
  `file_size` bigint NULL DEFAULT NULL COMMENT '鏂囦欢澶у皬(瀛楄妭)',
  `mime_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鏂囦欢绫诲瀷',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鎻忚堪',
  `duration` int NULL DEFAULT NULL COMMENT '鏃堕暱(绉?',
  `resolution` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鍒嗚鲸鐜?,
  `thumbnail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '灏侀潰鍥捐矾寰?,
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鍒涘缓鑰?,
  `create_time` datetime NULL DEFAULT NULL COMMENT '鍒涘缓鏃堕棿',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '鏇存柊鑰?,
  `update_time` datetime NULL DEFAULT NULL COMMENT '鏇存柊鏃堕棿',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶囨敞',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瑙嗛璧勬簮琛? ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_video_resource
-- ----------------------------
INSERT INTO `sys_video_resource` VALUES (1, '绀轰緥瑙嗛1', 'sample1.mp4', '/videos/sample1.mp4', 1024000, 'video/mp4', '杩欐槸涓€涓ず渚嬭棰?, 60, '1920x1080', '/thumbnails/sample1.jpg', '0', 'admin', '2026-06-22 17:45:52', '', '2026-06-22 17:45:52', '绯荤粺鍒濆鏁版嵁');
INSERT INTO `sys_video_resource` VALUES (2, '绀轰緥瑙嗛2', 'sample2.mp4', '/videos/sample2.mp4', 2048000, 'video/mp4', '鍙︿竴涓ず渚嬭棰?, 120, '1280x720', '/thumbnails/sample2.jpg', '0', 'admin', '2026-06-22 17:45:52', '', '2026-06-22 17:45:52', '绯荤粺鍒濆鏁版嵁');

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO `sys_menu` VALUES (200, '财务管理', 5, 1, 'finance', NULL, NULL, '', 1, 0, 'M', '0', '0', NULL, 'money', 'admin', now(), '', NULL, '财务管理目录');

-- 财务管理-列表
INSERT INTO `sys_menu` VALUES (201, '财务记录', 200, 1, 'index', 'finance/index', NULL, '', 1, 1, 'C', '0', '0', 'finance:list', 'list', 'admin', now(), '', NULL, '财务记录菜单');

-- 财务管理-统计
INSERT INTO `sys_menu` VALUES (202, '财务统计', 200, 2, 'statistics', 'finance/statistics', NULL, '', 1, 1, 'C', '0', '0', 'finance:stat', 'chart', 'admin', now(), '', NULL, '财务统计菜单');

-- 按钮权限
INSERT INTO `sys_menu` VALUES (203, '财务查询', 201, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:query', '#', 'admin', now(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (204, '财务新增', 201, 2, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:add', '#', 'admin', now(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (205, '财务修改', 201, 3, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:edit', '#', 'admin', now(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (206, '财务删除', 201, 4, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:remove', '#', 'admin', now(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (207, '财务统计', 202, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:stat', '#', 'admin', now(), '', NULL, '');

-- 给角色分配菜单权�?admin 角色 = 1, common 角色 = 2)
INSERT INTO `sys_role_menu` VALUES (1, 200), (1, 201), (1, 202), (1, 203), (1, 204), (1, 205), (1, 206), (1, 207);
INSERT INTO `sys_role_menu` VALUES (2, 200), (2, 201), (2, 202), (2, 203), (2, 204), (2, 205), (2, 206), (2, 207);


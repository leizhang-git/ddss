/*
 =====================================================================
  DDSS 全量初始化脚本（可重复执行 / 幂等）
 =====================================================================
  使用方式：
    1) 每次执行前，脚本会先 DROP DATABASE 再 CREATE DATABASE，并 USE 该库，
       因此无论执行多少次，结果都一致（先删库、再建库、再建表、再灌数据）。
    2) 直接运行本脚本即可，无需手工删库。重复执行不会报错。

  注意：
    - 需要具备 DROP / CREATE DATABASE 的权限（建议使用 root 或具备该权限的账号执行）。
    - 该脚本会清空整个 DDSS 业务库，生产环境请谨慎执行。
 =====================================================================
*/

-- 关闭外键检查，保证建表顺序无关
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 先删库再建库 + 使用该库（保证可重复执行）
DROP DATABASE IF EXISTS `ddss`;
CREATE DATABASE `ddss` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `ddss`;

-- ----------------------------
-- Table structure for ddss_resource
-- ----------------------------
DROP TABLE IF EXISTS `ddss_resource`;
CREATE TABLE `ddss_resource`  (
  `resource_id` bigint NOT NULL AUTO_INCREMENT COMMENT '资源ID',
  `resource_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资源名称',
  `file_size` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件大小',
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件类型',
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件路径',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`resource_id`) USING BTREE,
  INDEX `idx_resource_name`(`resource_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '资源管理表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ddss_resource
-- ----------------------------
INSERT INTO `ddss_resource` VALUES (1, '【哲风壁纸】8k-风景.png', '5.9 MB', 'png', '【哲风壁纸】8k-风景.png', '0', NULL, 'system', '2026-06-24 17:10:06', '', '2026-06-24 17:10:06');

-- ----------------------------
-- Table structure for ddss_video
-- ----------------------------
DROP TABLE IF EXISTS `ddss_video`;
CREATE TABLE `ddss_video`  (
  `video_id` bigint NOT NULL AUTO_INCREMENT COMMENT '视频ID',
  `video_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '视频名称',
  `video_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '视频URL',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图URL',
  `duration` int NULL DEFAULT NULL COMMENT '时长(秒)',
  `file_size` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件大小',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`video_id`) USING BTREE,
  INDEX `idx_video_name`(`video_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '视频管理表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ddss_video
-- ----------------------------
INSERT INTO `ddss_video` VALUES (1, '1', '2', NULL, NULL, NULL, '0', NULL, 'admin', '2026-06-23 19:08:19', '', '2026-06-23 19:08:19');

-- ----------------------------
-- Table structure for ddss_leave（工作流演示）
-- ----------------------------
DROP TABLE IF EXISTS `ddss_leave`;
CREATE TABLE `ddss_leave`  (
  `leave_id` bigint NOT NULL AUTO_INCREMENT COMMENT '请假单ID',
  `apply_user` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请人账号',
  `apply_user_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '申请人姓名',
  `leave_days` int NULL DEFAULT NULL COMMENT '请假天数',
  `start_date` date NULL DEFAULT NULL COMMENT '开始日期',
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '请假事由',
  `leader` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '一级审批人（部门经理）账号',
  `boss` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '二级审批人（总经理）账号',
  `process_instance_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '流程实例ID',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0待审批 1已通过 2已驳回）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`leave_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '请假申请单（工作流演示）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ddss_flow_design（流程模型/设计器）
-- ----------------------------
DROP TABLE IF EXISTS `ddss_flow_design`;
CREATE TABLE `ddss_flow_design`  (
  `flow_id` bigint NOT NULL AUTO_INCREMENT COMMENT '流程模型ID',
  `flow_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '流程Key（BPMN process id）',
  `flow_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '流程名称',
  `bpmn_xml` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'BPMN XML 内容',
  `version` int NULL DEFAULT 1 COMMENT '版本号',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0草稿 1已发布）',
  `deployment_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最近一次发布的部署ID',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`flow_id`) USING BTREE,
  UNIQUE INDEX `uk_flow_key`(`flow_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '流程模型表（工作流设计器）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `tpl_web_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '前端模板类型（element-ui模版 element-plus模版）',
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能作者',
  `gen_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint NULL DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `sort` int NULL DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表字段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_blob_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE `qrtz_blob_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `blob_data` blob NULL COMMENT '存放持久化Trigger对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Blob类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_blob_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_calendars
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE `qrtz_calendars`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`, `calendar_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '日历信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_calendars
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_cron_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE `qrtz_cron_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `cron_expression` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'cron表达式',
  `time_zone_id` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Cron类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_cron_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_fired_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE `qrtz_fired_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `entry_id` varchar(95) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度器实例id',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度器实例名',
  `fired_time` bigint NOT NULL COMMENT '触发的时间',
  `sched_time` bigint NOT NULL COMMENT '定时器制定的时间',
  `priority` int NOT NULL COMMENT '优先级',
  `state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务组名',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否并发',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否接受恢复执行',
  PRIMARY KEY (`sched_name`, `entry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '已触发的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_fired_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_job_details
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE `qrtz_job_details`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `job_class_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '执行任务类名称',
  `is_durable` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否持久化',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否并发',
  `is_update_data` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否更新数据',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否接受恢复执行',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_job_details
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_locks
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE `qrtz_locks`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`, `lock_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '存储的悲观锁信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_locks
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_paused_trigger_grps
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE `qrtz_paused_trigger_grps`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`, `trigger_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '暂停的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_paused_trigger_grps
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_scheduler_state
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE `qrtz_scheduler_state`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`, `instance_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '调度器状态表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_scheduler_state
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simple_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE `qrtz_simple_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `repeat_count` bigint NOT NULL COMMENT '重复的次数统计',
  `repeat_interval` bigint NOT NULL COMMENT '重复的间隔时间',
  `times_triggered` bigint NOT NULL COMMENT '已经触发的次数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '简单触发器的信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simple_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simprop_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE `qrtz_simprop_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `str_prop_1` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
  `str_prop_2` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
  `str_prop_3` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
  `int_prop_1` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
  `int_prop_2` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
  `long_prop_1` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
  `long_prop_2` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
  `dec_prop_1` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
  `dec_prop_2` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
  `bool_prop_1` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
  `bool_prop_2` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '同步机制的行锁表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simprop_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE `qrtz_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器的名字',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器所属组的名字',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `next_fire_time` bigint NULL DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
  `prev_fire_time` bigint NULL DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
  `priority` int NULL DEFAULT NULL COMMENT '优先级',
  `trigger_state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器状态',
  `trigger_type` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器的类型',
  `start_time` bigint NOT NULL COMMENT '开始时间',
  `end_time` bigint NULL DEFAULT NULL COMMENT '结束时间',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日程表名称',
  `misfire_instr` smallint NULL DEFAULT NULL COMMENT '补偿执行的策略',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  INDEX `sched_name`(`sched_name` ASC, `job_name` ASC, `job_group` ASC) USING BTREE,
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `qrtz_job_details` (`sched_name`, `job_name`, `job_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '触发器详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '是否开启验证码功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');
INSERT INTO `sys_config` VALUES (7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 200 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '部门表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', '若依科技', 0, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (101, 100, '0,100', '深圳总公司', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (102, 100, '0,100', '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (103, 101, '0,100,101', '研发部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (104, 101, '0,100,101', '市场部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (105, 101, '0,100,101', '测试部门', 3, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (106, 101, '0,100,101', '财务部门', 4, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO `sys_dept` VALUES (107, 101, '0,100,101', '运维部门', 5, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL);
INSERT INTO `sys_dept` VALUES (108, 102, '0,100,102', '市场部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL);
INSERT INTO `sys_dept` VALUES (109, 102, '0,100,102', '财务部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典数据表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '默认分组');
INSERT INTO `sys_dict_data` VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '系统分组');
INSERT INTO `sys_dict_data` VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '通知');
INSERT INTO `sys_dict_data` VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '公告');
INSERT INTO `sys_dict_data` VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '停用状态');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '任务状态列表');
INSERT INTO `sys_dict_type` VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '任务分组列表');
INSERT INTO `sys_dict_type` VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '登录状态列表');

-- ----------------------------
-- Table structure for sys_finance
-- ----------------------------
DROP TABLE IF EXISTS `sys_finance`;
CREATE TABLE `sys_finance`  (
  `finance_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `creditor_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '欠款方名称',
  `loan_amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '借款总额',
  `loan_date` date NULL DEFAULT NULL COMMENT '借款日期',
  `repayment_start_date` date NULL DEFAULT NULL COMMENT '还款开始日期',
  `repayment_end_date` date NULL DEFAULT NULL COMMENT '还款结束日期',
  `loan_term` int NULL DEFAULT NULL COMMENT '借款期限(月)',
  `repayment_day` int NULL DEFAULT NULL COMMENT '每月还款日(几号)',
  `monthly_payment` decimal(12, 2) NULL DEFAULT NULL COMMENT '月还款额',
  `interest_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT '利率(%)',
  `interest_amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '利息总额',
  `early_settlement_amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '提前结清金额',
  `remaining_amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '剩余未还金额',
  `paid_amount` decimal(12, 2) NULL DEFAULT NULL COMMENT '已还金额',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态(0还款中 1已结清 2逾期)',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `paid_months` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `month_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`finance_id`) USING BTREE,
  INDEX `idx_creditor_name`(`creditor_name` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '财务管理表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_finance
-- ----------------------------
INSERT INTO `sys_finance` VALUES (1, '洋钱罐', 15884.00, '2026-02-09', '2026-03-09', '2027-03-09', 12, 9, 1324.00, NULL, 4.00, 8848.00, 5292.00, 10592.00, '0', NULL, '7月', '{\"7月\":{\"amt\":0},\"4月\":{\"amt\":0}}', 'admin', '2026-07-01 13:01:11', 'admin', '2026-07-01 13:01:11');
INSERT INTO `sys_finance` VALUES (2, '洋钱罐', 13200.00, '2026-06-16', '2026-07-16', '2027-07-16', 12, 16, 1246.00, NULL, 1752.00, 13329.00, 0.00, 14952.00, '0', NULL, NULL, '{\"8月\":{\"amt\":1246},\"7月\":{\"amt\":1246},\"27-7月\":{\"amt\":0}}', 'admin', '2026-07-01 13:03:34', 'admin', '2026-07-01 13:03:34');
INSERT INTO `sys_finance` VALUES (3, '分期乐', NULL, NULL, NULL, NULL, NULL, 25, NULL, NULL, NULL, NULL, 0.00, 15409.00, '0', NULL, NULL, '{\"7月\":{\"amt\":0},\"8月\":{\"amt\":2637},\"9月\":{\"amt\":1770},\"10月\":{\"amt\":1533},\"11月\":{\"amt\":1533},\"12月\":{\"amt\":1533},\"1月\":{\"amt\":1533},\"2月\":{\"amt\":1533},\"3月\":{\"amt\":700},\"26-7月\":{\"amt\":2637}}', 'admin', '2026-07-01 16:49:54', 'admin', '2026-07-01 16:49:54');
INSERT INTO `sys_finance` VALUES (4, '安逸花', NULL, NULL, NULL, NULL, NULL, 16, NULL, NULL, NULL, NULL, 0.00, 6930.00, '0', NULL, NULL, '{\"26-7月\":{\"amt\":803},\"26-8月\":{\"amt\":803},\"26-9月\":{\"amt\":803},\"26-10月\":{\"amt\":803},\"26-11月\":{\"amt\":803},\"26-12月\":{\"amt\":803},\"27-1月\":{\"amt\":666},\"27-2月\":{\"amt\":666},\"27-3月\":{\"amt\":500},\"27-4月\":{\"amt\":280}}', 'admin', '2026-07-01 17:13:13', 'admin', '2026-07-01 17:13:13');
INSERT INTO `sys_finance` VALUES (5, '时光', NULL, NULL, NULL, NULL, 12, 28, 1100.00, NULL, NULL, NULL, 0.00, 11000.00, '0', NULL, NULL, '{\"26-7月\":{\"amt\":1100},\"26-8月\":{\"amt\":1100},\"26-9月\":{\"amt\":1100},\"26-10月\":{\"amt\":1100},\"26-11月\":{\"amt\":1100},\"26-12月\":{\"amt\":1100},\"27-1月\":{\"amt\":1100},\"27-2月\":{\"amt\":1100},\"27-3月\":{\"amt\":1100},\"27-4月\":{\"amt\":1100}}', 'admin', '2026-07-01 17:20:01', 'admin', '2026-07-01 17:20:01');
INSERT INTO `sys_finance` VALUES (6, '五八', NULL, NULL, NULL, NULL, NULL, 18, NULL, NULL, NULL, NULL, 0.00, 6300.00, '0', NULL, NULL, '{\"26-7月\":{\"amt\":900},\"26-8月\":{\"amt\":900},\"26-9月\":{\"amt\":900},\"26-10月\":{\"amt\":900},\"26-11月\":{\"amt\":900},\"26-12月\":{\"amt\":900},\"27-1月\":{\"amt\":900}}', 'admin', '2026-07-01 17:25:22', 'admin', '2026-07-01 17:25:22');
INSERT INTO `sys_finance` VALUES (7, '易花花', NULL, NULL, NULL, NULL, NULL, 19, 1100.00, NULL, NULL, NULL, 0.00, 11000.00, '0', NULL, NULL, '{\"26-7月\":{\"amt\":1100},\"26-8月\":{\"amt\":1100},\"26-9月\":{\"amt\":1100},\"26-10月\":{\"amt\":1100},\"26-11月\":{\"amt\":1100},\"26-12月\":{\"amt\":1100},\"27-1月\":{\"amt\":1100},\"27-2月\":{\"amt\":1100},\"27-3月\":{\"amt\":1100},\"27-4月\":{\"amt\":1100}}', 'admin', '2026-07-01 17:26:41', 'admin', '2026-07-01 17:26:41');
INSERT INTO `sys_finance` VALUES (8, '宜享花', NULL, NULL, NULL, NULL, NULL, 5, 450.00, NULL, NULL, NULL, 0.00, 3600.00, '0', NULL, NULL, '{\"26-7月\":{\"amt\":0},\"26-8月\":{\"amt\":450},\"26-9月\":{\"amt\":450},\"26-10月\":{\"amt\":450},\"26-11月\":{\"amt\":450},\"26-12月\":{\"amt\":450},\"27-1月\":{\"amt\":450},\"27-2月\":{\"amt\":450},\"27-3月\":{\"amt\":450}}', 'admin', '2026-07-01 17:28:34', 'admin', '2026-07-01 17:28:34');
INSERT INTO `sys_finance` VALUES (9, '宜享花', NULL, NULL, NULL, NULL, NULL, 14, 450.00, NULL, NULL, NULL, 0.00, 4500.00, '0', NULL, NULL, '{\"26-7月\":{\"amt\":450},\"26-8月\":{\"amt\":450},\"26-9月\":{\"amt\":450},\"26-10月\":{\"amt\":450},\"26-11月\":{\"amt\":450},\"26-12月\":{\"amt\":450},\"27-1月\":{\"amt\":450},\"27-2月\":{\"amt\":450},\"27-3月\":{\"amt\":450},\"27-4月\":{\"amt\":450}}', 'admin', '2026-07-01 17:29:47', 'admin', '2026-07-01 17:29:47');
INSERT INTO `sys_finance` VALUES (10, '宜享花', NULL, NULL, NULL, NULL, NULL, 23, 1000.00, NULL, NULL, NULL, 0.00, 8000.00, '0', NULL, NULL, '{\"26-7月\":{\"amt\":1000},\"26-8月\":{\"amt\":1000},\"26-9月\":{\"amt\":1000},\"26-10月\":{\"amt\":1000},\"26-11月\":{\"amt\":1000},\"26-12月\":{\"amt\":1000},\"27-1月\":{\"amt\":1000},\"27-2月\":{\"amt\":1000}}', 'admin', '2026-07-01 17:31:03', 'admin', '2026-07-01 17:31:03');
INSERT INTO `sys_finance` VALUES (11, '小花钱包', NULL, NULL, NULL, NULL, NULL, 28, NULL, NULL, NULL, NULL, 0.00, 7000.00, '0', NULL, NULL, '{\"26-7月\":{\"amt\":1000},\"26-8月\":{\"amt\":1000},\"26-9月\":{\"amt\":1000},\"26-10月\":{\"amt\":1000},\"26-11月\":{\"amt\":1000},\"26-12月\":{\"amt\":1000},\"27-1月\":{\"amt\":1000}}', 'admin', '2026-07-01 17:36:34', 'admin', '2026-07-01 17:36:34');
INSERT INTO `sys_finance` VALUES (12, '有钱花', NULL, NULL, NULL, NULL, 12, 24, 4000.00, NULL, NULL, NULL, 0.00, 44000.00, '0', NULL, NULL, '{\"26-8月\":{\"amt\":4000},\"26-9月\":{\"amt\":4000},\"26-10月\":{\"amt\":4000},\"26-11月\":{\"amt\":4000},\"26-12月\":{\"amt\":4000},\"27-1月\":{\"amt\":4000},\"27-2月\":{\"amt\":4000},\"27-3月\":{\"amt\":4000},\"27-4月\":{\"amt\":4000},\"27-5月\":{\"amt\":4000},\"27-6月\":{\"amt\":4000}}', 'admin', '2026-07-01 17:38:50', 'admin', '2026-07-01 17:38:50');
INSERT INTO `sys_finance` VALUES (13, '好分期', NULL, NULL, NULL, NULL, NULL, 20, 400.00, NULL, NULL, NULL, 0.00, 4800.00, '0', NULL, NULL, '{\"26-7月\":{\"amt\":400},\"26-8月\":{\"amt\":400},\"26-9月\":{\"amt\":400},\"26-10月\":{\"amt\":400},\"26-11月\":{\"amt\":400},\"26-12月\":{\"amt\":400},\"27-1月\":{\"amt\":400},\"27-2月\":{\"amt\":400},\"27-3月\":{\"amt\":400},\"27-4月\":{\"amt\":400},\"27-5月\":{\"amt\":400},\"27-6月\":{\"amt\":400}}', 'admin', '2026-07-01 17:56:39', 'admin', '2026-07-01 17:56:39');
INSERT INTO `sys_finance` VALUES (14, '好分期', NULL, NULL, NULL, NULL, NULL, 23, 300.00, NULL, NULL, NULL, 0.00, 3600.00, '0', NULL, NULL, '{\"27-6月\":{\"amt\":300},\"27-5月\":{\"amt\":300},\"27-4月\":{\"amt\":300},\"27-3月\":{\"amt\":300},\"27-2月\":{\"amt\":300},\"27-1月\":{\"amt\":300},\"26-12月\":{\"amt\":300},\"26-11月\":{\"amt\":300},\"26-10月\":{\"amt\":300},\"26-9月\":{\"amt\":300},\"26-8月\":{\"amt\":300},\"26-7月\":{\"amt\":300}}', 'admin', '2026-07-01 17:56:51', 'admin', '2026-07-01 17:56:51');
INSERT INTO `sys_finance` VALUES (15, '京东白条', NULL, NULL, NULL, NULL, NULL, 20, 1500.00, NULL, NULL, NULL, 0.00, 19500.00, '0', NULL, NULL, '{\"26-7月\":{\"amt\":1500},\"26-8月\":{\"amt\":1500},\"26-9月\":{\"amt\":1500},\"26-10月\":{\"amt\":1500},\"26-11月\":{\"amt\":1500},\"26-12月\":{\"amt\":1500},\"27-1月\":{\"amt\":1500},\"27-2月\":{\"amt\":1500},\"27-3月\":{\"amt\":1500},\"27-4月\":{\"amt\":1500},\"27-5月\":{\"amt\":1500},\"27-6月\":{\"amt\":1500},\"27-7月\":{\"amt\":1500}}', 'admin', '2026-07-01 18:02:37', 'admin', '2026-07-01 18:02:37');
INSERT INTO `sys_finance` VALUES (16, '金条', NULL, NULL, NULL, NULL, NULL, 2, 1200.00, NULL, NULL, NULL, 0.00, 14400.00, '0', NULL, NULL, '{\"26-8月\":{\"amt\":1200},\"26-9月\":{\"amt\":1200},\"26-10月\":{\"amt\":1200},\"26-11月\":{\"amt\":1200},\"26-12月\":{\"amt\":1200},\"27-1月\":{\"amt\":1200},\"27-2月\":{\"amt\":1200},\"27-3月\":{\"amt\":1200},\"27-4月\":{\"amt\":1200},\"27-5月\":{\"amt\":1200},\"27-6月\":{\"amt\":1200},\"27-7月\":{\"amt\":1200}}', 'admin', '2026-07-02 12:57:55', 'admin', '2026-07-02 12:57:55');
INSERT INTO `sys_finance` VALUES (17, '金条', NULL, NULL, NULL, NULL, 12, 16, NULL, NULL, NULL, NULL, 0.00, 3000.00, '0', NULL, NULL, '{\"26-8月\":{\"amt\":300},\"26-9月\":{\"amt\":300},\"26-10月\":{\"amt\":300},\"26-11月\":{\"amt\":300},\"26-12月\":{\"amt\":300},\"27-1月\":{\"amt\":300},\"27-2月\":{\"amt\":300},\"27-3月\":{\"amt\":300},\"27-4月\":{\"amt\":300},\"27-5月\":{\"amt\":300}}', 'admin', '2026-07-02 12:59:15', 'admin', '2026-07-02 12:59:15');

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE `sys_job`  (
  `job_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job
-- ----------------------------
INSERT INTO `sys_job` VALUES (1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2026-06-14 21:43:55', '', NULL, '');
INSERT INTO `sys_job` VALUES (2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2026-06-14 21:43:55', '', NULL, '');
INSERT INTO `sys_job` VALUES (3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2026-06-14 21:43:55', '', NULL, '');

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE `sys_job_log`  (
  `job_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日志信息',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '异常信息',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 160 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统访问记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
INSERT INTO `sys_logininfor` VALUES (100, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-22 16:58:32');
INSERT INTO `sys_logininfor` VALUES (101, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-22 18:11:14');
INSERT INTO `sys_logininfor` VALUES (102, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-22 18:20:25');
INSERT INTO `sys_logininfor` VALUES (103, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-23 10:48:23');
INSERT INTO `sys_logininfor` VALUES (104, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-23 13:53:58');
INSERT INTO `sys_logininfor` VALUES (105, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-23 18:09:38');
INSERT INTO `sys_logininfor` VALUES (106, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-23 18:24:16');
INSERT INTO `sys_logininfor` VALUES (107, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-23 18:30:09');
INSERT INTO `sys_logininfor` VALUES (108, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2026-06-23 18:54:40');
INSERT INTO `sys_logininfor` VALUES (109, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-23 18:54:43');
INSERT INTO `sys_logininfor` VALUES (110, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-23 19:01:23');
INSERT INTO `sys_logininfor` VALUES (111, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2026-06-23 19:04:06');
INSERT INTO `sys_logininfor` VALUES (112, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-23 19:04:09');
INSERT INTO `sys_logininfor` VALUES (113, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-24 08:35:39');
INSERT INTO `sys_logininfor` VALUES (114, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-24 09:16:18');
INSERT INTO `sys_logininfor` VALUES (115, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-24 11:03:39');
INSERT INTO `sys_logininfor` VALUES (116, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-24 12:22:50');
INSERT INTO `sys_logininfor` VALUES (117, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-24 14:17:01');
INSERT INTO `sys_logininfor` VALUES (118, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-24 17:10:18');
INSERT INTO `sys_logininfor` VALUES (119, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-25 08:33:38');
INSERT INTO `sys_logininfor` VALUES (120, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '验证码已失效', '2026-06-25 12:15:35');
INSERT INTO `sys_logininfor` VALUES (121, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '验证码已失效', '2026-06-25 12:15:41');
INSERT INTO `sys_logininfor` VALUES (122, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '验证码已失效', '2026-06-25 12:17:27');
INSERT INTO `sys_logininfor` VALUES (123, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-25 12:22:01');
INSERT INTO `sys_logininfor` VALUES (124, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-25 16:20:42');
INSERT INTO `sys_logininfor` VALUES (125, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2026-06-25 16:25:27');
INSERT INTO `sys_logininfor` VALUES (126, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-25 16:26:15');
INSERT INTO `sys_logininfor` VALUES (127, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2026-06-25 16:41:57');
INSERT INTO `sys_logininfor` VALUES (128, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '验证码错误', '2026-06-25 16:42:04');
INSERT INTO `sys_logininfor` VALUES (129, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-25 16:42:08');
INSERT INTO `sys_logininfor` VALUES (130, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '退出成功', '2026-06-25 16:42:30');
INSERT INTO `sys_logininfor` VALUES (131, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '验证码已失效', '2026-06-25 18:46:32');
INSERT INTO `sys_logininfor` VALUES (132, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-25 18:46:36');
INSERT INTO `sys_logininfor` VALUES (133, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-26 09:07:40');
INSERT INTO `sys_logininfor` VALUES (134, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-26 11:05:21');
INSERT INTO `sys_logininfor` VALUES (135, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-26 12:59:49');
INSERT INTO `sys_logininfor` VALUES (136, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-26 12:59:56');
INSERT INTO `sys_logininfor` VALUES (137, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-26 15:37:05');
INSERT INTO `sys_logininfor` VALUES (138, 'admin', '192.168.83.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-26 16:03:47');
INSERT INTO `sys_logininfor` VALUES (139, 'admin', '192.168.83.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-28 17:13:11');
INSERT INTO `sys_logininfor` VALUES (140, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '验证码错误', '2026-06-28 17:57:35');
INSERT INTO `sys_logininfor` VALUES (141, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-06-28 17:57:40');
INSERT INTO `sys_logininfor` VALUES (142, 'admin', '192.168.83.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-07-01 11:10:26');
INSERT INTO `sys_logininfor` VALUES (143, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-07-01 11:24:54');
INSERT INTO `sys_logininfor` VALUES (144, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-07-01 12:59:33');
INSERT INTO `sys_logininfor` VALUES (145, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-07-01 14:20:51');
INSERT INTO `sys_logininfor` VALUES (146, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-07-01 16:30:25');
INSERT INTO `sys_logininfor` VALUES (147, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-07-02 09:10:05');
INSERT INTO `sys_logininfor` VALUES (148, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-07-02 12:57:35');
INSERT INTO `sys_logininfor` VALUES (149, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-07-02 16:07:22');
INSERT INTO `sys_logininfor` VALUES (150, 'admin', '127.0.0.1', '内网IP', 'Chrome 15', 'Windows 10', '0', '登录成功', '2026-07-08 18:29:46');
INSERT INTO `sys_logininfor` VALUES (151, 'admin', '127.0.0.1', '内网IP', 'Chrome 15', 'Windows 10', '0', '登录成功', '2026-07-09 08:45:30');
INSERT INTO `sys_logininfor` VALUES (152, 'admin', '127.0.0.1', '内网IP', 'Chrome 15', 'Windows 10', '0', '登录成功', '2026-07-09 13:49:45');
INSERT INTO `sys_logininfor` VALUES (153, 'admin', '127.0.0.1', '内网IP', 'Chrome 15', 'Windows 10', '0', '登录成功', '2026-07-09 15:19:35');
INSERT INTO `sys_logininfor` VALUES (154, 'admin', '127.0.0.1', '内网IP', 'Chrome 15', 'Windows 10', '0', '登录成功', '2026-07-09 16:35:02');
INSERT INTO `sys_logininfor` VALUES (155, 'admin', '127.0.0.1', '内网IP', 'Chrome 15', 'Windows 10', '0', '登录成功', '2026-07-09 18:55:10');
INSERT INTO `sys_logininfor` VALUES (156, 'admin', '127.0.0.1', '内网IP', 'Chrome 15', 'Windows 10', '0', '登录成功', '2026-07-09 19:23:03');
INSERT INTO `sys_logininfor` VALUES (157, 'admin', '127.0.0.1', '内网IP', 'Chrome 15', 'Windows 10', '0', '登录成功', '2026-07-10 08:47:01');
INSERT INTO `sys_logininfor` VALUES (158, 'admin', '127.0.0.1', '内网IP', 'Chrome 15', 'Windows 10', '0', '登录成功', '2026-07-17 12:13:19');
INSERT INTO `sys_logininfor` VALUES (159, 'admin', '127.0.0.1', '内网IP', 'Chrome 15', 'Windows 10', '0', '登录成功', '2026-07-23 08:31:31');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由参数',
  `route_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由名称',
  `is_frame` int NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3012 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2026-06-14 21:43:54', '', NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '系统监控', 0, 2, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2026-06-14 21:43:54', '', NULL, '系统监控目录');
INSERT INTO `sys_menu` VALUES (3, '系统工具', 0, 3, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2026-06-14 21:43:54', '', NULL, '系统工具目录');
INSERT INTO `sys_menu` VALUES (5, '视频管理', 0, 5, 'video', NULL, NULL, '', 1, 0, 'M', '0', '0', NULL, 'video', 'admin', '2026-06-23 18:58:10', '', NULL, '视频管理目录');
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2026-06-14 21:43:54', '', NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2026-06-14 21:43:54', '', NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2026-06-14 21:43:54', '', NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (103, '部门管理', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2026-06-14 21:43:54', '', NULL, '部门管理菜单');
INSERT INTO `sys_menu` VALUES (104, '岗位管理', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2026-06-14 21:43:54', '', NULL, '岗位管理菜单');
INSERT INTO `sys_menu` VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2026-06-14 21:43:54', '', NULL, '字典管理菜单');
INSERT INTO `sys_menu` VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2026-06-14 21:43:54', '', NULL, '参数设置菜单');
INSERT INTO `sys_menu` VALUES (107, '通知公告', 1, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2026-06-14 21:43:54', '', NULL, '通知公告菜单');
INSERT INTO `sys_menu` VALUES (108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2026-06-14 21:43:54', '', NULL, '日志管理菜单');
INSERT INTO `sys_menu` VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2026-06-14 21:43:54', '', NULL, '在线用户菜单');
INSERT INTO `sys_menu` VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2026-06-14 21:43:54', '', NULL, '定时任务菜单');
INSERT INTO `sys_menu` VALUES (111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', 'admin', '2026-06-14 21:43:54', '', NULL, '数据监控菜单');
INSERT INTO `sys_menu` VALUES (112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2026-06-14 21:43:54', '', NULL, '服务监控菜单');
INSERT INTO `sys_menu` VALUES (113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2026-06-14 21:43:54', '', NULL, '缓存监控菜单');
INSERT INTO `sys_menu` VALUES (114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2026-06-14 21:43:54', '', NULL, '缓存列表菜单');
INSERT INTO `sys_menu` VALUES (115, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2026-06-14 21:43:54', '', NULL, '表单构建菜单');
INSERT INTO `sys_menu` VALUES (116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2026-06-14 21:43:54', '', NULL, '代码生成菜单');
INSERT INTO `sys_menu` VALUES (117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2026-06-14 21:43:54', '', NULL, '系统接口菜单');
INSERT INTO `sys_menu` VALUES (118, '中间件监控', 2, 7, 'middleware', 'monitor/middleware/index', '', '', 1, 0, 'C', '0', '0', 'monitor:middleware:list', 'server', 'admin', '2026-07-23 08:57:58', '', NULL, '中间件状态监控');
INSERT INTO `sys_menu` VALUES (200, '财务管理', 5, 1, 'finance', NULL, NULL, '', 1, 0, 'M', '0', '0', NULL, 'money', 'admin', '2026-07-01 11:23:16', '', NULL, '财务管理目录');
INSERT INTO `sys_menu` VALUES (201, '财务记录', 200, 1, 'index', 'finance/index', NULL, '', 1, 1, 'C', '0', '0', 'finance:list', 'list', 'admin', '2026-07-01 11:23:16', '', NULL, '财务记录菜单');
INSERT INTO `sys_menu` VALUES (202, '财务统计', 200, 2, 'statistics', 'finance/statistics', NULL, '', 1, 1, 'C', '0', '0', 'finance:stat', 'chart', 'admin', '2026-07-01 11:23:16', '', NULL, '财务统计菜单');
INSERT INTO `sys_menu` VALUES (203, '财务查询', 201, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:query', '#', 'admin', '2026-07-01 11:23:16', '', NULL, '');
INSERT INTO `sys_menu` VALUES (204, '财务新增', 201, 2, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:add', '#', 'admin', '2026-07-01 11:23:16', '', NULL, '');
INSERT INTO `sys_menu` VALUES (205, '财务修改', 201, 3, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:edit', '#', 'admin', '2026-07-01 11:23:16', '', NULL, '');
INSERT INTO `sys_menu` VALUES (206, '财务删除', 201, 4, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:remove', '#', 'admin', '2026-07-01 11:23:16', '', NULL, '');
INSERT INTO `sys_menu` VALUES (207, '财务统计', 202, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:stat', '#', 'admin', '2026-07-01 11:23:16', '', NULL, '');
INSERT INTO `sys_menu` VALUES (500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2026-06-14 21:43:54', '', NULL, '操作日志菜单');
INSERT INTO `sys_menu` VALUES (501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2026-06-14 21:43:54', '', NULL, '登录日志菜单');
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2000, '视频列表', 5, 1, 'list', 'video/index', NULL, '', 1, 0, 'C', '0', '0', 'video:list', 'list', 'admin', '2026-06-23 18:58:10', '', NULL, '视频列表菜单');
INSERT INTO `sys_menu` VALUES (2001, '视频查询', 2000, 1, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:query', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2002, '视频新增', 2000, 2, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:add', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2003, '视频修改', 2000, 3, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:edit', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2004, '视频删除', 2000, 4, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:remove', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2005, '视频导出', 2000, 5, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:export', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2010, '资源管理', 5, 2, 'resource', 'video/resource', NULL, '', 1, 0, 'C', '0', '0', 'video:resource:list', 'folder', 'admin', '2026-06-24 09:01:27', '', NULL, '资源管理菜单');
INSERT INTO `sys_menu` VALUES (2011, '资源查询', 2010, 1, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:query', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2012, '资源新增', 2010, 2, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:add', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2013, '资源修改', 2010, 3, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:edit', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2014, '资源删除', 2010, 4, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:remove', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2015, '资源导出', 2010, 5, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:export', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3006, '数据管理', 0, 6, 'data', NULL, '', '', 1, 0, 'M', '0', '0', '', 'database', 'admin', '2026-07-09 00:00:00', '', NULL, '数据管理目录');
INSERT INTO `sys_menu` VALUES (3007, 'SQL管理', 3006, 1, 'sqlRecord', 'system/sqlRecord/index', '', '', 1, 0, 'C', '0', '0', 'system:sql:list', 'code', 'admin', '2026-07-09 00:00:00', '', NULL, 'SQL记录管理菜单');
INSERT INTO `sys_menu` VALUES (3008, 'SQL查询', 3007, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'system:sql:query', '#', 'admin', '2026-07-09 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3009, 'SQL新增', 3007, 2, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'system:sql:add', '#', 'admin', '2026-07-09 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3010, 'SQL修改', 3007, 3, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'system:sql:edit', '#', 'admin', '2026-07-09 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3011, 'SQL删除', 3007, 4, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'system:sql:remove', '#', 'admin', '2026-07-09 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3012, '工作流', 3006, 2, 'workflow', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tree', 'admin', '2026-08-18 00:00:00', '', NULL, '工作流演示目录');
INSERT INTO `sys_menu` VALUES (3013, '请假申请', 3012, 1, 'leave', 'workflow/leave/index', '', '', 1, 0, 'C', '0', '0', 'workflow:leave:list', 'form', 'admin', '2026-08-18 00:00:00', '', NULL, '请假申请菜单');
INSERT INTO `sys_menu` VALUES (3014, '待办审批', 3012, 2, 'todo', 'workflow/todo/index', '', '', 1, 0, 'C', '0', '0', 'workflow:task:list', 'checkbox', 'admin', '2026-08-18 00:00:00', '', NULL, '待办审批菜单');
INSERT INTO `sys_menu` VALUES (3015, '流程定义', 3012, 3, 'definition', 'workflow/definition/index', '', '', 1, 0, 'C', '0', '0', 'workflow:definition:list', 'documentation', 'admin', '2026-08-18 00:00:00', '', NULL, '流程定义菜单');
INSERT INTO `sys_menu` VALUES (3016, '请假新增', 3013, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'workflow:leave:add', '#', 'admin', '2026-08-18 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3017, '请假删除', 3013, 2, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'workflow:leave:remove', '#', 'admin', '2026-08-18 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3018, '任务审批', 3014, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'workflow:task:approve', '#', 'admin', '2026-08-18 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3019, '流程部署', 3015, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'workflow:definition:add', '#', 'admin', '2026-08-18 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3020, '流程删除', 3015, 2, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'workflow:definition:remove', '#', 'admin', '2026-08-18 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3021, '流程管理', 3012, 4, 'model', 'workflow/model/index', '', '', 1, 0, 'C', '0', '0', 'workflow:model:list', 'guide', 'admin', '2026-08-19 00:00:00', '', NULL, '流程模型管理菜单');
INSERT INTO `sys_menu` VALUES (3022, '流程新增', 3021, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'workflow:model:add', '#', 'admin', '2026-08-19 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3023, '流程编辑', 3021, 2, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'workflow:model:edit', '#', 'admin', '2026-08-19 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3024, '流程发布', 3021, 3, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'workflow:model:publish', '#', 'admin', '2026-08-19 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3025, '流程删除', 3021, 4, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'workflow:model:remove', '#', 'admin', '2026-08-19 00:00:00', '', NULL, '');
INSERT INTO `sys_menu` VALUES (3026, '流程导入', 3021, 5, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'workflow:model:import', '#', 'admin', '2026-08-19 00:00:00', '', NULL, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` int NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES (1, '温馨提醒：2018-07-01 若依新版本发布啦', '2', 0xE696B0E78988E69CACE58685E5AEB9, '0', 'admin', '2026-06-14 21:43:55', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (2, '维护通知：2018-07-01 若依系统凌晨维护', '1', 0xE7BBB4E68AA4E58685E5AEB9, '0', 'admin', '2026-06-14 21:43:55', '', NULL, '管理员');

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 331 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (100, '菜单管理', 1, 'com.ddss.web.controller.system.SysMenuController.add()', 'POST', 1, 'admin', '研发部门', '/system/menu', '127.0.0.1', '内网IP', '{\"children\":[],\"createBy\":\"admin\",\"icon\":\"bug\",\"isCache\":\"0\",\"isFrame\":\"1\",\"menuName\":\"视频管理\",\"menuType\":\"M\",\"orderNum\":5,\"params\":{},\"parentId\":0,\"path\":\"video\",\"status\":\"0\",\"visible\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-06-23 18:10:51', 37);
INSERT INTO `sys_oper_log` VALUES (101, '角色管理', 2, 'com.ddss.web.controller.system.SysRoleController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/role', '127.0.0.1', '内网IP', '{\"admin\":false,\"createTime\":\"2026-06-14 21:45:31\",\"dataScope\":\"2\",\"delFlag\":\"0\",\"deptCheckStrictly\":true,\"flag\":false,\"menuCheckStrictly\":true,\"menuIds\":[1,100,1000,1001,1002,1003,1004,1005,1006,101,1007,1008,1009,1010,1011,102,1012,1013,1014,1015,103,1016,1017,1018,1019,104,1020,1021,1022,1023,1024,105,1025,1026,1027,1028,1029,106,1030,1031,1032,1033,1034,107,1035,1036,1037,1038,108,500,1039,1040,1041,501,1042,1043,1044,1045,2,109,1046,1047,1048,110,1049,1050,1051,1052,1053,1054,111,112,113,114,3,115,116,1055,1056,1057,1058,1059,1060,117,4,2000],\"params\":{},\"remark\":\"普通角色\",\"roleId\":2,\"roleKey\":\"common\",\"roleName\":\"普通角色\",\"roleSort\":2,\"status\":\"0\",\"updateBy\":\"admin\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-06-23 18:57:05', 137);
INSERT INTO `sys_oper_log` VALUES (102, '视频管理', 1, 'com.ddss.web.controller.video.VideoController.add()', 'POST', 1, 'admin', '研发部门', '/video', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"status\":\"0\",\"videoId\":1,\"videoName\":\"1\",\"videoUrl\":\"2\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-06-23 19:08:19', 35);
INSERT INTO `sys_oper_log` VALUES (103, '菜单管理', 3, 'com.ddss.web.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/4', '127.0.0.1', '内网IP', '4 ', '{\"msg\":\"菜单已分配,不允许删除\",\"code\":601}', 0, NULL, '2026-06-24 08:55:15', 24);
INSERT INTO `sys_oper_log` VALUES (104, '用户头像', 2, 'com.ddss.web.controller.system.SysProfileController.avatar()', 'POST', 1, 'admin', '研发部门', '/system/user/profile/avatar', '127.0.0.1', '内网IP', '', '{\"msg\":\"操作成功\",\"imgUrl\":\"/profile/avatar/2026/06/26/75e3b1cc4eb1460eb2d320c55a1662ea.png\",\"code\":200}', 0, NULL, '2026-06-26 13:00:35', 205);
INSERT INTO `sys_oper_log` VALUES (105, '个人信息', 2, 'com.ddss.web.controller.system.SysProfileController.updateProfile()', 'PUT', 1, 'admin', '研发部门', '/system/user/profile', '127.0.0.1', '内网IP', '{\"admin\":false,\"email\":\"vip.p@live.com\",\"nickName\":\"DDSS管理员\",\"params\":{},\"phonenumber\":\"13888888888\",\"sex\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-06-26 13:00:36', 24);
INSERT INTO `sys_oper_log` VALUES (106, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"remainingAmount\":9265,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:01:12', 74);
INSERT INTO `sys_oper_log` VALUES (107, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":13329,\"financeId\":2,\"interestAmount\":1752,\"loanAmount\":13200,\"loanDate\":\"2026-06-16\",\"loanTerm\":12,\"monthlyPayment\":1246,\"paidAmount\":0,\"remainingAmount\":13200,\"repaymentDay\":16,\"repaymentEndDate\":\"2027-07-16\",\"repaymentStartDate\":\"2026-07-16\",\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:03:34', 15);
INSERT INTO `sys_oper_log` VALUES (108, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:04', 66);
INSERT INTO `sys_oper_log` VALUES (109, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":2648.00,\"remainingAmount\":13236.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:05', 7);
INSERT INTO `sys_oper_log` VALUES (110, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":3972.00,\"remainingAmount\":11912.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:15', 9);
INSERT INTO `sys_oper_log` VALUES (111, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":5296.00,\"remainingAmount\":10588.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:16', 17);
INSERT INTO `sys_oper_log` VALUES (112, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":3972.00,\"remainingAmount\":11912.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:21', 7);
INSERT INTO `sys_oper_log` VALUES (113, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":2648.00,\"remainingAmount\":13236.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:26', 8);
INSERT INTO `sys_oper_log` VALUES (114, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:30', 6);
INSERT INTO `sys_oper_log` VALUES (115, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":2648.00,\"remainingAmount\":13236.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:31', 7);
INSERT INTO `sys_oper_log` VALUES (116, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":3972.00,\"remainingAmount\":11912.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:43', 6);
INSERT INTO `sys_oper_log` VALUES (117, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":5296.00,\"remainingAmount\":10588.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:45', 7);
INSERT INTO `sys_oper_log` VALUES (118, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":6620.00,\"remainingAmount\":9264.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:46', 8);
INSERT INTO `sys_oper_log` VALUES (119, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":5296.00,\"remainingAmount\":10588.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:46', 8);
INSERT INTO `sys_oper_log` VALUES (120, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":6620.00,\"remainingAmount\":9264.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:47', 12);
INSERT INTO `sys_oper_log` VALUES (121, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":5296.00,\"remainingAmount\":10588.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:48', 7);
INSERT INTO `sys_oper_log` VALUES (122, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":3972.00,\"remainingAmount\":11912.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:32:50', 10);
INSERT INTO `sys_oper_log` VALUES (123, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:36:23', 9);
INSERT INTO `sys_oper_log` VALUES (124, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":0.00,\"remainingAmount\":15884.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:36:25', 5);
INSERT INTO `sys_oper_log` VALUES (125, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:36:26', 7);
INSERT INTO `sys_oper_log` VALUES (126, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":2648.00,\"remainingAmount\":13236.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:36:26', 6);
INSERT INTO `sys_oper_log` VALUES (127, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:36:28', 6);
INSERT INTO `sys_oper_log` VALUES (128, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":0.00,\"remainingAmount\":15884.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:36:29', 14);
INSERT INTO `sys_oper_log` VALUES (129, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:38:24', 7);
INSERT INTO `sys_oper_log` VALUES (130, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"paidMonths\":\"7月\",\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:43:08', 110);
INSERT INTO `sys_oper_log` VALUES (131, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":0.00,\"paidMonths\":\"\",\"remainingAmount\":15884.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 13:50:58', 10);
INSERT INTO `sys_oper_log` VALUES (132, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"paidMonths\":\"7月\",\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:21:06', 78);
INSERT INTO `sys_oper_log` VALUES (133, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":0.00,\"paidMonths\":\"\",\"remainingAmount\":15884.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:21:24', 7);
INSERT INTO `sys_oper_log` VALUES (134, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"paidMonths\":\"7月\",\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:21:25', 12);
INSERT INTO `sys_oper_log` VALUES (135, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":0.00,\"paidMonths\":\"\",\"remainingAmount\":15884.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:50:12', 114);
INSERT INTO `sys_oper_log` VALUES (136, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"paidMonths\":\"7月\",\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:50:14', 25);
INSERT INTO `sys_oper_log` VALUES (137, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":0.00,\"paidMonths\":\"\",\"remainingAmount\":15884.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:55:49', 81);
INSERT INTO `sys_oper_log` VALUES (138, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"paidMonths\":\"7月\",\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:55:51', 8);
INSERT INTO `sys_oper_log` VALUES (139, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":0.00,\"paidMonths\":\"\",\"remainingAmount\":15884.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:55:55', 13);
INSERT INTO `sys_oper_log` VALUES (140, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"paidMonths\":\"7月\",\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:55:57', 11);
INSERT INTO `sys_oper_log` VALUES (141, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":2648.00,\"paidMonths\":\"7月,8月\",\"remainingAmount\":13236.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:56:12', 14);
INSERT INTO `sys_oper_log` VALUES (142, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthlyPayment\":1324,\"paidAmount\":1324.00,\"paidMonths\":\"7月\",\"remainingAmount\":14560.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:56:14', 7);
INSERT INTO `sys_oper_log` VALUES (143, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":124}}\",\"monthlyPayment\":1324,\"paidAmount\":1324,\"paidMonths\":\"7月\",\"remainingAmount\":14560,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:58:33', 9);
INSERT INTO `sys_oper_log` VALUES (144, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:03:34\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":13329,\"financeId\":2,\"interestAmount\":1752,\"loanAmount\":13200,\"loanDate\":\"2026-06-16\",\"loanTerm\":12,\"monthData\":\"{\\\"8月\\\":{\\\"amt\\\":1246}}\",\"monthlyPayment\":1246,\"paidAmount\":0,\"remainingAmount\":13200,\"repaymentDay\":16,\"repaymentEndDate\":\"2027-07-16\",\"repaymentStartDate\":\"2026-07-16\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:03:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 14:58:34', 11);
INSERT INTO `sys_oper_log` VALUES (145, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:03:34\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":13329,\"financeId\":2,\"interestAmount\":1752,\"loanAmount\":13200,\"loanDate\":\"2026-06-16\",\"loanTerm\":12,\"monthData\":\"{\\\"8月\\\":{\\\"amt\\\":1246},\\\"7月\\\":{\\\"amt\\\":1246}}\",\"monthlyPayment\":1246,\"paidAmount\":0,\"remainingAmount\":13200,\"repaymentDay\":16,\"repaymentEndDate\":\"2027-07-16\",\"repaymentStartDate\":\"2026-07-16\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:03:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 15:00:44', 12);
INSERT INTO `sys_oper_log` VALUES (146, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:03:34\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":13329,\"financeId\":2,\"interestAmount\":1752,\"loanAmount\":13200,\"loanDate\":\"2026-06-16\",\"loanTerm\":12,\"monthData\":\"{\\\"8月\\\":{\\\"amt\\\":1246},\\\"7月\\\":{\\\"amt\\\":1246}}\",\"monthlyPayment\":1246,\"paidAmount\":0,\"remainingAmount\":13200,\"repaymentDay\":16,\"repaymentEndDate\":\"2027-07-16\",\"repaymentStartDate\":\"2026-07-16\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:03:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 15:00:46', 6);
INSERT INTO `sys_oper_log` VALUES (147, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":124},\\\"4月\\\":{\\\"amt\\\":1}}\",\"monthlyPayment\":1324,\"paidAmount\":1324,\"paidMonths\":\"7月\",\"remainingAmount\":14560,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 15:00:51', 11);
INSERT INTO `sys_oper_log` VALUES (148, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:03:34\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":13329,\"financeId\":2,\"interestAmount\":1752,\"loanAmount\":13200,\"loanDate\":\"2026-06-16\",\"loanTerm\":12,\"monthData\":\"{\\\"8月\\\":{\\\"amt\\\":1246},\\\"7月\\\":{\\\"amt\\\":3}}\",\"monthlyPayment\":1246,\"paidAmount\":0,\"remainingAmount\":13200,\"repaymentDay\":16,\"repaymentEndDate\":\"2027-07-16\",\"repaymentStartDate\":\"2026-07-16\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:03:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 15:04:02', 92);
INSERT INTO `sys_oper_log` VALUES (149, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":1},\\\"4月\\\":{\\\"amt\\\":1}}\",\"monthlyPayment\":1324,\"paidAmount\":1324,\"paidMonths\":\"7月\",\"remainingAmount\":14560,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 15:04:05', 8);
INSERT INTO `sys_oper_log` VALUES (150, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":0},\\\"4月\\\":{\\\"amt\\\":1}}\",\"monthlyPayment\":1324,\"paidAmount\":10593.00,\"paidMonths\":\"7月\",\"remainingAmount\":5291.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 16:42:26', 10);
INSERT INTO `sys_oper_log` VALUES (151, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:03:34\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":13329,\"financeId\":2,\"interestAmount\":1752,\"loanAmount\":13200,\"loanDate\":\"2026-06-16\",\"loanTerm\":12,\"monthData\":\"{\\\"8月\\\":{\\\"amt\\\":1246},\\\"7月\\\":{\\\"amt\\\":0}}\",\"monthlyPayment\":1246,\"paidAmount\":13706.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"repaymentEndDate\":\"2027-07-16\",\"repaymentStartDate\":\"2026-07-16\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:03:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 16:42:33', 7);
INSERT INTO `sys_oper_log` VALUES (152, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:01:11\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":8848,\"financeId\":1,\"interestAmount\":4,\"loanAmount\":15884,\"loanDate\":\"2026-02-09\",\"loanTerm\":12,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":0},\\\"4月\\\":{\\\"amt\\\":0}}\",\"monthlyPayment\":1324,\"paidAmount\":10592.00,\"paidMonths\":\"7月\",\"remainingAmount\":5292.00,\"repaymentDay\":9,\"repaymentEndDate\":\"2027-03-09\",\"repaymentStartDate\":\"2026-03-09\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:01:11\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 16:42:43', 8);
INSERT INTO `sys_oper_log` VALUES (153, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:03:34\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":13329,\"financeId\":2,\"interestAmount\":1752,\"loanAmount\":13200,\"loanDate\":\"2026-06-16\",\"loanTerm\":12,\"monthData\":\"{\\\"8月\\\":{\\\"amt\\\":1246},\\\"7月\\\":{\\\"amt\\\":1246}}\",\"monthlyPayment\":1246,\"paidAmount\":16198.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"repaymentEndDate\":\"2027-07-16\",\"repaymentStartDate\":\"2026-07-16\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:03:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 16:43:03', 7);
INSERT INTO `sys_oper_log` VALUES (154, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"分期乐\",\"financeId\":3,\"repaymentDay\":25,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 16:49:54', 22);
INSERT INTO `sys_oper_log` VALUES (155, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637}}\",\"paidAmount\":5274.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 16:50:14', 7);
INSERT INTO `sys_oper_log` VALUES (156, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637},\\\"8月\\\":{\\\"amt\\\":2637}}\",\"paidAmount\":7911.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 16:50:22', 9);
INSERT INTO `sys_oper_log` VALUES (157, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637},\\\"8月\\\":{\\\"amt\\\":2637}}\",\"paidAmount\":7911.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 16:50:24', 3);
INSERT INTO `sys_oper_log` VALUES (158, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637},\\\"8月\\\":{\\\"amt\\\":2637}}\",\"paidAmount\":7911.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 16:50:28', 4);
INSERT INTO `sys_oper_log` VALUES (159, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637},\\\"8月\\\":{\\\"amt\\\":2637},\\\"9月\\\":{\\\"amt\\\":1770}}\",\"paidAmount\":9681.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 16:50:33', 6);
INSERT INTO `sys_oper_log` VALUES (160, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637},\\\"8月\\\":{\\\"amt\\\":2637},\\\"9月\\\":{\\\"amt\\\":1770},\\\"10月\\\":{\\\"amt\\\":1533}}\",\"paidAmount\":11214.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:05:16', 9);
INSERT INTO `sys_oper_log` VALUES (161, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637},\\\"8月\\\":{\\\"amt\\\":2637},\\\"9月\\\":{\\\"amt\\\":1770},\\\"10月\\\":{\\\"amt\\\":1533},\\\"11月\\\":{\\\"amt\\\":1533}}\",\"paidAmount\":12747.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:05:22', 6);
INSERT INTO `sys_oper_log` VALUES (162, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637},\\\"8月\\\":{\\\"amt\\\":2637},\\\"9月\\\":{\\\"amt\\\":1770},\\\"10月\\\":{\\\"amt\\\":1533},\\\"11月\\\":{\\\"amt\\\":1533},\\\"12月\\\":{\\\"amt\\\":1533}}\",\"paidAmount\":14280.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:05:29', 8);
INSERT INTO `sys_oper_log` VALUES (163, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637},\\\"8月\\\":{\\\"amt\\\":2637},\\\"9月\\\":{\\\"amt\\\":1770},\\\"10月\\\":{\\\"amt\\\":1533},\\\"11月\\\":{\\\"amt\\\":1533},\\\"12月\\\":{\\\"amt\\\":1533},\\\"1月\\\":{\\\"amt\\\":1533}}\",\"paidAmount\":15813.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:05:47', 19);
INSERT INTO `sys_oper_log` VALUES (164, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637},\\\"8月\\\":{\\\"amt\\\":2637},\\\"9月\\\":{\\\"amt\\\":1770},\\\"10月\\\":{\\\"amt\\\":1533},\\\"11月\\\":{\\\"amt\\\":1533},\\\"12月\\\":{\\\"amt\\\":1533},\\\"1月\\\":{\\\"amt\\\":1533},\\\"2月\\\":{\\\"amt\\\":1533}}\",\"paidAmount\":17346.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:05:51', 7);
INSERT INTO `sys_oper_log` VALUES (165, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":2637},\\\"8月\\\":{\\\"amt\\\":2637},\\\"9月\\\":{\\\"amt\\\":1770},\\\"10月\\\":{\\\"amt\\\":1533},\\\"11月\\\":{\\\"amt\\\":1533},\\\"12月\\\":{\\\"amt\\\":1533},\\\"1月\\\":{\\\"amt\\\":1533},\\\"2月\\\":{\\\"amt\\\":1533},\\\"3月\\\":{\\\"amt\\\":700}}\",\"paidAmount\":18046.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:05:56', 8);
INSERT INTO `sys_oper_log` VALUES (166, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":0},\\\"8月\\\":{\\\"amt\\\":2637},\\\"9月\\\":{\\\"amt\\\":1770},\\\"10月\\\":{\\\"amt\\\":1533},\\\"11月\\\":{\\\"amt\\\":1533},\\\"12月\\\":{\\\"amt\\\":1533},\\\"1月\\\":{\\\"amt\\\":1533},\\\"2月\\\":{\\\"amt\\\":1533},\\\"3月\\\":{\\\"amt\\\":700}}\",\"paidAmount\":12772.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:08:02', 8);
INSERT INTO `sys_oper_log` VALUES (167, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 16:49:54\",\"creditorName\":\"分期乐\",\"financeId\":3,\"monthData\":\"{\\\"7月\\\":{\\\"amt\\\":0},\\\"8月\\\":{\\\"amt\\\":2637},\\\"9月\\\":{\\\"amt\\\":1770},\\\"10月\\\":{\\\"amt\\\":1533},\\\"11月\\\":{\\\"amt\\\":1533},\\\"12月\\\":{\\\"amt\\\":1533},\\\"1月\\\":{\\\"amt\\\":1533},\\\"2月\\\":{\\\"amt\\\":1533},\\\"3月\\\":{\\\"amt\\\":700},\\\"26-7月\\\":{\\\"amt\\\":2637}}\",\"paidAmount\":15409.00,\"remainingAmount\":0.00,\"repaymentDay\":25,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 16:49:54\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:11:23', 7);
INSERT INTO `sys_oper_log` VALUES (168, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"安逸花\",\"financeId\":4,\"repaymentDay\":16,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:13:13', 14);
INSERT INTO `sys_oper_log` VALUES (169, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:13:13\",\"creditorName\":\"安逸花\",\"financeId\":4,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":803}}\",\"paidAmount\":803.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:13:13\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:14:19', 12);
INSERT INTO `sys_oper_log` VALUES (170, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:13:13\",\"creditorName\":\"安逸花\",\"financeId\":4,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":803},\\\"26-8月\\\":{\\\"amt\\\":803}}\",\"paidAmount\":1606.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:13:13\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:14:21', 7);
INSERT INTO `sys_oper_log` VALUES (171, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:13:13\",\"creditorName\":\"安逸花\",\"financeId\":4,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":803},\\\"26-8月\\\":{\\\"amt\\\":803},\\\"26-9月\\\":{\\\"amt\\\":803}}\",\"paidAmount\":2409.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:13:13\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:14:24', 7);
INSERT INTO `sys_oper_log` VALUES (172, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:13:13\",\"creditorName\":\"安逸花\",\"financeId\":4,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":803},\\\"26-8月\\\":{\\\"amt\\\":803},\\\"26-9月\\\":{\\\"amt\\\":803},\\\"26-10月\\\":{\\\"amt\\\":803}}\",\"paidAmount\":3212.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:13:13\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:14:26', 6);
INSERT INTO `sys_oper_log` VALUES (173, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:13:13\",\"creditorName\":\"安逸花\",\"financeId\":4,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":803},\\\"26-8月\\\":{\\\"amt\\\":803},\\\"26-9月\\\":{\\\"amt\\\":803},\\\"26-10月\\\":{\\\"amt\\\":803},\\\"26-11月\\\":{\\\"amt\\\":803}}\",\"paidAmount\":4015.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:13:13\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:14:31', 7);
INSERT INTO `sys_oper_log` VALUES (174, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:13:13\",\"creditorName\":\"安逸花\",\"financeId\":4,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":803},\\\"26-8月\\\":{\\\"amt\\\":803},\\\"26-9月\\\":{\\\"amt\\\":803},\\\"26-10月\\\":{\\\"amt\\\":803},\\\"26-11月\\\":{\\\"amt\\\":803},\\\"26-12月\\\":{\\\"amt\\\":803}}\",\"paidAmount\":4818.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:13:13\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:14:33', 8);
INSERT INTO `sys_oper_log` VALUES (175, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:13:13\",\"creditorName\":\"安逸花\",\"financeId\":4,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":803},\\\"26-8月\\\":{\\\"amt\\\":803},\\\"26-9月\\\":{\\\"amt\\\":803},\\\"26-10月\\\":{\\\"amt\\\":803},\\\"26-11月\\\":{\\\"amt\\\":803},\\\"26-12月\\\":{\\\"amt\\\":803},\\\"27-1月\\\":{\\\"amt\\\":666}}\",\"paidAmount\":5484.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:13:13\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:14:44', 7);
INSERT INTO `sys_oper_log` VALUES (176, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:13:13\",\"creditorName\":\"安逸花\",\"financeId\":4,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":803},\\\"26-8月\\\":{\\\"amt\\\":803},\\\"26-9月\\\":{\\\"amt\\\":803},\\\"26-10月\\\":{\\\"amt\\\":803},\\\"26-11月\\\":{\\\"amt\\\":803},\\\"26-12月\\\":{\\\"amt\\\":803},\\\"27-1月\\\":{\\\"amt\\\":666},\\\"27-2月\\\":{\\\"amt\\\":666}}\",\"paidAmount\":6150.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:13:13\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:14:47', 7);
INSERT INTO `sys_oper_log` VALUES (177, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:13:13\",\"creditorName\":\"安逸花\",\"financeId\":4,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":803},\\\"26-8月\\\":{\\\"amt\\\":803},\\\"26-9月\\\":{\\\"amt\\\":803},\\\"26-10月\\\":{\\\"amt\\\":803},\\\"26-11月\\\":{\\\"amt\\\":803},\\\"26-12月\\\":{\\\"amt\\\":803},\\\"27-1月\\\":{\\\"amt\\\":666},\\\"27-2月\\\":{\\\"amt\\\":666},\\\"27-3月\\\":{\\\"amt\\\":500}}\",\"paidAmount\":6650.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:13:13\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:14:52', 7);
INSERT INTO `sys_oper_log` VALUES (178, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:13:13\",\"creditorName\":\"安逸花\",\"financeId\":4,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":803},\\\"26-8月\\\":{\\\"amt\\\":803},\\\"26-9月\\\":{\\\"amt\\\":803},\\\"26-10月\\\":{\\\"amt\\\":803},\\\"26-11月\\\":{\\\"amt\\\":803},\\\"26-12月\\\":{\\\"amt\\\":803},\\\"27-1月\\\":{\\\"amt\\\":666},\\\"27-2月\\\":{\\\"amt\\\":666},\\\"27-3月\\\":{\\\"amt\\\":500},\\\"27-4月\\\":{\\\"amt\\\":280}}\",\"paidAmount\":6930.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:13:13\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:14:55', 6);
INSERT INTO `sys_oper_log` VALUES (179, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthlyPayment\":1100,\"repaymentDay\":28,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:20:01', 6);
INSERT INTO `sys_oper_log` VALUES (180, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 13:03:34\",\"creditorName\":\"洋钱罐\",\"earlySettlementAmount\":13329,\"financeId\":2,\"interestAmount\":1752,\"loanAmount\":13200,\"loanDate\":\"2026-06-16\",\"loanTerm\":12,\"monthData\":\"{\\\"8月\\\":{\\\"amt\\\":1246},\\\"7月\\\":{\\\"amt\\\":1246},\\\"27-7月\\\":{\\\"amt\\\":0}}\",\"monthlyPayment\":1246,\"paidAmount\":14952.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"repaymentEndDate\":\"2027-07-16\",\"repaymentStartDate\":\"2026-07-16\",\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 13:03:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:20:29', 5);
INSERT INTO `sys_oper_log` VALUES (181, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:20:01\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":1100.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:20:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:20:40', 7);
INSERT INTO `sys_oper_log` VALUES (182, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:20:01\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":2200.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:20:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:20:42', 6);
INSERT INTO `sys_oper_log` VALUES (183, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:20:01\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":3300.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:20:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:20:46', 6);
INSERT INTO `sys_oper_log` VALUES (184, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:20:01\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":4400.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:20:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:20:54', 6);
INSERT INTO `sys_oper_log` VALUES (185, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:20:01\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":5500.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:20:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:20:59', 7);
INSERT INTO `sys_oper_log` VALUES (186, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:20:01\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100},\\\"26-12月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":6600.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:20:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:21:01', 8);
INSERT INTO `sys_oper_log` VALUES (187, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:20:01\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100},\\\"26-12月\\\":{\\\"amt\\\":1100},\\\"27-1月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":7700.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:20:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:21:05', 6);
INSERT INTO `sys_oper_log` VALUES (188, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:20:01\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100},\\\"26-12月\\\":{\\\"amt\\\":1100},\\\"27-1月\\\":{\\\"amt\\\":1100},\\\"27-2月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":8800.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:20:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:21:07', 9);
INSERT INTO `sys_oper_log` VALUES (189, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:20:01\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100},\\\"26-12月\\\":{\\\"amt\\\":1100},\\\"27-1月\\\":{\\\"amt\\\":1100},\\\"27-2月\\\":{\\\"amt\\\":1100},\\\"27-3月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":9900.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:20:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:21:10', 7);
INSERT INTO `sys_oper_log` VALUES (190, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:20:01\",\"creditorName\":\"时光\",\"financeId\":5,\"loanTerm\":12,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100},\\\"26-12月\\\":{\\\"amt\\\":1100},\\\"27-1月\\\":{\\\"amt\\\":1100},\\\"27-2月\\\":{\\\"amt\\\":1100},\\\"27-3月\\\":{\\\"amt\\\":1100},\\\"27-4月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":11000.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:20:01\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:21:25', 7);
INSERT INTO `sys_oper_log` VALUES (191, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"五八\",\"financeId\":6,\"repaymentDay\":18,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:25:22', 4);
INSERT INTO `sys_oper_log` VALUES (192, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:25:22\",\"creditorName\":\"五八\",\"financeId\":6,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":900}}\",\"paidAmount\":900.00,\"remainingAmount\":0.00,\"repaymentDay\":18,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:25:22\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:25:29', 7);
INSERT INTO `sys_oper_log` VALUES (193, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:25:22\",\"creditorName\":\"五八\",\"financeId\":6,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":900},\\\"26-8月\\\":{\\\"amt\\\":900}}\",\"paidAmount\":1800.00,\"remainingAmount\":0.00,\"repaymentDay\":18,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:25:22\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:25:33', 8);
INSERT INTO `sys_oper_log` VALUES (194, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:25:22\",\"creditorName\":\"五八\",\"financeId\":6,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":900},\\\"26-8月\\\":{\\\"amt\\\":900},\\\"26-9月\\\":{\\\"amt\\\":900}}\",\"paidAmount\":2700.00,\"remainingAmount\":0.00,\"repaymentDay\":18,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:25:22\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:25:36', 6);
INSERT INTO `sys_oper_log` VALUES (195, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:25:22\",\"creditorName\":\"五八\",\"financeId\":6,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":900},\\\"26-8月\\\":{\\\"amt\\\":900},\\\"26-9月\\\":{\\\"amt\\\":900},\\\"26-10月\\\":{\\\"amt\\\":900}}\",\"paidAmount\":3600.00,\"remainingAmount\":0.00,\"repaymentDay\":18,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:25:22\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:25:41', 7);
INSERT INTO `sys_oper_log` VALUES (196, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:25:22\",\"creditorName\":\"五八\",\"financeId\":6,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":900},\\\"26-8月\\\":{\\\"amt\\\":900},\\\"26-9月\\\":{\\\"amt\\\":900},\\\"26-10月\\\":{\\\"amt\\\":900},\\\"26-11月\\\":{\\\"amt\\\":900}}\",\"paidAmount\":4500.00,\"remainingAmount\":0.00,\"repaymentDay\":18,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:25:22\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:25:43', 7);
INSERT INTO `sys_oper_log` VALUES (197, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:25:22\",\"creditorName\":\"五八\",\"financeId\":6,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":900},\\\"26-8月\\\":{\\\"amt\\\":900},\\\"26-9月\\\":{\\\"amt\\\":900},\\\"26-10月\\\":{\\\"amt\\\":900},\\\"26-11月\\\":{\\\"amt\\\":900},\\\"26-12月\\\":{\\\"amt\\\":900}}\",\"paidAmount\":5400.00,\"remainingAmount\":0.00,\"repaymentDay\":18,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:25:22\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:25:46', 7);
INSERT INTO `sys_oper_log` VALUES (198, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:25:22\",\"creditorName\":\"五八\",\"financeId\":6,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":900},\\\"26-8月\\\":{\\\"amt\\\":900},\\\"26-9月\\\":{\\\"amt\\\":900},\\\"26-10月\\\":{\\\"amt\\\":900},\\\"26-11月\\\":{\\\"amt\\\":900},\\\"26-12月\\\":{\\\"amt\\\":900},\\\"27-1月\\\":{\\\"amt\\\":900}}\",\"paidAmount\":6300.00,\"remainingAmount\":0.00,\"repaymentDay\":18,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:25:22\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:25:49', 7);
INSERT INTO `sys_oper_log` VALUES (199, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthlyPayment\":1100,\"repaymentDay\":19,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:26:41', 12);
INSERT INTO `sys_oper_log` VALUES (200, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:26:41\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":1100.00,\"remainingAmount\":0.00,\"repaymentDay\":19,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:26:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:26:48', 6);
INSERT INTO `sys_oper_log` VALUES (201, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:26:41\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":2200.00,\"remainingAmount\":0.00,\"repaymentDay\":19,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:26:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:26:51', 6);
INSERT INTO `sys_oper_log` VALUES (202, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:26:41\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":3300.00,\"remainingAmount\":0.00,\"repaymentDay\":19,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:26:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:26:54', 7);
INSERT INTO `sys_oper_log` VALUES (203, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:26:41\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":4400.00,\"remainingAmount\":0.00,\"repaymentDay\":19,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:26:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:26:57', 6);
INSERT INTO `sys_oper_log` VALUES (204, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:26:41\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":5500.00,\"remainingAmount\":0.00,\"repaymentDay\":19,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:26:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:26:59', 5);
INSERT INTO `sys_oper_log` VALUES (205, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:26:41\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100},\\\"26-12月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":6600.00,\"remainingAmount\":0.00,\"repaymentDay\":19,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:26:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:27:01', 7);
INSERT INTO `sys_oper_log` VALUES (206, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:26:41\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100},\\\"26-12月\\\":{\\\"amt\\\":1100},\\\"27-1月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":7700.00,\"remainingAmount\":0.00,\"repaymentDay\":19,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:26:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:27:05', 6);
INSERT INTO `sys_oper_log` VALUES (207, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:26:41\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100},\\\"26-12月\\\":{\\\"amt\\\":1100},\\\"27-1月\\\":{\\\"amt\\\":1100},\\\"27-2月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":8800.00,\"remainingAmount\":0.00,\"repaymentDay\":19,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:26:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:27:08', 7);
INSERT INTO `sys_oper_log` VALUES (208, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:26:41\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100},\\\"26-12月\\\":{\\\"amt\\\":1100},\\\"27-1月\\\":{\\\"amt\\\":1100},\\\"27-2月\\\":{\\\"amt\\\":1100},\\\"27-3月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":9900.00,\"remainingAmount\":0.00,\"repaymentDay\":19,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:26:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:27:10', 8);
INSERT INTO `sys_oper_log` VALUES (209, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:26:41\",\"creditorName\":\"易花花\",\"financeId\":7,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1100},\\\"26-8月\\\":{\\\"amt\\\":1100},\\\"26-9月\\\":{\\\"amt\\\":1100},\\\"26-10月\\\":{\\\"amt\\\":1100},\\\"26-11月\\\":{\\\"amt\\\":1100},\\\"26-12月\\\":{\\\"amt\\\":1100},\\\"27-1月\\\":{\\\"amt\\\":1100},\\\"27-2月\\\":{\\\"amt\\\":1100},\\\"27-3月\\\":{\\\"amt\\\":1100},\\\"27-4月\\\":{\\\"amt\\\":1100}}\",\"monthlyPayment\":1100,\"paidAmount\":11000.00,\"remainingAmount\":0.00,\"repaymentDay\":19,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:26:41\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:27:13', 8);
INSERT INTO `sys_oper_log` VALUES (210, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthlyPayment\":450,\"repaymentDay\":5,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:28:34', 11);
INSERT INTO `sys_oper_log` VALUES (211, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":450.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:28:40', 7);
INSERT INTO `sys_oper_log` VALUES (212, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":450.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:28:48', 3);
INSERT INTO `sys_oper_log` VALUES (213, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":900.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:28:51', 6);
INSERT INTO `sys_oper_log` VALUES (214, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":1350.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:28:53', 7);
INSERT INTO `sys_oper_log` VALUES (215, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":1800.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:28:55', 6);
INSERT INTO `sys_oper_log` VALUES (216, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":2250.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:29:01', 7);
INSERT INTO `sys_oper_log` VALUES (217, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450},\\\"26-12月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":2700.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:29:03', 9);
INSERT INTO `sys_oper_log` VALUES (218, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450},\\\"26-12月\\\":{\\\"amt\\\":450},\\\"27-1月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":3150.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:29:05', 10);
INSERT INTO `sys_oper_log` VALUES (219, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450},\\\"26-12月\\\":{\\\"amt\\\":450},\\\"27-1月\\\":{\\\"amt\\\":450},\\\"27-2月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":3600.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:29:07', 8);
INSERT INTO `sys_oper_log` VALUES (220, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450},\\\"26-12月\\\":{\\\"amt\\\":450},\\\"27-1月\\\":{\\\"amt\\\":450},\\\"27-2月\\\":{\\\"amt\\\":450},\\\"27-3月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":4050.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:29:10', 7);
INSERT INTO `sys_oper_log` VALUES (221, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthlyPayment\":450,\"repaymentDay\":14,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:29:47', 6);
INSERT INTO `sys_oper_log` VALUES (222, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:29:47\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":450.00,\"remainingAmount\":0.00,\"repaymentDay\":14,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:29:47\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:29:56', 11);
INSERT INTO `sys_oper_log` VALUES (223, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:29:47\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":900.00,\"remainingAmount\":0.00,\"repaymentDay\":14,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:29:47\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:29:59', 6);
INSERT INTO `sys_oper_log` VALUES (224, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:29:47\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":1350.00,\"remainingAmount\":0.00,\"repaymentDay\":14,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:29:47\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:30:01', 7);
INSERT INTO `sys_oper_log` VALUES (225, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:29:47\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":1800.00,\"remainingAmount\":0.00,\"repaymentDay\":14,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:29:47\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:30:04', 8);
INSERT INTO `sys_oper_log` VALUES (226, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:29:47\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":2250.00,\"remainingAmount\":0.00,\"repaymentDay\":14,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:29:47\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:30:09', 6);
INSERT INTO `sys_oper_log` VALUES (227, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:29:47\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450},\\\"26-12月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":2700.00,\"remainingAmount\":0.00,\"repaymentDay\":14,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:29:47\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:30:12', 7);
INSERT INTO `sys_oper_log` VALUES (228, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:29:47\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450},\\\"26-12月\\\":{\\\"amt\\\":450},\\\"27-1月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":3150.00,\"remainingAmount\":0.00,\"repaymentDay\":14,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:29:47\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:30:14', 6);
INSERT INTO `sys_oper_log` VALUES (229, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:29:47\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450},\\\"26-12月\\\":{\\\"amt\\\":450},\\\"27-1月\\\":{\\\"amt\\\":450},\\\"27-2月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":3600.00,\"remainingAmount\":0.00,\"repaymentDay\":14,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:29:47\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:30:16', 6);
INSERT INTO `sys_oper_log` VALUES (230, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:29:47\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450},\\\"26-12月\\\":{\\\"amt\\\":450},\\\"27-1月\\\":{\\\"amt\\\":450},\\\"27-2月\\\":{\\\"amt\\\":450},\\\"27-3月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":4050.00,\"remainingAmount\":0.00,\"repaymentDay\":14,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:29:47\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:30:32', 4);
INSERT INTO `sys_oper_log` VALUES (231, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:29:47\",\"creditorName\":\"宜享花\",\"financeId\":9,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":450},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450},\\\"26-12月\\\":{\\\"amt\\\":450},\\\"27-1月\\\":{\\\"amt\\\":450},\\\"27-2月\\\":{\\\"amt\\\":450},\\\"27-3月\\\":{\\\"amt\\\":450},\\\"27-4月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":4500.00,\"remainingAmount\":0.00,\"repaymentDay\":14,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:29:47\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:30:36', 9);
INSERT INTO `sys_oper_log` VALUES (232, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"宜享花\",\"financeId\":10,\"monthlyPayment\":1000,\"repaymentDay\":23,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:31:03', 6);
INSERT INTO `sys_oper_log` VALUES (233, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:31:03\",\"creditorName\":\"宜享花\",\"financeId\":10,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000}}\",\"monthlyPayment\":1000,\"paidAmount\":1000.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:31:03\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:31:08', 6);
INSERT INTO `sys_oper_log` VALUES (234, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:31:03\",\"creditorName\":\"宜享花\",\"financeId\":10,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000}}\",\"monthlyPayment\":1000,\"paidAmount\":2000.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:31:03\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:31:11', 7);
INSERT INTO `sys_oper_log` VALUES (235, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:31:03\",\"creditorName\":\"宜享花\",\"financeId\":10,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000}}\",\"monthlyPayment\":1000,\"paidAmount\":3000.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:31:03\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:31:15', 5);
INSERT INTO `sys_oper_log` VALUES (236, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:31:03\",\"creditorName\":\"宜享花\",\"financeId\":10,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000},\\\"26-10月\\\":{\\\"amt\\\":1000}}\",\"monthlyPayment\":1000,\"paidAmount\":4000.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:31:03\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:31:22', 6);
INSERT INTO `sys_oper_log` VALUES (237, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:31:03\",\"creditorName\":\"宜享花\",\"financeId\":10,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000},\\\"26-10月\\\":{\\\"amt\\\":1000},\\\"26-11月\\\":{\\\"amt\\\":1000}}\",\"monthlyPayment\":1000,\"paidAmount\":5000.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:31:03\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:31:24', 6);
INSERT INTO `sys_oper_log` VALUES (238, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:31:03\",\"creditorName\":\"宜享花\",\"financeId\":10,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000},\\\"26-10月\\\":{\\\"amt\\\":1000},\\\"26-11月\\\":{\\\"amt\\\":1000},\\\"26-12月\\\":{\\\"amt\\\":1000}}\",\"monthlyPayment\":1000,\"paidAmount\":6000.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:31:03\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:31:27', 7);
INSERT INTO `sys_oper_log` VALUES (239, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:31:03\",\"creditorName\":\"宜享花\",\"financeId\":10,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000},\\\"26-10月\\\":{\\\"amt\\\":1000},\\\"26-11月\\\":{\\\"amt\\\":1000},\\\"26-12月\\\":{\\\"amt\\\":1000},\\\"27-1月\\\":{\\\"amt\\\":1000}}\",\"monthlyPayment\":1000,\"paidAmount\":7000.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:31:03\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:31:30', 5);
INSERT INTO `sys_oper_log` VALUES (240, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:31:03\",\"creditorName\":\"宜享花\",\"financeId\":10,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000},\\\"26-10月\\\":{\\\"amt\\\":1000},\\\"26-11月\\\":{\\\"amt\\\":1000},\\\"26-12月\\\":{\\\"amt\\\":1000},\\\"27-1月\\\":{\\\"amt\\\":1000},\\\"27-2月\\\":{\\\"amt\\\":1000}}\",\"monthlyPayment\":1000,\"paidAmount\":8000.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:31:03\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:31:32', 6);
INSERT INTO `sys_oper_log` VALUES (241, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"小花钱包\",\"financeId\":11,\"repaymentDay\":28,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:36:34', 9);
INSERT INTO `sys_oper_log` VALUES (242, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:36:34\",\"creditorName\":\"小花钱包\",\"financeId\":11,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000}}\",\"paidAmount\":1000.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:36:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:36:41', 8);
INSERT INTO `sys_oper_log` VALUES (243, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:36:34\",\"creditorName\":\"小花钱包\",\"financeId\":11,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000}}\",\"paidAmount\":2000.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:36:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:36:44', 7);
INSERT INTO `sys_oper_log` VALUES (244, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:36:34\",\"creditorName\":\"小花钱包\",\"financeId\":11,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000}}\",\"paidAmount\":3000.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:36:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:36:46', 8);
INSERT INTO `sys_oper_log` VALUES (245, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:36:34\",\"creditorName\":\"小花钱包\",\"financeId\":11,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000},\\\"26-10月\\\":{\\\"amt\\\":1000}}\",\"paidAmount\":4000.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:36:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:36:49', 6);
INSERT INTO `sys_oper_log` VALUES (246, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:36:34\",\"creditorName\":\"小花钱包\",\"financeId\":11,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000},\\\"26-10月\\\":{\\\"amt\\\":1000},\\\"26-11月\\\":{\\\"amt\\\":1000}}\",\"paidAmount\":5000.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:36:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:36:51', 6);
INSERT INTO `sys_oper_log` VALUES (247, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:36:34\",\"creditorName\":\"小花钱包\",\"financeId\":11,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000},\\\"26-10月\\\":{\\\"amt\\\":1000},\\\"26-11月\\\":{\\\"amt\\\":1000},\\\"26-12月\\\":{\\\"amt\\\":1000}}\",\"paidAmount\":6000.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:36:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:36:54', 6);
INSERT INTO `sys_oper_log` VALUES (248, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:36:34\",\"creditorName\":\"小花钱包\",\"financeId\":11,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1000},\\\"26-8月\\\":{\\\"amt\\\":1000},\\\"26-9月\\\":{\\\"amt\\\":1000},\\\"26-10月\\\":{\\\"amt\\\":1000},\\\"26-11月\\\":{\\\"amt\\\":1000},\\\"26-12月\\\":{\\\"amt\\\":1000},\\\"27-1月\\\":{\\\"amt\\\":1000}}\",\"paidAmount\":7000.00,\"remainingAmount\":0.00,\"repaymentDay\":28,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:36:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:36:56', 6);
INSERT INTO `sys_oper_log` VALUES (249, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthlyPayment\":4000,\"repaymentDay\":24,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:38:50', 5);
INSERT INTO `sys_oper_log` VALUES (250, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":4000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:38:59', 5);
INSERT INTO `sys_oper_log` VALUES (251, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":8000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:39:02', 6);
INSERT INTO `sys_oper_log` VALUES (252, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000},\\\"26-10月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":12000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:39:04', 7);
INSERT INTO `sys_oper_log` VALUES (253, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000},\\\"26-10月\\\":{\\\"amt\\\":4000},\\\"26-11月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":16000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:39:07', 5);
INSERT INTO `sys_oper_log` VALUES (254, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000},\\\"26-10月\\\":{\\\"amt\\\":4000},\\\"26-11月\\\":{\\\"amt\\\":4000},\\\"26-12月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":20000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:39:09', 5);
INSERT INTO `sys_oper_log` VALUES (255, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000},\\\"26-10月\\\":{\\\"amt\\\":4000},\\\"26-11月\\\":{\\\"amt\\\":4000},\\\"26-12月\\\":{\\\"amt\\\":4000},\\\"27-1月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":24000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:39:12', 6);
INSERT INTO `sys_oper_log` VALUES (256, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000},\\\"26-10月\\\":{\\\"amt\\\":4000},\\\"26-11月\\\":{\\\"amt\\\":4000},\\\"26-12月\\\":{\\\"amt\\\":4000},\\\"27-1月\\\":{\\\"amt\\\":4000},\\\"27-2月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":28000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:39:14', 7);
INSERT INTO `sys_oper_log` VALUES (257, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000},\\\"26-10月\\\":{\\\"amt\\\":4000},\\\"26-11月\\\":{\\\"amt\\\":4000},\\\"26-12月\\\":{\\\"amt\\\":4000},\\\"27-1月\\\":{\\\"amt\\\":4000},\\\"27-2月\\\":{\\\"amt\\\":4000},\\\"27-3月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":32000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:41:25', 12);
INSERT INTO `sys_oper_log` VALUES (258, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000},\\\"26-10月\\\":{\\\"amt\\\":4000},\\\"26-11月\\\":{\\\"amt\\\":4000},\\\"26-12月\\\":{\\\"amt\\\":4000},\\\"27-1月\\\":{\\\"amt\\\":4000},\\\"27-2月\\\":{\\\"amt\\\":4000},\\\"27-3月\\\":{\\\"amt\\\":4000},\\\"27-4月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":36000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:41:33', 7);
INSERT INTO `sys_oper_log` VALUES (259, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000},\\\"26-10月\\\":{\\\"amt\\\":4000},\\\"26-11月\\\":{\\\"amt\\\":4000},\\\"26-12月\\\":{\\\"amt\\\":4000},\\\"27-1月\\\":{\\\"amt\\\":4000},\\\"27-2月\\\":{\\\"amt\\\":4000},\\\"27-3月\\\":{\\\"amt\\\":4000},\\\"27-4月\\\":{\\\"amt\\\":4000},\\\"27-5月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":40000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:41:40', 8);
INSERT INTO `sys_oper_log` VALUES (260, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000},\\\"26-10月\\\":{\\\"amt\\\":4000},\\\"26-11月\\\":{\\\"amt\\\":4000},\\\"26-12月\\\":{\\\"amt\\\":4000},\\\"27-1月\\\":{\\\"amt\\\":4000},\\\"27-2月\\\":{\\\"amt\\\":4000},\\\"27-3月\\\":{\\\"amt\\\":4000},\\\"27-4月\\\":{\\\"amt\\\":4000},\\\"27-5月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":40000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:41:42', 4);
INSERT INTO `sys_oper_log` VALUES (261, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:38:50\",\"creditorName\":\"有钱花\",\"financeId\":12,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":4000},\\\"26-9月\\\":{\\\"amt\\\":4000},\\\"26-10月\\\":{\\\"amt\\\":4000},\\\"26-11月\\\":{\\\"amt\\\":4000},\\\"26-12月\\\":{\\\"amt\\\":4000},\\\"27-1月\\\":{\\\"amt\\\":4000},\\\"27-2月\\\":{\\\"amt\\\":4000},\\\"27-3月\\\":{\\\"amt\\\":4000},\\\"27-4月\\\":{\\\"amt\\\":4000},\\\"27-5月\\\":{\\\"amt\\\":4000},\\\"27-6月\\\":{\\\"amt\\\":4000}}\",\"monthlyPayment\":4000,\"paidAmount\":44000.00,\"remainingAmount\":0.00,\"repaymentDay\":24,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:38:50\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:41:47', 6);
INSERT INTO `sys_oper_log` VALUES (262, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthlyPayment\":400,\"repaymentDay\":20,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:56:39', 13);
INSERT INTO `sys_oper_log` VALUES (263, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthlyPayment\":300,\"repaymentDay\":23,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:56:51', 6);
INSERT INTO `sys_oper_log` VALUES (264, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":400.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:57:18', 6);
INSERT INTO `sys_oper_log` VALUES (265, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":800.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:57:21', 11);
INSERT INTO `sys_oper_log` VALUES (266, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400},\\\"26-9月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":1200.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:57:23', 8);
INSERT INTO `sys_oper_log` VALUES (267, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400},\\\"26-9月\\\":{\\\"amt\\\":400},\\\"26-10月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":1600.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:57:25', 7);
INSERT INTO `sys_oper_log` VALUES (268, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400},\\\"26-9月\\\":{\\\"amt\\\":400},\\\"26-10月\\\":{\\\"amt\\\":400},\\\"26-11月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":2000.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:59:42', 8);
INSERT INTO `sys_oper_log` VALUES (269, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400},\\\"26-9月\\\":{\\\"amt\\\":400},\\\"26-10月\\\":{\\\"amt\\\":400},\\\"26-11月\\\":{\\\"amt\\\":400},\\\"26-12月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":2400.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:59:45', 6);
INSERT INTO `sys_oper_log` VALUES (270, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400},\\\"26-9月\\\":{\\\"amt\\\":400},\\\"26-10月\\\":{\\\"amt\\\":400},\\\"26-11月\\\":{\\\"amt\\\":400},\\\"26-12月\\\":{\\\"amt\\\":400},\\\"27-1月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":2800.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:59:48', 6);
INSERT INTO `sys_oper_log` VALUES (271, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400},\\\"26-9月\\\":{\\\"amt\\\":400},\\\"26-10月\\\":{\\\"amt\\\":400},\\\"26-11月\\\":{\\\"amt\\\":400},\\\"26-12月\\\":{\\\"amt\\\":400},\\\"27-1月\\\":{\\\"amt\\\":400},\\\"27-2月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":3200.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:59:50', 11);
INSERT INTO `sys_oper_log` VALUES (272, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400},\\\"26-9月\\\":{\\\"amt\\\":400},\\\"26-10月\\\":{\\\"amt\\\":400},\\\"26-11月\\\":{\\\"amt\\\":400},\\\"26-12月\\\":{\\\"amt\\\":400},\\\"27-1月\\\":{\\\"amt\\\":400},\\\"27-2月\\\":{\\\"amt\\\":400},\\\"27-3月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":3600.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 17:59:54', 4);
INSERT INTO `sys_oper_log` VALUES (273, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400},\\\"26-9月\\\":{\\\"amt\\\":400},\\\"26-10月\\\":{\\\"amt\\\":400},\\\"26-11月\\\":{\\\"amt\\\":400},\\\"26-12月\\\":{\\\"amt\\\":400},\\\"27-1月\\\":{\\\"amt\\\":400},\\\"27-2月\\\":{\\\"amt\\\":400},\\\"27-3月\\\":{\\\"amt\\\":400},\\\"27-4月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":4000.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:00', 7);
INSERT INTO `sys_oper_log` VALUES (274, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400},\\\"26-9月\\\":{\\\"amt\\\":400},\\\"26-10月\\\":{\\\"amt\\\":400},\\\"26-11月\\\":{\\\"amt\\\":400},\\\"26-12月\\\":{\\\"amt\\\":400},\\\"27-1月\\\":{\\\"amt\\\":400},\\\"27-2月\\\":{\\\"amt\\\":400},\\\"27-3月\\\":{\\\"amt\\\":400},\\\"27-4月\\\":{\\\"amt\\\":400},\\\"27-5月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":4400.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:03', 12);
INSERT INTO `sys_oper_log` VALUES (275, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:39\",\"creditorName\":\"好分期\",\"financeId\":13,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":400},\\\"26-8月\\\":{\\\"amt\\\":400},\\\"26-9月\\\":{\\\"amt\\\":400},\\\"26-10月\\\":{\\\"amt\\\":400},\\\"26-11月\\\":{\\\"amt\\\":400},\\\"26-12月\\\":{\\\"amt\\\":400},\\\"27-1月\\\":{\\\"amt\\\":400},\\\"27-2月\\\":{\\\"amt\\\":400},\\\"27-3月\\\":{\\\"amt\\\":400},\\\"27-4月\\\":{\\\"amt\\\":400},\\\"27-5月\\\":{\\\"amt\\\":400},\\\"27-6月\\\":{\\\"amt\\\":400}}\",\"monthlyPayment\":400,\"paidAmount\":4800.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:39\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:05', 13);
INSERT INTO `sys_oper_log` VALUES (276, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":300.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:15', 5);
INSERT INTO `sys_oper_log` VALUES (277, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":600.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:17', 7);
INSERT INTO `sys_oper_log` VALUES (278, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":900.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:21', 5);
INSERT INTO `sys_oper_log` VALUES (279, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":1200.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:23', 6);
INSERT INTO `sys_oper_log` VALUES (280, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":1500.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:26', 6);
INSERT INTO `sys_oper_log` VALUES (281, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":1800.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:29', 7);
INSERT INTO `sys_oper_log` VALUES (282, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":2100.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:32', 5);
INSERT INTO `sys_oper_log` VALUES (283, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":2400.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:35', 7);
INSERT INTO `sys_oper_log` VALUES (284, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":2700.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:41', 5);
INSERT INTO `sys_oper_log` VALUES (285, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":3000.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:43', 10);
INSERT INTO `sys_oper_log` VALUES (286, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300},\\\"26-8月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":3300.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:46', 6);
INSERT INTO `sys_oper_log` VALUES (287, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:56:51\",\"creditorName\":\"好分期\",\"financeId\":14,\"monthData\":\"{\\\"27-6月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300},\\\"26-8月\\\":{\\\"amt\\\":300},\\\"26-7月\\\":{\\\"amt\\\":300}}\",\"monthlyPayment\":300,\"paidAmount\":3600.00,\"remainingAmount\":0.00,\"repaymentDay\":23,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:56:51\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:00:48', 4);
INSERT INTO `sys_oper_log` VALUES (288, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthlyPayment\":1500,\"repaymentDay\":20,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:02:37', 7);
INSERT INTO `sys_oper_log` VALUES (289, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":1500.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:02:41', 6);
INSERT INTO `sys_oper_log` VALUES (290, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":3000.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:02:49', 6);
INSERT INTO `sys_oper_log` VALUES (291, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":4500.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:02:52', 6);
INSERT INTO `sys_oper_log` VALUES (292, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500},\\\"26-10月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":6000.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:02:54', 6);
INSERT INTO `sys_oper_log` VALUES (293, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500},\\\"26-10月\\\":{\\\"amt\\\":1500},\\\"26-11月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":7500.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:02:56', 6);
INSERT INTO `sys_oper_log` VALUES (294, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500},\\\"26-10月\\\":{\\\"amt\\\":1500},\\\"26-11月\\\":{\\\"amt\\\":1500},\\\"26-12月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":9000.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:03:00', 6);
INSERT INTO `sys_oper_log` VALUES (295, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500},\\\"26-10月\\\":{\\\"amt\\\":1500},\\\"26-11月\\\":{\\\"amt\\\":1500},\\\"26-12月\\\":{\\\"amt\\\":1500},\\\"27-1月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":10500.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:03:03', 5);
INSERT INTO `sys_oper_log` VALUES (296, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500},\\\"26-10月\\\":{\\\"amt\\\":1500},\\\"26-11月\\\":{\\\"amt\\\":1500},\\\"26-12月\\\":{\\\"amt\\\":1500},\\\"27-1月\\\":{\\\"amt\\\":1500},\\\"27-2月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":12000.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:03:10', 5);
INSERT INTO `sys_oper_log` VALUES (297, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500},\\\"26-10月\\\":{\\\"amt\\\":1500},\\\"26-11月\\\":{\\\"amt\\\":1500},\\\"26-12月\\\":{\\\"amt\\\":1500},\\\"27-1月\\\":{\\\"amt\\\":1500},\\\"27-2月\\\":{\\\"amt\\\":1500},\\\"27-3月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":13500.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:03:12', 5);
INSERT INTO `sys_oper_log` VALUES (298, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500},\\\"26-10月\\\":{\\\"amt\\\":1500},\\\"26-11月\\\":{\\\"amt\\\":1500},\\\"26-12月\\\":{\\\"amt\\\":1500},\\\"27-1月\\\":{\\\"amt\\\":1500},\\\"27-2月\\\":{\\\"amt\\\":1500},\\\"27-3月\\\":{\\\"amt\\\":1500},\\\"27-4月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":15000.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:03:14', 6);
INSERT INTO `sys_oper_log` VALUES (299, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500},\\\"26-10月\\\":{\\\"amt\\\":1500},\\\"26-11月\\\":{\\\"amt\\\":1500},\\\"26-12月\\\":{\\\"amt\\\":1500},\\\"27-1月\\\":{\\\"amt\\\":1500},\\\"27-2月\\\":{\\\"amt\\\":1500},\\\"27-3月\\\":{\\\"amt\\\":1500},\\\"27-4月\\\":{\\\"amt\\\":1500},\\\"27-5月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":16500.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:03:16', 6);
INSERT INTO `sys_oper_log` VALUES (300, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500},\\\"26-10月\\\":{\\\"amt\\\":1500},\\\"26-11月\\\":{\\\"amt\\\":1500},\\\"26-12月\\\":{\\\"amt\\\":1500},\\\"27-1月\\\":{\\\"amt\\\":1500},\\\"27-2月\\\":{\\\"amt\\\":1500},\\\"27-3月\\\":{\\\"amt\\\":1500},\\\"27-4月\\\":{\\\"amt\\\":1500},\\\"27-5月\\\":{\\\"amt\\\":1500},\\\"27-6月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":18000.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:03:20', 7);
INSERT INTO `sys_oper_log` VALUES (301, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 18:02:37\",\"creditorName\":\"京东白条\",\"financeId\":15,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":1500},\\\"26-8月\\\":{\\\"amt\\\":1500},\\\"26-9月\\\":{\\\"amt\\\":1500},\\\"26-10月\\\":{\\\"amt\\\":1500},\\\"26-11月\\\":{\\\"amt\\\":1500},\\\"26-12月\\\":{\\\"amt\\\":1500},\\\"27-1月\\\":{\\\"amt\\\":1500},\\\"27-2月\\\":{\\\"amt\\\":1500},\\\"27-3月\\\":{\\\"amt\\\":1500},\\\"27-4月\\\":{\\\"amt\\\":1500},\\\"27-5月\\\":{\\\"amt\\\":1500},\\\"27-6月\\\":{\\\"amt\\\":1500},\\\"27-7月\\\":{\\\"amt\\\":1500}}\",\"monthlyPayment\":1500,\"paidAmount\":19500.00,\"remainingAmount\":0.00,\"repaymentDay\":20,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 18:02:37\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-01 18:03:22', 8);
INSERT INTO `sys_oper_log` VALUES (302, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"金条\",\"financeId\":16,\"monthlyPayment\":1200,\"repaymentDay\":2,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:57:55', 8);
INSERT INTO `sys_oper_log` VALUES (303, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":1200.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:03', 7);
INSERT INTO `sys_oper_log` VALUES (304, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":2400.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:08', 6);
INSERT INTO `sys_oper_log` VALUES (305, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200},\\\"26-10月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":3600.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:11', 5);
INSERT INTO `sys_oper_log` VALUES (306, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200},\\\"26-10月\\\":{\\\"amt\\\":1200},\\\"26-11月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":4800.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:18', 7);
INSERT INTO `sys_oper_log` VALUES (307, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200},\\\"26-10月\\\":{\\\"amt\\\":1200},\\\"26-11月\\\":{\\\"amt\\\":1200},\\\"26-12月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":6000.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:20', 8);
INSERT INTO `sys_oper_log` VALUES (308, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200},\\\"26-10月\\\":{\\\"amt\\\":1200},\\\"26-11月\\\":{\\\"amt\\\":1200},\\\"26-12月\\\":{\\\"amt\\\":1200},\\\"27-1月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":7200.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:22', 5);
INSERT INTO `sys_oper_log` VALUES (309, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200},\\\"26-10月\\\":{\\\"amt\\\":1200},\\\"26-11月\\\":{\\\"amt\\\":1200},\\\"26-12月\\\":{\\\"amt\\\":1200},\\\"27-1月\\\":{\\\"amt\\\":1200},\\\"27-2月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":8400.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:24', 5);
INSERT INTO `sys_oper_log` VALUES (310, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200},\\\"26-10月\\\":{\\\"amt\\\":1200},\\\"26-11月\\\":{\\\"amt\\\":1200},\\\"26-12月\\\":{\\\"amt\\\":1200},\\\"27-1月\\\":{\\\"amt\\\":1200},\\\"27-2月\\\":{\\\"amt\\\":1200},\\\"27-3月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":9600.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:27', 7);
INSERT INTO `sys_oper_log` VALUES (311, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200},\\\"26-10月\\\":{\\\"amt\\\":1200},\\\"26-11月\\\":{\\\"amt\\\":1200},\\\"26-12月\\\":{\\\"amt\\\":1200},\\\"27-1月\\\":{\\\"amt\\\":1200},\\\"27-2月\\\":{\\\"amt\\\":1200},\\\"27-3月\\\":{\\\"amt\\\":1200},\\\"27-4月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":10800.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:29', 7);
INSERT INTO `sys_oper_log` VALUES (312, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200},\\\"26-10月\\\":{\\\"amt\\\":1200},\\\"26-11月\\\":{\\\"amt\\\":1200},\\\"26-12月\\\":{\\\"amt\\\":1200},\\\"27-1月\\\":{\\\"amt\\\":1200},\\\"27-2月\\\":{\\\"amt\\\":1200},\\\"27-3月\\\":{\\\"amt\\\":1200},\\\"27-4月\\\":{\\\"amt\\\":1200},\\\"27-5月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":12000.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:32', 7);
INSERT INTO `sys_oper_log` VALUES (313, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200},\\\"26-10月\\\":{\\\"amt\\\":1200},\\\"26-11月\\\":{\\\"amt\\\":1200},\\\"26-12月\\\":{\\\"amt\\\":1200},\\\"27-1月\\\":{\\\"amt\\\":1200},\\\"27-2月\\\":{\\\"amt\\\":1200},\\\"27-3月\\\":{\\\"amt\\\":1200},\\\"27-4月\\\":{\\\"amt\\\":1200},\\\"27-5月\\\":{\\\"amt\\\":1200},\\\"27-6月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":13200.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:36', 6);
INSERT INTO `sys_oper_log` VALUES (314, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:57:55\",\"creditorName\":\"金条\",\"financeId\":16,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":1200},\\\"26-9月\\\":{\\\"amt\\\":1200},\\\"26-10月\\\":{\\\"amt\\\":1200},\\\"26-11月\\\":{\\\"amt\\\":1200},\\\"26-12月\\\":{\\\"amt\\\":1200},\\\"27-1月\\\":{\\\"amt\\\":1200},\\\"27-2月\\\":{\\\"amt\\\":1200},\\\"27-3月\\\":{\\\"amt\\\":1200},\\\"27-4月\\\":{\\\"amt\\\":1200},\\\"27-5月\\\":{\\\"amt\\\":1200},\\\"27-6月\\\":{\\\"amt\\\":1200},\\\"27-7月\\\":{\\\"amt\\\":1200}}\",\"monthlyPayment\":1200,\"paidAmount\":14400.00,\"remainingAmount\":0.00,\"repaymentDay\":2,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:57:55\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:58:40', 6);
INSERT INTO `sys_oper_log` VALUES (315, '财务管理', 1, 'com.ddss.web.controller.finance.FinanceController.add()', 'POST', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"repaymentDay\":16,\"status\":\"0\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:15', 5);
INSERT INTO `sys_oper_log` VALUES (316, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:59:15\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":300}}\",\"paidAmount\":300.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:59:15\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:22', 12);
INSERT INTO `sys_oper_log` VALUES (317, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:59:15\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300}}\",\"paidAmount\":600.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:59:15\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:25', 7);
INSERT INTO `sys_oper_log` VALUES (318, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:59:15\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300}}\",\"paidAmount\":900.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:59:15\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:27', 8);
INSERT INTO `sys_oper_log` VALUES (319, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:59:15\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300}}\",\"paidAmount\":1200.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:59:15\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:29', 4);
INSERT INTO `sys_oper_log` VALUES (320, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:59:15\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300}}\",\"paidAmount\":1500.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:59:15\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:31', 8);
INSERT INTO `sys_oper_log` VALUES (321, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:59:15\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300}}\",\"paidAmount\":1800.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:59:15\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:34', 5);
INSERT INTO `sys_oper_log` VALUES (322, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:59:15\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300}}\",\"paidAmount\":2100.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:59:15\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:36', 6);
INSERT INTO `sys_oper_log` VALUES (323, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:59:15\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300}}\",\"paidAmount\":2400.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:59:15\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:39', 7);
INSERT INTO `sys_oper_log` VALUES (324, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:59:15\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300}}\",\"paidAmount\":2700.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:59:15\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:41', 7);
INSERT INTO `sys_oper_log` VALUES (325, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-02 12:59:15\",\"creditorName\":\"金条\",\"financeId\":17,\"loanTerm\":12,\"monthData\":\"{\\\"26-8月\\\":{\\\"amt\\\":300},\\\"26-9月\\\":{\\\"amt\\\":300},\\\"26-10月\\\":{\\\"amt\\\":300},\\\"26-11月\\\":{\\\"amt\\\":300},\\\"26-12月\\\":{\\\"amt\\\":300},\\\"27-1月\\\":{\\\"amt\\\":300},\\\"27-2月\\\":{\\\"amt\\\":300},\\\"27-3月\\\":{\\\"amt\\\":300},\\\"27-4月\\\":{\\\"amt\\\":300},\\\"27-5月\\\":{\\\"amt\\\":300}}\",\"paidAmount\":3000.00,\"remainingAmount\":0.00,\"repaymentDay\":16,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-02 12:59:15\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-02 12:59:44', 6);
INSERT INTO `sys_oper_log` VALUES (326, '财务管理', 5, 'com.ddss.web.controller.finance.FinanceController.export()', 'GET', 1, 'admin', '研发部门', '/finance/export', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-07-02 16:32:19', 5200);
INSERT INTO `sys_oper_log` VALUES (327, '财务管理', 5, 'com.ddss.web.controller.finance.FinanceController.export()', 'GET', 1, 'admin', '研发部门', '/finance/export', '127.0.0.1', '内网IP', '{}', NULL, 0, NULL, '2026-07-02 16:32:19', 73);
INSERT INTO `sys_oper_log` VALUES (328, '财务管理', 2, 'com.ddss.web.controller.finance.FinanceController.edit()', 'PUT', 1, 'admin', '研发部门', '/finance', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"createTime\":\"2026-07-01 17:28:34\",\"creditorName\":\"宜享花\",\"financeId\":8,\"monthData\":\"{\\\"26-7月\\\":{\\\"amt\\\":0},\\\"26-8月\\\":{\\\"amt\\\":450},\\\"26-9月\\\":{\\\"amt\\\":450},\\\"26-10月\\\":{\\\"amt\\\":450},\\\"26-11月\\\":{\\\"amt\\\":450},\\\"26-12月\\\":{\\\"amt\\\":450},\\\"27-1月\\\":{\\\"amt\\\":450},\\\"27-2月\\\":{\\\"amt\\\":450},\\\"27-3月\\\":{\\\"amt\\\":450}}\",\"monthlyPayment\":450,\"paidAmount\":3600.00,\"remainingAmount\":0.00,\"repaymentDay\":5,\"status\":\"0\",\"updateBy\":\"admin\",\"updateTime\":\"2026-07-01 17:28:34\"} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-08 18:30:14', 85);
INSERT INTO `sys_oper_log` VALUES (329, 'SQL管理', 1, 'com.ddss.web.controller.system.SysSqlRecordController.add()', 'POST', 1, 'admin', '研发部门', '/system/sqlRecord', '127.0.0.1', '内网IP', '{\"createBy\":\"admin\",\"purpose\":\"测试SQL\",\"sqlContent\":\"select * from A;\",\"sqlId\":1} ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-09 17:10:52', 22);
INSERT INTO `sys_oper_log` VALUES (330, 'SQL管理', 3, 'com.ddss.web.controller.system.SysSqlRecordController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/sqlRecord/1', '127.0.0.1', '内网IP', '[1] ', '{\"msg\":\"操作成功\",\"code\":200}', 0, NULL, '2026-07-09 17:11:05', 16);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '岗位信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'ceo', '董事长', 1, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_post` VALUES (2, 'se', '项目经理', 2, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_post` VALUES (3, 'hr', '人力资源', 3, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO `sys_post` VALUES (4, 'user', '普通员工', 4, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL, '普通角色');

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和部门关联表' ROW_FORMAT = Dynamic;

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
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (1, 5);
INSERT INTO `sys_role_menu` VALUES (1, 200);
INSERT INTO `sys_role_menu` VALUES (1, 201);
INSERT INTO `sys_role_menu` VALUES (1, 202);
INSERT INTO `sys_role_menu` VALUES (1, 203);
INSERT INTO `sys_role_menu` VALUES (1, 204);
INSERT INTO `sys_role_menu` VALUES (1, 205);
INSERT INTO `sys_role_menu` VALUES (1, 206);
INSERT INTO `sys_role_menu` VALUES (1, 207);
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
INSERT INTO `sys_role_menu` VALUES (1, 3006);
INSERT INTO `sys_role_menu` VALUES (1, 3007);
INSERT INTO `sys_role_menu` VALUES (1, 3008);
INSERT INTO `sys_role_menu` VALUES (1, 3009);
INSERT INTO `sys_role_menu` VALUES (1, 3010);
INSERT INTO `sys_role_menu` VALUES (1, 3011);
INSERT INTO `sys_role_menu` VALUES (1, 3012);
INSERT INTO `sys_role_menu` VALUES (1, 3013);
INSERT INTO `sys_role_menu` VALUES (1, 3014);
INSERT INTO `sys_role_menu` VALUES (1, 3015);
INSERT INTO `sys_role_menu` VALUES (1, 3016);
INSERT INTO `sys_role_menu` VALUES (1, 3017);
INSERT INTO `sys_role_menu` VALUES (1, 3018);
INSERT INTO `sys_role_menu` VALUES (1, 3019);
INSERT INTO `sys_role_menu` VALUES (1, 3020);
INSERT INTO `sys_role_menu` VALUES (1, 3021);
INSERT INTO `sys_role_menu` VALUES (1, 3022);
INSERT INTO `sys_role_menu` VALUES (1, 3023);
INSERT INTO `sys_role_menu` VALUES (1, 3024);
INSERT INTO `sys_role_menu` VALUES (1, 3025);
INSERT INTO `sys_role_menu` VALUES (1, 3026);
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
INSERT INTO `sys_role_menu` VALUES (2, 118);
INSERT INTO `sys_role_menu` VALUES (2, 200);
INSERT INTO `sys_role_menu` VALUES (2, 201);
INSERT INTO `sys_role_menu` VALUES (2, 202);
INSERT INTO `sys_role_menu` VALUES (2, 203);
INSERT INTO `sys_role_menu` VALUES (2, 204);
INSERT INTO `sys_role_menu` VALUES (2, 205);
INSERT INTO `sys_role_menu` VALUES (2, 206);
INSERT INTO `sys_role_menu` VALUES (2, 207);
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
INSERT INTO `sys_role_menu` VALUES (2, 3006);
INSERT INTO `sys_role_menu` VALUES (2, 3007);
INSERT INTO `sys_role_menu` VALUES (2, 3008);
INSERT INTO `sys_role_menu` VALUES (2, 3012);
INSERT INTO `sys_role_menu` VALUES (2, 3013);
INSERT INTO `sys_role_menu` VALUES (2, 3014);
INSERT INTO `sys_role_menu` VALUES (2, 3015);
INSERT INTO `sys_role_menu` VALUES (2, 3021);

-- ----------------------------
-- Table structure for sys_sql_record
-- ----------------------------
DROP TABLE IF EXISTS `sys_sql_record`;
CREATE TABLE `sys_sql_record`  (
  `sql_id` bigint NOT NULL AUTO_INCREMENT COMMENT 'SQL记录ID',
  `purpose` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '作用/用途说明',
  `sql_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'SQL内容',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`sql_id`) USING BTREE,
  INDEX `idx_purpose`(`purpose` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'SQL记录管理表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_sql_record
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户）',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime NULL DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 103, 'admin', 'DDSS管理员', '00', 'vip.p@live.com', '13888888888', '0', '/profile/avatar/2026/06/26/75e3b1cc4eb1460eb2d320c55a1662ea.png', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-07-23 08:31:29', '2026-06-14 21:43:54', 'admin', '2026-06-14 21:43:54', '', '2026-06-26 13:00:36', '管理员');
INSERT INTO `sys_user` VALUES (2, 105, 'ry', '若依', '00', 'ry@qq.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2026-06-14 21:43:54', '2026-06-14 21:43:54', 'admin', '2026-06-14 21:43:54', '', NULL, '测试员');

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = Dynamic;

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
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

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
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '视频资源ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '视频名称',
  `file_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件名',
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文件路径',
  `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小(字节)',
  `mime_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文件类型',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `duration` int NULL DEFAULT NULL COMMENT '时长(秒)',
  `resolution` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分辨率',
  `thumbnail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图路径',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '视频资源表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_video_resource
-- ----------------------------
INSERT INTO `sys_video_resource` VALUES (1, '示例视频1', 'sample1.mp4', '/videos/sample1.mp4', 1024000, 'video/mp4', '这是一个示例视频', 60, '1920x1080', '/thumbnails/sample1.jpg', '0', 'admin', '2026-06-22 17:45:52', '', '2026-06-22 17:45:52', '系统初始数据');
INSERT INTO `sys_video_resource` VALUES (2, '示例视频2', 'sample2.mp4', '/videos/sample2.mp4', 2048000, 'video/mp4', '另一个示例视频', 120, '1280x720', '/thumbnails/sample2.jpg', '0', 'admin', '2026-06-22 17:45:52', '', '2026-06-22 17:45:52', '系统初始数据');

SET FOREIGN_KEY_CHECKS = 1;

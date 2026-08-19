-- DDSS H2 内存库建表脚本（Dev 模式：ddss.middleware.mysql.enabled=false 时由 H2DataInitializer 执行）
-- 兼容 H2 MODE=MySQL；已去除 MySQL 专有语法（CHARACTER SET/COLLATE/ENGINE/ROW_FORMAT/COMMENT/ON UPDATE/USING BTREE）
-- 注意：本脚本每条语句以分号结尾，行首 -- 为注释，勿使用块注释

-- ----------------------------
-- 系统配置表
-- ----------------------------
DROP TABLE IF EXISTS sys_config;
CREATE TABLE sys_config (
  config_id INT NOT NULL AUTO_INCREMENT,
  config_name VARCHAR(100) DEFAULT '',
  config_key VARCHAR(100) DEFAULT '',
  config_value VARCHAR(500) DEFAULT '',
  config_type CHAR(1) DEFAULT 'N',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (config_id)
);

-- ----------------------------
-- 部门表
-- ----------------------------
DROP TABLE IF EXISTS sys_dept;
CREATE TABLE sys_dept (
  dept_id BIGINT NOT NULL AUTO_INCREMENT,
  parent_id BIGINT DEFAULT 0,
  ancestors VARCHAR(50) DEFAULT '',
  dept_name VARCHAR(30) DEFAULT '',
  order_num INT DEFAULT 0,
  leader VARCHAR(20) DEFAULT NULL,
  phone VARCHAR(11) DEFAULT NULL,
  email VARCHAR(50) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  del_flag CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (dept_id)
);

-- ----------------------------
-- 字典数据表
-- ----------------------------
DROP TABLE IF EXISTS sys_dict_data;
CREATE TABLE sys_dict_data (
  dict_code BIGINT NOT NULL AUTO_INCREMENT,
  dict_sort INT DEFAULT 0,
  dict_label VARCHAR(100) DEFAULT '',
  dict_value VARCHAR(100) DEFAULT '',
  dict_type VARCHAR(100) DEFAULT '',
  css_class VARCHAR(100) DEFAULT NULL,
  list_class VARCHAR(100) DEFAULT NULL,
  is_default CHAR(1) DEFAULT 'N',
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (dict_code)
);

-- ----------------------------
-- 字典类型表
-- ----------------------------
DROP TABLE IF EXISTS sys_dict_type;
CREATE TABLE sys_dict_type (
  dict_id BIGINT NOT NULL AUTO_INCREMENT,
  dict_name VARCHAR(100) DEFAULT '',
  dict_type VARCHAR(100) DEFAULT '',
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (dict_id)
);
CREATE UNIQUE INDEX idx_dict_type ON sys_dict_type (dict_type);

-- ----------------------------
-- 财务管理表
-- ----------------------------
DROP TABLE IF EXISTS sys_finance;
CREATE TABLE sys_finance (
  finance_id BIGINT NOT NULL AUTO_INCREMENT,
  creditor_name VARCHAR(100) NOT NULL,
  loan_amount DECIMAL(12, 2) DEFAULT NULL,
  loan_date DATE DEFAULT NULL,
  repayment_start_date DATE DEFAULT NULL,
  repayment_end_date DATE DEFAULT NULL,
  loan_term INT DEFAULT NULL,
  repayment_day INT DEFAULT NULL,
  monthly_payment DECIMAL(12, 2) DEFAULT NULL,
  interest_rate DECIMAL(5, 2) DEFAULT NULL,
  interest_amount DECIMAL(12, 2) DEFAULT NULL,
  early_settlement_amount DECIMAL(12, 2) DEFAULT NULL,
  remaining_amount DECIMAL(12, 2) DEFAULT NULL,
  paid_amount DECIMAL(12, 2) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  remark VARCHAR(500) DEFAULT NULL,
  paid_months VARCHAR(500) DEFAULT NULL,
  month_data TEXT DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (finance_id)
);
CREATE INDEX idx_finance_creditor_name ON sys_finance (creditor_name);
CREATE INDEX idx_finance_status ON sys_finance (status);

-- ----------------------------
-- 定时任务调度表
-- ----------------------------
DROP TABLE IF EXISTS sys_job;
CREATE TABLE sys_job (
  job_id BIGINT NOT NULL AUTO_INCREMENT,
  job_name VARCHAR(64) NOT NULL DEFAULT '',
  job_group VARCHAR(64) NOT NULL DEFAULT 'DEFAULT',
  invoke_target VARCHAR(500) NOT NULL,
  cron_expression VARCHAR(255) DEFAULT '',
  misfire_policy VARCHAR(20) DEFAULT '3',
  concurrent CHAR(1) DEFAULT '1',
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(500) DEFAULT '',
  PRIMARY KEY (job_id, job_name, job_group)
);

-- ----------------------------
-- 定时任务调度日志表
-- ----------------------------
DROP TABLE IF EXISTS sys_job_log;
CREATE TABLE sys_job_log (
  job_log_id BIGINT NOT NULL AUTO_INCREMENT,
  job_name VARCHAR(64) NOT NULL,
  job_group VARCHAR(64) NOT NULL,
  invoke_target VARCHAR(500) NOT NULL,
  job_message VARCHAR(500) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  exception_info VARCHAR(2000) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  PRIMARY KEY (job_log_id)
);

-- ----------------------------
-- 系统访问记录表
-- ----------------------------
DROP TABLE IF EXISTS sys_logininfor;
CREATE TABLE sys_logininfor (
  info_id BIGINT NOT NULL AUTO_INCREMENT,
  user_name VARCHAR(50) DEFAULT '',
  ipaddr VARCHAR(128) DEFAULT '',
  login_location VARCHAR(255) DEFAULT '',
  browser VARCHAR(50) DEFAULT '',
  os VARCHAR(50) DEFAULT '',
  status CHAR(1) DEFAULT '0',
  msg VARCHAR(255) DEFAULT '',
  login_time DATETIME DEFAULT NULL,
  PRIMARY KEY (info_id)
);
CREATE INDEX idx_logininfor_status ON sys_logininfor (status);
CREATE INDEX idx_logininfor_login_time ON sys_logininfor (login_time);

-- ----------------------------
-- 菜单权限表
-- ----------------------------
DROP TABLE IF EXISTS sys_menu;
CREATE TABLE sys_menu (
  menu_id BIGINT NOT NULL AUTO_INCREMENT,
  menu_name VARCHAR(50) NOT NULL,
  parent_id BIGINT DEFAULT 0,
  order_num INT DEFAULT 0,
  path VARCHAR(200) DEFAULT '',
  component VARCHAR(255) DEFAULT NULL,
  query VARCHAR(255) DEFAULT NULL,
  route_name VARCHAR(50) DEFAULT '',
  is_frame INT DEFAULT 1,
  is_cache INT DEFAULT 0,
  menu_type CHAR(1) DEFAULT '',
  visible CHAR(1) DEFAULT '0',
  status CHAR(1) DEFAULT '0',
  perms VARCHAR(100) DEFAULT NULL,
  icon VARCHAR(100) DEFAULT '#',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(500) DEFAULT '',
  PRIMARY KEY (menu_id)
);

-- ----------------------------
-- 通知公告表
-- ----------------------------
DROP TABLE IF EXISTS sys_notice;
CREATE TABLE sys_notice (
  notice_id INT NOT NULL AUTO_INCREMENT,
  notice_title VARCHAR(50) NOT NULL,
  notice_type CHAR(1) NOT NULL,
  notice_content VARCHAR(2000) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (notice_id)
);

-- ----------------------------
-- 操作日志记录表
-- ----------------------------
DROP TABLE IF EXISTS sys_oper_log;
CREATE TABLE sys_oper_log (
  oper_id BIGINT NOT NULL AUTO_INCREMENT,
  title VARCHAR(50) DEFAULT '',
  business_type INT DEFAULT 0,
  method VARCHAR(200) DEFAULT '',
  request_method VARCHAR(10) DEFAULT '',
  operator_type INT DEFAULT 0,
  oper_name VARCHAR(50) DEFAULT '',
  dept_name VARCHAR(50) DEFAULT '',
  oper_url VARCHAR(255) DEFAULT '',
  oper_ip VARCHAR(128) DEFAULT '',
  oper_location VARCHAR(255) DEFAULT '',
  oper_param VARCHAR(2000) DEFAULT '',
  json_result VARCHAR(2000) DEFAULT '',
  status INT DEFAULT 0,
  error_msg VARCHAR(2000) DEFAULT '',
  oper_time DATETIME DEFAULT NULL,
  cost_time BIGINT DEFAULT 0,
  PRIMARY KEY (oper_id)
);
CREATE INDEX idx_oper_log_business_type ON sys_oper_log (business_type);
CREATE INDEX idx_oper_log_status ON sys_oper_log (status);
CREATE INDEX idx_oper_log_oper_time ON sys_oper_log (oper_time);

-- ----------------------------
-- 岗位信息表
-- ----------------------------
DROP TABLE IF EXISTS sys_post;
CREATE TABLE sys_post (
  post_id BIGINT NOT NULL AUTO_INCREMENT,
  post_code VARCHAR(64) NOT NULL,
  post_name VARCHAR(50) NOT NULL,
  post_sort INT NOT NULL,
  status CHAR(1) NOT NULL,
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (post_id)
);

-- ----------------------------
-- 角色信息表
-- ----------------------------
DROP TABLE IF EXISTS sys_role;
CREATE TABLE sys_role (
  role_id BIGINT NOT NULL AUTO_INCREMENT,
  role_name VARCHAR(30) NOT NULL,
  role_key VARCHAR(100) NOT NULL,
  role_sort INT NOT NULL,
  data_scope CHAR(1) DEFAULT '1',
  menu_check_strictly TINYINT DEFAULT 1,
  dept_check_strictly TINYINT DEFAULT 1,
  status CHAR(1) NOT NULL,
  del_flag CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (role_id)
);

-- ----------------------------
-- 角色和部门关联表
-- ----------------------------
DROP TABLE IF EXISTS sys_role_dept;
CREATE TABLE sys_role_dept (
  role_id BIGINT NOT NULL,
  dept_id BIGINT NOT NULL,
  PRIMARY KEY (role_id, dept_id)
);

-- ----------------------------
-- 角色和菜单关联表
-- ----------------------------
DROP TABLE IF EXISTS sys_role_menu;
CREATE TABLE sys_role_menu (
  role_id BIGINT NOT NULL,
  menu_id BIGINT NOT NULL,
  PRIMARY KEY (role_id, menu_id)
);

-- ----------------------------
-- 用户信息表
-- ----------------------------
DROP TABLE IF EXISTS sys_user;
CREATE TABLE sys_user (
  user_id BIGINT NOT NULL AUTO_INCREMENT,
  dept_id BIGINT DEFAULT NULL,
  user_name VARCHAR(30) NOT NULL,
  nick_name VARCHAR(30) NOT NULL,
  user_type VARCHAR(2) DEFAULT '00',
  email VARCHAR(50) DEFAULT '',
  phonenumber VARCHAR(11) DEFAULT '',
  sex CHAR(1) DEFAULT '0',
  avatar VARCHAR(100) DEFAULT '',
  password VARCHAR(100) DEFAULT '',
  status CHAR(1) DEFAULT '0',
  del_flag CHAR(1) DEFAULT '0',
  login_ip VARCHAR(128) DEFAULT '',
  login_date DATETIME DEFAULT NULL,
  pwd_update_date DATETIME DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (user_id)
);

-- ----------------------------
-- 用户与岗位关联表
-- ----------------------------
DROP TABLE IF EXISTS sys_user_post;
CREATE TABLE sys_user_post (
  user_id BIGINT NOT NULL,
  post_id BIGINT NOT NULL,
  PRIMARY KEY (user_id, post_id)
);

-- ----------------------------
-- 用户和角色关联表
-- ----------------------------
DROP TABLE IF EXISTS sys_user_role;
CREATE TABLE sys_user_role (
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  PRIMARY KEY (user_id, role_id)
);

-- ----------------------------
-- 视频管理表
-- ----------------------------
DROP TABLE IF EXISTS ddss_video;
CREATE TABLE ddss_video (
  video_id BIGINT NOT NULL AUTO_INCREMENT,
  video_name VARCHAR(100) NOT NULL,
  video_url VARCHAR(500) NOT NULL,
  cover_image VARCHAR(500) DEFAULT NULL,
  duration INT DEFAULT NULL,
  file_size VARCHAR(50) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  remark VARCHAR(500) DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (video_id)
);
CREATE INDEX idx_video_name ON ddss_video (video_name);

-- ----------------------------
-- 请假申请单（工作流演示）
-- ----------------------------
DROP TABLE IF EXISTS ddss_leave;
CREATE TABLE ddss_leave (
  leave_id BIGINT NOT NULL AUTO_INCREMENT,
  apply_user VARCHAR(64) NOT NULL,
  apply_user_name VARCHAR(64) DEFAULT '',
  leave_days INT DEFAULT NULL,
  start_date DATE DEFAULT NULL,
  reason VARCHAR(500) DEFAULT NULL,
  leader VARCHAR(64) DEFAULT NULL,
  boss VARCHAR(64) DEFAULT NULL,
  process_instance_id VARCHAR(64) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (leave_id)
);

-- ----------------------------
-- 流程模型表（工作流设计器）
-- ----------------------------
DROP TABLE IF EXISTS ddss_flow_design;
CREATE TABLE ddss_flow_design (
  flow_id BIGINT NOT NULL AUTO_INCREMENT,
  flow_key VARCHAR(100) NOT NULL,
  flow_name VARCHAR(100) NOT NULL,
  bpmn_xml CLOB,
  version INT DEFAULT 1,
  status CHAR(1) DEFAULT '0',
  deployment_id VARCHAR(64) DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (flow_id)
);
CREATE UNIQUE INDEX uk_flow_key ON ddss_flow_design (flow_key);

-- ----------------------------
-- 资源管理表
-- ----------------------------
DROP TABLE IF EXISTS ddss_resource;
CREATE TABLE ddss_resource (
  resource_id BIGINT NOT NULL AUTO_INCREMENT,
  resource_name VARCHAR(100) NOT NULL,
  file_size VARCHAR(50) DEFAULT NULL,
  file_type VARCHAR(50) DEFAULT NULL,
  file_path VARCHAR(500) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  remark VARCHAR(500) DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (resource_id)
);
CREATE INDEX idx_resource_name ON ddss_resource (resource_name);

-- ----------------------------
-- 视频资源表
-- ----------------------------
DROP TABLE IF EXISTS sys_video_resource;
CREATE TABLE sys_video_resource (
  id BIGINT NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  file_name VARCHAR(100) NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  file_size BIGINT DEFAULT NULL,
  mime_type VARCHAR(50) DEFAULT NULL,
  description VARCHAR(500) DEFAULT NULL,
  duration INT DEFAULT NULL,
  resolution VARCHAR(20) DEFAULT NULL,
  thumbnail VARCHAR(255) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (id)
);

-- ----------------------------
-- 代码生成业务表
-- ----------------------------
DROP TABLE IF EXISTS gen_table;
CREATE TABLE gen_table (
  table_id BIGINT NOT NULL AUTO_INCREMENT,
  table_name VARCHAR(200) DEFAULT '',
  table_comment VARCHAR(500) DEFAULT '',
  sub_table_name VARCHAR(64) DEFAULT NULL,
  sub_table_fk_name VARCHAR(64) DEFAULT NULL,
  sub_table_fk_column_name VARCHAR(64) DEFAULT NULL,
  class_name VARCHAR(100) DEFAULT '',
  tpl_category VARCHAR(200) DEFAULT 'crud',
  tpl_web_type VARCHAR(30) DEFAULT '',
  package_name VARCHAR(100) DEFAULT '',
  module_name VARCHAR(30) DEFAULT '',
  business_name VARCHAR(30) DEFAULT '',
  function_name VARCHAR(50) DEFAULT '',
  function_author VARCHAR(50) DEFAULT '',
  gen_type CHAR(1) DEFAULT '0',
  gen_path VARCHAR(200) DEFAULT '/',
  options VARCHAR(1000) DEFAULT '',
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  remark VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (table_id)
);

-- ----------------------------
-- 代码生成业务表字段
-- ----------------------------
DROP TABLE IF EXISTS gen_table_column;
CREATE TABLE gen_table_column (
  column_id BIGINT NOT NULL AUTO_INCREMENT,
  table_id BIGINT DEFAULT NULL,
  column_name VARCHAR(200) DEFAULT '',
  column_comment VARCHAR(500) DEFAULT '',
  column_type VARCHAR(100) DEFAULT '',
  java_type VARCHAR(500) DEFAULT '',
  java_field VARCHAR(200) DEFAULT '',
  is_pk CHAR(1) DEFAULT '0',
  is_increment CHAR(1) DEFAULT '0',
  is_required CHAR(1) DEFAULT '0',
  is_insert CHAR(1) DEFAULT '0',
  is_edit CHAR(1) DEFAULT '0',
  is_list CHAR(1) DEFAULT '0',
  is_query CHAR(1) DEFAULT '0',
  is_unique CHAR(1) DEFAULT '0',
  query_type VARCHAR(200) DEFAULT 'EQ',
  html_type VARCHAR(200) DEFAULT '',
  dict_type VARCHAR(200) DEFAULT '',
  sort INT DEFAULT 0,
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (column_id)
);

-- ----------------------------
-- SQL记录管理表
-- ----------------------------
DROP TABLE IF EXISTS sys_sql_record;
CREATE TABLE sys_sql_record (
  sql_id BIGINT NOT NULL AUTO_INCREMENT,
  purpose VARCHAR(200) NOT NULL,
  sql_content TEXT NOT NULL,
  create_by VARCHAR(64) DEFAULT '',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  update_by VARCHAR(64) DEFAULT '',
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  remark VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY (sql_id)
);
CREATE INDEX idx_sql_record_purpose ON sys_sql_record (purpose);

-- ----------------------------
-- 财务管理表
-- ----------------------------
DROP TABLE IF EXISTS `sys_finance`;
CREATE TABLE `sys_finance` (
  `finance_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `creditor_name` varchar(100) NOT NULL COMMENT '欠款方名称',
  `loan_amount` decimal(12,2) DEFAULT NULL COMMENT '借款总额',
  `loan_date` date DEFAULT NULL COMMENT '借款日期',
  `repayment_start_date` date DEFAULT NULL COMMENT '还款开始日期',
  `repayment_end_date` date DEFAULT NULL COMMENT '还款结束日期',
  `loan_term` int DEFAULT NULL COMMENT '借款期限(月)',
  `repayment_day` int DEFAULT NULL COMMENT '每月还款日(几号)',
  `monthly_payment` decimal(12,2) DEFAULT NULL COMMENT '月还款额',
  `interest_rate` decimal(5,2) DEFAULT NULL COMMENT '利率(%)',
  `interest_amount` decimal(12,2) DEFAULT NULL COMMENT '利息总额',
  `early_settlement_amount` decimal(12,2) DEFAULT NULL COMMENT '提前结清金额',
  `remaining_amount` decimal(12,2) DEFAULT NULL COMMENT '剩余未还金额',
  `paid_amount` decimal(12,2) DEFAULT NULL COMMENT '已还金额',
  `status` char(1) DEFAULT '0' COMMENT '状态(0还款中 1已结清 2逾期)',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`finance_id`),
  INDEX `idx_creditor_name`(`creditor_name`),
  INDEX `idx_status`(`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='财务管理表';

-- ----------------------------
-- 菜单: 财务管理
-- ----------------------------
INSERT INTO `sys_menu` VALUES (200, '财务管理', 5, 1, 'finance', NULL, NULL, '', 1, 0, 'M', '0', '0', NULL, 'money', 'admin', now(), '', NULL, '财务管理目录');

-- 财务管理-列表
INSERT INTO `sys_menu` VALUES (201, '财务记录', 200, 1, 'index', 'finance/index', NULL, '', 1, 1, 'C', '0', '0', 'finance:list', 'list', 'admin', now(), '', NULL, '财务记录菜单');

-- 财务管理-统u计
INSERT INTO `sys_menu` VALUES (202, '财务统计', 200, 2, 'statistics', 'finance/statistics', NULL, '', 1, 1, 'C', '0', '0', 'finance:stat', 'chart', 'admin', now(), '', NULL, '财务统计菜单');

-- 按钮权限
INSERT INTO `sys_menu` VALUES (203, '财务查询', 201, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:query', '#', 'admin', now(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (204, '财务新增', 201, 2, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:add', '#', 'admin', now(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (205, '财务修改', 201, 3, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:edit', '#', 'admin', now(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (206, '财务删除', 201, 4, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:remove', '#', 'admin', now(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (207, '财务统计', 202, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:stat', '#', 'admin', now(), '', NULL, '');

-- 给角色分配菜单权限(admin 角色 = 1, common 角色 = 2)
INSERT INTO `sys_role_menu` VALUES (1, 200), (1, 201), (1, 202), (1, 203), (1, 204), (1, 205), (1, 206), (1, 207);
INSERT INTO `sys_role_menu` VALUES (2, 200), (2, 201), (2, 202), (2, 203), (2, 204), (2, 205), (2, 206), (2, 207);

-- DDSS H2 内存库初始数据（Dev 模式：ddss.middleware.mysql.enabled=false 时由 H2DataInitializer 执行）
-- 日志表（sys_logininfor/sys_oper_log/sys_job_log）保留为空，不含历史数据

-- ----------------------------
-- 系统配置
-- ----------------------------
INSERT INTO sys_config VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO sys_config VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '初始化密码 123456');
INSERT INTO sys_config VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO sys_config VALUES (4, '账号自助-验证码开关', 'sys.account.captchaEnabled', 'true', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '是否开启验证码功能（true开启，false关闭）');
INSERT INTO sys_config VALUES (5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '是否开启注册用户功能');
INSERT INTO sys_config VALUES (6, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '设置登录IP黑名单限制，多个匹配项以分号分隔，支持匹配（*通配、网段）');
INSERT INTO sys_config VALUES (7, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '0：关闭，1：提醒用户修改初始密码');
INSERT INTO sys_config VALUES (8, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2026-06-14 21:43:55', '', NULL, '密码更新周期（0不限制，否则为大于0小于365的正整数）');

-- ----------------------------
-- 部门
-- ----------------------------
INSERT INTO sys_dept VALUES (100, 0, '0', 'DDSS科技', 0, '管理员', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO sys_dept VALUES (101, 100, '0,100', '深圳总公司', 1, '管理员', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO sys_dept VALUES (102, 100, '0,100', '长沙分公司', 2, '管理员', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO sys_dept VALUES (103, 101, '0,100,101', '研发部门', 1, '管理员', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO sys_dept VALUES (104, 101, '0,100,101', '市场部门', 2, '管理员', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO sys_dept VALUES (105, 101, '0,100,101', '测试部门', 3, '管理员', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO sys_dept VALUES (106, 101, '0,100,101', '财务部门', 4, '管理员', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO sys_dept VALUES (107, 101, '0,100,101', '运维部门', 5, '管理员', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO sys_dept VALUES (108, 102, '0,100,102', '市场部门', 1, '管理员', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:53', '', NULL);
INSERT INTO sys_dept VALUES (109, 102, '0,100,102', '财务部门', 2, '管理员', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL);

-- ----------------------------
-- 字典类型
-- ----------------------------
INSERT INTO sys_dict_type VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '用户性别列表');
INSERT INTO sys_dict_type VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '菜单状态列表');
INSERT INTO sys_dict_type VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '系统开关列表');
INSERT INTO sys_dict_type VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '任务状态列表');
INSERT INTO sys_dict_type VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '任务分组列表');
INSERT INTO sys_dict_type VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '系统是否列表');
INSERT INTO sys_dict_type VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '通知类型列表');
INSERT INTO sys_dict_type VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '通知状态列表');
INSERT INTO sys_dict_type VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '操作类型列表');
INSERT INTO sys_dict_type VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '登录状态列表');

-- ----------------------------
-- 字典数据
-- ----------------------------
INSERT INTO sys_dict_data VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '性别男');
INSERT INTO sys_dict_data VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '性别女');
INSERT INTO sys_dict_data VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '性别未知');
INSERT INTO sys_dict_data VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '显示菜单');
INSERT INTO sys_dict_data VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '隐藏菜单');
INSERT INTO sys_dict_data VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '正常状态');
INSERT INTO sys_dict_data VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '停用状态');
INSERT INTO sys_dict_data VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '正常状态');
INSERT INTO sys_dict_data VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '停用状态');
INSERT INTO sys_dict_data VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '默认分组');
INSERT INTO sys_dict_data VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '系统分组');
INSERT INTO sys_dict_data VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '系统默认是');
INSERT INTO sys_dict_data VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '系统默认否');
INSERT INTO sys_dict_data VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '通知');
INSERT INTO sys_dict_data VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '公告');
INSERT INTO sys_dict_data VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '正常状态');
INSERT INTO sys_dict_data VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '关闭状态');
INSERT INTO sys_dict_data VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '其他操作');
INSERT INTO sys_dict_data VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '新增操作');
INSERT INTO sys_dict_data VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '修改操作');
INSERT INTO sys_dict_data VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '删除操作');
INSERT INTO sys_dict_data VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '授权操作');
INSERT INTO sys_dict_data VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '导出操作');
INSERT INTO sys_dict_data VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '导入操作');
INSERT INTO sys_dict_data VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '强退操作');
INSERT INTO sys_dict_data VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '生成操作');
INSERT INTO sys_dict_data VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '清空操作');
INSERT INTO sys_dict_data VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '正常状态');
INSERT INTO sys_dict_data VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '停用状态');

-- ----------------------------
-- 用户（密码均为 admin123 的 BCrypt 值）
-- ----------------------------
INSERT INTO sys_user VALUES (1, 103, 'admin', 'DDSS管理员', '00', 'vip.p@live.com', '13888888888', '0', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', NULL, NULL, 'admin', '2026-06-14 21:43:54', '', NULL, '管理员');
INSERT INTO sys_user VALUES (2, 105, 'ry', '测试员', '00', 'ry@qq.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', NULL, NULL, 'admin', '2026-06-14 21:43:54', '', NULL, '测试员');

-- ----------------------------
-- 角色
-- ----------------------------
INSERT INTO sys_role VALUES (1, '超级管理员', 'admin', 1, '1', 1, 1, '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL, '超级管理员');
INSERT INTO sys_role VALUES (2, '普通角色', 'common', 2, '2', 1, 1, '0', '0', 'admin', '2026-06-14 21:43:54', '', NULL, '普通角色');

-- ----------------------------
-- 岗位
-- ----------------------------
INSERT INTO sys_post VALUES (1, 'ceo', '董事长', 1, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_post VALUES (2, 'se', '项目经理', 2, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_post VALUES (3, 'hr', '人力资源', 3, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_post VALUES (4, 'user', '普通员工', 4, '0', 'admin', '2026-06-14 21:43:54', '', NULL, '');

-- ----------------------------
-- 用户-角色关联
-- ----------------------------
INSERT INTO sys_user_role VALUES (1, 1);
INSERT INTO sys_user_role VALUES (2, 2);

-- ----------------------------
-- 用户-岗位关联
-- ----------------------------
INSERT INTO sys_user_post VALUES (1, 1);
INSERT INTO sys_user_post VALUES (2, 2);

-- ----------------------------
-- 角色-部门关联
-- ----------------------------
INSERT INTO sys_role_dept VALUES (2, 100);
INSERT INTO sys_role_dept VALUES (2, 101);
INSERT INTO sys_role_dept VALUES (2, 105);

-- ----------------------------
-- 菜单（目录/菜单/按钮）
-- ----------------------------
INSERT INTO sys_menu VALUES (1, '系统管理', 0, 1, 'system', NULL, '', '', 1, 0, 'M', '0', '0', '', 'system', 'admin', '2026-06-14 21:43:54', '', NULL, '系统管理目录');
INSERT INTO sys_menu VALUES (2, '系统监控', 0, 2, 'monitor', NULL, '', '', 1, 0, 'M', '0', '0', '', 'monitor', 'admin', '2026-06-14 21:43:54', '', NULL, '系统监控目录');
INSERT INTO sys_menu VALUES (3, '系统工具', 0, 3, 'tool', NULL, '', '', 1, 0, 'M', '0', '0', '', 'tool', 'admin', '2026-06-14 21:43:54', '', NULL, '系统工具目录');
INSERT INTO sys_menu VALUES (5, '视频管理', 0, 5, 'video', NULL, NULL, '', 1, 0, 'M', '0', '0', NULL, 'video', 'admin', '2026-06-23 18:58:10', '', NULL, '视频管理目录');
INSERT INTO sys_menu VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', 'admin', '2026-06-14 21:43:54', '', NULL, '用户管理菜单');
INSERT INTO sys_menu VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', 'admin', '2026-06-14 21:43:54', '', NULL, '角色管理菜单');
INSERT INTO sys_menu VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', 'admin', '2026-06-14 21:43:54', '', NULL, '菜单管理菜单');
INSERT INTO sys_menu VALUES (103, '部门管理', 1, 4, 'dept', 'system/dept/index', '', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', 'admin', '2026-06-14 21:43:54', '', NULL, '部门管理菜单');
INSERT INTO sys_menu VALUES (104, '岗位管理', 1, 5, 'post', 'system/post/index', '', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', 'admin', '2026-06-14 21:43:54', '', NULL, '岗位管理菜单');
INSERT INTO sys_menu VALUES (105, '字典管理', 1, 6, 'dict', 'system/dict/index', '', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', 'admin', '2026-06-14 21:43:54', '', NULL, '字典管理菜单');
INSERT INTO sys_menu VALUES (106, '参数设置', 1, 7, 'config', 'system/config/index', '', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', 'admin', '2026-06-14 21:43:54', '', NULL, '参数设置菜单');
INSERT INTO sys_menu VALUES (107, '通知公告', 1, 8, 'notice', 'system/notice/index', '', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', 'admin', '2026-06-14 21:43:54', '', NULL, '通知公告菜单');
INSERT INTO sys_menu VALUES (108, '日志管理', 1, 9, 'log', '', '', '', 1, 0, 'M', '0', '0', '', 'log', 'admin', '2026-06-14 21:43:54', '', NULL, '日志管理菜单');
INSERT INTO sys_menu VALUES (109, '在线用户', 2, 1, 'online', 'monitor/online/index', '', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', 'admin', '2026-06-14 21:43:54', '', NULL, '在线用户菜单');
INSERT INTO sys_menu VALUES (110, '定时任务', 2, 2, 'job', 'monitor/job/index', '', '', 1, 0, 'C', '0', '0', 'monitor:job:list', 'job', 'admin', '2026-06-14 21:43:54', '', NULL, '定时任务菜单');
INSERT INTO sys_menu VALUES (111, '数据监控', 2, 3, 'druid', 'monitor/druid/index', '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list', 'druid', 'admin', '2026-06-14 21:43:54', '', NULL, '数据监控菜单');
INSERT INTO sys_menu VALUES (112, '服务监控', 2, 4, 'server', 'monitor/server/index', '', '', 1, 0, 'C', '0', '0', 'monitor:server:list', 'server', 'admin', '2026-06-14 21:43:54', '', NULL, '服务监控菜单');
INSERT INTO sys_menu VALUES (113, '缓存监控', 2, 5, 'cache', 'monitor/cache/index', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', 'admin', '2026-06-14 21:43:54', '', NULL, '缓存监控菜单');
INSERT INTO sys_menu VALUES (114, '缓存列表', 2, 6, 'cacheList', 'monitor/cache/list', '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis-list', 'admin', '2026-06-14 21:43:54', '', NULL, '缓存列表菜单');
INSERT INTO sys_menu VALUES (118, '中间件监控', 2, 7, 'middleware', 'monitor/middleware/index', '', '', 1, 0, 'C', '0', '0', 'monitor:middleware:list', 'server', 'admin', '2026-07-23 00:00:00', '', NULL, '中间件状态监控');
INSERT INTO sys_menu VALUES (115, '表单构建', 3, 1, 'build', 'tool/build/index', '', '', 1, 0, 'C', '0', '0', 'tool:build:list', 'build', 'admin', '2026-06-14 21:43:54', '', NULL, '表单构建菜单');
INSERT INTO sys_menu VALUES (116, '代码生成', 3, 2, 'gen', 'tool/gen/index', '', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', 'admin', '2026-06-14 21:43:54', '', NULL, '代码生成菜单');
INSERT INTO sys_menu VALUES (117, '系统接口', 3, 3, 'swagger', 'tool/swagger/index', '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list', 'swagger', 'admin', '2026-06-14 21:43:54', '', NULL, '系统接口菜单');
INSERT INTO sys_menu VALUES (200, '财务管理', 5, 1, 'finance', NULL, NULL, '', 1, 0, 'M', '0', '0', NULL, 'money', 'admin', '2026-07-01 11:23:16', '', NULL, '财务管理目录');
INSERT INTO sys_menu VALUES (201, '财务记录', 200, 1, 'index', 'finance/index', NULL, '', 1, 1, 'C', '0', '0', 'finance:list', 'list', 'admin', '2026-07-01 11:23:16', '', NULL, '财务记录菜单');
INSERT INTO sys_menu VALUES (202, '财务统计', 200, 2, 'statistics', 'finance/statistics', NULL, '', 1, 1, 'C', '0', '0', 'finance:stat', 'chart', 'admin', '2026-07-01 11:23:16', '', NULL, '财务统计菜单');
INSERT INTO sys_menu VALUES (203, '财务查询', 201, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:query', '#', 'admin', '2026-07-01 11:23:16', '', NULL, '');
INSERT INTO sys_menu VALUES (204, '财务新增', 201, 2, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:add', '#', 'admin', '2026-07-01 11:23:16', '', NULL, '');
INSERT INTO sys_menu VALUES (205, '财务修改', 201, 3, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:edit', '#', 'admin', '2026-07-01 11:23:16', '', NULL, '');
INSERT INTO sys_menu VALUES (206, '财务删除', 201, 4, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:remove', '#', 'admin', '2026-07-01 11:23:16', '', NULL, '');
INSERT INTO sys_menu VALUES (207, '财务统计', 202, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'finance:stat', '#', 'admin', '2026-07-01 11:23:16', '', NULL, '');
INSERT INTO sys_menu VALUES (500, '操作日志', 108, 1, 'operlog', 'monitor/operlog/index', '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', 'admin', '2026-06-14 21:43:54', '', NULL, '操作日志菜单');
INSERT INTO sys_menu VALUES (501, '登录日志', 108, 2, 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', 'admin', '2026-06-14 21:43:54', '', NULL, '登录日志菜单');
INSERT INTO sys_menu VALUES (1000, '用户查询', 100, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1001, '用户新增', 100, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1002, '用户修改', 100, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1003, '用户删除', 100, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1004, '用户导出', 100, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1005, '用户导入', 100, 6, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1006, '重置密码', 100, 7, '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1007, '角色查询', 101, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1008, '角色新增', 101, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1009, '角色修改', 101, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1010, '角色删除', 101, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1011, '角色导出', 101, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1012, '菜单查询', 102, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1013, '菜单新增', 102, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1014, '菜单修改', 102, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1015, '菜单删除', 102, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1016, '部门查询', 103, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1017, '部门新增', 103, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1018, '部门修改', 103, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1019, '部门删除', 103, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1020, '岗位查询', 104, 1, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1021, '岗位新增', 104, 2, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1022, '岗位修改', 104, 3, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1023, '岗位删除', 104, 4, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1024, '岗位导出', 104, 5, '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1025, '字典查询', 105, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1026, '字典新增', 105, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1027, '字典修改', 105, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1028, '字典删除', 105, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1029, '字典导出', 105, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1030, '参数查询', 106, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1031, '参数新增', 106, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1032, '参数修改', 106, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1033, '参数删除', 106, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1034, '参数导出', 106, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1035, '公告查询', 107, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1036, '公告新增', 107, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1037, '公告修改', 107, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1038, '公告删除', 107, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1039, '操作查询', 500, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1040, '操作删除', 500, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1041, '日志导出', 500, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1042, '登录查询', 501, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1043, '登录删除', 501, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1044, '日志导出', 501, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1045, '账户解锁', 501, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1046, '在线查询', 109, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1047, '批量强退', 109, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1048, '单条强退', 109, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1049, '任务查询', 110, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1050, '任务新增', 110, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1051, '任务修改', 110, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1052, '任务删除', 110, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1053, '状态修改', 110, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1054, '任务导出', 110, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1055, '生成查询', 116, 1, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1056, '生成修改', 116, 2, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1057, '生成删除', 116, 3, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1058, '导入代码', 116, 4, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1059, '预览代码', 116, 5, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (1060, '生成代码', 116, 6, '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', 'admin', '2026-06-14 21:43:54', '', NULL, '');
INSERT INTO sys_menu VALUES (2000, '视频列表', 5, 1, 'list', 'video/index', NULL, '', 1, 0, 'C', '0', '0', 'video:list', 'list', 'admin', '2026-06-23 18:58:10', '', NULL, '视频列表菜单');
INSERT INTO sys_menu VALUES (2001, '视频查询', 2000, 1, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:query', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO sys_menu VALUES (2002, '视频新增', 2000, 2, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:add', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO sys_menu VALUES (2003, '视频修改', 2000, 3, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:edit', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO sys_menu VALUES (2004, '视频删除', 2000, 4, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:remove', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO sys_menu VALUES (2005, '视频导出', 2000, 5, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:export', '#', 'admin', '2026-06-23 18:58:10', '', NULL, '');
INSERT INTO sys_menu VALUES (2010, '资源管理', 5, 2, 'resource', 'video/resource', NULL, '', 1, 0, 'C', '0', '0', 'video:resource:list', 'folder', 'admin', '2026-06-24 09:01:27', '', NULL, '资源管理菜单');
INSERT INTO sys_menu VALUES (2011, '资源查询', 2010, 1, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:query', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO sys_menu VALUES (2012, '资源新增', 2010, 2, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:add', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO sys_menu VALUES (2013, '资源修改', 2010, 3, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:edit', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO sys_menu VALUES (2014, '资源删除', 2010, 4, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:remove', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');
INSERT INTO sys_menu VALUES (2015, '资源导出', 2010, 5, '#', NULL, NULL, '', 1, 0, 'F', '0', '0', 'video:resource:export', '#', 'admin', '2026-06-24 09:01:27', '', NULL, '');

-- ----------------------------
-- 角色-菜单关联（角色1=超级管理员：财务+视频菜单；角色2=普通角色：系统+监控+工具+财务菜单）
-- ----------------------------
INSERT INTO sys_role_menu VALUES (1, 5);
INSERT INTO sys_role_menu VALUES (1, 200);
INSERT INTO sys_role_menu VALUES (1, 201);
INSERT INTO sys_role_menu VALUES (1, 202);
INSERT INTO sys_role_menu VALUES (1, 203);
INSERT INTO sys_role_menu VALUES (1, 204);
INSERT INTO sys_role_menu VALUES (1, 205);
INSERT INTO sys_role_menu VALUES (1, 206);
INSERT INTO sys_role_menu VALUES (1, 207);
INSERT INTO sys_role_menu VALUES (1, 2000);
INSERT INTO sys_role_menu VALUES (1, 2001);
INSERT INTO sys_role_menu VALUES (1, 2002);
INSERT INTO sys_role_menu VALUES (1, 2003);
INSERT INTO sys_role_menu VALUES (1, 2004);
INSERT INTO sys_role_menu VALUES (1, 2005);
INSERT INTO sys_role_menu VALUES (1, 2010);
INSERT INTO sys_role_menu VALUES (1, 2011);
INSERT INTO sys_role_menu VALUES (1, 2012);
INSERT INTO sys_role_menu VALUES (1, 2013);
INSERT INTO sys_role_menu VALUES (1, 2014);
INSERT INTO sys_role_menu VALUES (1, 2015);
INSERT INTO sys_role_menu VALUES (2, 1);
INSERT INTO sys_role_menu VALUES (2, 2);
INSERT INTO sys_role_menu VALUES (2, 3);
INSERT INTO sys_role_menu VALUES (2, 100);
INSERT INTO sys_role_menu VALUES (2, 101);
INSERT INTO sys_role_menu VALUES (2, 102);
INSERT INTO sys_role_menu VALUES (2, 103);
INSERT INTO sys_role_menu VALUES (2, 104);
INSERT INTO sys_role_menu VALUES (2, 105);
INSERT INTO sys_role_menu VALUES (2, 106);
INSERT INTO sys_role_menu VALUES (2, 107);
INSERT INTO sys_role_menu VALUES (2, 108);
INSERT INTO sys_role_menu VALUES (2, 109);
INSERT INTO sys_role_menu VALUES (2, 110);
INSERT INTO sys_role_menu VALUES (2, 111);
INSERT INTO sys_role_menu VALUES (2, 112);
INSERT INTO sys_role_menu VALUES (2, 113);
INSERT INTO sys_role_menu VALUES (2, 114);
INSERT INTO sys_role_menu VALUES (2, 118);
INSERT INTO sys_role_menu VALUES (2, 115);
INSERT INTO sys_role_menu VALUES (2, 116);
INSERT INTO sys_role_menu VALUES (2, 117);
INSERT INTO sys_role_menu VALUES (2, 200);
INSERT INTO sys_role_menu VALUES (2, 201);
INSERT INTO sys_role_menu VALUES (2, 202);
INSERT INTO sys_role_menu VALUES (2, 203);
INSERT INTO sys_role_menu VALUES (2, 204);
INSERT INTO sys_role_menu VALUES (2, 205);
INSERT INTO sys_role_menu VALUES (2, 206);
INSERT INTO sys_role_menu VALUES (2, 207);
INSERT INTO sys_role_menu VALUES (2, 500);
INSERT INTO sys_role_menu VALUES (2, 501);
INSERT INTO sys_role_menu VALUES (2, 1000);
INSERT INTO sys_role_menu VALUES (2, 1001);
INSERT INTO sys_role_menu VALUES (2, 1002);
INSERT INTO sys_role_menu VALUES (2, 1003);
INSERT INTO sys_role_menu VALUES (2, 1004);
INSERT INTO sys_role_menu VALUES (2, 1005);
INSERT INTO sys_role_menu VALUES (2, 1006);
INSERT INTO sys_role_menu VALUES (2, 1007);
INSERT INTO sys_role_menu VALUES (2, 1008);
INSERT INTO sys_role_menu VALUES (2, 1009);
INSERT INTO sys_role_menu VALUES (2, 1010);
INSERT INTO sys_role_menu VALUES (2, 1011);
INSERT INTO sys_role_menu VALUES (2, 1012);
INSERT INTO sys_role_menu VALUES (2, 1013);
INSERT INTO sys_role_menu VALUES (2, 1014);
INSERT INTO sys_role_menu VALUES (2, 1015);
INSERT INTO sys_role_menu VALUES (2, 1016);
INSERT INTO sys_role_menu VALUES (2, 1017);
INSERT INTO sys_role_menu VALUES (2, 1018);
INSERT INTO sys_role_menu VALUES (2, 1019);
INSERT INTO sys_role_menu VALUES (2, 1020);
INSERT INTO sys_role_menu VALUES (2, 1021);
INSERT INTO sys_role_menu VALUES (2, 1022);
INSERT INTO sys_role_menu VALUES (2, 1023);
INSERT INTO sys_role_menu VALUES (2, 1024);
INSERT INTO sys_role_menu VALUES (2, 1025);
INSERT INTO sys_role_menu VALUES (2, 1026);
INSERT INTO sys_role_menu VALUES (2, 1027);
INSERT INTO sys_role_menu VALUES (2, 1028);
INSERT INTO sys_role_menu VALUES (2, 1029);
INSERT INTO sys_role_menu VALUES (2, 1030);
INSERT INTO sys_role_menu VALUES (2, 1031);
INSERT INTO sys_role_menu VALUES (2, 1032);
INSERT INTO sys_role_menu VALUES (2, 1033);
INSERT INTO sys_role_menu VALUES (2, 1034);
INSERT INTO sys_role_menu VALUES (2, 1035);
INSERT INTO sys_role_menu VALUES (2, 1036);
INSERT INTO sys_role_menu VALUES (2, 1037);
INSERT INTO sys_role_menu VALUES (2, 1038);
INSERT INTO sys_role_menu VALUES (2, 1039);
INSERT INTO sys_role_menu VALUES (2, 1040);
INSERT INTO sys_role_menu VALUES (2, 1041);
INSERT INTO sys_role_menu VALUES (2, 1042);
INSERT INTO sys_role_menu VALUES (2, 1043);
INSERT INTO sys_role_menu VALUES (2, 1044);
INSERT INTO sys_role_menu VALUES (2, 1045);
INSERT INTO sys_role_menu VALUES (2, 1046);
INSERT INTO sys_role_menu VALUES (2, 1047);
INSERT INTO sys_role_menu VALUES (2, 1048);
INSERT INTO sys_role_menu VALUES (2, 1049);
INSERT INTO sys_role_menu VALUES (2, 1050);
INSERT INTO sys_role_menu VALUES (2, 1051);
INSERT INTO sys_role_menu VALUES (2, 1052);
INSERT INTO sys_role_menu VALUES (2, 1053);
INSERT INTO sys_role_menu VALUES (2, 1054);
INSERT INTO sys_role_menu VALUES (2, 1055);
INSERT INTO sys_role_menu VALUES (2, 1056);
INSERT INTO sys_role_menu VALUES (2, 1057);
INSERT INTO sys_role_menu VALUES (2, 1058);
INSERT INTO sys_role_menu VALUES (2, 1059);
INSERT INTO sys_role_menu VALUES (2, 1060);

-- ----------------------------
-- 定时任务
-- ----------------------------
INSERT INTO sys_job VALUES (1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2026-06-14 21:43:55', '', NULL, '');
INSERT INTO sys_job VALUES (2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2026-06-14 21:43:55', '', NULL, '');
INSERT INTO sys_job VALUES (3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2026-06-14 21:43:55', '', NULL, '');

-- ----------------------------
-- 通知公告
-- ----------------------------
INSERT INTO sys_notice VALUES (1, '温馨提醒：DDSS 新版本发布啦', '2', '新版本内容', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '管理员');
INSERT INTO sys_notice VALUES (2, '维护通知：DDSS 系统凌晨维护', '1', '维护内容', '0', 'admin', '2026-06-14 21:43:55', '', NULL, '管理员');

-- ----------------------------
-- 财务管理（演示数据）
-- ----------------------------
INSERT INTO sys_finance VALUES (1, '示例欠款A', 15884.00, '2026-02-09', '2026-03-09', '2027-03-09', 12, 9, 1324.00, NULL, 4.00, 8848.00, 14560.00, 1324.00, '0', NULL, '7月', '{"7月":{"amt":1},"4月":{"amt":1}}', 'admin', '2026-07-01 13:01:11', 'admin', '2026-07-01 13:01:11');
INSERT INTO sys_finance VALUES (2, '示例欠款B', 13200.00, '2026-06-16', '2026-07-16', '2027-07-16', 12, 16, 1246.00, NULL, 1752.00, 13329.00, 13200.00, 0.00, '0', NULL, NULL, '{"8月":{"amt":1246},"7月":{"amt":3}}', 'admin', '2026-07-01 13:03:34', 'admin', '2026-07-01 13:03:34');

-- ----------------------------
-- 视频与资源（演示数据）
-- ----------------------------
INSERT INTO ddss_video VALUES (1, '示例视频', 'http://example.com/sample.mp4', NULL, NULL, NULL, '0', NULL, 'admin', '2026-06-23 19:08:19', '', '2026-06-23 19:08:19');
INSERT INTO ddss_resource VALUES (1, '示例图片.png', '5.9 MB', 'png', '示例图片.png', '0', NULL, 'system', '2026-06-24 17:10:06', '', '2026-06-24 17:10:06');
INSERT INTO sys_video_resource VALUES (1, '示例视频1', 'sample1.mp4', '/videos/sample1.mp4', 1024000, 'video/mp4', '示例视频', 60, '1920x1080', '/thumbnails/sample1.jpg', '0', 'admin', '2026-06-22 17:45:52', '', '2026-06-22 17:45:52', '系统初始数据');
INSERT INTO sys_video_resource VALUES (2, '示例视频2', 'sample2.mp4', '/videos/sample2.mp4', 2048000, 'video/mp4', '另一个示例视频', 120, '1280x720', '/thumbnails/sample2.jpg', '0', 'admin', '2026-06-22 17:45:52', '', '2026-06-22 17:45:52', '系统初始数据');

-- ----------------------------
-- SQL记录管理 - 菜单与权限
-- ----------------------------
INSERT INTO sys_menu VALUES (3006, '数据管理', 0, 6, 'data', NULL, '', '', 1, 0, 'M', '0', '0', '', 'database', 'admin', '2026-07-09 00:00:00', '', NULL, '数据管理目录');
INSERT INTO sys_menu VALUES (3007, 'SQL管理', 3006, 1, 'sqlRecord', 'system/sqlRecord/index', '', '', 1, 0, 'C', '0', '0', 'system:sql:list', 'code', 'admin', '2026-07-09 00:00:00', '', NULL, 'SQL记录管理菜单');
INSERT INTO sys_menu VALUES (3008, 'SQL查询', 3007, 1, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'system:sql:query', '#', 'admin', '2026-07-09 00:00:00', '', NULL, '');
INSERT INTO sys_menu VALUES (3009, 'SQL新增', 3007, 2, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'system:sql:add', '#', 'admin', '2026-07-09 00:00:00', '', NULL, '');
INSERT INTO sys_menu VALUES (3010, 'SQL修改', 3007, 3, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'system:sql:edit', '#', 'admin', '2026-07-09 00:00:00', '', NULL, '');
INSERT INTO sys_menu VALUES (3011, 'SQL删除', 3007, 4, '', NULL, NULL, '', 1, 0, 'F', '0', '0', 'system:sql:remove', '#', 'admin', '2026-07-09 00:00:00', '', NULL, '');

-- 角色-菜单关联
INSERT INTO sys_role_menu VALUES (1, 3006);
INSERT INTO sys_role_menu VALUES (1, 3007);
INSERT INTO sys_role_menu VALUES (1, 3008);
INSERT INTO sys_role_menu VALUES (1, 3009);
INSERT INTO sys_role_menu VALUES (1, 3010);
INSERT INTO sys_role_menu VALUES (1, 3011);
INSERT INTO sys_role_menu VALUES (2, 3006);
INSERT INTO sys_role_menu VALUES (2, 3007);
INSERT INTO sys_role_menu VALUES (2, 3008);

-- 将既有请假申请的整数天数列升级为支持半天精度。
ALTER TABLE `ddss_leave`
    MODIFY COLUMN `leave_days` DECIMAL(4,1) NULL DEFAULT NULL COMMENT '请假天数';

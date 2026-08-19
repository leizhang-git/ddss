package com.ddss.server.workflow;

/**
 * 工作流演示常量
 *
 * @author ddss
 */
public class WorkflowConstants {

    /** 演示流程定义 Key */
    public static final String PROCESS_KEY = "leaveDemo";

    /** 请假单状态：待审批 */
    public static final String LEAVE_STATUS_PENDING = "0";

    /** 请假单状态：已通过 */
    public static final String LEAVE_STATUS_PASS = "1";

    /** 请假单状态：已驳回 */
    public static final String LEAVE_STATUS_REJECT = "2";

    /** 流程模型状态：草稿 */
    public static final String MODEL_STATUS_DRAFT = "0";

    /** 流程模型状态：已发布 */
    public static final String MODEL_STATUS_PUBLISHED = "1";

    /** 流程实例变量：一级审批人 */
    public static final String VAR_LEADER = "leader";

    /** 流程实例变量：二级审批人 */
    public static final String VAR_BOSS = "boss";

    /** 流程实例变量：审批结果 */
    public static final String VAR_APPROVED = "approved";

    /** 流程实例变量：审批意见 */
    public static final String VAR_COMMENT = "comment";

    /** 任务本地变量：审批结果（已办记录用） */
    public static final String VAR_APPROVED_LOCAL = "approvedLocal";

    /** 任务本地变量：审批意见（已办记录用） */
    public static final String VAR_COMMENT_LOCAL = "commentLocal";

    private WorkflowConstants() {
    }

}
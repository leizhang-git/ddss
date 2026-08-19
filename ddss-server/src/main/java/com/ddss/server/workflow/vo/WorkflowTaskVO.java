package com.ddss.server.workflow.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.Date;

/**
 * 工作流任务（待办/已办）视图对象
 *
 * @author ddss
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class WorkflowTaskVO {

    /** 任务ID */
    private String taskId;

    /** 任务名称（审批节点） */
    private String taskName;

    /** 流程实例ID */
    private String processInstanceId;

    /** 任务创建时间 */
    private Date taskCreateTime;

    /** 请假单ID */
    private Long leaveId;

    /** 申请人账号 */
    private String applicant;

    /** 申请人姓名 */
    private String applyUserName;

    /** 请假天数 */
    private Integer leaveDays;

    /** 开始日期 */
    private LocalDate startDate;

    /** 请假事由 */
    private String reason;

    /** 一级审批人 */
    private String leader;

    /** 二级审批人 */
    private String boss;

    /** 审批结论（已办：true通过 / false驳回） */
    private Boolean approved;

    /** 审批意见（已办） */
    private String comment;

    /** 完成时间（已办） */
    private Date finishTime;

}
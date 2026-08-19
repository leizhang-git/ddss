package com.ddss.server.workflow.vo;

import lombok.Data;

/**
 * 任务审批请求体
 *
 * @author ddss
 */
@Data
public class WorkflowApproveBody {

    /** 任务ID */
    private String taskId;

    /** 审批结果（true通过 / false驳回） */
    private Boolean approved;

    /** 审批意见 */
    private String comment;

}
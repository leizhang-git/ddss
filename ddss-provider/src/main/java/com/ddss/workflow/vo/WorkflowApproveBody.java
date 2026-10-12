package com.ddss.workflow.vo;

/** 任务审批请求体 */
public class WorkflowApproveBody {
    private String taskId;
    private Boolean approved;
    private String comment;
    public String getTaskId() { return taskId; }
    public void setTaskId(String value) { taskId = value; }
    public Boolean getApproved() { return approved; }
    public void setApproved(Boolean value) { approved = value; }
    public String getComment() { return comment; }
    public void setComment(String value) { comment = value; }
}

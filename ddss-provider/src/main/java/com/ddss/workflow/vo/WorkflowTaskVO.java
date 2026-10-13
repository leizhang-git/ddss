package com.ddss.workflow.vo;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Date;

/** 工作流任务（待办/已办）视图对象 */
public class WorkflowTaskVO {
    private String taskId;
    private String taskName;
    private String processInstanceId;
    private Date taskCreateTime;
    private Long leaveId;
    private String applicant;
    private String applyUserName;
    private BigDecimal leaveDays;
    private LocalDate startDate;
    private String reason;
    private String leader;
    private String boss;
    private Boolean approved;
    private String comment;
    private Date finishTime;

    public WorkflowTaskVO() {}
    public WorkflowTaskVO(String taskId, String taskName, String processInstanceId, Date taskCreateTime, Long leaveId,
                          String applicant, String applyUserName, BigDecimal leaveDays, LocalDate startDate, String reason,
                          String leader, String boss, Boolean approved, String comment, Date finishTime) {
        this.taskId = taskId; this.taskName = taskName; this.processInstanceId = processInstanceId;
        this.taskCreateTime = taskCreateTime; this.leaveId = leaveId; this.applicant = applicant;
        this.applyUserName = applyUserName; this.leaveDays = leaveDays; this.startDate = startDate;
        this.reason = reason; this.leader = leader; this.boss = boss; this.approved = approved;
        this.comment = comment; this.finishTime = finishTime;
    }
    public String getTaskId() { return taskId; }
    public void setTaskId(String value) { taskId = value; }
    public String getTaskName() { return taskName; }
    public void setTaskName(String value) { taskName = value; }
    public String getProcessInstanceId() { return processInstanceId; }
    public void setProcessInstanceId(String value) { processInstanceId = value; }
    public Date getTaskCreateTime() { return taskCreateTime; }
    public void setTaskCreateTime(Date value) { taskCreateTime = value; }
    public Long getLeaveId() { return leaveId; }
    public void setLeaveId(Long value) { leaveId = value; }
    public String getApplicant() { return applicant; }
    public void setApplicant(String value) { applicant = value; }
    public String getApplyUserName() { return applyUserName; }
    public void setApplyUserName(String value) { applyUserName = value; }
    public BigDecimal getLeaveDays() { return leaveDays; }
    public void setLeaveDays(BigDecimal value) { leaveDays = value; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate value) { startDate = value; }
    public String getReason() { return reason; }
    public void setReason(String value) { reason = value; }
    public String getLeader() { return leader; }
    public void setLeader(String value) { leader = value; }
    public String getBoss() { return boss; }
    public void setBoss(String value) { boss = value; }
    public Boolean getApproved() { return approved; }
    public void setApproved(Boolean value) { approved = value; }
    public String getComment() { return comment; }
    public void setComment(String value) { comment = value; }
    public Date getFinishTime() { return finishTime; }
    public void setFinishTime(Date value) { finishTime = value; }
}

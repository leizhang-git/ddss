package com.ddss.workflow.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 请假申请单（工作流演示业务表） */
@TableName(value = "ddss_leave")
public class DdssLeave {
    @TableId(value = "leave_id", type = IdType.AUTO)
    private Long leaveId;
    @TableField(value = "apply_user")
    private String applyUser;
    @TableField(value = "apply_user_name")
    private String applyUserName;
    @TableField(value = "leave_days")
    private BigDecimal leaveDays;
    @TableField(value = "start_date")
    private LocalDate startDate;
    @TableField(value = "reason")
    private String reason;
    @TableField(value = "leader")
    private String leader;
    @TableField(value = "boss")
    private String boss;
    @TableField(value = "process_instance_id")
    private String processInstanceId;
    @TableField(value = "status")
    private String status;
    @TableField(value = "create_by")
    private String createBy;
    @TableField(value = "create_time")
    private LocalDateTime createTime;
    @TableField(value = "update_by")
    private String updateBy;
    @TableField(value = "update_time")
    private LocalDateTime updateTime;

    public DdssLeave() {}

    public DdssLeave(Long leaveId, String applyUser, String applyUserName, BigDecimal leaveDays, LocalDate startDate,
                     String reason, String leader, String boss, String processInstanceId, String status,
                     String createBy, LocalDateTime createTime, String updateBy, LocalDateTime updateTime) {
        this.leaveId = leaveId; this.applyUser = applyUser; this.applyUserName = applyUserName;
        this.leaveDays = leaveDays; this.startDate = startDate; this.reason = reason; this.leader = leader;
        this.boss = boss; this.processInstanceId = processInstanceId; this.status = status; this.createBy = createBy;
        this.createTime = createTime; this.updateBy = updateBy; this.updateTime = updateTime;
    }

    public Long getLeaveId() { return leaveId; }
    public void setLeaveId(Long value) { this.leaveId = value; }
    public String getApplyUser() { return applyUser; }
    public void setApplyUser(String value) { this.applyUser = value; }
    public String getApplyUserName() { return applyUserName; }
    public void setApplyUserName(String value) { this.applyUserName = value; }
    public BigDecimal getLeaveDays() { return leaveDays; }
    public void setLeaveDays(BigDecimal value) { this.leaveDays = value; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate value) { this.startDate = value; }
    public String getReason() { return reason; }
    public void setReason(String value) { this.reason = value; }
    public String getLeader() { return leader; }
    public void setLeader(String value) { this.leader = value; }
    public String getBoss() { return boss; }
    public void setBoss(String value) { this.boss = value; }
    public String getProcessInstanceId() { return processInstanceId; }
    public void setProcessInstanceId(String value) { this.processInstanceId = value; }
    public String getStatus() { return status; }
    public void setStatus(String value) { this.status = value; }
    public String getCreateBy() { return createBy; }
    public void setCreateBy(String value) { this.createBy = value; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime value) { this.createTime = value; }
    public String getUpdateBy() { return updateBy; }
    public void setUpdateBy(String value) { this.updateBy = value; }
    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime value) { this.updateTime = value; }
}

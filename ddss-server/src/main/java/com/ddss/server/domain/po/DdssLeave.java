package com.ddss.server.domain.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 请假申请单（工作流演示业务表）
 *
 * @author ddss
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName(value = "ddss_leave")
public class DdssLeave {

    /**
     * 请假单ID
     */
    @TableId(value = "leave_id", type = IdType.AUTO)
    private Long leaveId;

    /**
     * 申请人账号
     */
    @TableField(value = "apply_user")
    private String applyUser;

    /**
     * 申请人姓名
     */
    @TableField(value = "apply_user_name")
    private String applyUserName;

    /**
     * 请假天数
     */
    @TableField(value = "leave_days")
    private Integer leaveDays;

    /**
     * 开始日期
     */
    @TableField(value = "start_date")
    private LocalDate startDate;

    /**
     * 请假事由
     */
    @TableField(value = "reason")
    private String reason;

    /**
     * 一级审批人（部门经理）账号
     */
    @TableField(value = "leader")
    private String leader;

    /**
     * 二级审批人（总经理）账号
     */
    @TableField(value = "boss")
    private String boss;

    /**
     * 流程实例ID
     */
    @TableField(value = "process_instance_id")
    private String processInstanceId;

    /**
     * 状态（0待审批 1已通过 2已驳回）
     */
    @TableField(value = "status")
    private String status;

    /**
     * 创建者
     */
    @TableField(value = "create_by")
    private String createBy;

    /**
     * 创建时间
     */
    @TableField(value = "create_time")
    private LocalDateTime createTime;

    /**
     * 更新者
     */
    @TableField(value = "update_by")
    private String updateBy;

    /**
     * 更新时间
     */
    @TableField(value = "update_time")
    private LocalDateTime updateTime;

}
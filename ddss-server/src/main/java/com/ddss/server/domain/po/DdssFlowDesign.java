package com.ddss.server.domain.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 流程模型（设计器保存的 BPMN 模型）
 *
 * @author ddss
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName(value = "ddss_flow_design")
public class DdssFlowDesign {

    /**
     * 流程模型ID
     */
    @TableId(value = "flow_id", type = IdType.AUTO)
    private Long flowId;

    /**
     * 流程Key（BPMN 中 process 的 id）
     */
    @TableField(value = "flow_key")
    private String flowKey;

    /**
     * 流程名称
     */
    @TableField(value = "flow_name")
    private String flowName;

    /**
     * BPMN XML 内容
     */
    @TableField(value = "bpmn_xml")
    private String bpmnXml;

    /**
     * 版本号
     */
    @TableField(value = "version")
    private Integer version;

    /**
     * 状态（0草稿 1已发布）
     */
    @TableField(value = "status")
    private String status;

    /**
     * 最近一次发布的部署ID
     */
    @TableField(value = "deployment_id")
    private String deploymentId;

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
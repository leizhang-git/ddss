package com.ddss.workflow.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDateTime;

/**
 * 流程模型（设计器保存的 BPMN 模型）。
 *
 * <p>该实体使用显式访问器，避免 provider 的构建结果依赖 Lombok 注解处理顺序。</p>
 */
@TableName(value = "ddss_flow_design")
public class DdssFlowDesign {

    @TableId(value = "flow_id", type = IdType.AUTO)
    private Long flowId;
    @TableField(value = "flow_key")
    private String flowKey;
    @TableField(value = "flow_name")
    private String flowName;
    @TableField(value = "bpmn_xml")
    private String bpmnXml;
    @TableField(value = "version")
    private Integer version;
    @TableField(value = "status")
    private String status;
    @TableField(value = "deployment_id")
    private String deploymentId;
    @TableField(value = "create_by")
    private String createBy;
    @TableField(value = "create_time")
    private LocalDateTime createTime;
    @TableField(value = "update_by")
    private String updateBy;
    @TableField(value = "update_time")
    private LocalDateTime updateTime;

    public DdssFlowDesign() {
    }

    public DdssFlowDesign(Long flowId, String flowKey, String flowName, String bpmnXml, Integer version,
                          String status, String deploymentId, String createBy, LocalDateTime createTime,
                          String updateBy, LocalDateTime updateTime) {
        this.flowId = flowId;
        this.flowKey = flowKey;
        this.flowName = flowName;
        this.bpmnXml = bpmnXml;
        this.version = version;
        this.status = status;
        this.deploymentId = deploymentId;
        this.createBy = createBy;
        this.createTime = createTime;
        this.updateBy = updateBy;
        this.updateTime = updateTime;
    }

    public Long getFlowId() { return flowId; }
    public void setFlowId(Long flowId) { this.flowId = flowId; }
    public String getFlowKey() { return flowKey; }
    public void setFlowKey(String flowKey) { this.flowKey = flowKey; }
    public String getFlowName() { return flowName; }
    public void setFlowName(String flowName) { this.flowName = flowName; }
    public String getBpmnXml() { return bpmnXml; }
    public void setBpmnXml(String bpmnXml) { this.bpmnXml = bpmnXml; }
    public Integer getVersion() { return version; }
    public void setVersion(Integer version) { this.version = version; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getDeploymentId() { return deploymentId; }
    public void setDeploymentId(String deploymentId) { this.deploymentId = deploymentId; }
    public String getCreateBy() { return createBy; }
    public void setCreateBy(String createBy) { this.createBy = createBy; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public String getUpdateBy() { return updateBy; }
    public void setUpdateBy(String updateBy) { this.updateBy = updateBy; }
    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }
}

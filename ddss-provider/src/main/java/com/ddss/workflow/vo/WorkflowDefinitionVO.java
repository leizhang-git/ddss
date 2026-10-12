package com.ddss.workflow.vo;

import java.util.Date;

/** 流程定义视图对象 */
public class WorkflowDefinitionVO {
    private String definitionId;
    private String key;
    private String name;
    private Integer version;
    private String deploymentId;
    private String resourceName;
    private String category;
    private Date deploymentTime;

    public WorkflowDefinitionVO() {}
    public WorkflowDefinitionVO(String definitionId, String key, String name, Integer version, String deploymentId,
                                String resourceName, String category, Date deploymentTime) {
        this.definitionId = definitionId; this.key = key; this.name = name; this.version = version;
        this.deploymentId = deploymentId; this.resourceName = resourceName; this.category = category;
        this.deploymentTime = deploymentTime;
    }
    public String getDefinitionId() { return definitionId; }
    public void setDefinitionId(String value) { definitionId = value; }
    public String getKey() { return key; }
    public void setKey(String value) { key = value; }
    public String getName() { return name; }
    public void setName(String value) { name = value; }
    public Integer getVersion() { return version; }
    public void setVersion(Integer value) { version = value; }
    public String getDeploymentId() { return deploymentId; }
    public void setDeploymentId(String value) { deploymentId = value; }
    public String getResourceName() { return resourceName; }
    public void setResourceName(String value) { resourceName = value; }
    public String getCategory() { return category; }
    public void setCategory(String value) { category = value; }
    public Date getDeploymentTime() { return deploymentTime; }
    public void setDeploymentTime(Date value) { deploymentTime = value; }
}

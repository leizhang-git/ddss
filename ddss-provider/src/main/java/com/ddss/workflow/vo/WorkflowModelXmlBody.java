package com.ddss.workflow.vo;

/** 流程模型保存 XML 请求体 */
public class WorkflowModelXmlBody {
    private Long flowId;
    private String bpmnXml;
    public Long getFlowId() { return flowId; }
    public void setFlowId(Long value) { flowId = value; }
    public String getBpmnXml() { return bpmnXml; }
    public void setBpmnXml(String value) { bpmnXml = value; }
}

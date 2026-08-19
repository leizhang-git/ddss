package com.ddss.server.workflow.vo;

import lombok.Data;

/**
 * 流程模型保存 XML 请求体
 *
 * @author ddss
 */
@Data
public class WorkflowModelXmlBody {

    /** 流程模型ID */
    private Long flowId;

    /** BPMN XML 内容 */
    private String bpmnXml;

}
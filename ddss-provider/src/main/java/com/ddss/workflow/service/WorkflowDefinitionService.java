package com.ddss.workflow.service;

import com.ddss.workflow.vo.WorkflowDefinitionVO;
import com.ddss.workflow.vo.WorkflowPage;

/**
 * 流程定义服务
 *
 * @author ddss
 */
public interface WorkflowDefinitionService {

    /**
     * 流程定义分页列表（仅最新版本）
     */
    WorkflowPage<WorkflowDefinitionVO> selectDefinitionList(int pageNum, int pageSize);

    /**
     * 部署流程定义（BPMN 内容）
     *
     * @return 部署ID
     */
    String deployProcess(String fileName, String content);

    /**
     * 删除流程定义（级联删除历史；拒绝删除包含运行实例的任一部署）
     */
    void deleteDefinition(String deploymentIds);

    /**
     * 查看流程定义 XML 内容
     */
    String getDefinitionXml(String deploymentId, String resourceName);

}
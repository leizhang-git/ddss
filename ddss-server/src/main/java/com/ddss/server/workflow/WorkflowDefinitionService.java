package com.ddss.server.workflow;

import com.ddss.server.workflow.vo.WorkflowDefinitionVO;
import com.ddss.server.workflow.vo.WorkflowPage;

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
     * 删除流程定义（级联删除运行实例）
     */
    void deleteDefinition(String deploymentId);

    /**
     * 查看流程定义 XML 内容
     */
    String getDefinitionXml(String deploymentId, String resourceName);

}
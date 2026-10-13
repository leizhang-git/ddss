package com.ddss.workflow.service.impl;

import com.ddss.application.workflow.DeleteWorkflowDeployments;
import com.ddss.application.workflow.DeploymentDeletionResult;
import com.ddss.workflow.service.WorkflowDefinitionService;

import com.ddss.common.exception.ServiceException;
import com.ddss.common.utils.StringUtils;
import com.ddss.workflow.vo.WorkflowDefinitionVO;
import com.ddss.workflow.vo.WorkflowPage;
import org.flowable.engine.RepositoryService;
import org.flowable.engine.repository.Deployment;
import org.flowable.engine.repository.ProcessDefinition;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * 流程定义服务实现
 *
 * @author ddss
 */
@Service
public class WorkflowDefinitionServiceImpl implements WorkflowDefinitionService {

    @Autowired
    private RepositoryService repositoryService;

    @Autowired
    private DeleteWorkflowDeployments deleteWorkflowDeployments;

    @Override
    public WorkflowPage<WorkflowDefinitionVO> selectDefinitionList(int pageNum, int pageSize) {
        long total = repositoryService.createProcessDefinitionQuery().latestVersion().count();
        List<ProcessDefinition> definitions = repositoryService.createProcessDefinitionQuery()
                .latestVersion()
                .orderByProcessDefinitionKey().asc()
                .listPage((pageNum - 1) * pageSize, pageSize);
        List<WorkflowDefinitionVO> rows = new ArrayList<>();
        for (ProcessDefinition definition : definitions) {
            rows.add(toVO(definition));
        }
        return new WorkflowPage<>(total, rows);
    }

    @Override
    public String deployProcess(String fileName, String content) {
        if (StringUtils.isEmpty(fileName) || StringUtils.isEmpty(content)) {
            throw new ServiceException("BPMN 内容不能为空");
        }
        Deployment deployment = repositoryService.createDeployment()
                .name(fileName)
                .addString(fileName, content)
                .deploy();
        return deployment.getId();
    }

    @Override
    @org.springframework.transaction.annotation.Transactional(rollbackFor = Exception.class)
    public void deleteDefinition(String deploymentIds) {
        DeploymentDeletionResult result = deleteWorkflowDeployments.execute(deploymentIds);
        if (result instanceof DeploymentDeletionResult.Rejected) {
            DeploymentDeletionResult.Rejected rejection = (DeploymentDeletionResult.Rejected) result;
            throw new ServiceException(switch (rejection.reason()) {
                case DEPLOYMENT_ID_REQUIRED -> "部署ID不能为空";
                case DEPLOYMENT_NOT_FOUND -> "流程部署不存在: " + rejection.deploymentId();
                case RUNNING_INSTANCES -> "流程定义存在运行中的实例，无法删除";
            });
        }
    }

    @Override
    public String getDefinitionXml(String deploymentId, String resourceName) {
        InputStream inputStream = repositoryService.getResourceAsStream(deploymentId, resourceName);
        if (inputStream == null) {
            throw new ServiceException("未找到流程定义资源: " + resourceName);
        }
        try (InputStream stream = inputStream) {
            return StreamUtils.copyToString(stream, StandardCharsets.UTF_8);
        } catch (Exception e) {
            ServiceException exception = new ServiceException("读取流程定义内容失败");
            exception.initCause(e);
            throw exception;
        }
    }

    private WorkflowDefinitionVO toVO(ProcessDefinition definition) {
        WorkflowDefinitionVO vo = new WorkflowDefinitionVO();
        vo.setDefinitionId(definition.getId());
        vo.setKey(definition.getKey());
        vo.setName(definition.getName());
        vo.setVersion(definition.getVersion());
        vo.setDeploymentId(definition.getDeploymentId());
        vo.setResourceName(definition.getResourceName());
        vo.setCategory(definition.getCategory());
        Deployment deployment = repositoryService.createDeploymentQuery()
                .deploymentId(definition.getDeploymentId()).singleResult();
        if (deployment != null) {
            vo.setDeploymentTime(deployment.getDeploymentTime());
        }
        return vo;
    }

}
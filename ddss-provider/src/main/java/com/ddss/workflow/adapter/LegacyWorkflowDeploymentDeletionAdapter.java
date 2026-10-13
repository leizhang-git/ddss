package com.ddss.workflow.adapter;

import com.ddss.application.workflow.WorkflowDeploymentDeletionPort;
import com.ddss.application.workflow.WorkflowDeploymentSnapshot;
import org.flowable.engine.RepositoryService;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.repository.ProcessDefinition;

import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

public final class LegacyWorkflowDeploymentDeletionAdapter implements WorkflowDeploymentDeletionPort {
    private final RepositoryService repositoryService;
    private final RuntimeService runtimeService;

    public LegacyWorkflowDeploymentDeletionAdapter(RepositoryService repositoryService, RuntimeService runtimeService) {
        this.repositoryService = Objects.requireNonNull(repositoryService, "repositoryService");
        this.runtimeService = Objects.requireNonNull(runtimeService, "runtimeService");
    }

    @Override
    public Optional<WorkflowDeploymentSnapshot> find(String deploymentId) {
        if (repositoryService.createDeploymentQuery().deploymentId(deploymentId).singleResult() == null) {
            return Optional.empty();
        }
        List<String> processDefinitionIds = repositoryService.createProcessDefinitionQuery()
                .deploymentId(deploymentId)
                .list()
                .stream()
                .map(ProcessDefinition::getId)
                .collect(Collectors.toList());
        return Optional.of(new WorkflowDeploymentSnapshot(deploymentId, processDefinitionIds));
    }

    @Override
    public boolean hasRunningInstances(String processDefinitionId) {
        return runtimeService.createProcessInstanceQuery().processDefinitionId(processDefinitionId).count() > 0;
    }

    @Override
    public void deleteCascade(String deploymentId) {
        repositoryService.deleteDeployment(deploymentId, true);
    }
}

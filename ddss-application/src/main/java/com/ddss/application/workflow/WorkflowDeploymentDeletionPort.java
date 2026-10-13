package com.ddss.application.workflow;

import java.util.Optional;

public interface WorkflowDeploymentDeletionPort {
    Optional<WorkflowDeploymentSnapshot> find(String deploymentId);

    boolean hasRunningInstances(String processDefinitionId);

    void deleteCascade(String deploymentId);
}

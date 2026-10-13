package com.ddss.application.workflow;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;

public final class DeleteWorkflowDeployments {
    private final WorkflowDeploymentDeletionPort deployments;

    public DeleteWorkflowDeployments(WorkflowDeploymentDeletionPort deployments) {
        this.deployments = Objects.requireNonNull(deployments, "deployments");
    }

    public DeploymentDeletionResult execute(String deploymentIds) {
        if (deploymentIds == null || deploymentIds.trim().isEmpty()) {
            return new DeploymentDeletionResult.Rejected(DeploymentDeletionResult.Reason.DEPLOYMENT_ID_REQUIRED, null);
        }

        Set<String> ids = new LinkedHashSet<>();
        for (String value : deploymentIds.split(",", -1)) {
            String deploymentId = value.trim();
            if (deploymentId.isEmpty()) {
                return new DeploymentDeletionResult.Rejected(
                        DeploymentDeletionResult.Reason.DEPLOYMENT_ID_REQUIRED, null);
            }
            ids.add(deploymentId);
        }

        List<WorkflowDeploymentSnapshot> found = new ArrayList<>();
        for (String deploymentId : ids) {
            var deployment = deployments.find(deploymentId);
            if (deployment.isEmpty()) {
                return new DeploymentDeletionResult.Rejected(
                        DeploymentDeletionResult.Reason.DEPLOYMENT_NOT_FOUND, deploymentId);
            }
            for (String processDefinitionId : deployment.get().processDefinitionIds()) {
                if (deployments.hasRunningInstances(processDefinitionId)) {
                    return new DeploymentDeletionResult.Rejected(
                            DeploymentDeletionResult.Reason.RUNNING_INSTANCES, null);
                }
            }
            found.add(deployment.get());
        }

        for (WorkflowDeploymentSnapshot deployment : found) {
            deployments.deleteCascade(deployment.deploymentId());
        }
        return new DeploymentDeletionResult.Deleted();
    }
}

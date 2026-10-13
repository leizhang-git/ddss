package com.ddss.application.workflow;

import java.util.List;
import java.util.Objects;

public record WorkflowDeploymentSnapshot(String deploymentId, List<String> processDefinitionIds) {
    public WorkflowDeploymentSnapshot {
        if (deploymentId == null || deploymentId.isBlank()) {
            throw new IllegalArgumentException("deploymentId must not be blank");
        }
        processDefinitionIds = List.copyOf(Objects.requireNonNull(processDefinitionIds, "processDefinitionIds"));
    }
}

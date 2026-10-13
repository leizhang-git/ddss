package com.ddss.application.workflow;

public sealed interface DeploymentDeletionResult
        permits DeploymentDeletionResult.Deleted, DeploymentDeletionResult.Rejected {
    record Deleted() implements DeploymentDeletionResult { }

    record Rejected(Reason reason, String deploymentId) implements DeploymentDeletionResult { }

    enum Reason {
        DEPLOYMENT_ID_REQUIRED,
        DEPLOYMENT_NOT_FOUND,
        RUNNING_INSTANCES
    }
}

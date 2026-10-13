package com.ddss.application.workflow;

import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class DeleteWorkflowDeploymentsTest {
    @Test
    void rejectsWholeBatchBeforeDeletingWhenAnyDefinitionHasRunningInstances() {
        RecordingPort port = new RecordingPort();
        port.deployments.put("d1", new WorkflowDeploymentSnapshot("d1", List.of("p1")));
        port.deployments.put("d2", new WorkflowDeploymentSnapshot("d2", List.of("p2")));
        port.running.put("p2", true);

        DeploymentDeletionResult result = new DeleteWorkflowDeployments(port).execute("d1,d2");

        assertEquals(new DeploymentDeletionResult.Rejected(
                DeploymentDeletionResult.Reason.RUNNING_INSTANCES, null), result);
        assertEquals(List.of("find:d1", "running:p1", "find:d2", "running:p2"), port.calls);
    }

    @Test
    void trimsDeduplicatesAndDeletesOnlyAfterPreflightingEveryDeployment() {
        RecordingPort port = new RecordingPort();
        port.deployments.put("d1", new WorkflowDeploymentSnapshot("d1", List.of("p1")));
        port.deployments.put("d2", new WorkflowDeploymentSnapshot("d2", List.of("p2", "p3")));

        DeploymentDeletionResult result = new DeleteWorkflowDeployments(port).execute(" d1, d2,d1 ");

        assertTrue(result instanceof DeploymentDeletionResult.Deleted);
        assertEquals(List.of("find:d1", "running:p1", "find:d2", "running:p2", "running:p3",
                "delete:d1", "delete:d2"), port.calls);
    }

    @Test
    void rejectsBlankIdsAndMissingDeploymentWithoutDeleting() {
        RecordingPort port = new RecordingPort();

        assertEquals(new DeploymentDeletionResult.Rejected(
                DeploymentDeletionResult.Reason.DEPLOYMENT_ID_REQUIRED, null),
                new DeleteWorkflowDeployments(port).execute("d1,,d2"));
        assertTrue(port.calls.isEmpty());

        assertEquals(new DeploymentDeletionResult.Rejected(
                DeploymentDeletionResult.Reason.DEPLOYMENT_NOT_FOUND, "missing"),
                new DeleteWorkflowDeployments(port).execute("missing"));
        assertEquals(List.of("find:missing"), port.calls);
    }

    private static final class RecordingPort implements WorkflowDeploymentDeletionPort {
        private final Map<String, WorkflowDeploymentSnapshot> deployments = new HashMap<>();
        private final Map<String, Boolean> running = new HashMap<>();
        private final List<String> calls = new ArrayList<>();

        @Override
        public Optional<WorkflowDeploymentSnapshot> find(String deploymentId) {
            calls.add("find:" + deploymentId);
            return Optional.ofNullable(deployments.get(deploymentId));
        }

        @Override
        public boolean hasRunningInstances(String processDefinitionId) {
            calls.add("running:" + processDefinitionId);
            return running.getOrDefault(processDefinitionId, false);
        }

        @Override
        public void deleteCascade(String deploymentId) {
            calls.add("delete:" + deploymentId);
        }
    }
}

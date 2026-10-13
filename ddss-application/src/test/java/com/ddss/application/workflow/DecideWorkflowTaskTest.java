package com.ddss.application.workflow;

import com.ddss.domain.workflow.LeaveStatus;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class DecideWorkflowTaskTest {
    @Test
    void requiresTaskIdDecisionAndActorBeforeCallingPorts() {
        RecordingApprovalPort port = new RecordingApprovalPort();
        DecideWorkflowTask useCase = new DecideWorkflowTask(port);

        assertRejected(useCase.execute(null), DecisionResult.Reason.TASK_ID_REQUIRED);
        assertRejected(useCase.execute(new DecideWorkflowTask.DecisionCommand(" ", true, null, "alice")),
                DecisionResult.Reason.TASK_ID_REQUIRED);
        assertRejected(useCase.execute(new DecideWorkflowTask.DecisionCommand("task-1", null, null, "alice")),
                DecisionResult.Reason.DECISION_REQUIRED);
        assertRejected(useCase.execute(new DecideWorkflowTask.DecisionCommand("task-1", true, null, " ")),
                DecisionResult.Reason.ACTOR_REQUIRED);
        assertTrue(port.calls.isEmpty());
    }

    @Test
    void rejectsMissingOrUnassignedTaskWithoutCompletingIt() {
        RecordingApprovalPort port = new RecordingApprovalPort();
        DecideWorkflowTask useCase = new DecideWorkflowTask(port);

        port.task = Optional.empty();
        assertRejected(useCase.execute(command("alice", true)), DecisionResult.Reason.TASK_NOT_FOUND);

        port.task = Optional.of(new WorkflowTaskSnapshot("task-1", "process-1", "bob"));
        assertRejected(useCase.execute(command("alice", true)), DecisionResult.Reason.NOT_ASSIGNEE);
        assertTrue(port.calls.isEmpty());
    }

    @Test
    void doesNotSetFinalLeaveStatusWhileAnotherApprovalTaskIsRunning() {
        RecordingApprovalPort port = new RecordingApprovalPort();
        port.running = true;

        DecisionResult result = new DecideWorkflowTask(port).execute(command("alice", true));

        assertTrue(result instanceof DecisionResult.Completed);
        assertEquals("complete:task-1:true:Reason;running:process-1", String.join(";", port.calls));
    }

    @Test
    void updatesFinalLeaveStatusOnlyAfterTerminalApprovalOrRejection() {
        RecordingApprovalPort port = new RecordingApprovalPort();
        port.running = false;
        DecideWorkflowTask useCase = new DecideWorkflowTask(port);

        assertTrue(useCase.execute(command("alice", true)) instanceof DecisionResult.Completed);
        assertEquals("complete:task-1:true:Reason;running:process-1;status:APPROVED:alice",
                String.join(";", port.calls));

        port.calls.clear();
        assertTrue(useCase.execute(command("alice", false)) instanceof DecisionResult.Completed);
        assertEquals("complete:task-1:false:Reason;running:process-1;status:REJECTED:alice",
                String.join(";", port.calls));
    }

    private DecideWorkflowTask.DecisionCommand command(String actor, Boolean approved) {
        return new DecideWorkflowTask.DecisionCommand("task-1", approved, "Reason", actor);
    }

    private void assertRejected(DecisionResult result, DecisionResult.Reason reason) {
        assertTrue(result instanceof DecisionResult.Rejected);
        assertEquals(reason, ((DecisionResult.Rejected) result).reason());
    }

    private static final class RecordingApprovalPort implements WorkflowApprovalPort {
        private Optional<WorkflowTaskSnapshot> task =
                Optional.of(new WorkflowTaskSnapshot("task-1", "process-1", "alice"));
        private final java.util.List<String> calls = new java.util.ArrayList<>();
        private boolean running;

        @Override
        public Optional<WorkflowTaskSnapshot> findActiveTask(String taskId) {
            return task;
        }

        @Override
        public void completeTask(String taskId, boolean approved, String comment) {
            calls.add("complete:" + taskId + ":" + approved + ":" + comment);
        }

        @Override
        public boolean isProcessRunning(String processInstanceId) {
            calls.add("running:" + processInstanceId);
            return running;
        }

        @Override
        public void updateLeaveStatus(String processInstanceId, LeaveStatus status, String actor) {
            calls.add("status:" + status + ":" + actor);
        }
    }
}

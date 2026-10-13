package com.ddss.application.workflow;

import com.ddss.domain.workflow.LeaveStatus;

import java.util.Objects;
import java.util.Optional;

public final class DecideWorkflowTask {
    private final WorkflowApprovalPort approvals;

    public DecideWorkflowTask(WorkflowApprovalPort approvals) {
        this.approvals = Objects.requireNonNull(approvals, "approvals");
    }

    public DecisionResult execute(DecisionCommand command) {
        if (command == null || isBlank(command.taskId())) {
            return new DecisionResult.Rejected(DecisionResult.Reason.TASK_ID_REQUIRED);
        }
        if (command.approved() == null) {
            return new DecisionResult.Rejected(DecisionResult.Reason.DECISION_REQUIRED);
        }
        if (isBlank(command.actor())) {
            return new DecisionResult.Rejected(DecisionResult.Reason.ACTOR_REQUIRED);
        }

        Optional<WorkflowTaskSnapshot> activeTask = approvals.findActiveTask(command.taskId());
        if (activeTask.isEmpty()) {
            return new DecisionResult.Rejected(DecisionResult.Reason.TASK_NOT_FOUND);
        }
        WorkflowTaskSnapshot task = activeTask.get();
        if (task.assignee() == null || !task.assignee().equals(command.actor())) {
            return new DecisionResult.Rejected(DecisionResult.Reason.NOT_ASSIGNEE);
        }

        approvals.completeTask(task.taskId(), command.approved(), command.comment());
        if (!approvals.isProcessRunning(task.processInstanceId())) {
            approvals.updateLeaveStatus(task.processInstanceId(),
                    command.approved() ? LeaveStatus.APPROVED : LeaveStatus.REJECTED, command.actor());
        }
        return new DecisionResult.Completed();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public record DecisionCommand(String taskId, Boolean approved, String comment, String actor) { }
}

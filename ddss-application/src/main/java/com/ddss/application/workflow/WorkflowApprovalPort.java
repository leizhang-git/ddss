package com.ddss.application.workflow;

import com.ddss.domain.workflow.LeaveStatus;

import java.util.Optional;

public interface WorkflowApprovalPort {
    Optional<WorkflowTaskSnapshot> findActiveTask(String taskId);

    void completeTask(String taskId, boolean approved, String comment);

    boolean isProcessRunning(String processInstanceId);

    void updateLeaveStatus(String processInstanceId, LeaveStatus status, String actor);
}

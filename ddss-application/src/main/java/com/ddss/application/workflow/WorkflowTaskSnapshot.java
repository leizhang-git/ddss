package com.ddss.application.workflow;

import java.util.Objects;

public record WorkflowTaskSnapshot(String taskId, String processInstanceId, String assignee) {
    public WorkflowTaskSnapshot {
        taskId = requireText(taskId, "taskId");
        processInstanceId = requireText(processInstanceId, "processInstanceId");
        assignee = assignee == null ? null : assignee.trim();
    }

    private static String requireText(String value, String name) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(name + " is required");
        }
        return Objects.requireNonNull(value).trim();
    }
}

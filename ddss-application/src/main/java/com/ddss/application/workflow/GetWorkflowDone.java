package com.ddss.application.workflow;

import java.util.Objects;

public final class GetWorkflowDone {
    private final WorkflowTaskQueryPort tasks;

    public GetWorkflowDone(WorkflowTaskQueryPort tasks) {
        this.tasks = Objects.requireNonNull(tasks, "tasks");
    }

    public WorkflowTaskPage execute(String actor, int pageNum, int pageSize) {
        return tasks.findDone(actor, pageNum, pageSize);
    }
}

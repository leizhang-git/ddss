package com.ddss.application.workflow;

import java.util.Objects;

public final class GetWorkflowTodo {
    private final WorkflowTaskQueryPort tasks;

    public GetWorkflowTodo(WorkflowTaskQueryPort tasks) {
        this.tasks = Objects.requireNonNull(tasks, "tasks");
    }

    public WorkflowTaskPage execute(String actor, int pageNum, int pageSize) {
        return tasks.findTodo(actor, pageNum, pageSize);
    }
}

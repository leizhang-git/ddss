package com.ddss.application.workflow;

public interface WorkflowTaskQueryPort {
    WorkflowTaskPage findTodo(String actor, int pageNum, int pageSize);

    WorkflowTaskPage findDone(String actor, int pageNum, int pageSize);
}

package com.ddss.application.workflow;

import java.util.List;

public record WorkflowTaskPage(long total, List<WorkflowTaskRow> rows) {
    public WorkflowTaskPage {
        rows = List.copyOf(rows);
    }
}

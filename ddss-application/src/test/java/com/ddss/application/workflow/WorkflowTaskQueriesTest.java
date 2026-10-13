package com.ddss.application.workflow;

import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;

class WorkflowTaskQueriesTest {
    @Test
    void delegatesTodoQueryWithActorAndPaging() {
        WorkflowTaskPage page = new WorkflowTaskPage(1, List.of(row("task-1")));
        WorkflowTaskQueryPort port = new WorkflowTaskQueryPort() {
            @Override
            public WorkflowTaskPage findTodo(String actor, int pageNum, int pageSize) {
                assertEquals("alice", actor);
                assertEquals(2, pageNum);
                assertEquals(15, pageSize);
                return page;
            }

            @Override
            public WorkflowTaskPage findDone(String actor, int pageNum, int pageSize) {
                throw new AssertionError("done query was not expected");
            }
        };

        assertSame(page, new GetWorkflowTodo(port).execute("alice", 2, 15));
    }

    @Test
    void delegatesDoneQueryWithActorAndPaging() {
        WorkflowTaskPage page = new WorkflowTaskPage(1, List.of(row("task-2")));
        WorkflowTaskQueryPort port = new WorkflowTaskQueryPort() {
            @Override
            public WorkflowTaskPage findTodo(String actor, int pageNum, int pageSize) {
                throw new AssertionError("todo query was not expected");
            }

            @Override
            public WorkflowTaskPage findDone(String actor, int pageNum, int pageSize) {
                assertEquals("bob", actor);
                assertEquals(3, pageNum);
                assertEquals(20, pageSize);
                return page;
            }
        };

        assertSame(page, new GetWorkflowDone(port).execute("bob", 3, 20));
    }

    @Test
    void pageRowsAreImmutable() {
        var rows = new java.util.ArrayList<>(List.of(row("task-1")));
        WorkflowTaskPage page = new WorkflowTaskPage(1, rows);
        rows.clear();

        assertEquals(1, page.rows().size());
    }

    private WorkflowTaskRow row(String taskId) {
        return new WorkflowTaskRow(taskId, "Review", "process-1", Instant.parse("2026-10-13T01:00:00Z"),
                null, null, null, null, null, null, null, null, null, null, null);
    }
}

package com.ddss.workflow.adapter;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.ddss.workflow.WorkflowConstants;
import com.ddss.workflow.domain.DdssLeave;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import org.flowable.engine.HistoryService;
import org.flowable.engine.TaskService;
import org.flowable.task.api.Task;
import org.flowable.task.api.TaskQuery;
import org.flowable.task.api.history.HistoricTaskInstance;
import org.flowable.task.api.history.HistoricTaskInstanceQuery;
import org.flowable.variable.api.history.HistoricVariableInstance;
import org.flowable.variable.api.history.HistoricVariableInstanceQuery;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Date;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class LegacyWorkflowTaskQueryAdapterTest {
    @Test
    void queriesTodoForAssigneeAndMapsLeaveDetailsInBatch() {
        TaskService taskService = mock(TaskService.class);
        TaskQuery query = mock(TaskQuery.class);
        DdssLeaveMapper mapper = mock(DdssLeaveMapper.class);
        Task task = mock(Task.class);
        Date created = new Date(1_791_854_400_000L);
        when(taskService.createTaskQuery()).thenReturn(query, query);
        when(query.taskAssignee("alice")).thenReturn(query);
        when(query.orderByTaskCreateTime()).thenReturn(query);
        when(query.desc()).thenReturn(query);
        when(query.listPage(10, 5)).thenReturn(List.of(task));
        when(query.count()).thenReturn(7L);
        when(task.getId()).thenReturn("task-1");
        when(task.getName()).thenReturn("Manager approval");
        when(task.getProcessInstanceId()).thenReturn("process-1");
        when(task.getCreateTime()).thenReturn(created);
        DdssLeave leave = leave("process-1");
        when(mapper.selectList(any(QueryWrapper.class))).thenReturn(List.of(leave));

        var page = new LegacyWorkflowTaskQueryAdapter(taskService, mock(HistoryService.class), mapper)
                .findTodo("alice", 3, 5);

        assertEquals(7L, page.total());
        assertEquals(1, page.rows().size());
        assertEquals("task-1", page.rows().get(0).taskId());
        assertEquals(created.toInstant(), page.rows().get(0).taskCreateTime());
        assertEquals(12L, page.rows().get(0).leaveId());
        assertEquals(new BigDecimal("1.5"), page.rows().get(0).leaveDays());
        verify(query, org.mockito.Mockito.times(2)).taskAssignee("alice");
        verify(query).listPage(10, 5);
        verify(mapper).selectList(any(QueryWrapper.class));
    }

    @Test
    void queriesDoneTasksAndMapsLocalVariablesAndMissingLeave() {
        HistoryService historyService = mock(HistoryService.class);
        HistoricTaskInstanceQuery query = mock(HistoricTaskInstanceQuery.class);
        HistoricVariableInstanceQuery variableQuery = mock(HistoricVariableInstanceQuery.class);
        DdssLeaveMapper mapper = mock(DdssLeaveMapper.class);
        HistoricTaskInstance task = mock(HistoricTaskInstance.class);
        HistoricVariableInstance approved = variable("task-2", WorkflowConstants.VAR_APPROVED_LOCAL, false);
        HistoricVariableInstance comment = variable("task-2", WorkflowConstants.VAR_COMMENT_LOCAL, "Needs changes");
        HistoricVariableInstance processVariable = variable(null, "instanceOnly", "ignored");
        Date created = new Date(1_791_854_400_000L);
        Date finished = new Date(1_791_858_000_000L);
        when(historyService.createHistoricTaskInstanceQuery()).thenReturn(query, query);
        when(query.taskAssignee("bob")).thenReturn(query);
        when(query.finished()).thenReturn(query);
        when(query.orderByHistoricTaskInstanceEndTime()).thenReturn(query);
        when(query.desc()).thenReturn(query);
        when(query.listPage(0, 10)).thenReturn(List.of(task));
        when(query.count()).thenReturn(2L);
        when(task.getId()).thenReturn("task-2");
        when(task.getName()).thenReturn("Director approval");
        when(task.getProcessInstanceId()).thenReturn("process-2");
        when(task.getCreateTime()).thenReturn(created);
        when(task.getEndTime()).thenReturn(finished);
        when(historyService.createHistoricVariableInstanceQuery()).thenReturn(variableQuery);
        when(variableQuery.processInstanceId("process-2")).thenReturn(variableQuery);
        when(variableQuery.list()).thenReturn(List.of(approved, comment, processVariable));
        when(mapper.selectList(any(QueryWrapper.class))).thenReturn(List.of());

        var page = new LegacyWorkflowTaskQueryAdapter(mock(TaskService.class), historyService, mapper)
                .findDone("bob", 1, 10);

        assertEquals(2L, page.total());
        assertEquals("task-2", page.rows().get(0).taskId());
        assertEquals(created.toInstant(), page.rows().get(0).taskCreateTime());
        assertEquals(finished.toInstant(), page.rows().get(0).finishTime());
        assertEquals(Boolean.FALSE, page.rows().get(0).approved());
        assertEquals("Needs changes", page.rows().get(0).comment());
        assertNull(page.rows().get(0).leaveId());
        verify(query, org.mockito.Mockito.times(2)).taskAssignee("bob");
        verify(query, org.mockito.Mockito.times(2)).finished();
        verify(query).listPage(0, 10);
        verify(variableQuery).processInstanceId("process-2");
        verify(mapper).selectList(any(QueryWrapper.class));
    }

    @Test
    void avoidsLeaveQueryWhenTodoPageIsEmpty() {
        TaskService taskService = mock(TaskService.class);
        TaskQuery query = mock(TaskQuery.class);
        DdssLeaveMapper mapper = mock(DdssLeaveMapper.class);
        when(taskService.createTaskQuery()).thenReturn(query, query);
        when(query.taskAssignee("alice")).thenReturn(query);
        when(query.orderByTaskCreateTime()).thenReturn(query);
        when(query.desc()).thenReturn(query);
        when(query.listPage(0, 10)).thenReturn(List.of());
        when(query.count()).thenReturn(0L);

        var page = new LegacyWorkflowTaskQueryAdapter(taskService, mock(HistoryService.class), mapper)
                .findTodo("alice", 1, 10);

        assertEquals(0L, page.total());
        assertEquals(List.of(), page.rows());
        verify(mapper, org.mockito.Mockito.never()).selectList(any(QueryWrapper.class));
    }

    private DdssLeave leave(String processInstanceId) {
        DdssLeave leave = new DdssLeave();
        leave.setLeaveId(12L);
        leave.setApplyUser("alice");
        leave.setApplyUserName("Alice");
        leave.setLeaveDays(new BigDecimal("1.5"));
        leave.setStartDate(LocalDate.of(2026, 10, 13));
        leave.setReason("Personal");
        leave.setLeader("manager");
        leave.setBoss("director");
        leave.setProcessInstanceId(processInstanceId);
        return leave;
    }

    private HistoricVariableInstance variable(String taskId, String name, Object value) {
        HistoricVariableInstance variable = mock(HistoricVariableInstance.class);
        when(variable.getTaskId()).thenReturn(taskId);
        when(variable.getVariableName()).thenReturn(name);
        when(variable.getValue()).thenReturn(value);
        return variable;
    }
}

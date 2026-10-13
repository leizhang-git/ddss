package com.ddss.workflow.adapter;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.ddss.domain.workflow.LeaveStatus;
import com.ddss.workflow.WorkflowConstants;
import com.ddss.workflow.domain.DdssLeave;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.TaskService;
import org.flowable.engine.runtime.ProcessInstanceQuery;
import org.flowable.task.api.Task;
import org.flowable.task.api.TaskQuery;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class LegacyWorkflowApprovalAdapterTest {
    @Test
    void readsAssigneeAndProcessFromTheActiveFlowableTask() {
        TaskService taskService = mock(TaskService.class);
        TaskQuery taskQuery = mock(TaskQuery.class);
        Task task = mock(Task.class);
        when(taskService.createTaskQuery()).thenReturn(taskQuery);
        when(taskQuery.taskId("task-1")).thenReturn(taskQuery);
        when(taskQuery.singleResult()).thenReturn(task);
        when(task.getId()).thenReturn("task-1");
        when(task.getProcessInstanceId()).thenReturn("process-1");
        when(task.getAssignee()).thenReturn("alice");

        var snapshot = new LegacyWorkflowApprovalAdapter(taskService, mock(RuntimeService.class),
                mock(DdssLeaveMapper.class)).findActiveTask("task-1");

        assertTrue(snapshot.isPresent());
        assertEquals("task-1", snapshot.get().taskId());
        assertEquals("process-1", snapshot.get().processInstanceId());
        assertEquals("alice", snapshot.get().assignee());
    }

    @Test
    void writesProcessAndLocalAuditVariablesBeforeCompletingTheTask() {
        TaskService taskService = mock(TaskService.class);
        LegacyWorkflowApprovalAdapter adapter = new LegacyWorkflowApprovalAdapter(taskService,
                mock(RuntimeService.class), mock(DdssLeaveMapper.class));

        adapter.completeTask("task-1", false, "Rejected");

        verify(taskService).setVariable("task-1", WorkflowConstants.VAR_APPROVED, false);
        verify(taskService).setVariable("task-1", WorkflowConstants.VAR_COMMENT, "Rejected");
        verify(taskService).setVariableLocal("task-1", WorkflowConstants.VAR_APPROVED_LOCAL, false);
        verify(taskService).setVariableLocal("task-1", WorkflowConstants.VAR_COMMENT_LOCAL, "Rejected");
        verify(taskService).complete("task-1");
    }

    @Test
    void updatesLeaveStatusAndAuditActorOnlyWithTerminalDecision() {
        RuntimeService runtimeService = mock(RuntimeService.class);
        ProcessInstanceQuery query = mock(ProcessInstanceQuery.class);
        DdssLeaveMapper mapper = mock(DdssLeaveMapper.class);
        when(runtimeService.createProcessInstanceQuery()).thenReturn(query);
        when(query.processInstanceId("process-1")).thenReturn(query);
        when(query.count()).thenReturn(0L);
        DdssLeave leave = new DdssLeave();
        leave.setLeaveId(10L);
        when(mapper.selectOne(any(QueryWrapper.class))).thenReturn(leave);
        when(mapper.updateById(any(DdssLeave.class))).thenReturn(1);

        LegacyWorkflowApprovalAdapter adapter = new LegacyWorkflowApprovalAdapter(mock(TaskService.class),
                runtimeService, mapper);

        assertFalse(adapter.isProcessRunning("process-1"));
        adapter.updateLeaveStatus("process-1", LeaveStatus.APPROVED, "alice");

        org.mockito.ArgumentCaptor<DdssLeave> update = org.mockito.ArgumentCaptor.forClass(DdssLeave.class);
        verify(mapper).updateById(update.capture());
        assertEquals(10L, update.getValue().getLeaveId());
        assertEquals(WorkflowConstants.LEAVE_STATUS_PASS, update.getValue().getStatus());
        assertEquals("alice", update.getValue().getUpdateBy());
    }
}

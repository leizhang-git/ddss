package com.ddss.workflow.adapter;

import com.ddss.workflow.domain.DdssLeave;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.runtime.ProcessInstanceQuery;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class LegacyLeaveWithdrawalAdapterTest {
    @Test
    void mapsLeaveRecordToWithdrawalSnapshot() {
        DdssLeaveMapper mapper = mock(DdssLeaveMapper.class);
        DdssLeave leave = new DdssLeave();
        leave.setApplyUser("alice");
        leave.setProcessInstanceId("process-1");
        when(mapper.selectById(10L)).thenReturn(leave);
        LegacyLeaveWithdrawalAdapter adapter = new LegacyLeaveWithdrawalAdapter(mapper, mock(RuntimeService.class));

        var snapshot = adapter.find(10L);

        assertTrue(snapshot.isPresent());
        assertEquals(10L, snapshot.get().leaveId());
        assertEquals("alice", snapshot.get().applicant());
        assertEquals("process-1", snapshot.get().processInstanceId());
        verify(mapper).selectById(10L);
    }

    @Test
    void returnsEmptyWhenLeaveDoesNotExist() {
        DdssLeaveMapper mapper = mock(DdssLeaveMapper.class);
        when(mapper.selectById(99L)).thenReturn(null);
        LegacyLeaveWithdrawalAdapter adapter = new LegacyLeaveWithdrawalAdapter(mapper, mock(RuntimeService.class));

        assertTrue(adapter.find(99L).isEmpty());
    }

    @Test
    void checksRunningStateAndCancelsFlowableProcess() {
        RuntimeService runtimeService = mock(RuntimeService.class);
        ProcessInstanceQuery query = mock(ProcessInstanceQuery.class);
        when(runtimeService.createProcessInstanceQuery()).thenReturn(query);
        when(query.processInstanceId("process-1")).thenReturn(query);
        when(query.count()).thenReturn(1L);
        LegacyLeaveWithdrawalAdapter adapter = new LegacyLeaveWithdrawalAdapter(mock(DdssLeaveMapper.class), runtimeService);

        assertTrue(adapter.isProcessRunning("process-1"));
        adapter.cancelProcess("process-1", "申请人删除申请单");

        verify(runtimeService).deleteProcessInstance("process-1", "申请人删除申请单");
    }

    @Test
    void requiresExactlyOneDeletedLeaveRecord() {
        DdssLeaveMapper mapper = mock(DdssLeaveMapper.class);
        when(mapper.deleteById(10L)).thenReturn(1);
        when(mapper.deleteById(11L)).thenReturn(0);
        LegacyLeaveWithdrawalAdapter adapter = new LegacyLeaveWithdrawalAdapter(mapper, mock(RuntimeService.class));

        adapter.delete(10L);
        IllegalStateException failure = assertThrows(IllegalStateException.class, () -> adapter.delete(11L));

        assertEquals("Leave application was not deleted", failure.getMessage());
        verify(mapper).deleteById(10L);
        verify(mapper).deleteById(11L);
    }

    @Test
    void returnsFalseWhenFlowableProcessIsNotRunning() {
        RuntimeService runtimeService = mock(RuntimeService.class);
        ProcessInstanceQuery query = mock(ProcessInstanceQuery.class);
        when(runtimeService.createProcessInstanceQuery()).thenReturn(query);
        when(query.processInstanceId("process-1")).thenReturn(query);
        when(query.count()).thenReturn(0L);
        LegacyLeaveWithdrawalAdapter adapter = new LegacyLeaveWithdrawalAdapter(mock(DdssLeaveMapper.class), runtimeService);

        assertFalse(adapter.isProcessRunning("process-1"));
    }
}

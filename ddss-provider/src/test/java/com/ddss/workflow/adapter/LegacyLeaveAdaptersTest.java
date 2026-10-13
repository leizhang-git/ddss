package com.ddss.workflow.adapter;

import com.ddss.domain.workflow.LeaveApplication;
import com.ddss.domain.workflow.LeaveDays;
import com.ddss.workflow.domain.DdssLeave;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class LegacyLeaveAdaptersTest {
    @Test
    void failsIfApplicationRowCouldNotBeLinkedToProcess() {
        DdssLeaveMapper mapper = mock(DdssLeaveMapper.class);
        when(mapper.updateById(any(DdssLeave.class))).thenReturn(0);
        LegacyLeaveAdapters.Persistence persistence = new LegacyLeaveAdapters.Persistence(mapper);

        IllegalStateException failure = assertThrows(IllegalStateException.class,
                () -> persistence.updateStatus(44L, "process-44"));

        assertEquals("Leave application was not linked to its workflow process", failure.getMessage());
        verify(mapper).updateById(any(DdssLeave.class));
    }

    @Test
    void mapsHalfDayValueIntoPersistenceRecord() {
        DdssLeaveMapper mapper = mock(DdssLeaveMapper.class);
        when(mapper.insert(any(DdssLeave.class))).thenAnswer(invocation -> {
            DdssLeave leave = invocation.getArgument(0);
            leave.setLeaveId(5L);
            return 1;
        });
        LegacyLeaveAdapters.Persistence persistence = new LegacyLeaveAdapters.Persistence(mapper);
        LeaveApplication application = LeaveApplication.submit("alice", "Alice", LeaveDays.of(new BigDecimal("0.5")),
                LocalDate.of(2026, 10, 13), "Reason", "manager", "director");

        assertEquals(5L, persistence.insert(application));
        verify(mapper).insert(any(DdssLeave.class));
    }
}

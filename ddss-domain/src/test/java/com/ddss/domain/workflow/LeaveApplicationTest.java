package com.ddss.domain.workflow;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class LeaveApplicationTest {
    private LeaveApplication pending() {
        return LeaveApplication.submit("alice", "Alice", LeaveDays.of(new BigDecimal("1.5")),
                LocalDate.of(2026, 10, 13), "Personal reasons", "manager", "director");
    }

    @Test
    void startsPendingAndProducesAnApprovedValue() {
        LeaveApplication pending = pending();

        assertEquals(LeaveStatus.PENDING, pending.status());
        assertEquals(LeaveStatus.APPROVED, pending.approve().status());
        assertEquals(LeaveStatus.PENDING, pending.status());
    }

    @Test
    void completedApplicationsCannotBeDecidedAgain() {
        assertThrows(IllegalStateException.class, () -> pending().approve().reject());
    }
}

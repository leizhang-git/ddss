package com.ddss.application.workflow;

import com.ddss.domain.workflow.LeaveApplication;
import com.ddss.domain.workflow.LeaveDays;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SubmitLeaveTest {
    @Test
    void persistsBeforeStartingTheProcessAndStoresItsIdentifier() {
        StringBuilder calls = new StringBuilder();
        LeaveApplicationPort applications = new LeaveApplicationPort() {
            @Override
            public long insert(LeaveApplication application) {
                calls.append("insert;");
                return 42L;
            }

            @Override
            public void updateStatus(long leaveId, String processInstanceId) {
                calls.append("update:").append(leaveId).append(":").append(processInstanceId).append(';');
            }

            @Override
            public void delete(long leaveId) {
                calls.append("delete:").append(leaveId).append(';');
            }
        };
        WorkflowProcessPort processes = new WorkflowProcessPort() {
            @Override
            public String startLeave(String businessKey, LeaveApplication application) {
                calls.append("start:").append(businessKey).append(';');
                return "process-42";
            }

            @Override
            public void cancel(String processInstanceId, String reason) { }

            @Override
            public boolean isRunning(String processInstanceId) { return false; }
        };
        LeaveApplication application = LeaveApplication.submit("alice", "Alice",
                LeaveDays.of(new BigDecimal("0.5")), LocalDate.of(2026, 10, 13), "Reason", "manager", "director");

        SubmissionResult result = new SubmitLeave(applications, processes).execute(application);
        assertTrue(result instanceof SubmissionResult.Submitted);
        SubmissionResult.Submitted submitted = (SubmissionResult.Submitted) result;
        assertEquals(42L, submitted.leaveId());
        assertEquals("process-42", submitted.processInstanceId());
        assertEquals("insert;start:42;update:42:process-42;", calls.toString());
    }

    @Test
    void rejectsMissingWorkflowIdentifierAndDeletesThePersistedApplication() {
        StringBuilder calls = new StringBuilder();
        LeaveApplicationPort applications = new LeaveApplicationPort() {
            @Override
            public long insert(LeaveApplication application) { return 42L; }
            @Override
            public void updateStatus(long leaveId, String processInstanceId) { }
            @Override
            public void delete(long leaveId) { calls.append("delete:").append(leaveId); }
        };
        WorkflowProcessPort processes = new WorkflowProcessPort() {
            @Override
            public String startLeave(String businessKey, LeaveApplication application) { return " "; }
            @Override
            public void cancel(String processInstanceId, String reason) { }
            @Override
            public boolean isRunning(String processInstanceId) { return false; }
        };
        LeaveApplication application = LeaveApplication.submit("alice", "Alice",
                LeaveDays.of(new BigDecimal("1")), LocalDate.of(2026, 10, 13), "Reason", "manager", "director");

        SubmissionResult result = new SubmitLeave(applications, processes).execute(application);
        assertTrue(result instanceof SubmissionResult.Rejected);
        SubmissionResult.Rejected rejected = (SubmissionResult.Rejected) result;
        assertEquals(SubmissionResult.Reason.PROCESS_START_FAILED, rejected.reason());
        assertEquals("delete:42", calls.toString());
    }

    @Test
    void cancelsProcessAndDeletesApplicationWhenLinkingFails() {
        IllegalStateException persistenceFailure = new IllegalStateException("link failed");
        StringBuilder calls = new StringBuilder();
        LeaveApplicationPort applications = new LeaveApplicationPort() {
            @Override
            public long insert(LeaveApplication application) { return 42L; }
            @Override
            public void updateStatus(long leaveId, String processInstanceId) { throw persistenceFailure; }
            @Override
            public void delete(long leaveId) { calls.append("delete:").append(leaveId).append(';'); }
        };
        WorkflowProcessPort processes = new WorkflowProcessPort() {
            @Override
            public String startLeave(String businessKey, LeaveApplication application) { return "process-42"; }
            @Override
            public void cancel(String processInstanceId, String reason) {
                calls.append("cancel:").append(processInstanceId).append(';');
            }
            @Override
            public boolean isRunning(String processInstanceId) { return false; }
        };
        LeaveApplication application = LeaveApplication.submit("alice", "Alice",
                LeaveDays.of(new BigDecimal("1")), LocalDate.of(2026, 10, 13), "Reason", "manager", "director");

        IllegalStateException failure = assertThrows(IllegalStateException.class,
                () -> new SubmitLeave(applications, processes).execute(application));

        assertSame(persistenceFailure, failure);
        assertEquals("cancel:process-42;delete:42;", calls.toString());
    }

    @Test
    void preservesOriginalFailureWhenCleanupAlsoFails() {
        IllegalStateException startFailure = new IllegalStateException("engine unavailable");
        IllegalStateException cleanupFailure = new IllegalStateException("delete failed");
        LeaveApplicationPort applications = new LeaveApplicationPort() {
            @Override
            public long insert(LeaveApplication application) { return 42L; }
            @Override
            public void updateStatus(long leaveId, String processInstanceId) { }
            @Override
            public void delete(long leaveId) { throw cleanupFailure; }
        };
        WorkflowProcessPort processes = new WorkflowProcessPort() {
            @Override
            public String startLeave(String businessKey, LeaveApplication application) { throw startFailure; }
            @Override
            public void cancel(String processInstanceId, String reason) { }
            @Override
            public boolean isRunning(String processInstanceId) { return false; }
        };
        LeaveApplication application = LeaveApplication.submit("alice", "Alice",
                LeaveDays.of(new BigDecimal("1")), LocalDate.of(2026, 10, 13), "Reason", "manager", "director");

        IllegalStateException failure = assertThrows(IllegalStateException.class,
                () -> new SubmitLeave(applications, processes).execute(application));

        assertSame(startFailure, failure);
        assertEquals(1, failure.getSuppressed().length);
        assertSame(cleanupFailure, failure.getSuppressed()[0]);
    }
}

package com.ddss.application.workflow;

import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class WithdrawLeaveApplicationsTest {
    @Test
    void validatesAllOwnersBeforeCancellingOrDeletingAnyApplication() {
        RecordingPort port = new RecordingPort();
        port.leaves.put(1L, new LeaveWithdrawalSnapshot(1L, "alice", "process-1"));
        port.leaves.put(2L, new LeaveWithdrawalSnapshot(2L, "bob", "process-2"));

        WithdrawalResult result = new WithdrawLeaveApplications(port).execute(new Long[]{1L, 2L}, "alice");

        assertTrue(result instanceof WithdrawalResult.Rejected);
        assertEquals(WithdrawalResult.Reason.NOT_OWNER, ((WithdrawalResult.Rejected) result).reason());
        assertEquals(List.of("find:1", "find:2"), port.calls);
    }

    @Test
    void ignoresMissingAndDuplicateIdsAndCancelsRunningProcessesBeforeDeletion() {
        RecordingPort port = new RecordingPort();
        port.leaves.put(1L, new LeaveWithdrawalSnapshot(1L, "alice", "process-1"));
        port.running.put("process-1", true);

        WithdrawalResult result = new WithdrawLeaveApplications(port)
                .execute(new Long[]{1L, null, 99L, 1L}, "alice");

        assertEquals(new WithdrawalResult.Completed(true), result);
        assertEquals(List.of("find:1", "find:99", "running:process-1", "cancel:process-1:申请人删除申请单",
                "delete:1"), port.calls);
    }

    @Test
    void emptyBatchKeepsTheExistingFalseReturnBehavior() {
        RecordingPort port = new RecordingPort();

        assertEquals(new WithdrawalResult.Completed(false), new WithdrawLeaveApplications(port).execute(null, "alice"));
        assertTrue(port.calls.isEmpty());
    }

    private static final class RecordingPort implements LeaveWithdrawalPort {
        private final Map<Long, LeaveWithdrawalSnapshot> leaves = new HashMap<>();
        private final Map<String, Boolean> running = new HashMap<>();
        private final List<String> calls = new ArrayList<>();

        @Override
        public Optional<LeaveWithdrawalSnapshot> find(long leaveId) {
            calls.add("find:" + leaveId);
            return Optional.ofNullable(leaves.get(leaveId));
        }

        @Override
        public void cancelProcess(String processInstanceId, String reason) {
            calls.add("cancel:" + processInstanceId + ":" + reason);
        }

        @Override
        public boolean isProcessRunning(String processInstanceId) {
            calls.add("running:" + processInstanceId);
            return running.getOrDefault(processInstanceId, false);
        }

        @Override
        public void delete(long leaveId) {
            calls.add("delete:" + leaveId);
        }
    }
}

package com.ddss.application.workflow;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;

public final class WithdrawLeaveApplications {
    private final LeaveWithdrawalPort withdrawals;

    public WithdrawLeaveApplications(LeaveWithdrawalPort withdrawals) {
        this.withdrawals = Objects.requireNonNull(withdrawals, "withdrawals");
    }

    public WithdrawalResult execute(Long[] leaveIds, String actor) {
        if (leaveIds == null || leaveIds.length == 0) {
            return new WithdrawalResult.Completed(false);
        }
        if (actor == null || actor.trim().isEmpty()) {
            return new WithdrawalResult.Rejected(WithdrawalResult.Reason.ACTOR_REQUIRED);
        }

        Map<Long, LeaveWithdrawalSnapshot> found = new LinkedHashMap<>();
        for (Long leaveId : leaveIds) {
            if (leaveId == null || found.containsKey(leaveId)) {
                continue;
            }
            var leave = withdrawals.find(leaveId);
            if (leave.isPresent()) {
                if (!actor.equals(leave.get().applicant())) {
                    return new WithdrawalResult.Rejected(WithdrawalResult.Reason.NOT_OWNER);
                }
                found.put(leaveId, leave.get());
            }
        }

        for (LeaveWithdrawalSnapshot leave : found.values()) {
            String processInstanceId = leave.processInstanceId();
            if (processInstanceId != null && !processInstanceId.trim().isEmpty()
                    && withdrawals.isProcessRunning(processInstanceId)) {
                withdrawals.cancelProcess(processInstanceId, "申请人删除申请单");
            }
            withdrawals.delete(leave.leaveId());
        }
        return new WithdrawalResult.Completed(true);
    }

}

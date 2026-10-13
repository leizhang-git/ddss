package com.ddss.application.workflow;

import java.util.Optional;

public interface LeaveWithdrawalPort {
    Optional<LeaveWithdrawalSnapshot> find(long leaveId);

    void cancelProcess(String processInstanceId, String reason);

    boolean isProcessRunning(String processInstanceId);

    void delete(long leaveId);
}

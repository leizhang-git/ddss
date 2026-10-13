package com.ddss.application.workflow;

import com.ddss.domain.workflow.LeaveApplication;

public interface LeaveApplicationPort {
    long insert(LeaveApplication application);

    void updateStatus(long leaveId, String processInstanceId);

    void delete(long leaveId);
}

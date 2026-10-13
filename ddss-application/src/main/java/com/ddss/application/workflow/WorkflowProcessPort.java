package com.ddss.application.workflow;

import com.ddss.domain.workflow.LeaveApplication;

public interface WorkflowProcessPort {
    String startLeave(String businessKey, LeaveApplication application);

    void cancel(String processInstanceId, String reason);

    boolean isRunning(String processInstanceId);
}

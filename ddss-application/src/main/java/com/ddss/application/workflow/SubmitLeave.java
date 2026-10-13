package com.ddss.application.workflow;

import com.ddss.domain.workflow.LeaveApplication;

import java.util.Objects;

public final class SubmitLeave {
    private final LeaveApplicationPort applications;
    private final WorkflowProcessPort processes;

    public SubmitLeave(LeaveApplicationPort applications, WorkflowProcessPort processes) {
        this.applications = Objects.requireNonNull(applications, "applications");
        this.processes = Objects.requireNonNull(processes, "processes");
    }

    public SubmissionResult execute(LeaveApplication application) {
        if (application == null) {
            return new SubmissionResult.Rejected(SubmissionResult.Reason.INVALID_APPLICATION);
        }
        long leaveId = applications.insert(application);
        String processInstanceId;
        try {
            processInstanceId = processes.startLeave(Long.toString(leaveId), application);
        } catch (RuntimeException failure) {
            try {
                applications.delete(leaveId);
            } catch (RuntimeException cleanupFailure) {
                failure.addSuppressed(cleanupFailure);
            }
            throw failure;
        }
        if (processInstanceId == null || processInstanceId.trim().isEmpty()) {
            applications.delete(leaveId);
            return new SubmissionResult.Rejected(SubmissionResult.Reason.PROCESS_START_FAILED);
        }
        try {
            applications.updateStatus(leaveId, processInstanceId);
        } catch (RuntimeException failure) {
            try {
                processes.cancel(processInstanceId, "Leave application could not be linked to process");
            } catch (RuntimeException compensationFailure) {
                failure.addSuppressed(compensationFailure);
            }
            try {
                applications.delete(leaveId);
            } catch (RuntimeException cleanupFailure) {
                failure.addSuppressed(cleanupFailure);
            }
            throw failure;
        }
        return new SubmissionResult.Submitted(leaveId, processInstanceId);
    }
}

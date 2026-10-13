package com.ddss.application.workflow;

public sealed interface SubmissionResult permits SubmissionResult.Submitted, SubmissionResult.Rejected {
    record Submitted(long leaveId, String processInstanceId) implements SubmissionResult { }

    record Rejected(Reason reason) implements SubmissionResult { }

    enum Reason {
        INVALID_APPLICATION,
        PROCESS_START_FAILED
    }
}

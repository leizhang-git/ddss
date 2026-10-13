package com.ddss.application.workflow;

public sealed interface DecisionResult permits DecisionResult.Completed, DecisionResult.Rejected {
    record Completed() implements DecisionResult { }

    record Rejected(Reason reason) implements DecisionResult { }

    enum Reason {
        TASK_ID_REQUIRED,
        DECISION_REQUIRED,
        ACTOR_REQUIRED,
        TASK_NOT_FOUND,
        NOT_ASSIGNEE
    }
}

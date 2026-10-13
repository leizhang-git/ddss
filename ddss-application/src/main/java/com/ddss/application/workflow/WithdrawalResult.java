package com.ddss.application.workflow;

public sealed interface WithdrawalResult permits WithdrawalResult.Completed, WithdrawalResult.Rejected {
    record Completed(boolean deleted) implements WithdrawalResult { }

    record Rejected(Reason reason) implements WithdrawalResult { }

    enum Reason {
        ACTOR_REQUIRED,
        NOT_OWNER
    }
}

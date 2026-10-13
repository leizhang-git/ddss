package com.ddss.application.workflow;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

public record WorkflowTaskRow(
        String taskId,
        String taskName,
        String processInstanceId,
        Instant taskCreateTime,
        Long leaveId,
        String applicant,
        String applyUserName,
        BigDecimal leaveDays,
        LocalDate startDate,
        String reason,
        String leader,
        String boss,
        Boolean approved,
        String comment,
        Instant finishTime) {
}

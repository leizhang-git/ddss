package com.ddss.application.finance;

import com.ddss.domain.finance.FinanceSchedule;

import java.time.YearMonth;
import java.util.List;
import java.util.Objects;

public record FinanceExportPlan(List<YearMonth> months, List<FinanceSchedule> rows) {
    public FinanceExportPlan {
        months = List.copyOf(Objects.requireNonNull(months, "months"));
        rows = List.copyOf(Objects.requireNonNull(rows, "rows"));
    }
}

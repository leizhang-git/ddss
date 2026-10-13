package com.ddss.application.finance;

import com.ddss.domain.finance.FinanceLoan;
import com.ddss.domain.finance.FinanceScheduleCalculator;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

public final class PrepareFinanceExport {
    private final FinanceExportPort finance;
    private final FinanceScheduleCalculator calculator;

    public PrepareFinanceExport(FinanceExportPort finance, FinanceScheduleCalculator calculator) {
        this.finance = Objects.requireNonNull(finance, "finance");
        this.calculator = Objects.requireNonNull(calculator, "calculator");
    }

    public FinanceExportPlan execute() {
        List<FinanceLoan> loans = List.copyOf(finance.findAllForExport());
        List<java.time.YearMonth> months = calculator.buildMonthAxis(loans);
        return new FinanceExportPlan(months, loans.stream()
                .map(loan -> calculator.calculate(loan, months))
                .collect(Collectors.toList()));
    }
}

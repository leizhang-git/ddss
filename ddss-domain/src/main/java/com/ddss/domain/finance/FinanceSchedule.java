package com.ddss.domain.finance;

import java.math.BigDecimal;
import java.time.YearMonth;
import java.util.Map;
import java.util.Objects;

public record FinanceSchedule(
        FinanceLoan loan,
        Map<YearMonth, BigDecimal> monthAmounts,
        BigDecimal totalRepay) {

    public FinanceSchedule {
        Objects.requireNonNull(loan, "loan");
        monthAmounts = Map.copyOf(Objects.requireNonNull(monthAmounts, "monthAmounts"));
        Objects.requireNonNull(totalRepay, "totalRepay");
    }

    public BigDecimal amount(YearMonth month) {
        return monthAmounts.getOrDefault(month, BigDecimal.ZERO);
    }

    public BigDecimal cheap() {
        BigDecimal total = nvl(loan.loanAmount());
        BigDecimal early = nvl(loan.earlySettlementAmount());
        if (total.compareTo(BigDecimal.ZERO) <= 0 || early.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }
        return total.subtract(early).max(BigDecimal.ZERO);
    }

    public BigDecimal remaining() {
        return nvl(loan.remainingAmount());
    }

    private static BigDecimal nvl(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}

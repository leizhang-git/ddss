package com.ddss.domain.finance;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.Map;
import java.util.Objects;

public record FinanceLoan(
        String creditorName,
        BigDecimal loanAmount,
        LocalDate repaymentStartDate,
        Integer repaymentDay,
        Integer loanTerm,
        BigDecimal monthlyPayment,
        BigDecimal earlySettlementAmount,
        BigDecimal remainingAmount,
        FinanceStatus status,
        Map<YearMonth, BigDecimal> paidByMonth,
        Map<Integer, BigDecimal> paidByMonthOfYear) {

    public FinanceLoan {
        paidByMonth = Map.copyOf(Objects.requireNonNull(paidByMonth, "paidByMonth"));
        paidByMonthOfYear = Map.copyOf(Objects.requireNonNull(paidByMonthOfYear, "paidByMonthOfYear"));
    }
}

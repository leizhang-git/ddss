package com.ddss.domain.finance;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

class FinanceScheduleCalculatorTest {
    private final Clock clock = Clock.fixed(Instant.parse("2025-01-15T00:00:00Z"), ZoneId.of("UTC"));
    private final FinanceScheduleCalculator calculator = new FinanceScheduleCalculator(clock);

    @Test
    void buildsAxisThroughLatestRepaymentMonthAndAtLeastSixMonthsAhead() {
        FinanceLoan loan = loan(LocalDate.of(2025, 1, 1), 2, new BigDecimal("100.00"), Map.of(), Map.of());

        assertEquals(List.of(YearMonth.of(2025, 1), YearMonth.of(2025, 2), YearMonth.of(2025, 3),
                        YearMonth.of(2025, 4), YearMonth.of(2025, 5), YearMonth.of(2025, 6), YearMonth.of(2025, 7)),
                calculator.buildMonthAxis(List.of(loan)));
    }

    @Test
    void prefersPaidAmountsAndInfersInstallmentsAcrossYears() {
        FinanceLoan loan = loan(LocalDate.of(2024, 12, 1), 3, new BigDecimal("100.00"),
                Map.of(YearMonth.of(2025, 1), new BigDecimal("75.25")), Map.of());
        List<YearMonth> months = List.of(YearMonth.of(2024, 12), YearMonth.of(2025, 1), YearMonth.of(2025, 2));

        FinanceSchedule schedule = calculator.calculate(loan, months);

        assertEquals(new BigDecimal("100.00"), schedule.amount(YearMonth.of(2024, 12)));
        assertEquals(new BigDecimal("75.25"), schedule.amount(YearMonth.of(2025, 1)));
        assertEquals(new BigDecimal("100.00"), schedule.amount(YearMonth.of(2025, 2)));
        assertEquals(new BigDecimal("275.25"), schedule.totalRepay());
    }

    @Test
    void infersOnlyWithinInclusiveRepaymentIntervalAndClampsShortMonths() {
        FinanceLoan loan = loan(LocalDate.of(2025, 1, 31), 1, new BigDecimal("50.00"), Map.of(), Map.of());

        FinanceSchedule schedule = calculator.calculate(loan, List.of(
                YearMonth.of(2025, 1), YearMonth.of(2025, 2), YearMonth.of(2025, 3)));

        assertEquals(new BigDecimal("50.00"), schedule.amount(YearMonth.of(2025, 1)));
        assertEquals(new BigDecimal("50.00"), schedule.amount(YearMonth.of(2025, 2)));
        assertEquals(BigDecimal.ZERO, schedule.amount(YearMonth.of(2025, 3)));
    }

    @Test
    void fallsBackToMonthlyPaymentTimesTermWhenMonthAxisIsEmpty() {
        FinanceLoan loan = loan(null, 12, new BigDecimal("12.50"), Map.of(), Map.of());

        assertEquals(new BigDecimal("150.00"), calculator.calculate(loan, List.of()).totalRepay());
    }

    @Test
    void calculatesCheapAndPreservesStoredRemainingAmount() {
        FinanceLoan loan = new FinanceLoan("Creditor", new BigDecimal("100.10"), null, null, null, null,
                new BigDecimal("0.10"), new BigDecimal("70.00"), FinanceStatus.REPAYING, Map.of(), Map.of());
        FinanceSchedule schedule = calculator.calculate(loan, List.of());

        assertEquals(new BigDecimal("100.00"), schedule.cheap());
        assertEquals(new BigDecimal("70.00"), schedule.remaining());
    }

    private FinanceLoan loan(LocalDate start, Integer term, BigDecimal monthlyPayment,
                             Map<YearMonth, BigDecimal> paidByMonth, Map<Integer, BigDecimal> paidByMonthOfYear) {
        return new FinanceLoan("Creditor", new BigDecimal("1000.00"), start, 31, term, monthlyPayment,
                BigDecimal.ZERO, new BigDecimal("500.00"), FinanceStatus.REPAYING, paidByMonth, paidByMonthOfYear);
    }
}

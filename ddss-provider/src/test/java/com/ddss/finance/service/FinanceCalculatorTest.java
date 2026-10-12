package com.ddss.finance.service;

import com.ddss.finance.domain.SysFinance;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneId;
import java.util.Arrays;
import java.util.Collections;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class FinanceCalculatorTest {

    private final Clock clock = Clock.fixed(Instant.parse("2025-01-15T00:00:00Z"), ZoneId.of("UTC"));
    private final FinanceCalculator calculator = new FinanceCalculator(clock);

    @Test
    void shouldCalculateMoneyWithoutDoublePrecisionLoss() {
        SysFinance finance = new SysFinance();
        finance.setLoanAmount(new BigDecimal("100.10"));
        finance.setEarlySettlementAmount(new BigDecimal("0.10"));

        assertEquals(new BigDecimal("100.00"), calculator.calculate(finance, Collections.emptyList()).getCheap());
    }

    @Test
    void shouldResolveYearPrefixedMonthAcrossYears() {
        SysFinance finance = new SysFinance();
        finance.setRepaymentStartDate(java.time.LocalDate.of(2024, 12, 1));
        finance.setRepaymentDay(15);
        finance.setMonthlyPayment(new BigDecimal("100.00"));
        finance.setLoanTerm(3);

        FinanceCalculator.Row row = calculator.calculate(finance, Arrays.asList("24-12月", "25-1月", "25-2月"));

        assertEquals(new BigDecimal("100.00"), row.getAmount("25-1月"));
        assertEquals(new BigDecimal("100.00"), row.getAmount("25-2月"));
    }

    @Test
    void shouldBuildAtLeastSixMonthsAxis() {
        SysFinance finance = new SysFinance();
        finance.setRepaymentStartDate(java.time.LocalDate.of(2025, 1, 1));
        finance.setLoanTerm(2);

        assertTrue(calculator.buildMonthAxis(Collections.singletonList(finance)).size() >= 7);
    }
}

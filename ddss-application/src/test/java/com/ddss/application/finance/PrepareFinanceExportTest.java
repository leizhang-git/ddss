package com.ddss.application.finance;

import com.ddss.domain.finance.FinanceLoan;
import com.ddss.domain.finance.FinanceScheduleCalculator;
import com.ddss.domain.finance.FinanceStatus;
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

class PrepareFinanceExportTest {
    @Test
    void readsLoansAndPreparesTypedExportRows() {
        FinanceLoan loan = new FinanceLoan("Creditor", new BigDecimal("1000.00"), LocalDate.of(2025, 1, 1),
                15, 2, new BigDecimal("100.00"), BigDecimal.ZERO, new BigDecimal("800.00"),
                FinanceStatus.REPAYING, Map.of(), Map.of());
        FinanceExportPort port = () -> List.of(loan);
        FinanceScheduleCalculator calculator = new FinanceScheduleCalculator(
                Clock.fixed(Instant.parse("2025-01-15T00:00:00Z"), ZoneId.of("UTC")));

        FinanceExportPlan plan = new PrepareFinanceExport(port, calculator).execute();

        assertEquals(1, plan.rows().size());
        assertEquals(7, plan.months().size());
        assertEquals(new BigDecimal("200.00"), plan.rows().get(0).totalRepay());
        assertEquals(YearMonth.of(2025, 1), plan.months().get(0));
    }

    @Test
    void returnsEmptyRowsAndStillProvidesCurrentMonthAxis() {
        FinanceExportPlan plan = new PrepareFinanceExport(List::of,
                new FinanceScheduleCalculator(Clock.fixed(Instant.parse("2025-01-15T00:00:00Z"), ZoneId.of("UTC"))))
                .execute();

        assertEquals(List.of(), plan.rows());
        assertEquals(7, plan.months().size());
    }
}

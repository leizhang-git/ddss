package com.ddss.finance.service;

import com.ddss.application.finance.FinanceExportPlan;
import com.ddss.application.finance.FinanceExportPort;
import com.ddss.application.finance.PrepareFinanceExport;
import com.ddss.domain.finance.FinanceLoan;
import com.ddss.domain.finance.FinanceScheduleCalculator;
import com.ddss.domain.finance.FinanceStatus;
import com.ddss.finance.adapter.LegacyFinanceExportAdapter;
import com.ddss.finance.domain.SysFinance;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class FinanceExportMigrationTest {
    @Test
    void exportUsesFrameworkFreeDomainAndApplicationCalculation() {
        SysFinance stored = new SysFinance();
        stored.setCreditorName("Creditor");
        stored.setLoanAmount(new BigDecimal("1000.00"));
        stored.setRepaymentStartDate(LocalDate.of(2025, 1, 1));
        stored.setRepaymentDay(15);
        stored.setLoanTerm(2);
        stored.setMonthlyPayment(new BigDecimal("100.00"));
        stored.setEarlySettlementAmount(new BigDecimal("10.00"));
        stored.setRemainingAmount(new BigDecimal("800.00"));
        stored.setStatus("0");
        stored.setMonthData("{\"25-1月\":{\"amt\":\"90.50\"}}");

        SysFinanceService service = mock(SysFinanceService.class);
        when(service.selectFinanceList(any(SysFinance.class))).thenReturn(Collections.singletonList(stored));
        FinanceExportPort port = new LegacyFinanceExportAdapter(service);
        FinanceScheduleCalculator calculator = new FinanceScheduleCalculator(
                Clock.fixed(Instant.parse("2025-01-15T00:00:00Z"), ZoneId.of("UTC")));

        FinanceExportPlan plan = new PrepareFinanceExport(port, calculator).execute();
        FinanceLoan loan = plan.rows().get(0).loan();

        assertEquals(7, plan.months().size());
        assertEquals(YearMonth.of(2025, 1), plan.months().get(0));
        assertEquals(new BigDecimal("90.50"), plan.rows().get(0).amount(YearMonth.of(2025, 1)));
        assertEquals(new BigDecimal("100.00"), plan.rows().get(0).amount(YearMonth.of(2025, 2)));
        assertEquals(new BigDecimal("190.50"), plan.rows().get(0).totalRepay());
        assertEquals(new BigDecimal("990.00"), plan.rows().get(0).cheap());
        assertEquals(new BigDecimal("800.00"), plan.rows().get(0).remaining());
        assertEquals(FinanceStatus.REPAYING, loan.status());
    }
}

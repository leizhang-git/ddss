package com.ddss.finance.adapter;

import com.ddss.domain.finance.FinanceLoan;
import com.ddss.domain.finance.FinanceScheduleCalculator;
import com.ddss.finance.domain.SysFinance;
import com.ddss.finance.service.SysFinanceService;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class LegacyFinanceExportAdapterTest {
    @Test
    void mapsPersistedMonthJsonAndEnumIntoTypedDomainData() {
        SysFinance finance = new SysFinance();
        finance.setCreditorName("Creditor");
        finance.setStatus("0");
        finance.setMonthData("{\"25-1月\":{\"amt\":\"12.30\"},\"2月\":{\"amt\":5}}");
        SysFinanceService service = mock(SysFinanceService.class);
        when(service.selectFinanceList(any(SysFinance.class))).thenReturn(Collections.singletonList(finance));

        List<FinanceLoan> loans = new LegacyFinanceExportAdapter(service).findAllForExport();

        assertEquals(new BigDecimal("12.30"), loans.get(0).paidByMonth().get(YearMonth.of(2025, 1)));
        assertEquals(new BigDecimal("5"), loans.get(0).paidByMonthOfYear().get(2));
        assertEquals("REPAYING", loans.get(0).status().name());
        verify(service).selectFinanceList(any(SysFinance.class));
    }

    @Test
    void oldCalculatorMonthAxisBehaviorRemainsEquivalent() {
        SysFinance finance = new SysFinance();
        finance.setRepaymentStartDate(java.time.LocalDate.of(2025, 1, 1));
        finance.setLoanTerm(2);
        SysFinanceService service = mock(SysFinanceService.class);
        when(service.selectFinanceList(any(SysFinance.class))).thenReturn(Collections.singletonList(finance));

        FinanceLoan loan = new LegacyFinanceExportAdapter(service).findAllForExport().get(0);
        List<YearMonth> months = new FinanceScheduleCalculator(
                Clock.fixed(Instant.parse("2025-01-15T00:00:00Z"), ZoneId.of("UTC"))).buildMonthAxis(List.of(loan));

        assertEquals(7, months.size());
        assertEquals(YearMonth.of(2025, 7), months.get(6));
    }

    @Test
    void rejectsMalformedMonthDataAndPreservesTheParsingCause() {
        assertMonthDataFails("{invalid-json", "Invalid month_data for finance export");
    }

    @Test
    void rejectsInvalidAmountInsteadOfSilentlyDroppingIt() {
        assertMonthDataFails("{\"25-1月\":{\"amt\":\"not-a-number\"}}", "Invalid month_data for finance export");
    }

    private void assertMonthDataFails(String monthData, String message) {
        SysFinance finance = new SysFinance();
        finance.setMonthData(monthData);
        SysFinanceService service = mock(SysFinanceService.class);
        when(service.selectFinanceList(any(SysFinance.class))).thenReturn(Collections.singletonList(finance));

        IllegalArgumentException failure = assertThrows(IllegalArgumentException.class,
                () -> new LegacyFinanceExportAdapter(service).findAllForExport());

        assertEquals(message, failure.getMessage());
        assertTrue(failure.getCause() != null);
    }
}

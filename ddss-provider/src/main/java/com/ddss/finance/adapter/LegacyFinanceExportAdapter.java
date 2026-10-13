package com.ddss.finance.adapter;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.TypeReference;
import com.ddss.application.finance.FinanceExportPort;
import com.ddss.domain.finance.FinanceLoan;
import com.ddss.domain.finance.FinanceStatus;
import com.ddss.finance.domain.SysFinance;
import com.ddss.finance.service.SysFinanceService;

import java.math.BigDecimal;
import java.time.DateTimeException;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

public final class LegacyFinanceExportAdapter implements FinanceExportPort {
    private final SysFinanceService financeService;

    public LegacyFinanceExportAdapter(SysFinanceService financeService) {
        this.financeService = Objects.requireNonNull(financeService, "financeService");
    }

    @Override
    public List<FinanceLoan> findAllForExport() {
        return financeService.selectFinanceList(new SysFinance()).stream()
                .map(this::toDomain)
                .collect(Collectors.toList());
    }

    private FinanceLoan toDomain(SysFinance finance) {
        Map<YearMonth, BigDecimal> paidByMonth = new HashMap<>();
        Map<Integer, BigDecimal> paidByMonthOfYear = new HashMap<>();
        parseMonthData(finance.getMonthData()).forEach((label, amount) -> {
            if (label.indexOf('-') >= 0) {
                YearMonth month = parseYearMonth(label);
                if (month != null) {
                    paidByMonth.put(month, amount);
                }
            } else {
                Integer month = parseMonth(label);
                if (month != null) {
                    paidByMonthOfYear.put(month, amount);
                }
            }
        });
        return new FinanceLoan(finance.getCreditorName(), finance.getLoanAmount(), finance.getRepaymentStartDate(),
                finance.getRepaymentDay(), finance.getLoanTerm(), finance.getMonthlyPayment(),
                finance.getEarlySettlementAmount(), finance.getRemainingAmount(),
                FinanceStatus.fromLegacyCode(finance.getStatus()),
                paidByMonth, paidByMonthOfYear);
    }

    private Map<String, BigDecimal> parseMonthData(String json) {
        if (json == null || json.trim().isEmpty()) {
            return Map.of();
        }
        try {
            Map<String, Object> values = JSON.parseObject(json, new TypeReference<Map<String, Object>>() { });
            if (values == null) {
                return Map.of();
            }
            Map<String, BigDecimal> amounts = new HashMap<>();
            values.forEach((key, value) -> {
                BigDecimal amount = parseAmount(value);
                if (key != null && amount != null) {
                    amounts.put(key, amount);
                }
            });
            return amounts;
        } catch (RuntimeException cause) {
            throw new IllegalArgumentException("Invalid month_data for finance export", cause);
        }
    }

    private BigDecimal parseAmount(Object value) {
        if (!(value instanceof Map)) {
            return null;
        }
        Object amount = ((Map<?, ?>) value).get("amt");
        if (!(amount instanceof Number) && !(amount instanceof String)) {
            return null;
        }
        try {
            return new BigDecimal(String.valueOf(amount));
        } catch (NumberFormatException cause) {
            throw new IllegalArgumentException("Invalid month amount: " + amount, cause);
        }
    }

    private YearMonth parseYearMonth(String label) {
        Integer month = parseMonth(label.substring(label.indexOf('-') + 1));
        if (month == null) {
            return null;
        }
        String yearPart = label.substring(0, label.indexOf('-'));
        try {
            int year = Integer.parseInt(yearPart);
            year += year < 100 ? 2000 : 0;
            return YearMonth.of(year, month);
        } catch (NumberFormatException | DateTimeException ignored) {
            return null;
        }
    }

    private Integer parseMonth(String label) {
        String normalized = label.trim().replace("月", "");
        try {
            int month = Integer.parseInt(normalized);
            return month >= 1 && month <= 12 ? month : null;
        } catch (NumberFormatException ignored) {
            return null;
        }
    }
}

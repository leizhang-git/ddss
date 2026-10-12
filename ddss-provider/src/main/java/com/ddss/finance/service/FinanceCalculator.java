package com.ddss.finance.service;

import com.alibaba.fastjson2.JSON;
import com.ddss.finance.domain.SysFinance;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.DateTimeException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 财务月度计算引擎（领域规则唯一权威实现，前端只做展示）
 * <p>
 * 规则（与设计文档"自动计算规则"对齐）：
 * <pre>
 * 月度金额   = monthData 中该月实付 amt；缺失月份若落在还款区间内则按 monthlyPayment 计
 * 总额       = sum(所有月份金额)，无月度数据时 = monthlyPayment × loanTerm
 * 便宜       = max(0, 借款总额 - 提前结清金额)
 * 剩余未还   = max(0, 借款总额 - 已还金额)
 * </pre>
 */
@Component
public class FinanceCalculator {

    private final Clock clock;

    public FinanceCalculator() {
        this(Clock.systemDefaultZone());
    }

    public FinanceCalculator(Clock clock) {
        this.clock = clock;
    }

    /**
     * 某条借款的月度金额计算结果
     */
    public static class Row {
        private final SysFinance finance;
        private final Map<String, BigDecimal> monthAmounts;
        private final BigDecimal totalRepay;

        Row(SysFinance finance, Map<String, BigDecimal> monthAmounts, BigDecimal totalRepay) {
            this.finance = finance;
            this.monthAmounts = monthAmounts;
            this.totalRepay = totalRepay;
        }

        public SysFinance getFinance() {
            return finance;
        }

        /** 月 -> 实付金额（含规则推算的月份） */
        public Map<String, BigDecimal> getMonthAmounts() {
            return monthAmounts;
        }

        /** 该月实付（无数据返回 0） */
        public BigDecimal getAmount(String month) {
            return monthAmounts.getOrDefault(month, BigDecimal.ZERO);
        }

        /** 总还款额 */
        public BigDecimal getTotalRepay() {
            return totalRepay;
        }

        /** 便宜 = max(0, 借款总额 - 提前结清金额) */
        public BigDecimal getCheap() {
            BigDecimal total = nvl(finance.getLoanAmount());
            BigDecimal early = nvl(finance.getEarlySettlementAmount());
            if (total.compareTo(BigDecimal.ZERO) <= 0 || early.compareTo(BigDecimal.ZERO) <= 0) {
                return BigDecimal.ZERO;
            }
            return total.subtract(early).max(BigDecimal.ZERO);
        }

        /** 剩余未还 */
        public BigDecimal getRemaining() {
            return nvl(finance.getRemainingAmount());
        }
    }

    /**
     * 计算一条借款在给定月份轴上的金额矩阵
     *
     * @param finance 借款记录
     * @param months  月份轴（如 ["25-7月","25-8月"]，与前端表格列一致）
     */
    public Row calculate(SysFinance finance, List<String> months) {
        Map<String, Object> monthData = parseMonthData(finance.getMonthData());

        // 1. 月度实付：优先 monthData 精确月（"25-7月" 或 "7月"），缺失月份按还款区间推算
        Map<String, BigDecimal> amounts = new LinkedHashMap<>();
        for (String month : months) {
            amounts.put(month, monthAmount(finance, monthData, month));
        }

        // 2. 总额：有月度数据按月求和；全零则回退 monthlyPayment × loanTerm
        BigDecimal totalRepay = amounts.values().stream()
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        if (totalRepay.compareTo(BigDecimal.ZERO) <= 0 && finance.getMonthlyPayment() != null && finance.getLoanTerm() != null) {
            totalRepay = finance.getMonthlyPayment().multiply(BigDecimal.valueOf(finance.getLoanTerm()));
        }
        return new Row(finance, amounts, totalRepay);
    }

    /**
     * 单月金额：monthData 实付优先，其次按还款区间内应付推算
     */
    private BigDecimal monthAmount(SysFinance f, Map<String, Object> monthData, String month) {
        BigDecimal paid = readAmount(monthData, month);
        if (paid != null) {
            return paid;
        }
        // 兼容不带年份前缀的 key（"7月"）
        String label = month.contains("-") ? month.substring(month.indexOf('-') + 1) : month;
        paid = readAmount(monthData, label);
        if (paid != null) {
            return paid;
        }
        return inferScheduled(f, month);
    }

    /**
     * 推算应付：月份落在 [还款开始, 开始+期限] 内则按 monthlyPayment 计
     */
    private BigDecimal inferScheduled(SysFinance f, String label) {
        if (f.getRepaymentStartDate() == null || f.getRepaymentDay() == null
                || f.getMonthlyPayment() == null || f.getLoanTerm() == null) {
            return BigDecimal.ZERO;
        }
        LocalDate today = LocalDate.now(clock);
        YearMonth targetMonth = parseYearMonth(label, YearMonth.from(today));
        if (targetMonth == null) {
            return BigDecimal.ZERO;
        }
        int day = Math.min(f.getRepaymentDay(), targetMonth.lengthOfMonth());
        LocalDate target = targetMonth.atDay(day);
        LocalDate start = f.getRepaymentStartDate();
        LocalDate end = start.plusMonths(f.getLoanTerm());
        return (!target.isBefore(start) && !target.isAfter(end)) ? f.getMonthlyPayment() : BigDecimal.ZERO;
    }

    private YearMonth parseYearMonth(String label, YearMonth reference) {
        String normalized = label == null ? "" : label.trim().replace("月", "");
        String[] parts = normalized.split("-");
        try {
            if (parts.length == 2) {
                int year = Integer.parseInt(parts[0]);
                year += year < 100 ? 2000 : 0;
                return YearMonth.of(year, Integer.parseInt(parts[1]));
            }
            if (parts.length == 1) {
                int month = Integer.parseInt(parts[0]);
                YearMonth candidate = YearMonth.of(reference.getYear(), month);
                return candidate.isBefore(reference) ? candidate.plusYears(1) : candidate;
            }
        } catch (NumberFormatException | DateTimeException ignored) {
            // 非法月份数据按无计划月份处理，避免异常打断整张财务表。
        }
        return null;
    }

    /**
     * 月份轴：从当前月推到 max(全部借款的还款结束月, 当前+6月)
     */
    public List<String> buildMonthAxis(List<SysFinance> list) {
        LocalDate now = LocalDate.now(clock);
        LocalDate maxDate = now.plusMonths(6);
        for (SysFinance f : list) {
            if (f.getRepaymentStartDate() != null && f.getLoanTerm() != null) {
                LocalDate end = f.getRepaymentStartDate().plusMonths(f.getLoanTerm());
                if (end.isAfter(maxDate)) {
                    maxDate = end;
                }
            }
        }
        List<String> months = new ArrayList<>();
        LocalDate cur = LocalDate.of(now.getYear(), now.getMonth(), 1);
        while (!cur.isAfter(maxDate)) {
            months.add((cur.getYear() % 100) + "-" + cur.getMonthValue() + "月");
            cur = cur.plusMonths(1);
        }
        return months;
    }

    @SuppressWarnings("unchecked")
    private BigDecimal readAmount(Map<String, Object> monthData, String key) {
        Object cell = monthData.get(key);
        if (cell instanceof Map) {
            Object amt = ((Map<String, Object>) cell).get("amt");
            if (amt instanceof BigDecimal) {
                return (BigDecimal) amt;
            }
            if (amt instanceof Number || amt instanceof String) {
                try {
                    return new BigDecimal(String.valueOf(amt));
                } catch (NumberFormatException ignored) {
                    return null;
                }
            }
        }
        return null;
    }

    private Map<String, Object> parseMonthData(String json) {
        if (json == null || json.isEmpty()) {
            return new HashMap<>();
        }
        try {
            return JSON.parseObject(json);
        } catch (Exception e) {
            return new HashMap<>();
        }
    }

    private static BigDecimal nvl(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}

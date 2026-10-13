package com.ddss.domain.finance;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Objects;

public final class FinanceScheduleCalculator {
    private final Clock clock;

    public FinanceScheduleCalculator(Clock clock) {
        this.clock = Objects.requireNonNull(clock, "clock");
    }

    public List<YearMonth> buildMonthAxis(List<FinanceLoan> loans) {
        YearMonth currentMonth = YearMonth.now(clock);
        LocalDate maxDate = currentMonth.plusMonths(6).atEndOfMonth();
        for (FinanceLoan loan : loans) {
            if (loan.repaymentStartDate() != null && loan.loanTerm() != null) {
                LocalDate end = loan.repaymentStartDate().plusMonths(loan.loanTerm());
                if (end.isAfter(maxDate)) {
                    maxDate = end;
                }
            }
        }

        List<YearMonth> months = new ArrayList<>();
        YearMonth current = currentMonth;
        YearMonth last = YearMonth.from(maxDate);
        while (!current.isAfter(last)) {
            months.add(current);
            current = current.plusMonths(1);
        }
        return List.copyOf(months);
    }

    public FinanceSchedule calculate(FinanceLoan loan, List<YearMonth> months) {
        Objects.requireNonNull(loan, "loan");
        Objects.requireNonNull(months, "months");
        LinkedHashMap<YearMonth, BigDecimal> amounts = new LinkedHashMap<>();
        for (YearMonth month : months) {
            amounts.put(month, monthAmount(loan, month));
        }

        BigDecimal totalRepay = amounts.values().stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        if (totalRepay.compareTo(BigDecimal.ZERO) <= 0 && loan.monthlyPayment() != null && loan.loanTerm() != null) {
            totalRepay = loan.monthlyPayment().multiply(BigDecimal.valueOf(loan.loanTerm()));
        }
        return new FinanceSchedule(loan, amounts, totalRepay);
    }

    private BigDecimal monthAmount(FinanceLoan loan, YearMonth month) {
        BigDecimal paid = loan.paidByMonth().get(month);
        if (paid == null) {
            paid = loan.paidByMonthOfYear().get(month.getMonthValue());
        }
        if (paid != null) {
            return paid;
        }
        return inferScheduled(loan, month);
    }

    private BigDecimal inferScheduled(FinanceLoan loan, YearMonth month) {
        if (loan.repaymentStartDate() == null || loan.repaymentDay() == null
                || loan.monthlyPayment() == null || loan.loanTerm() == null) {
            return BigDecimal.ZERO;
        }
        int day = Math.min(loan.repaymentDay(), month.lengthOfMonth());
        LocalDate target = month.atDay(day);
        LocalDate start = loan.repaymentStartDate();
        LocalDate end = start.plusMonths(loan.loanTerm());
        return !target.isBefore(start) && !target.isAfter(end) ? loan.monthlyPayment() : BigDecimal.ZERO;
    }
}

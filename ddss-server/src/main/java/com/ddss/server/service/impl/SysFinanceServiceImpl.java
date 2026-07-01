package com.ddss.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ddss.common.utils.StringUtils;
import com.ddss.server.domain.po.SysFinance;
import com.ddss.server.mapper.SysFinanceMapper;
import com.ddss.server.service.SysFinanceService;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;

@Service
public class SysFinanceServiceImpl extends ServiceImpl<SysFinanceMapper, SysFinance> implements SysFinanceService {

    @Override
    public List<SysFinance> selectFinanceList(SysFinance finance) {
        QueryWrapper<SysFinance> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(finance.getCreditorName())) {
            qw.like("creditor_name", finance.getCreditorName());
        }
        if (StringUtils.isNotEmpty(finance.getStatus())) {
            qw.eq("status", finance.getStatus());
        }
        qw.orderByDesc("create_time");
        return this.list(qw);
    }

    @Override
    public SysFinance selectFinanceById(Long financeId) {
        return this.getById(financeId);
    }

    @Override
    public int insertFinance(SysFinance finance) {
        return this.save(finance) ? 1 : 0;
    }

    @Override
    public int updateFinance(SysFinance finance) {
        return this.updateById(finance) ? 1 : 0;
    }

    @Override
    public int deleteFinanceByIds(Long[] financeIds) {
        return this.removeByIds(Arrays.asList(financeIds)) ? financeIds.length : 0;
    }

    @Override
    public Map<String, Object> getFinanceSummary() {
        List<SysFinance> all = this.list();
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("totalCount", all.size());

        BigDecimal totalLoan = BigDecimal.ZERO;
        BigDecimal totalPaid = BigDecimal.ZERO;
        BigDecimal totalRemaining = BigDecimal.ZERO;
        BigDecimal totalInterest = BigDecimal.ZERO;
        int repaying = 0, settled = 0, overdue = 0;

        for (SysFinance f : all) {
            totalLoan = totalLoan.add(nvl(f.getLoanAmount()));
            totalPaid = totalPaid.add(nvl(f.getPaidAmount()));
            totalRemaining = totalRemaining.add(nvl(f.getRemainingAmount()));
            totalInterest = totalInterest.add(nvl(f.getInterestAmount()));
            if ("0".equals(f.getStatus())) repaying++;
            else if ("1".equals(f.getStatus())) settled++;
            else if ("2".equals(f.getStatus())) overdue++;
        }

        result.put("totalLoan", totalLoan);
        result.put("totalPaid", totalPaid);
        result.put("totalRemaining", totalRemaining);
        result.put("totalInterest", totalInterest);
        result.put("repayingCount", repaying);
        result.put("settledCount", settled);
        result.put("overdueCount", overdue);
        return result;
    }

    @Override
    public List<Map<String, Object>> getGroupByCreditor() {
        List<SysFinance> all = this.list();
        Map<String, BigDecimal[]> group = new LinkedHashMap<>();
        for (SysFinance f : all) {
            String name = f.getCreditorName();
            BigDecimal[] vals = group.computeIfAbsent(name, k -> new BigDecimal[]{BigDecimal.ZERO, BigDecimal.ZERO});
            vals[0] = vals[0].add(nvl(f.getLoanAmount()));
            vals[1] = vals[1].add(nvl(f.getRemainingAmount()));
        }
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map.Entry<String, BigDecimal[]> e : group.entrySet()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("name", e.getKey());
            m.put("loanAmount", e.getValue()[0]);
            m.put("remainingAmount", e.getValue()[1]);
            list.add(m);
        }
        return list;
    }

    @Override
    public List<Map<String, Object>> getMonthlyTrend() {
        List<SysFinance> all = this.list();
        TreeMap<String, BigDecimal> trend = new TreeMap<>();
        for (SysFinance f : all) {
            if (f.getRepaymentDay() != null && nvl(f.getMonthlyPayment()).compareTo(BigDecimal.ZERO) > 0) {
                String key = "每月" + f.getRepaymentDay() + "日";
                BigDecimal val = trend.getOrDefault(key, BigDecimal.ZERO);
                trend.put(key, val.add(nvl(f.getMonthlyPayment())));
            }
        }
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map.Entry<String, BigDecimal> e : trend.entrySet()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("name", e.getKey());
            m.put("value", e.getValue());
            list.add(m);
        }
        return list;
    }

    private BigDecimal nvl(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}

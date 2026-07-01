package com.ddss.server.service;

import com.ddss.server.domain.po.SysFinance;

import java.util.List;
import java.util.Map;

public interface SysFinanceService {

    List<SysFinance> selectFinanceList(SysFinance finance);

    SysFinance selectFinanceById(Long financeId);

    int insertFinance(SysFinance finance);

    int updateFinance(SysFinance finance);

    int deleteFinanceByIds(Long[] financeIds);

    /** 统计汇总：总额、已还、剩余、利息等 */
    Map<String, Object> getFinanceSummary();

    /** 按欠款方分组统计 */
    List<Map<String, Object>> getGroupByCreditor();

    /** 按月还款趋势（未来N个月） */
    List<Map<String, Object>> getMonthlyTrend();
}

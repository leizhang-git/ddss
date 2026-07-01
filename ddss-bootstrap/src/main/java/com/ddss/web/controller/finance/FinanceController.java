package com.ddss.web.controller.finance;

import com.ddss.common.annotation.Log;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.server.domain.po.SysFinance;
import com.ddss.server.service.SysFinanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/finance")
public class FinanceController extends BaseController {

    @Autowired
    private SysFinanceService financeService;

    @PreAuthorize("@ss.hasPermi('finance:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysFinance finance) {
        startPage();
        List<SysFinance> list = financeService.selectFinanceList(finance);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('finance:query')")
    @GetMapping("/{financeId}")
    public AjaxResult getInfo(@PathVariable Long financeId) {
        return success(financeService.selectFinanceById(financeId));
    }

    @PreAuthorize("@ss.hasPermi('finance:add')")
    @Log(title = "财务管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody SysFinance finance) {
        finance.setCreateBy(getUsername());
        return toAjax(financeService.insertFinance(finance));
    }

    @PreAuthorize("@ss.hasPermi('finance:edit')")
    @Log(title = "财务管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody SysFinance finance) {
        finance.setUpdateBy(getUsername());
        return toAjax(financeService.updateFinance(finance));
    }

    @PreAuthorize("@ss.hasPermi('finance:remove')")
    @Log(title = "财务管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{financeIds}")
    public AjaxResult remove(@PathVariable Long[] financeIds) {
        return toAjax(financeService.deleteFinanceByIds(financeIds));
    }

    @PreAuthorize("@ss.hasPermi('finance:stat')")
    @GetMapping("/summary")
    public AjaxResult summary() {
        return success(financeService.getFinanceSummary());
    }

    @PreAuthorize("@ss.hasPermi('finance:stat')")
    @GetMapping("/groupByCreditor")
    public AjaxResult groupByCreditor() {
        return success(financeService.getGroupByCreditor());
    }

    @PreAuthorize("@ss.hasPermi('finance:stat')")
    @GetMapping("/monthlyTrend")
    public AjaxResult monthlyTrend() {
        return success(financeService.getMonthlyTrend());
    }
}

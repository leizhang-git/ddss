package com.ddss.web.controller.finance;

import com.alibaba.fastjson2.JSON;
import com.ddss.common.annotation.Log;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.server.domain.po.SysFinance;
import com.ddss.server.service.SysFinanceService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

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

    @PreAuthorize("@ss.hasPermi('finance:list')")
    @Log(title = "财务管理", businessType = BusinessType.EXPORT)
    @GetMapping("/export")
    public void export(HttpServletResponse response) throws Exception {
        List<SysFinance> list = financeService.selectFinanceList(new SysFinance());

        // 月份列（同前端逻辑）
        LocalDate now = LocalDate.now();
        LocalDate maxDate = now.plusMonths(6);
        for (SysFinance f : list) {
            if (f.getRepaymentStartDate() != null && f.getLoanTerm() != null) {
                LocalDate end = f.getRepaymentStartDate().plusMonths(f.getLoanTerm());
                if (end.isAfter(maxDate)) maxDate = end;
            }
        }
        List<String> months = new ArrayList<>();
        LocalDate cur = LocalDate.of(now.getYear(), now.getMonth(), 1);
        while (!cur.isAfter(maxDate)) {
            months.add((cur.getYear() % 100) + "-" + cur.getMonthValue() + "月");
            cur = cur.plusMonths(1);
        }

        // 解析 monthData
        List<Map<String, Object>> allMd = list.stream().map(f -> {
            try { return JSON.parseObject(f.getMonthData() != null ? f.getMonthData() : "{}"); } catch (Exception e) { return new HashMap<String, Object>(); }
        }).collect(Collectors.toList());

        // 计算某月金额
        java.util.function.BiFunction<SysFinance, Map<String, Object>, Double> payMonth = (f, md) -> {
            return 0.0; // 由 getCellVal 逻辑覆盖简化
        };
        java.util.function.ToDoubleBiFunction<SysFinance, String> getCellVal = (f, m) -> {
            int idx = list.indexOf(f); if (idx < 0) return 0.0;
            Map<String, Object> md = idx < allMd.size() ? allMd.get(idx) : new HashMap<>();
            if (md.containsKey(m)) { Object o = ((Map) md.get(m)).get("amt"); if (o != null) return ((Number) o).doubleValue(); }
            String label = m.contains("-") ? m.split("-")[1] : m;
            if (md.containsKey(label)) { Object o = ((Map) md.get(label)).get("amt"); if (o != null) return ((Number) o).doubleValue(); }
            if (f.getRepaymentStartDate() == null || f.getRepaymentDay() == null || f.getMonthlyPayment() == null) return 0.0;
            int mon = Integer.parseInt(label.replace("月", ""));
            int nowMon = now.getMonthValue();
            int targetYr = mon >= nowMon ? now.getYear() : now.getYear() + 1;
            LocalDate target = LocalDate.of(targetYr, mon, Math.min(f.getRepaymentDay(), 28));
            LocalDate start = f.getRepaymentStartDate();
            LocalDate end = start.plusMonths(f.getLoanTerm() != null ? f.getLoanTerm() : 0);
            return (!target.isBefore(start) && !target.isAfter(end)) ? f.getMonthlyPayment().doubleValue() : 0.0;
        };

        // 创建 Excel
        SXSSFWorkbook wb = new SXSSFWorkbook();
        Sheet sheet = wb.createSheet("财务管理");

        Font hf = wb.createFont(); hf.setBold(true); hf.setFontHeightInPoints((short) 11);
        CellStyle hs = wb.createCellStyle();
        hs.setFont(hf); hs.setAlignment(HorizontalAlignment.CENTER);
        hs.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        hs.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        hs.setBorderBottom(BorderStyle.THIN); hs.setBorderTop(BorderStyle.THIN);
        hs.setBorderLeft(BorderStyle.THIN); hs.setBorderRight(BorderStyle.THIN);

        CellStyle cs = wb.createCellStyle(); cs.setAlignment(HorizontalAlignment.CENTER);
        CellStyle ns = wb.createCellStyle(); ns.setAlignment(HorizontalAlignment.RIGHT);
        ns.setDataFormat(wb.createDataFormat().getFormat("#,##0.00"));

        // 表头
        String[] heads = {"名称", "便宜", "提前结清", "总额", "日期", "几号", "剩余", "状态"};
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < heads.length; i++) { Cell c = headerRow.createCell(i); c.setCellValue(heads[i]); c.setCellStyle(hs); }
        int ms = heads.length;
        for (int i = 0; i < months.size(); i++) { Cell c = headerRow.createCell(ms + i); c.setCellValue(months.get(i)); c.setCellStyle(hs); }

        // 列宽
        int[] widths = {4000, 3500, 3500, 3500, 3000, 2000, 3500, 2000};
        for (int i = 0; i < widths.length; i++) sheet.setColumnWidth(i, widths[i]);
        for (int i = 0; i < months.size(); i++) sheet.setColumnWidth(ms + i, 3000);

        // 数据
        for (int r = 0; r < list.size(); r++) {
            SysFinance f = list.get(r);
            Row row = sheet.createRow(r + 1);
            BigDecimal early = nvl(f.getEarlySettlementAmount());
            BigDecimal total = nvl(f.getLoanAmount());
            double cheap = total.doubleValue() > 0 && early.doubleValue() > 0 ? Math.max(0, total.doubleValue() - early.doubleValue()) : 0;
            double totalRepay = months.stream().mapToDouble(m -> getCellVal.applyAsDouble(f, m)).sum();
            if (totalRepay <= 0 && f.getMonthlyPayment() != null && f.getLoanTerm() != null)
                totalRepay = f.getMonthlyPayment().doubleValue() * f.getLoanTerm();

            int ci = 0;
            setCell(row, ci++, f.getCreditorName(), null);
            setCell(row, ci++, cheap, ns);
            setCell(row, ci++, early.doubleValue(), ns);
            setCell(row, ci++, totalRepay, ns);
            setCell(row, ci++, f.getRepaymentStartDate() != null ? f.getRepaymentStartDate().toString() : "", cs);
            setCell(row, ci++, f.getRepaymentDay() != null ? String.valueOf(f.getRepaymentDay()) : "", cs);
            setCell(row, ci++, nvl(f.getRemainingAmount()).doubleValue(), ns);
            setCell(row, ci++, statusLabel(f.getStatus()), cs);
            for (String m : months) {
                double v = getCellVal.applyAsDouble(f, m);
                setCell(row, ci++, v > 0 ? v : 0, ns);
            }
        }

        // 合计行
        Row sumRow = sheet.createRow(list.size() + 1);
        Font sf = wb.createFont(); sf.setBold(true);
        CellStyle ss = wb.createCellStyle(); ss.setFont(sf); ss.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        ss.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        setCell(sumRow, 0, "合计", ss);
        for (int c = 1; c < heads.length; c++) {
            String label = heads[c];
            int col = c;
            double val;
            switch (label) {
                case "便宜": val = list.stream().mapToDouble(f -> { double e=nvl(f.getEarlySettlementAmount()).doubleValue(), t=nvl(f.getLoanAmount()).doubleValue(); return t>0&&e>0?Math.max(0,t-e):0; }).sum(); break;
                case "提前结清": val = list.stream().mapToDouble(f -> nvl(f.getEarlySettlementAmount()).doubleValue()).sum(); break;
                case "总额": val = list.stream().mapToDouble(f -> months.stream().mapToDouble(m->getCellVal.applyAsDouble(f,m)).sum()).sum(); break;
                case "剩余": val = list.stream().mapToDouble(f -> nvl(f.getRemainingAmount()).doubleValue()).sum(); break;
                default: val = 0;
            }
            if (val != 0 || label.equals("总额") || label.equals("提前结清") || label.equals("剩余")) setCell(sumRow, c, val, ns);
        }
        for (int i = 0; i < months.size(); i++) {
            String m = months.get(i);
            double val = list.stream().mapToDouble(f -> getCellVal.applyAsDouble(f, m)).sum();
            setCell(sumRow, ms + i, val > 0 ? val : 0, ns);
        }

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode("财务管理.xlsx", "UTF-8"));
        wb.write(response.getOutputStream());
        wb.dispose();
    }

    private void setCell(Row row, int i, Object v, CellStyle s) {
        Cell c = row.createCell(i);
        if (v instanceof Number) { c.setCellValue(((Number)v).doubleValue()); c.setCellStyle(s); }
        else { c.setCellValue(v != null ? v.toString() : ""); if (s != null) c.setCellStyle(s); }
    }

    private String statusLabel(String s) {
        if ("0".equals(s)) return "还款中"; if ("1".equals(s)) return "已结清"; if ("2".equals(s)) return "逾期"; return "";
    }

    private BigDecimal nvl(BigDecimal v) { return v == null ? BigDecimal.ZERO : v; }
}

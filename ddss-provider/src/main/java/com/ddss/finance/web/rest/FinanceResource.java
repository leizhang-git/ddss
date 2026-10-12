package com.ddss.finance.web.rest;

import com.ddss.common.annotation.Log;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.R;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.finance.domain.SysFinance;
import com.ddss.finance.service.FinanceCalculator;
import com.ddss.finance.service.SysFinanceService;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

/**
 * 财务管理（v2 范式样板：R 响应契约 + pageQuery 分页 + 计算委托 FinanceCalculator）
 */
@RestController
@RequestMapping("/finance")
public class FinanceResource extends BaseController {

    @Autowired
    private SysFinanceService financeService;

    @Autowired
    private FinanceCalculator calculator;

    @PreAuthorize("@ss.hasPermi('finance:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysFinance finance) {
        return pageQuery(() -> financeService.selectFinanceList(finance));
    }

    @PreAuthorize("@ss.hasPermi('finance:query')")
    @GetMapping("/{financeId}")
    public R<SysFinance> getInfo(@PathVariable Long financeId) {
        return R.ok(financeService.selectFinanceById(financeId));
    }

    @PreAuthorize("@ss.hasPermi('finance:add')")
    @Log(title = "财务管理", businessType = BusinessType.INSERT)
    @PostMapping
    public R<Void> add(@RequestBody SysFinance finance) {
        finance.setCreateBy(getUsername());
        return toResult(financeService.insertFinance(finance));
    }

    @PreAuthorize("@ss.hasPermi('finance:edit')")
    @Log(title = "财务管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public R<Void> edit(@RequestBody SysFinance finance) {
        finance.setUpdateBy(getUsername());
        return toResult(financeService.updateFinance(finance));
    }

    @PreAuthorize("@ss.hasPermi('finance:remove')")
    @Log(title = "财务管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{financeIds}")
    public R<Void> remove(@PathVariable Long[] financeIds) {
        return toResult(financeService.deleteFinanceByIds(financeIds));
    }

    @PreAuthorize("@ss.hasPermi('finance:stat')")
    @GetMapping("/summary")
    public R<?> summary() {
        return R.ok(financeService.getFinanceSummary());
    }

    @PreAuthorize("@ss.hasPermi('finance:stat')")
    @GetMapping("/groupByCreditor")
    public R<?> groupByCreditor() {
        return R.ok(financeService.getGroupByCreditor());
    }

    @PreAuthorize("@ss.hasPermi('finance:stat')")
    @GetMapping("/monthlyTrend")
    public R<?> monthlyTrend() {
        return R.ok(financeService.getMonthlyTrend());
    }

    @PreAuthorize("@ss.hasPermi('finance:list')")
    @Log(title = "财务管理", businessType = BusinessType.EXPORT)
    @GetMapping("/export")
    public void export(HttpServletResponse response) throws Exception {
        List<SysFinance> list = financeService.selectFinanceList(new SysFinance());
        List<String> months = calculator.buildMonthAxis(list);
        List<FinanceCalculator.Row> rows = new ArrayList<>(list.size());
        for (SysFinance f : list) {
            rows.add(calculator.calculate(f, months));
        }
        writeExcel(response, rows, months);
    }

    /**
     * Excel 渲染：只管样式与写单元格，金额全部来自 Row
     */
    private void writeExcel(HttpServletResponse response, List<FinanceCalculator.Row> rows,
                            List<String> months) throws Exception {
        String[] heads = {"名称", "便宜", "提前结清", "总额", "日期", "几号", "剩余", "状态"};
        int ms = heads.length;

        SXSSFWorkbook wb = new SXSSFWorkbook();
        try {
            Sheet sheet = wb.createSheet("财务管理");

            CellStyle hs = headerStyle(wb);
            CellStyle cs = centerStyle(wb);
            CellStyle ns = numberStyle(wb);

            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < heads.length; i++) {
                Cell c = headerRow.createCell(i);
                c.setCellValue(heads[i]);
                c.setCellStyle(hs);
            }
            for (int i = 0; i < months.size(); i++) {
                Cell c = headerRow.createCell(ms + i);
                c.setCellValue(months.get(i));
                c.setCellStyle(hs);
            }

            int[] widths = {4000, 3500, 3500, 3500, 3000, 2000, 3500, 2000};
            for (int i = 0; i < widths.length; i++) {
                sheet.setColumnWidth(i, widths[i]);
            }
            for (int i = 0; i < months.size(); i++) {
                sheet.setColumnWidth(ms + i, 3000);
            }

            // 数据行
            for (int r = 0; r < rows.size(); r++) {
                FinanceCalculator.Row row = rows.get(r);
                SysFinance f = row.getFinance();
                Row xRow = sheet.createRow(r + 1);

                setCell(xRow, 0, str(f.getCreditorName()), null);
                setCell(xRow, 1, row.getCheap().doubleValue(), ns);
                setCell(xRow, 2, nvl(f.getEarlySettlementAmount()).doubleValue(), ns);
                setCell(xRow, 3, row.getTotalRepay().doubleValue(), ns);
                setCell(xRow, 4, f.getRepaymentStartDate() != null ? f.getRepaymentStartDate().toString() : "", cs);
                setCell(xRow, 5, f.getRepaymentDay() != null ? String.valueOf(f.getRepaymentDay()) : "", cs);
                setCell(xRow, 6, row.getRemaining().doubleValue(), ns);
                setCell(xRow, 7, statusLabel(f.getStatus()), cs);
                for (int i = 0; i < months.size(); i++) {
                    double v = row.getAmount(months.get(i)).doubleValue();
                    setCell(xRow, ms + i, Math.max(v, 0), ns);
                }
            }

            // 合计行
            Row sumRow = sheet.createRow(rows.size() + 1);
            CellStyle ss = sumStyle(wb);
            setCell(sumRow, 0, "合计", ss);
            setCell(sumRow, 1, rows.stream().mapToDouble(r -> r.getCheap().doubleValue()).sum(), ns);
            setCell(sumRow, 2, rows.stream().mapToDouble(r -> nvl(r.getFinance().getEarlySettlementAmount()).doubleValue()).sum(), ns);
            setCell(sumRow, 3, rows.stream().mapToDouble(r -> r.getTotalRepay().doubleValue()).sum(), ns);
            setCell(sumRow, 6, rows.stream().mapToDouble(r -> r.getRemaining().doubleValue()).sum(), ns);
            for (int i = 0; i < months.size(); i++) {
                String m = months.get(i);
                double val = rows.stream().mapToDouble(r -> r.getAmount(m).doubleValue()).sum();
                setCell(sumRow, ms + i, Math.max(val, 0), ns);
            }

            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode("财务管理.xlsx", "UTF-8"));
            wb.write(response.getOutputStream());
        } finally {
            wb.dispose();
        }
    }

    private CellStyle headerStyle(SXSSFWorkbook wb) {
        Font hf = wb.createFont();
        hf.setBold(true);
        hf.setFontHeightInPoints((short) 11);
        CellStyle hs = wb.createCellStyle();
        hs.setFont(hf);
        hs.setAlignment(HorizontalAlignment.CENTER);
        hs.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        hs.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        hs.setBorderBottom(BorderStyle.THIN);
        hs.setBorderTop(BorderStyle.THIN);
        hs.setBorderLeft(BorderStyle.THIN);
        hs.setBorderRight(BorderStyle.THIN);
        return hs;
    }

    private CellStyle sumStyle(SXSSFWorkbook wb) {
        Font sf = wb.createFont();
        sf.setBold(true);
        CellStyle ss = wb.createCellStyle();
        ss.setFont(sf);
        ss.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        ss.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return ss;
    }

    private CellStyle centerStyle(SXSSFWorkbook wb) {
        CellStyle cs = wb.createCellStyle();
        cs.setAlignment(HorizontalAlignment.CENTER);
        return cs;
    }

    private CellStyle numberStyle(SXSSFWorkbook wb) {
        CellStyle ns = wb.createCellStyle();
        ns.setAlignment(HorizontalAlignment.RIGHT);
        ns.setDataFormat(wb.createDataFormat().getFormat("#,##0.00"));
        return ns;
    }

    private void setCell(Row row, int i, Object v, CellStyle s) {
        Cell c = row.createCell(i);
        if (v instanceof Number) {
            c.setCellValue(((Number) v).doubleValue());
            c.setCellStyle(s);
        } else {
            c.setCellValue(v != null ? v.toString() : "");
            if (s != null) {
                c.setCellStyle(s);
            }
        }
    }

    private String str(String s) {
        return s == null ? "" : s;
    }

    private String statusLabel(String s) {
        if ("0".equals(s)) return "还款中";
        if ("1".equals(s)) return "已结清";
        if ("2".equals(s)) return "逾期";
        return "";
    }

    private BigDecimal nvl(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}

package com.ddss.workflow.vo;

import java.util.List;

/** 工作流内部查询分页结果 */
public class WorkflowPage<T> {
    private long total;
    private List<T> rows;

    public WorkflowPage() {}
    public WorkflowPage(long total, List<T> rows) { this.total = total; this.rows = rows; }
    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }
    public List<T> getRows() { return rows; }
    public void setRows(List<T> rows) { this.rows = rows; }
}

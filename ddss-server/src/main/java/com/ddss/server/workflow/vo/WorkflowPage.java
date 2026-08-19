package com.ddss.server.workflow.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * 工作流内部查询分页结果
 *
 * @author ddss
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class WorkflowPage<T> {

    /** 总记录数 */
    private long total;

    /** 当前页数据 */
    private List<T> rows;

}
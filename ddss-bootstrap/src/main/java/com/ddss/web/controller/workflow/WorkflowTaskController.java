package com.ddss.web.controller.workflow;

import com.ddss.common.annotation.Log;
import com.ddss.common.constant.HttpStatus;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.server.workflow.WorkflowTaskService;
import com.ddss.server.workflow.vo.WorkflowApproveBody;
import com.ddss.server.workflow.vo.WorkflowPage;
import com.ddss.server.workflow.vo.WorkflowTaskVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 工作流任务（待办/已办/审批）
 *
 * @author ddss
 */
@RestController
@RequestMapping("/workflow/task")
public class WorkflowTaskController extends BaseController {

    @Autowired
    private WorkflowTaskService workflowTaskService;

    /**
     * 我的待办任务
     */
    @PreAuthorize("@ss.hasPermi('workflow:task:list')")
    @GetMapping("/todo")
    public TableDataInfo todo(@RequestParam(defaultValue = "1") int pageNum,
                              @RequestParam(defaultValue = "10") int pageSize) {
        WorkflowPage<WorkflowTaskVO> page = workflowTaskService.selectTodoList(getUsername(), pageNum, pageSize);
        return buildDataTable(page.getRows(), page.getTotal());
    }

    /**
     * 我的已办任务
     */
    @PreAuthorize("@ss.hasPermi('workflow:task:list')")
    @GetMapping("/done")
    public TableDataInfo done(@RequestParam(defaultValue = "1") int pageNum,
                              @RequestParam(defaultValue = "10") int pageSize) {
        WorkflowPage<WorkflowTaskVO> page = workflowTaskService.selectDoneList(getUsername(), pageNum, pageSize);
        return buildDataTable(page.getRows(), page.getTotal());
    }

    /**
     * 审批任务（同意/驳回）
     */
    @Log(title = "工作流审批", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('workflow:task:approve')")
    @PostMapping("/approve")
    public AjaxResult approve(@RequestBody WorkflowApproveBody body) {
        workflowTaskService.approve(body, getUsername());
        return success();
    }

    private TableDataInfo buildDataTable(List<WorkflowTaskVO> rows, long total) {
        TableDataInfo data = new TableDataInfo();
        data.setCode(HttpStatus.SUCCESS);
        data.setMsg("查询成功");
        data.setRows(rows);
        data.setTotal(total);
        return data;
    }

}
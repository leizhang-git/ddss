package com.ddss.server.workflow;

import com.ddss.server.workflow.vo.WorkflowApproveBody;
import com.ddss.server.workflow.vo.WorkflowPage;
import com.ddss.server.workflow.vo.WorkflowTaskVO;

/**
 * 工作流任务（待办/已办/审批）服务
 *
 * @author ddss
 */
public interface WorkflowTaskService {

    /**
     * 当前用户的待办任务（分页）
     */
    WorkflowPage<WorkflowTaskVO> selectTodoList(String currentUser, int pageNum, int pageSize);

    /**
     * 当前用户的已办任务（分页）
     */
    WorkflowPage<WorkflowTaskVO> selectDoneList(String currentUser, int pageNum, int pageSize);

    /**
     * 审批任务（同意/驳回）
     */
    void approve(WorkflowApproveBody body, String currentUser);

}
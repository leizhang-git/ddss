package com.ddss.workflow.service.impl;

import com.ddss.application.workflow.DecideWorkflowTask;
import com.ddss.application.workflow.DecisionResult;
import com.ddss.application.workflow.GetWorkflowDone;
import com.ddss.application.workflow.GetWorkflowTodo;
import com.ddss.application.workflow.WorkflowTaskPage;
import com.ddss.application.workflow.WorkflowTaskRow;
import com.ddss.common.exception.ServiceException;
import com.ddss.workflow.service.WorkflowTaskService;
import com.ddss.workflow.vo.WorkflowApproveBody;
import com.ddss.workflow.vo.WorkflowPage;
import com.ddss.workflow.vo.WorkflowTaskVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class WorkflowTaskServiceImpl implements WorkflowTaskService {

    @Autowired
    private GetWorkflowTodo getWorkflowTodo;

    @Autowired
    private GetWorkflowDone getWorkflowDone;

    @Autowired
    private DecideWorkflowTask decideWorkflowTask;

    @Override
    public WorkflowPage<WorkflowTaskVO> selectTodoList(String currentUser, int pageNum, int pageSize) {
        return toLegacyPage(getWorkflowTodo.execute(currentUser, pageNum, pageSize));
    }

    @Override
    public WorkflowPage<WorkflowTaskVO> selectDoneList(String currentUser, int pageNum, int pageSize) {
        return toLegacyPage(getWorkflowDone.execute(currentUser, pageNum, pageSize));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void approve(WorkflowApproveBody body, String currentUser) {
        DecisionResult result = decideWorkflowTask.execute(body == null ? null
                : new DecideWorkflowTask.DecisionCommand(body.getTaskId(), body.getApproved(),
                body.getComment(), currentUser));
        if (result instanceof DecisionResult.Rejected) {
            DecisionResult.Reason reason = ((DecisionResult.Rejected) result).reason();
            throw new ServiceException(switch (reason) {
                case TASK_ID_REQUIRED -> "任务ID不能为空";
                case DECISION_REQUIRED -> "审批结果不能为空";
                case ACTOR_REQUIRED -> "无权审批该任务";
                case TASK_NOT_FOUND -> "待办任务不存在或已处理";
                case NOT_ASSIGNEE -> "无权审批该任务";
            });
        }
    }

    private WorkflowPage<WorkflowTaskVO> toLegacyPage(WorkflowTaskPage page) {
        List<WorkflowTaskVO> rows = page.rows().stream().map(this::toLegacyRow).collect(Collectors.toList());
        return new WorkflowPage<>(page.total(), rows);
    }

    private WorkflowTaskVO toLegacyRow(WorkflowTaskRow row) {
        WorkflowTaskVO vo = new WorkflowTaskVO();
        vo.setTaskId(row.taskId());
        vo.setTaskName(row.taskName());
        vo.setProcessInstanceId(row.processInstanceId());
        vo.setTaskCreateTime(toDate(row.taskCreateTime()));
        vo.setLeaveId(row.leaveId());
        vo.setApplicant(row.applicant());
        vo.setApplyUserName(row.applyUserName());
        vo.setLeaveDays(row.leaveDays());
        vo.setStartDate(row.startDate());
        vo.setReason(row.reason());
        vo.setLeader(row.leader());
        vo.setBoss(row.boss());
        vo.setApproved(row.approved());
        vo.setComment(row.comment());
        vo.setFinishTime(toDate(row.finishTime()));
        return vo;
    }

    private Date toDate(java.time.Instant value) {
        return value == null ? null : Date.from(value);
    }
}

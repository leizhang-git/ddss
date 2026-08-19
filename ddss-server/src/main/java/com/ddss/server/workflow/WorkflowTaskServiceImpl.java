package com.ddss.server.workflow;

import com.ddss.common.exception.ServiceException;
import com.ddss.common.utils.StringUtils;
import com.ddss.server.domain.po.DdssLeave;
import com.ddss.server.mapper.DdssLeaveMapper;
import com.ddss.server.workflow.vo.WorkflowApproveBody;
import com.ddss.server.workflow.vo.WorkflowPage;
import com.ddss.server.workflow.vo.WorkflowTaskVO;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.flowable.engine.HistoryService;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.TaskService;
import org.flowable.task.api.Task;
import org.flowable.task.api.history.HistoricTaskInstance;
import org.flowable.variable.api.history.HistoricVariableInstance;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 工作流任务服务实现
 *
 * @author ddss
 */
@Service
public class WorkflowTaskServiceImpl implements WorkflowTaskService {

    @Autowired
    private TaskService taskService;

    @Autowired
    private HistoryService historyService;

    @Autowired
    private RuntimeService runtimeService;

    @Autowired
    private DdssLeaveMapper leaveMapper;

    @Override
    public WorkflowPage<WorkflowTaskVO> selectTodoList(String currentUser, int pageNum, int pageSize) {
        List<Task> tasks = taskService.createTaskQuery()
                .taskAssignee(currentUser)
                .orderByTaskCreateTime().desc()
                .listPage((pageNum - 1) * pageSize, pageSize);
        long total = taskService.createTaskQuery()
                .taskAssignee(currentUser)
                .count();
        Map<String, DdssLeave> leaveMap = loadLeaveMap(tasks.stream()
                .map(Task::getProcessInstanceId).collect(Collectors.toList()));
        List<WorkflowTaskVO> rows = new ArrayList<>();
        for (Task task : tasks) {
            rows.add(buildTodoVO(task, leaveMap.get(task.getProcessInstanceId())));
        }
        return new WorkflowPage<>(total, rows);
    }

    @Override
    public WorkflowPage<WorkflowTaskVO> selectDoneList(String currentUser, int pageNum, int pageSize) {
        List<HistoricTaskInstance> tasks = historyService.createHistoricTaskInstanceQuery()
                .taskAssignee(currentUser)
                .finished()
                .orderByHistoricTaskInstanceEndTime().desc()
                .listPage((pageNum - 1) * pageSize, pageSize);
        long total = historyService.createHistoricTaskInstanceQuery()
                .taskAssignee(currentUser)
                .finished()
                .count();
        Map<String, DdssLeave> leaveMap = loadLeaveMap(tasks.stream()
                .map(HistoricTaskInstance::getProcessInstanceId).collect(Collectors.toList()));
        // 按流程实例批量取任务本地变量（审批结论/意见）
        Map<String, Map<String, Object>> taskVars = loadTaskLocalVariables(tasks.stream()
                .map(HistoricTaskInstance::getProcessInstanceId).distinct().collect(Collectors.toList()));
        List<WorkflowTaskVO> rows = new ArrayList<>();
        for (HistoricTaskInstance task : tasks) {
            rows.add(buildDoneVO(task, leaveMap.get(task.getProcessInstanceId()),
                    taskVars.get(task.getId())));
        }
        return new WorkflowPage<>(total, rows);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void approve(WorkflowApproveBody body, String currentUser) {
        if (body == null || StringUtils.isEmpty(body.getTaskId())) {
            throw new ServiceException("任务ID不能为空");
        }
        if (body.getApproved() == null) {
            throw new ServiceException("审批结果不能为空");
        }
        Task task = taskService.createTaskQuery().taskId(body.getTaskId()).singleResult();
        if (task == null) {
            throw new ServiceException("待办任务不存在或已处理");
        }
        String assignee = task.getAssignee();
        if (StringUtils.isEmpty(assignee) || !assignee.equals(currentUser)) {
            throw new ServiceException("无权审批该任务");
        }
        boolean approved = body.getApproved();
        String comment = body.getComment();

        // 过程变量驱动排他网关 + 任务本地变量记录每一步结论
        taskService.setVariable(task.getId(), WorkflowConstants.VAR_APPROVED, approved);
        taskService.setVariable(task.getId(), WorkflowConstants.VAR_COMMENT, comment);
        taskService.setVariableLocal(task.getId(), WorkflowConstants.VAR_APPROVED_LOCAL, approved);
        taskService.setVariableLocal(task.getId(), WorkflowConstants.VAR_COMMENT_LOCAL, comment);
        taskService.complete(task.getId());

        // 流程结束 → 回写请假单业务状态
        String processInstanceId = task.getProcessInstanceId();
        long running = runtimeService.createProcessInstanceQuery()
                .processInstanceId(processInstanceId).count();
        if (running == 0) {
            DdssLeave leave = leaveMapper.selectOne(new QueryWrapper<DdssLeave>()
                    .eq("process_instance_id", processInstanceId).last("LIMIT 1"));
            if (leave != null) {
                DdssLeave update = new DdssLeave();
                update.setLeaveId(leave.getLeaveId());
                update.setStatus(approved ? WorkflowConstants.LEAVE_STATUS_PASS : WorkflowConstants.LEAVE_STATUS_REJECT);
                update.setUpdateBy(currentUser);
                update.setUpdateTime(LocalDateTime.now());
                leaveMapper.updateById(update);
            }
        }
    }

    /**
     * 批量加载请假单（key = processInstanceId）
     */
    private Map<String, DdssLeave> loadLeaveMap(List<String> processInstanceIds) {
        Map<String, DdssLeave> leaveMap = new HashMap<>();
        List<String> distinctIds = processInstanceIds.stream().distinct().collect(Collectors.toList());
        if (!distinctIds.isEmpty()) {
            List<DdssLeave> leaves = leaveMapper.selectList(new QueryWrapper<DdssLeave>()
                    .in("process_instance_id", distinctIds));
            leaveMap = leaves.stream().collect(Collectors.toMap(DdssLeave::getProcessInstanceId, Function.identity()));
        }
        return leaveMap;
    }

    /**
     * 批量加载已办任务的任务本地变量（key = taskId）
     */
    private Map<String, Map<String, Object>> loadTaskLocalVariables(List<String> processInstanceIds) {
        Map<String, Map<String, Object>> result = new HashMap<>();
        for (String processInstanceId : processInstanceIds) {
            List<HistoricVariableInstance> variables = historyService.createHistoricVariableInstanceQuery()
                    .processInstanceId(processInstanceId).list();
            for (HistoricVariableInstance variable : variables) {
                if (variable.getTaskId() == null) {
                    continue;
                }
                result.computeIfAbsent(variable.getTaskId(), k -> new HashMap<>())
                        .put(variable.getVariableName(), variable.getValue());
            }
        }
        return result;
    }

    private WorkflowTaskVO buildTodoVO(Task task, DdssLeave leave) {
        WorkflowTaskVO vo = new WorkflowTaskVO();
        vo.setTaskId(task.getId());
        vo.setTaskName(task.getName());
        vo.setProcessInstanceId(task.getProcessInstanceId());
        vo.setTaskCreateTime(task.getCreateTime());
        fillLeaveFields(vo, leave);
        return vo;
    }

    private WorkflowTaskVO buildDoneVO(HistoricTaskInstance task, DdssLeave leave, Map<String, Object> variables) {
        WorkflowTaskVO vo = new WorkflowTaskVO();
        vo.setTaskId(task.getId());
        vo.setTaskName(task.getName());
        vo.setProcessInstanceId(task.getProcessInstanceId());
        vo.setTaskCreateTime(task.getCreateTime());
        vo.setFinishTime(task.getEndTime());
        if (variables != null) {
            Object approved = variables.get(WorkflowConstants.VAR_APPROVED_LOCAL);
            if (approved != null) {
                vo.setApproved(Boolean.valueOf(approved.toString()));
            }
            Object comment = variables.get(WorkflowConstants.VAR_COMMENT_LOCAL);
            if (comment != null) {
                vo.setComment(comment.toString());
            }
        }
        fillLeaveFields(vo, leave);
        return vo;
    }

    private void fillLeaveFields(WorkflowTaskVO vo, DdssLeave leave) {
        if (leave != null) {
            vo.setLeaveId(leave.getLeaveId());
            vo.setApplicant(leave.getApplyUser());
            vo.setApplyUserName(leave.getApplyUserName());
            vo.setLeaveDays(leave.getLeaveDays());
            vo.setStartDate(leave.getStartDate());
            vo.setReason(leave.getReason());
            vo.setLeader(leave.getLeader());
            vo.setBoss(leave.getBoss());
        }
    }

}
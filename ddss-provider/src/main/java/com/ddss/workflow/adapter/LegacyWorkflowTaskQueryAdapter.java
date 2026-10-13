package com.ddss.workflow.adapter;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.ddss.application.workflow.WorkflowTaskPage;
import com.ddss.application.workflow.WorkflowTaskQueryPort;
import com.ddss.application.workflow.WorkflowTaskRow;
import com.ddss.workflow.WorkflowConstants;
import com.ddss.workflow.domain.DdssLeave;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import org.flowable.engine.HistoryService;
import org.flowable.engine.TaskService;
import org.flowable.task.api.Task;
import org.flowable.task.api.history.HistoricTaskInstance;
import org.flowable.variable.api.history.HistoricVariableInstance;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

public final class LegacyWorkflowTaskQueryAdapter implements WorkflowTaskQueryPort {
    private final TaskService taskService;
    private final HistoryService historyService;
    private final DdssLeaveMapper leaveMapper;

    public LegacyWorkflowTaskQueryAdapter(TaskService taskService, HistoryService historyService,
                                          DdssLeaveMapper leaveMapper) {
        this.taskService = Objects.requireNonNull(taskService, "taskService");
        this.historyService = Objects.requireNonNull(historyService, "historyService");
        this.leaveMapper = Objects.requireNonNull(leaveMapper, "leaveMapper");
    }

    @Override
    public WorkflowTaskPage findTodo(String actor, int pageNum, int pageSize) {
        List<Task> tasks = taskService.createTaskQuery()
                .taskAssignee(actor)
                .orderByTaskCreateTime().desc()
                .listPage((pageNum - 1) * pageSize, pageSize);
        long total = taskService.createTaskQuery()
                .taskAssignee(actor)
                .count();
        Map<String, DdssLeave> leaves = loadLeaveMap(tasks.stream()
                .map(Task::getProcessInstanceId).collect(Collectors.toList()));
        List<WorkflowTaskRow> rows = new ArrayList<>();
        for (Task task : tasks) {
            rows.add(toTodoRow(task, leaves.get(task.getProcessInstanceId())));
        }
        return new WorkflowTaskPage(total, rows);
    }

    @Override
    public WorkflowTaskPage findDone(String actor, int pageNum, int pageSize) {
        List<HistoricTaskInstance> tasks = historyService.createHistoricTaskInstanceQuery()
                .taskAssignee(actor)
                .finished()
                .orderByHistoricTaskInstanceEndTime().desc()
                .listPage((pageNum - 1) * pageSize, pageSize);
        long total = historyService.createHistoricTaskInstanceQuery()
                .taskAssignee(actor)
                .finished()
                .count();
        List<String> processInstanceIds = tasks.stream()
                .map(HistoricTaskInstance::getProcessInstanceId).collect(Collectors.toList());
        Map<String, DdssLeave> leaves = loadLeaveMap(processInstanceIds);
        Map<String, Map<String, Object>> taskVariables = loadTaskLocalVariables(processInstanceIds.stream()
                .distinct().collect(Collectors.toList()));
        List<WorkflowTaskRow> rows = new ArrayList<>();
        for (HistoricTaskInstance task : tasks) {
            rows.add(toDoneRow(task, leaves.get(task.getProcessInstanceId()), taskVariables.get(task.getId())));
        }
        return new WorkflowTaskPage(total, rows);
    }

    private Map<String, DdssLeave> loadLeaveMap(List<String> processInstanceIds) {
        List<String> distinctIds = processInstanceIds.stream().distinct().collect(Collectors.toList());
        if (distinctIds.isEmpty()) {
            return Map.of();
        }
        List<DdssLeave> leaves = leaveMapper.selectList(new QueryWrapper<DdssLeave>()
                .in("process_instance_id", distinctIds));
        return leaves.stream().collect(Collectors.toMap(DdssLeave::getProcessInstanceId, Function.identity()));
    }

    private Map<String, Map<String, Object>> loadTaskLocalVariables(List<String> processInstanceIds) {
        Map<String, Map<String, Object>> result = new HashMap<>();
        for (String processInstanceId : processInstanceIds) {
            List<HistoricVariableInstance> variables = historyService.createHistoricVariableInstanceQuery()
                    .processInstanceId(processInstanceId).list();
            for (HistoricVariableInstance variable : variables) {
                if (variable.getTaskId() == null) {
                    continue;
                }
                result.computeIfAbsent(variable.getTaskId(), key -> new HashMap<>())
                        .put(variable.getVariableName(), variable.getValue());
            }
        }
        return result;
    }

    private WorkflowTaskRow toTodoRow(Task task, DdssLeave leave) {
        return new WorkflowTaskRow(task.getId(), task.getName(), task.getProcessInstanceId(),
                toInstant(task.getCreateTime()), leave == null ? null : leave.getLeaveId(),
                leave == null ? null : leave.getApplyUser(), leave == null ? null : leave.getApplyUserName(),
                leave == null ? null : leave.getLeaveDays(), leave == null ? null : leave.getStartDate(),
                leave == null ? null : leave.getReason(), leave == null ? null : leave.getLeader(),
                leave == null ? null : leave.getBoss(), null, null, null);
    }

    private WorkflowTaskRow toDoneRow(HistoricTaskInstance task, DdssLeave leave,
                                      Map<String, Object> variables) {
        Boolean approved = null;
        String comment = null;
        if (variables != null) {
            Object approvedValue = variables.get(WorkflowConstants.VAR_APPROVED_LOCAL);
            if (approvedValue != null) {
                approved = Boolean.valueOf(approvedValue.toString());
            }
            Object commentValue = variables.get(WorkflowConstants.VAR_COMMENT_LOCAL);
            if (commentValue != null) {
                comment = commentValue.toString();
            }
        }
        return new WorkflowTaskRow(task.getId(), task.getName(), task.getProcessInstanceId(),
                toInstant(task.getCreateTime()), leave == null ? null : leave.getLeaveId(),
                leave == null ? null : leave.getApplyUser(), leave == null ? null : leave.getApplyUserName(),
                leave == null ? null : leave.getLeaveDays(), leave == null ? null : leave.getStartDate(),
                leave == null ? null : leave.getReason(), leave == null ? null : leave.getLeader(),
                leave == null ? null : leave.getBoss(), approved, comment, toInstant(task.getEndTime()));
    }

    private Instant toInstant(Date value) {
        return value == null ? null : value.toInstant();
    }
}

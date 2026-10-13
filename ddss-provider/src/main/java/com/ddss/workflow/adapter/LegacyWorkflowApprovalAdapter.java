package com.ddss.workflow.adapter;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.ddss.application.workflow.WorkflowApprovalPort;
import com.ddss.application.workflow.WorkflowTaskSnapshot;
import com.ddss.domain.workflow.LeaveStatus;
import com.ddss.workflow.WorkflowConstants;
import com.ddss.workflow.domain.DdssLeave;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.TaskService;
import org.flowable.engine.runtime.ProcessInstanceQuery;
import org.flowable.task.api.Task;

import java.time.LocalDateTime;
import java.util.Objects;
import java.util.Optional;

public final class LegacyWorkflowApprovalAdapter implements WorkflowApprovalPort {
    private final TaskService taskService;
    private final RuntimeService runtimeService;
    private final DdssLeaveMapper leaveMapper;

    public LegacyWorkflowApprovalAdapter(TaskService taskService, RuntimeService runtimeService,
                                        DdssLeaveMapper leaveMapper) {
        this.taskService = Objects.requireNonNull(taskService, "taskService");
        this.runtimeService = Objects.requireNonNull(runtimeService, "runtimeService");
        this.leaveMapper = Objects.requireNonNull(leaveMapper, "leaveMapper");
    }

    @Override
    public Optional<WorkflowTaskSnapshot> findActiveTask(String taskId) {
        Task task = taskService.createTaskQuery().taskId(taskId).singleResult();
        if (task == null) {
            return Optional.empty();
        }
        return Optional.of(new WorkflowTaskSnapshot(task.getId(), task.getProcessInstanceId(), task.getAssignee()));
    }

    @Override
    public void completeTask(String taskId, boolean approved, String comment) {
        taskService.setVariable(taskId, WorkflowConstants.VAR_APPROVED, approved);
        taskService.setVariable(taskId, WorkflowConstants.VAR_COMMENT, comment);
        taskService.setVariableLocal(taskId, WorkflowConstants.VAR_APPROVED_LOCAL, approved);
        taskService.setVariableLocal(taskId, WorkflowConstants.VAR_COMMENT_LOCAL, comment);
        taskService.complete(taskId);
    }

    @Override
    public boolean isProcessRunning(String processInstanceId) {
        return runtimeService.createProcessInstanceQuery().processInstanceId(processInstanceId).count() > 0;
    }

    @Override
    public void updateLeaveStatus(String processInstanceId, LeaveStatus status, String actor) {
        DdssLeave leave = leaveMapper.selectOne(new QueryWrapper<DdssLeave>()
                .eq("process_instance_id", processInstanceId).last("LIMIT 1"));
        if (leave == null) {
            return;
        }
        DdssLeave update = new DdssLeave();
        update.setLeaveId(leave.getLeaveId());
        update.setStatus(toLegacyStatus(status));
        update.setUpdateBy(actor);
        update.setUpdateTime(LocalDateTime.now());
        if (leaveMapper.updateById(update) != 1) {
            throw new IllegalStateException("Leave application status was not updated after workflow completion");
        }
    }

    private String toLegacyStatus(LeaveStatus status) {
        return switch (status) {
            case APPROVED -> WorkflowConstants.LEAVE_STATUS_PASS;
            case REJECTED -> WorkflowConstants.LEAVE_STATUS_REJECT;
            case PENDING -> throw new IllegalArgumentException("A completed workflow cannot restore pending status");
        };
    }
}

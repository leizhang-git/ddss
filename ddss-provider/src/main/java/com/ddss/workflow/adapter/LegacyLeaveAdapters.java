package com.ddss.workflow.adapter;

import com.ddss.application.workflow.LeaveApplicationPort;
import com.ddss.application.workflow.WorkflowProcessPort;
import com.ddss.domain.workflow.LeaveApplication;
import com.ddss.workflow.WorkflowConstants;
import com.ddss.workflow.domain.DdssLeave;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.runtime.ProcessInstance;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public final class LegacyLeaveAdapters {
    private LegacyLeaveAdapters() { }

    public static final class Persistence implements LeaveApplicationPort {
        private final DdssLeaveMapper mapper;

        public Persistence(DdssLeaveMapper mapper) {
            this.mapper = Objects.requireNonNull(mapper, "mapper");
        }

        @Override
        public long insert(LeaveApplication application) {
            DdssLeave leave = new DdssLeave();
            leave.setApplyUser(application.applicant());
            leave.setApplyUserName(application.applicantName());
            leave.setLeaveDays(application.days().value());
            leave.setStartDate(application.startDate());
            leave.setReason(application.reason());
            leave.setLeader(application.leader());
            leave.setBoss(application.boss());
            leave.setStatus(WorkflowConstants.LEAVE_STATUS_PENDING);
            leave.setCreateBy(application.applicant());
            leave.setCreateTime(LocalDateTime.now());
            mapper.insert(leave);
            if (leave.getLeaveId() == null) {
                throw new IllegalStateException("Persistence did not return the leave identifier");
            }
            return leave.getLeaveId();
        }

        @Override
        public void delete(long leaveId) {
            if (mapper.deleteById(leaveId) != 1) {
                throw new IllegalStateException("Leave application could not be removed after process start failure");
            }
        }

        @Override
        public void updateStatus(long leaveId, String processInstanceId) {
            DdssLeave update = new DdssLeave();
            update.setLeaveId(leaveId);
            update.setProcessInstanceId(processInstanceId);
            update.setUpdateBy("workflow");
            update.setUpdateTime(LocalDateTime.now());
            if (mapper.updateById(update) != 1) {
                throw new IllegalStateException("Leave application was not linked to its workflow process");
            }
        }
    }

    public static final class Process implements WorkflowProcessPort {
        private final RuntimeService runtimeService;

        public Process(RuntimeService runtimeService) {
            this.runtimeService = Objects.requireNonNull(runtimeService, "runtimeService");
        }

        @Override
        public String startLeave(String businessKey, LeaveApplication application) {
            ProcessInstance processInstance = runtimeService.startProcessInstanceByKey(
                    WorkflowConstants.PROCESS_KEY, businessKey, variables(application));
            return processInstance == null ? null : processInstance.getId();
        }

        @Override
        public void cancel(String processInstanceId, String reason) {
            runtimeService.deleteProcessInstance(processInstanceId, reason);
        }

        @Override
        public boolean isRunning(String processInstanceId) {
            return runtimeService.createProcessInstanceQuery().processInstanceId(processInstanceId).count() > 0;
        }

        private Map<String, Object> variables(LeaveApplication application) {
            Map<String, Object> variables = new HashMap<>();
            variables.put(WorkflowConstants.VAR_LEADER, application.leader());
            variables.put(WorkflowConstants.VAR_BOSS, application.boss());
            variables.put("days", application.days().value());
            variables.put("reason", application.reason());
            variables.put("applicant", application.applicant());
            return variables;
        }
    }
}

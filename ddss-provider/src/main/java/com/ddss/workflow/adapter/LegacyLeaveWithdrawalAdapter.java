package com.ddss.workflow.adapter;

import com.ddss.application.workflow.LeaveWithdrawalPort;
import com.ddss.application.workflow.LeaveWithdrawalSnapshot;
import com.ddss.workflow.domain.DdssLeave;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import org.flowable.engine.RuntimeService;

import java.util.Objects;
import java.util.Optional;

public final class LegacyLeaveWithdrawalAdapter implements LeaveWithdrawalPort {
    private final DdssLeaveMapper leaveMapper;
    private final RuntimeService runtimeService;

    public LegacyLeaveWithdrawalAdapter(DdssLeaveMapper leaveMapper, RuntimeService runtimeService) {
        this.leaveMapper = Objects.requireNonNull(leaveMapper, "leaveMapper");
        this.runtimeService = Objects.requireNonNull(runtimeService, "runtimeService");
    }

    @Override
    public Optional<LeaveWithdrawalSnapshot> find(long leaveId) {
        DdssLeave leave = leaveMapper.selectById(leaveId);
        if (leave == null) {
            return Optional.empty();
        }
        return Optional.of(new LeaveWithdrawalSnapshot(leaveId, leave.getApplyUser(), leave.getProcessInstanceId()));
    }

    @Override
    public void cancelProcess(String processInstanceId, String reason) {
        runtimeService.deleteProcessInstance(processInstanceId, reason);
    }

    @Override
    public boolean isProcessRunning(String processInstanceId) {
        return runtimeService.createProcessInstanceQuery().processInstanceId(processInstanceId).count() > 0;
    }

    @Override
    public void delete(long leaveId) {
        if (leaveMapper.deleteById(leaveId) != 1) {
            throw new IllegalStateException("Leave application was not deleted");
        }
    }
}

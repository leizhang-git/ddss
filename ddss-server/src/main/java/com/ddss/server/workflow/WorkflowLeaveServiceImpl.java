package com.ddss.server.workflow.vo;

import com.ddss.common.exception.ServiceException;
import com.ddss.common.utils.StringUtils;
import com.ddss.server.domain.po.DdssLeave;
import com.ddss.server.mapper.DdssLeaveMapper;
import com.ddss.server.workflow.WorkflowConstants;
import com.ddss.server.workflow.WorkflowLeaveService;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.runtime.ProcessInstance;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 请假申请工作流服务实现
 *
 * @author ddss
 */
@Service
public class WorkflowLeaveServiceImpl implements WorkflowLeaveService {

    @Autowired
    private DdssLeaveMapper leaveMapper;

    @Autowired
    private RuntimeService runtimeService;

    @Override
    public List<DdssLeave> selectLeaveList(DdssLeave leave, String currentUser) {
        QueryWrapper<DdssLeave> wrapper = new QueryWrapper<>();
        wrapper.eq("apply_user", currentUser);
        if (leave != null) {
            if (StringUtils.isNotEmpty(leave.getReason())) {
                wrapper.like("reason", leave.getReason());
            }
            if (StringUtils.isNotEmpty(leave.getStatus())) {
                wrapper.eq("status", leave.getStatus());
            }
        }
        wrapper.orderByDesc("create_time");
        return leaveMapper.selectList(wrapper);
    }

    @Override
    public DdssLeave selectLeaveById(Long leaveId) {
        return leaveMapper.selectById(leaveId);
    }

    @Override
    public boolean startLeave(DdssLeave leave, String currentUser) {
        if (leave == null) {
            throw new ServiceException("请假单信息不能为空");
        }
        if (StringUtils.isEmpty(currentUser)) {
            throw new ServiceException("申请人不能为空");
        }
        leave.setApplyUser(currentUser);
        leave.setStatus(WorkflowConstants.LEAVE_STATUS_PENDING);
        leave.setCreateBy(currentUser);
        leave.setCreateTime(LocalDateTime.now());
        // 先落库拿到主键，作为流程实例的 businessKey
        leaveMapper.insert(leave);

        // 启动演示流程（两级审批：部门经理 leader → 总经理 boss）
        ProcessInstance processInstance = runtimeService.startProcessInstanceByKey(
                WorkflowConstants.PROCESS_KEY,
                String.valueOf(leave.getLeaveId()),
                buildProcessVariables(leave));
        if (processInstance == null) {
            throw new ServiceException("流程启动失败");
        }
        DdssLeave update = new DdssLeave();
        update.setLeaveId(leave.getLeaveId());
        update.setProcessInstanceId(processInstance.getId());
        update.setUpdateBy(currentUser);
        update.setUpdateTime(LocalDateTime.now());
        leaveMapper.updateById(update);
        return true;
    }

    @Override
    public boolean deleteLeaveByIds(Long[] leaveIds, String currentUser) {
        if (leaveIds == null || leaveIds.length == 0) {
            return false;
        }
        for (Long leaveId : leaveIds) {
            DdssLeave leave = leaveMapper.selectById(leaveId);
            if (leave == null) {
                continue;
            }
            if (!currentUser.equals(leave.getApplyUser())) {
                throw new ServiceException("只能删除本人发起的申请");
            }
            // 流程未结束时先终止
            String processInstanceId = leave.getProcessInstanceId();
            if (StringUtils.isNotEmpty(processInstanceId)
                    && runtimeService.createProcessInstanceQuery().processInstanceId(processInstanceId).count() > 0) {
                runtimeService.deleteProcessInstance(processInstanceId, "申请人删除申请单");
            }
            leaveMapper.deleteById(leaveId);
        }
        return true;
    }

    /**
     * 组装流程启动变量
     */
    private java.util.Map<String, Object> buildProcessVariables(DdssLeave leave) {
        java.util.Map<String, Object> variables = new java.util.HashMap<>();
        variables.put(WorkflowConstants.VAR_LEADER, leave.getLeader());
        variables.put(WorkflowConstants.VAR_BOSS, leave.getBoss());
        variables.put("days", leave.getLeaveDays());
        variables.put("reason", leave.getReason());
        variables.put("applicant", leave.getApplyUser());
        return variables;
    }

}
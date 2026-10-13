package com.ddss.workflow.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.ddss.application.workflow.SubmitLeave;
import com.ddss.application.workflow.SubmissionResult;
import com.ddss.application.workflow.WithdrawLeaveApplications;
import com.ddss.application.workflow.WithdrawalResult;
import com.ddss.common.exception.ServiceException;
import com.ddss.common.utils.StringUtils;
import com.ddss.domain.workflow.LeaveApplication;
import com.ddss.domain.workflow.LeaveDays;
import com.ddss.workflow.WorkflowConstants;
import com.ddss.workflow.domain.DdssLeave;
import com.ddss.workflow.mapper.DdssLeaveMapper;
import com.ddss.workflow.service.WorkflowLeaveService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
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
    private SubmitLeave submitLeave;

    @Autowired
    private WithdrawLeaveApplications withdrawLeaveApplications;

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
    @Transactional(rollbackFor = Exception.class)
    public boolean startLeave(DdssLeave leave, String currentUser) {
        if (leave == null) {
            throw new ServiceException("请假单信息不能为空");
        }
        if (StringUtils.isEmpty(currentUser)) {
            throw new ServiceException("申请人不能为空");
        }
        LeaveDays days = validateLeaveDays(leave.getLeaveDays());
        String applicantName = StringUtils.isNotEmpty(leave.getApplyUserName())
                ? leave.getApplyUserName() : currentUser;
        LeaveApplication application;
        try {
            application = LeaveApplication.submit(currentUser, applicantName, days, leave.getStartDate(),
                    leave.getReason(), leave.getLeader(), leave.getBoss());
        } catch (IllegalArgumentException | NullPointerException exception) {
            throw new ServiceException(exception.getMessage(), exception);
        }
        SubmissionResult result = submitLeave.execute(application);
        if (result instanceof SubmissionResult.Rejected) {
            throw new ServiceException("流程启动失败: " + ((SubmissionResult.Rejected) result).reason());
        }
        SubmissionResult.Submitted submitted = (SubmissionResult.Submitted) result;
        leave.setLeaveId(submitted.leaveId());
        leave.setApplyUser(currentUser);
        leave.setApplyUserName(applicantName);
        leave.setStatus(WorkflowConstants.LEAVE_STATUS_PENDING);
        leave.setProcessInstanceId(submitted.processInstanceId());
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteLeaveByIds(Long[] leaveIds, String currentUser) {
        WithdrawalResult result = withdrawLeaveApplications.execute(leaveIds, currentUser);
        if (result instanceof WithdrawalResult.Rejected) {
            WithdrawalResult.Reason reason = ((WithdrawalResult.Rejected) result).reason();
            throw new ServiceException(switch (reason) {
                case ACTOR_REQUIRED -> "申请人不能为空";
                case NOT_OWNER -> "只能删除本人发起的申请";
            });
        }
        return ((WithdrawalResult.Completed) result).deleted();
    }

    private LeaveDays validateLeaveDays(BigDecimal leaveDays) {
        try {
            return LeaveDays.of(leaveDays);
        } catch (NullPointerException | IllegalArgumentException exception) {
            throw new ServiceException("请假天数必须在0.5至30天之间，且按0.5天递增", exception);
        }
    }

}
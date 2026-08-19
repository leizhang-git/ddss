package com.ddss.server.workflow;

import com.ddss.server.domain.po.DdssLeave;

import java.util.List;

/**
 * 请假申请工作流服务
 *
 * @author ddss
 */
public interface WorkflowLeaveService {

    /**
     * 查询当前用户发起的请假申请列表
     */
    List<DdssLeave> selectLeaveList(DdssLeave leave, String currentUser);

    /**
     * 查询请假申请详情
     */
    DdssLeave selectLeaveById(Long leaveId);

    /**
     * 发起请假：保存业务数据并启动流程实例
     */
    boolean startLeave(DdssLeave leave, String currentUser);

    /**
     * 删除请假申请（流程未结束时先终止流程实例）
     */
    boolean deleteLeaveByIds(Long[] leaveIds, String currentUser);

}
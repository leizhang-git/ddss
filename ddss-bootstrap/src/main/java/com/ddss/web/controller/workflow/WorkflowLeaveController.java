package com.ddss.web.controller.workflow;

import com.ddss.common.annotation.Log;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.domain.entity.SysUser;
import com.ddss.common.core.domain.model.LoginUser;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.common.utils.StringUtils;
import com.ddss.server.domain.po.DdssLeave;
import com.ddss.server.workflow.WorkflowLeaveService;
import com.ddss.system.service.ISysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 请假申请工作流
 *
 * @author ddss
 */
@RestController
@RequestMapping("/workflow/leave")
public class WorkflowLeaveController extends BaseController {

    @Autowired
    private WorkflowLeaveService workflowLeaveService;

    @Autowired
    private ISysUserService userService;

    /**
     * 我的请假申请列表
     */
    @PreAuthorize("@ss.hasPermi('workflow:leave:list')")
    @GetMapping("/list")
    public TableDataInfo list(DdssLeave leave) {
        startPage();
        List<DdssLeave> list = workflowLeaveService.selectLeaveList(leave, getUsername());
        return getDataTable(list);
    }

    /**
     * 请假申请详情
     */
    @PreAuthorize("@ss.hasPermi('workflow:leave:list')")
    @GetMapping("/{leaveId}")
    public AjaxResult getInfo(@PathVariable Long leaveId) {
        return success(workflowLeaveService.selectLeaveById(leaveId));
    }

    /**
     * 发起请假申请（同时启动流程实例）
     */
    @Log(title = "请假申请", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('workflow:leave:add')")
    @PostMapping
    public AjaxResult add(@RequestBody DdssLeave leave) {
        LoginUser loginUser = getLoginUser();
        leave.setApplyUser(loginUser.getUsername());
        leave.setApplyUserName(loginUser.getUser() != null
                && StringUtils.isNotEmpty(loginUser.getUser().getNickName())
                ? loginUser.getUser().getNickName() : loginUser.getUsername());
        return toAjax(workflowLeaveService.startLeave(leave, loginUser.getUsername()));
    }

    /**
     * 删除请假申请
     */
    @Log(title = "请假申请", businessType = BusinessType.DELETE)
    @PreAuthorize("@ss.hasPermi('workflow:leave:remove')")
    @DeleteMapping("/{leaveIds}")
    public AjaxResult remove(@PathVariable Long[] leaveIds) {
        return toAjax(workflowLeaveService.deleteLeaveByIds(leaveIds, getUsername()));
    }

    /**
     * 可用审批人下拉（正常状态的用户）
     */
    @GetMapping("/userOptions")
    public AjaxResult userOptions() {
        SysUser query = new SysUser();
        query.setStatus("0");
        List<SysUser> users = userService.selectUserList(query);
        List<Map<String, Object>> options = new ArrayList<>();
        for (SysUser user : users) {
            Map<String, Object> item = new HashMap<>();
            item.put("userId", user.getUserId());
            item.put("userName", user.getUserName());
            item.put("nickName", user.getNickName());
            item.put("label", StringUtils.isNotEmpty(user.getNickName()) ? user.getNickName() : user.getUserName());
            options.add(item);
        }
        return AjaxResult.success(options);
    }

}
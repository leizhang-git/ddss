package com.ddss.server.web;

import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.domain.entity.SysRole;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * @Author zhanglei
 * @Date 2025/12/8 15:55
 */
@RestController
@RequestMapping("/api/v1/ddss/test")
public class DDSSTsetController {

    @PreAuthorize("@ss.hasPermi('system:role:list')")
    @GetMapping("/list")
    public AjaxResult list(SysRole role) {
        startPage();
        List<SysRole> list = roleService.selectRoleList(role);
        return getDataTable(list);
    }
}

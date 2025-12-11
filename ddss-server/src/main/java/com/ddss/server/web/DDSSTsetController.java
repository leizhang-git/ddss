package com.ddss.server.web;

import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.domain.entity.SysRole;
import com.ddss.server.service.DdssSysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


/**
 * @Author zhanglei
 * @Date 2025/12/8 15:55
 */
@RestController
@RequestMapping("/api/v1/ddss/test")
public class DDSSTsetController {

    @Autowired
    private DdssSysUserService ddssSysUserService;

    @GetMapping("/createManyData")
    public AjaxResult list(SysRole role) {
        ddssSysUserService.testCreateManyData();
        return AjaxResult.success();
    }

    public static void main(String[] args) {
        String str = "123";
        String[] split = str.split(",");
        System.out.println(split);
    }
}

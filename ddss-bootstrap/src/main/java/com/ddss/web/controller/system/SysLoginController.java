package com.ddss.web.controller.system;

import com.ddss.common.constant.SystemConstants;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.domain.entity.SysMenu;
import com.ddss.common.core.domain.entity.SysUser;
import com.ddss.common.core.domain.model.LoginBody;
import com.ddss.common.core.domain.model.LoginUser;
import com.ddss.common.core.text.Convert;
import com.ddss.common.utils.DateUtils;
import com.ddss.common.utils.SecurityUtils;
import com.ddss.common.utils.StringUtils;
import com.ddss.framework.web.service.SysLoginService;
import com.ddss.framework.web.service.SysPermissionService;
import com.ddss.framework.web.service.TokenService;
import com.ddss.system.service.ISysConfigService;
import com.ddss.system.service.ISysMenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.*;

/**
 * 登录验证（支持无 MySQL 开发模式）
 *
 * @author ddss
 */
@RestController
public class SysLoginController {

    @Autowired
    private SysLoginService loginService;
    @Autowired
    private ISysMenuService menuService;
    @Autowired
    private SysPermissionService permissionService;
    @Autowired
    private TokenService tokenService;
    @Autowired
    private ISysConfigService configService;

    @Value("${ddss.middleware.mysql.enabled:true}")
    private boolean mysqlEnabled;

    @Value("${ddss.dev.login-enabled:true}")
    private boolean devLoginEnabled;

    /**
     * 登录方法（MySQL 关闭时自动放行）
     */
    @PostMapping("/login")
    public AjaxResult login(@RequestBody LoginBody loginBody) {
        if (!mysqlEnabled && devLoginEnabled) return devLogin();
        AjaxResult ajax = AjaxResult.success();
        String token = loginService.login(loginBody.getUsername(), loginBody.getPassword(), loginBody.getCode(), loginBody.getUuid());
        ajax.put(SystemConstants.TOKEN, token);
        return ajax;
    }

    /** 开发模式：跳过密码验证，直接生成 admin token */
    private AjaxResult devLogin() {
        SysUser user = new SysUser();
        user.setUserId(1L);
        user.setDeptId(103L);
        user.setUserName("admin");
        user.setNickName("开发者");
        user.setDept(null);
        Set<String> perms = new HashSet<>(Collections.singletonList(SystemConstants.ALL_PERMISSION));
        LoginUser loginUser = new LoginUser(user.getUserId(), user.getDeptId(), user, perms);
        String token = tokenService.createToken(loginUser);
        AjaxResult ajax = AjaxResult.success();
        ajax.put(SystemConstants.TOKEN, token);
        return ajax;
    }

    @GetMapping("getInfo")
    public AjaxResult getInfo() {
        if (!mysqlEnabled && devLoginEnabled) return devGetInfo();
        LoginUser loginUser = SecurityUtils.getLoginUser();
        SysUser user = loginUser.getUser();
        Set<String> roles = permissionService.getRolePermission(user);
        Set<String> permissions = permissionService.getMenuPermission(user);
        if (!loginUser.getPermissions().equals(permissions)) {
            loginUser.setPermissions(permissions);
            tokenService.refreshToken(loginUser);
        }
        AjaxResult ajax = AjaxResult.success();
        ajax.put("user", user);
        ajax.put("roles", roles);
        ajax.put("permissions", permissions);
        ajax.put("isDefaultModifyPwd", initPasswordIsModify(user.getPwdUpdateDate()));
        ajax.put("isPasswordExpired", passwordIsExpiration(user.getPwdUpdateDate()));
        return ajax;
    }

    private AjaxResult devGetInfo() {
        SysUser user = new SysUser();
        user.setUserId(1L);
        user.setDeptId(103L);
        user.setUserName("admin");
        user.setNickName("开发者");
        user.setDept(null);
        Set<String> roles = new HashSet<>(Collections.singletonList("admin"));
        Set<String> permissions = new HashSet<>(Collections.singletonList(SystemConstants.ALL_PERMISSION));
        AjaxResult ajax = AjaxResult.success();
        ajax.put("user", user);
        ajax.put("roles", roles);
        ajax.put("permissions", permissions);
        ajax.put("isDefaultModifyPwd", false);
        ajax.put("isPasswordExpired", false);
        return ajax;
    }

    @GetMapping("getRouters")
    public AjaxResult getRouters() {
        if (!mysqlEnabled && devLoginEnabled) return AjaxResult.success(Collections.emptyList());
        Long userId = SecurityUtils.getUserId();
        List<SysMenu> menus = menuService.selectMenuTreeByUserId(userId);
        return AjaxResult.success(menuService.buildMenus(menus));
    }

    public boolean initPasswordIsModify(Date pwdUpdateDate) {
        Integer initPasswordModify = Convert.toInt(configService.selectConfigByKey("sys.account.initPasswordModify"));
        return initPasswordModify != null && initPasswordModify == 1 && pwdUpdateDate == null;
    }

    public boolean passwordIsExpiration(Date pwdUpdateDate) {
        Integer passwordValidateDays = Convert.toInt(configService.selectConfigByKey("sys.account.passwordValidateDays"));
        if (passwordValidateDays != null && passwordValidateDays > 0) {
            if (StringUtils.isNull(pwdUpdateDate)) return true;
            return DateUtils.differentDaysByMillisecond(DateUtils.getNowDate(), pwdUpdateDate) > passwordValidateDays;
        }
        return false;
    }
}

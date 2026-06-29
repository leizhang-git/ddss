package com.ddss.framework.security.filter;

import com.ddss.common.constant.SystemConstants;
import com.ddss.common.core.domain.entity.SysUser;
import com.ddss.common.core.domain.model.LoginUser;
import com.ddss.common.utils.SecurityUtils;
import com.ddss.common.utils.StringUtils;
import com.ddss.framework.web.service.TokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;

/**
 * token过滤器 验证token有效性
 *
 * @author ddss
 */
@Component
public class JwtAuthenticationTokenFilter extends OncePerRequestFilter {

    @Autowired
    private TokenService tokenService;

    @Value("${ddss.middleware.mysql.enabled:true}")
    private boolean mysqlEnabled;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        LoginUser loginUser = tokenService.getLoginUser(request);

        // MySQL 关闭时，自动注入 admin 身份，跳过所有认证
        if (!mysqlEnabled && loginUser == null) {
            loginUser = buildDevLoginUser();
        }

        if (StringUtils.isNotNull(loginUser) && StringUtils.isNull(SecurityUtils.getAuthentication())) {
            tokenService.verifyToken(loginUser);
            UsernamePasswordAuthenticationToken authenticationToken =
                    new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
            authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authenticationToken);
        }
        chain.doFilter(request, response);
    }

    private LoginUser buildDevLoginUser() {
        SysUser user = new SysUser();
        user.setUserId(1L);
        user.setDeptId(103L);
        user.setUserName("admin");
        user.setNickName("开发者");
        user.setDept(null);
        LoginUser loginUser = new LoginUser(user.getUserId(), user.getDeptId(), user,
                new HashSet<>(Collections.singletonList(SystemConstants.ALL_PERMISSION)));
        loginUser.setToken("dev-token");
        loginUser.setLoginTime(System.currentTimeMillis());
        loginUser.setExpireTime(System.currentTimeMillis() + 3600_000L);
        return loginUser;
    }
}

package com.ddss.framework.web.service;

import com.ddss.common.constant.CacheConstants;
import com.ddss.common.constant.SystemConstants;
import com.ddss.common.constant.UserConstants;
import com.ddss.common.core.domain.model.LoginUser;
import com.ddss.common.core.redis.RedisCache;
import com.ddss.framework.event.EventPublisher;
import com.ddss.common.exception.ServiceException;
import com.ddss.common.exception.user.*;
import com.ddss.common.utils.DateUtils;
import com.ddss.common.utils.DDSSMessageUtils;
import com.ddss.common.utils.StringUtils;
import com.ddss.common.utils.ip.IpUtils;
import com.ddss.framework.security.context.AuthenticationContextHolder;
import com.ddss.system.service.ISysConfigService;
import com.ddss.system.service.ISysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;

/**
 * 登录校验方法（使用 Spring Events 异步记录日志）
 *
 * @author ddss
 */
@Component
public class SysLoginService {
    @Autowired
    private TokenService tokenService;

    @Resource
    private AuthenticationManager authenticationManager;

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysConfigService configService;

    @Autowired
    private EventPublisher eventPublisher;

    public String login(String username, String password, String code, String uuid) {
        validateCaptcha(username, code, uuid);
        loginPreCheck(username, password);
        Authentication authentication = null;
        try {
            UsernamePasswordAuthenticationToken authenticationToken =
                    new UsernamePasswordAuthenticationToken(username, password);
            AuthenticationContextHolder.setContext(authenticationToken);
            authentication = authenticationManager.authenticate(authenticationToken);
        } catch (Exception e) {
            if (e instanceof BadCredentialsException) {
                eventPublisher.publishLoginEvent(username, SystemConstants.LOGIN_FAIL,
                        DDSSMessageUtils.message("user.password.not.match"));
                throw new UserPasswordNotMatchException();
            } else {
                eventPublisher.publishLoginEvent(username, SystemConstants.LOGIN_FAIL, e.getMessage());
                throw new ServiceException(e.getMessage());
            }
        } finally {
            AuthenticationContextHolder.clearContext();
        }
        eventPublisher.publishLoginEvent(username, SystemConstants.LOGIN_SUCCESS,
                DDSSMessageUtils.message("user.login.success"));
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        recordLoginInfo(loginUser.getUserId());
        return tokenService.createToken(loginUser);
    }

    public void validateCaptcha(String username, String code, String uuid) {
        boolean captchaEnabled = configService.selectCaptchaEnabled();
        if (captchaEnabled) {
            String verifyKey = CacheConstants.CAPTCHA_CODE_KEY + StringUtils.nvl(uuid, "");
            String captcha = redisCache.getCacheObject(verifyKey);
            if (captcha == null) {
                eventPublisher.publishLoginEvent(username, SystemConstants.LOGIN_FAIL,
                        DDSSMessageUtils.message("user.jcaptcha.expire"));
                throw new CaptchaExpireException();
            }
            redisCache.deleteObject(verifyKey);
            if (!code.equalsIgnoreCase(captcha)) {
                eventPublisher.publishLoginEvent(username, SystemConstants.LOGIN_FAIL,
                        DDSSMessageUtils.message("user.jcaptcha.error"));
                throw new CaptchaException();
            }
        }
    }

    public void loginPreCheck(String username, String password) {
        if (StringUtils.isEmpty(username) || StringUtils.isEmpty(password)) {
            eventPublisher.publishLoginEvent(username, SystemConstants.LOGIN_FAIL,
                    DDSSMessageUtils.message("not.null"));
            throw new UserNotExistsException();
        }
        if (password.length() < UserConstants.PASSWORD_MIN_LENGTH
                || password.length() > UserConstants.PASSWORD_MAX_LENGTH) {
            eventPublisher.publishLoginEvent(username, SystemConstants.LOGIN_FAIL,
                    DDSSMessageUtils.message("user.password.not.match"));
            throw new UserPasswordNotMatchException();
        }
        if (username.length() < UserConstants.USERNAME_MIN_LENGTH
                || username.length() > UserConstants.USERNAME_MAX_LENGTH) {
            eventPublisher.publishLoginEvent(username, SystemConstants.LOGIN_FAIL,
                    DDSSMessageUtils.message("user.password.not.match"));
            throw new UserPasswordNotMatchException();
        }
        String blackStr = configService.selectConfigByKey("sys.login.blackIPList");
        if (IpUtils.isMatchedIp(blackStr, IpUtils.getIpAddr())) {
            eventPublisher.publishLoginEvent(username, SystemConstants.LOGIN_FAIL,
                    DDSSMessageUtils.message("login.blocked"));
            throw new BlackListException();
        }
    }

    public void recordLoginInfo(Long userId) {
        userService.updateLoginInfo(userId, IpUtils.getIpAddr(), DateUtils.getNowDate());
    }
}

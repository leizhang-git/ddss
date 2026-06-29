package com.ddss.framework.listener;

import com.ddss.common.constant.SystemConstants;
import com.ddss.framework.event.LoginEvent;
import com.ddss.common.utils.LogUtils;
import com.ddss.common.utils.StringUtils;
import com.ddss.common.utils.ip.AddressUtils;
import com.ddss.common.utils.ip.IpUtils;
import com.ddss.system.domain.SysLogininfor;
import com.ddss.system.service.ISysLogininforService;
import eu.bitwalker.useragentutils.UserAgent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;

@Component
public class LoginEventListener {

    private static final Logger sys_user_logger = LoggerFactory.getLogger(LoginEventListener.class);

    @Autowired
    private ISysLogininforService logininforService;

    @Async
    @EventListener(LoginEvent.class)
    public void handleLoginEvent(LoginEvent event) {
        try {
            HttpServletRequest request = event.getRequest();
            String ip = IpUtils.getIpAddr(request);
            String address = AddressUtils.getRealAddressByIP(ip);
            UserAgent userAgent = UserAgent.parseUserAgentString(request.getHeader("User-Agent"));

            String logBlock = LogUtils.getBlock(ip) +
                    address +
                    LogUtils.getBlock(event.getUsername()) +
                    LogUtils.getBlock(event.getStatus()) +
                    LogUtils.getBlock(event.getMessage());

            sys_user_logger.info(logBlock);

            String os = getOperatingSystemName(userAgent);
            String browser = getBrowserName(userAgent);

            SysLogininfor logininfor = new SysLogininfor();
            logininfor.setUserName(event.getUsername());
            logininfor.setIpaddr(ip);
            logininfor.setLoginLocation(address);
            logininfor.setBrowser(browser);
            logininfor.setOs(os);
            logininfor.setMsg(event.getMessage());

            if (StringUtils.equalsAny(event.getStatus(), SystemConstants.LOGIN_SUCCESS, SystemConstants.LOGOUT, SystemConstants.REGISTER)) {
                logininfor.setStatus(SystemConstants.SUCCESS);
            } else if (SystemConstants.LOGIN_FAIL.equals(event.getStatus())) {
                logininfor.setStatus(SystemConstants.FAIL);
            }

            logininforService.insertLogininfor(logininfor);
        } catch (Exception e) {
            sys_user_logger.error("Failed to record login info for user: {}", event.getUsername(), e);
        }
    }

    private static String getBrowserName(UserAgent userAgent) {
        if (userAgent == null || userAgent.getBrowser() == null) {
            return "Unknown";
        }
        return userAgent.getBrowser().getName();
    }

    private static String getOperatingSystemName(UserAgent userAgent) {
        if (userAgent == null || userAgent.getOperatingSystem() == null) {
            return "Unknown";
        }
        return userAgent.getOperatingSystem().getName();
    }
}

package com.ddss.framework.event;

import com.ddss.common.utils.ServletUtils;
import com.ddss.common.utils.ip.IpUtils;
import com.ddss.system.domain.SysOperLog;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;

@Component
public class EventPublisher {

    @Autowired
    private ApplicationEventPublisher applicationEventPublisher;

    public void publishLoginEvent(String username, String status, String message) {
        javax.servlet.http.HttpServletRequest request = ServletUtils.getRequest();
        String ipAddress = IpUtils.getIpAddr(request);
        String userAgent = request == null ? "" : request.getHeader("User-Agent");
        LoginEvent event = new LoginEvent(this, username, status, message, ipAddress, userAgent);
        applicationEventPublisher.publishEvent(event);
    }

    public void publishOperLogEvent(SysOperLog operLog) {
        OperLogEvent event = new OperLogEvent(this, operLog);
        applicationEventPublisher.publishEvent(event);
    }
}

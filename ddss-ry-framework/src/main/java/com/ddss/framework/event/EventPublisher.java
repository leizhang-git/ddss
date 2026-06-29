package com.ddss.framework.event;

import com.ddss.common.utils.ServletUtils;
import com.ddss.system.domain.SysOperLog;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;

@Component
public class EventPublisher {

    @Autowired
    private ApplicationEventPublisher applicationEventPublisher;

    public void publishLoginEvent(String username, String status, String message) {
        LoginEvent event = new LoginEvent(this, username, status, message, ServletUtils.getRequest());
        applicationEventPublisher.publishEvent(event);
    }

    public void publishOperLogEvent(SysOperLog operLog) {
        OperLogEvent event = new OperLogEvent(this, operLog);
        applicationEventPublisher.publishEvent(event);
    }
}

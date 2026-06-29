package com.ddss.framework.event;

import com.ddss.system.domain.SysOperLog;
import org.springframework.context.ApplicationEvent;

public class OperLogEvent extends ApplicationEvent {

    private static final long serialVersionUID = 1L;

    private final SysOperLog operLog;

    public OperLogEvent(Object source, SysOperLog operLog) {
        super(source);
        this.operLog = operLog;
    }

    public SysOperLog getOperLog() {
        return operLog;
    }
}

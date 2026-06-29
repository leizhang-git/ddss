package com.ddss.framework.listener;

import com.ddss.framework.event.OperLogEvent;
import com.ddss.common.utils.ip.AddressUtils;
import com.ddss.system.domain.SysOperLog;
import com.ddss.system.service.ISysOperLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

@Component
public class OperLogEventListener {

    @Autowired
    private ISysOperLogService operLogService;

    @Async
    @EventListener(OperLogEvent.class)
    public void handleOperLogEvent(OperLogEvent event) {
        SysOperLog operLog = event.getOperLog();
        operLog.setOperLocation(AddressUtils.getRealAddressByIP(operLog.getOperIp()));
        operLogService.insertOperlog(operLog);
    }
}

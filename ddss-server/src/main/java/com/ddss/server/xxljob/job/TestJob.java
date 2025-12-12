package com.ddss.server.xxljob.job;

import com.xxl.job.core.handler.annotation.XxlJob;
import org.springframework.stereotype.Component;

/**
 * @Author zhanglei
 * @Date 2025/12/12 14:34
 */
@Component
public class TestJob {

    @XxlJob("testJobHandler")
    protected void testJobHandler() {
        System.out.println("testJobHandler");
    }
}

package com.ddss.framework.config;

import com.ddss.common.utils.Threads;
import org.apache.commons.lang3.concurrent.BasicThreadFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import javax.annotation.Resource;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * &#064;Author:  zhang lei
 * &#064;Date:  2022/3/24 14:33
 */
@Configuration
public class ThreadPoolConfig {

    private final Logger log = LoggerFactory.getLogger(ThreadPoolConfig.class);

    @Resource
    ThreadPoolProperties threadPoolProperties;

    @Bean
    public ThreadPoolTaskExecutor poolExecutor() {

        ThreadPoolTaskExecutor threadPoolTaskExecutor = new ThreadPoolTaskExecutor();
        /*
          设置核心线程数
         */
        threadPoolTaskExecutor.setCorePoolSize(threadPoolProperties.getCorePoolSize());

        /*
          设置最大线程数
         */
        threadPoolTaskExecutor.setMaxPoolSize(threadPoolProperties.getMaxPoolSize());

        /*
          配置队列大小
         */
        threadPoolTaskExecutor.setQueueCapacity(threadPoolProperties.getQueueCapacity());

        /*
          设置线程活跃时间（s）
         */
        threadPoolTaskExecutor.setKeepAliveSeconds(threadPoolProperties.getKeepAliveSeconds());

        /*
          设置默认线程名称
         */
        threadPoolTaskExecutor.setThreadNamePrefix(threadPoolProperties.getDefaultName());

        // 设置拒绝策略
        switch (threadPoolProperties.getRejectionPolicy()) {
            case "AbortPolicy":
                threadPoolTaskExecutor.setRejectedExecutionHandler(new ThreadPoolExecutor.AbortPolicy());
                break;
            case "DiscardPolicy":
                threadPoolTaskExecutor.setRejectedExecutionHandler(new ThreadPoolExecutor.DiscardPolicy());
                break;
            case "CallerRunsPolicy":
            default:
                threadPoolTaskExecutor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        }
        /*
          初始化
         */
        threadPoolTaskExecutor.initialize();

        log.info("corePoolSize[{}], maxPoolSize[{}], queueCapacity[{}], keepAliveSeconds[{}], threadName[{}]",
                threadPoolProperties.getCorePoolSize(),
                threadPoolProperties.getMaxPoolSize(),
                threadPoolProperties.getQueueCapacity(),
                threadPoolProperties.getKeepAliveSeconds(),
                threadPoolProperties.getDefaultName());

        log.info("----------------------------线程池加载完毕----------------------------------");
        return threadPoolTaskExecutor;
    }

    /**
     * 执行周期性或定时任务
     */
    @Bean(name = "scheduledExecutorService")
    protected ScheduledExecutorService scheduledExecutorService() {
        return new ScheduledThreadPoolExecutor(threadPoolProperties.getCorePoolSize(),
                new BasicThreadFactory.Builder().namingPattern("schedule-pool-%d").daemon(true).build(),
                new ThreadPoolExecutor.CallerRunsPolicy()) {
            @Override
            protected void afterExecute(Runnable r, Throwable t) {
                super.afterExecute(r, t);
                Threads.printException(r, t);
            }
        };
    }
}

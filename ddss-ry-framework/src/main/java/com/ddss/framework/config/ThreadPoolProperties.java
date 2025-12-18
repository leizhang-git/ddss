package com.ddss.framework.config;

import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * @Author: zhang lei
 * @Date: 2022/3/24 14:01
 */
@Data
@Component
@ConfigurationProperties(prefix = ThreadPoolProperties.PREFIX)
public class ThreadPoolProperties {

    static final String PREFIX = "threadpool";

    /**
     * 是否开启线程
     */
    @Value("${threadpool.open_flag:false}")
    private boolean openFlag;

    /**
     * 核心线程数
     */
    @Value("${threadpool.core_pool_size:10}")
    private int corePoolSize;

    /**
     * 最大线程数
     */
    @Value("${threadpool.max_pool_size:200}")
    private int maxPoolSize;

    /**
     * 队列大小
     */
    @Value("${threadpool.queue_capacity:1024}")
    private int queueCapacity;

    /**
     * 空闲线程活跃时间（s）
     */
    @Value("${threadpool.keep_alive_seconds:60}")
    private int keepAliveSeconds;

    /**
     * 默认线程名称
     */
    @Value("${threadpool.default_name:ddss-pool}")
    private String defaultName;

    @Value("${threadpool.rejection_policy:CallerRunsPolicy}")
    private String rejectionPolicy;
}

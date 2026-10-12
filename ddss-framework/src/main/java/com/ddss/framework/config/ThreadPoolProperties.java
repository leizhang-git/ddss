package com.ddss.framework.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.validation.annotation.Validated;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;

/**
 * 线程池配置。
 * <p>统一由 {@link ConfigurationProperties} 绑定，避免和字段级 {@code @Value} 产生双重配置来源。</p>
 */
@Data
@Component
@Validated
@ConfigurationProperties(prefix = ThreadPoolProperties.PREFIX)
public class ThreadPoolProperties {

    public static final String PREFIX = "threadpool";

    /** 是否开启异步线程池 */
    private boolean openFlag = true;

    /** 核心线程数 */
    @Min(1)
    private int corePoolSize = 10;

    /** 最大线程数 */
    @Min(1)
    private int maxPoolSize = 200;

    /** 队列容量 */
    @Min(0)
    private int queueCapacity = 1024;

    /** 空闲线程存活时间（秒） */
    @Min(0)
    private int keepAliveSeconds = 60;

    /** 线程名称前缀 */
    @NotBlank
    private String defaultName = "ddss-pool";

    /** 拒绝策略：AbortPolicy、DiscardPolicy 或 CallerRunsPolicy */
    @NotBlank
    private String rejectionPolicy = "CallerRunsPolicy";
}

package com.ddss.web.core.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;
import org.springframework.core.env.PropertySource;

import java.util.*;

/**
 * 中间件条件加载处理器。
 * 根据 ddss.middleware.*.enabled 开关：
 *   1. 排除对应 Spring Boot 自动配置
 *   2. MySQL 关闭时自动切 H2 内存数据库
 *
 * @author ddss
 */
public class MiddlewareAutoConfigExcluder implements EnvironmentPostProcessor {

    private static final Map<String, List<String>> EXCLUDES = new LinkedHashMap<>();
    static {
        EXCLUDES.put("ddss.middleware.redis.enabled", Arrays.asList(
                "org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration",
                "org.springframework.boot.autoconfigure.data.redis.RedisRepositoriesAutoConfiguration"
        ));
        EXCLUDES.put("ddss.middleware.kafka.enabled", Arrays.asList(
                "org.springframework.boot.autoconfigure.kafka.KafkaAutoConfiguration"
        ));
        EXCLUDES.put("ddss.middleware.mysql.enabled", Arrays.asList(
                "com.alibaba.druid.spring.boot.autoconfigure.DruidDataSourceAutoConfigure"
        ));
    }

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment env, SpringApplication application) {
        List<String> excludes = new ArrayList<>();
        Map<String, Object> props = new HashMap<>();

        for (Map.Entry<String, List<String>> entry : EXCLUDES.entrySet()) {
            boolean enabled = "true".equals(env.getProperty(entry.getKey(), "true"));
            if (!enabled) {
                excludes.addAll(entry.getValue());
            }
        }

        // MySQL 关闭 → 自动切到 H2 内存数据库
        boolean mysqlEnabled = "true".equals(env.getProperty("ddss.middleware.mysql.enabled", "true"));
        if (!mysqlEnabled) {
            String h2Url = "jdbc:h2:mem:ddss;MODE=MySQL;DB_CLOSE_DELAY=-1;DATABASE_TO_LOWER=TRUE";
            props.put("spring.datasource.dynamic.primary", "master");
            props.put("spring.datasource.dynamic.datasource.master.url", h2Url);
            props.put("spring.datasource.dynamic.datasource.master.driver-class-name", "org.h2.Driver");
            props.put("spring.datasource.dynamic.datasource.master.username", "sa");
            props.put("spring.datasource.dynamic.datasource.master.password", "");
            props.put("spring.datasource.dynamic.datasource.ddss.url", h2Url);
            props.put("spring.datasource.dynamic.datasource.ddss.driver-class-name", "org.h2.Driver");
            props.put("spring.datasource.dynamic.datasource.ddss.username", "sa");
            props.put("spring.datasource.dynamic.datasource.ddss.password", "");
            // H2 初始化由 H2DataInitializer 处理，不走 spring.sql.init
            props.put("spring.sql.init.mode", "never");
        }

        if (!excludes.isEmpty()) {
            String existing = env.getProperty("spring.autoconfigure.exclude", "");
            if (!existing.isEmpty()) {
                excludes.addAll(Arrays.asList(existing.split(",")));
            }
            props.put("spring.autoconfigure.exclude", String.join(",", excludes));
        }

        if (!props.isEmpty()) {
            env.getPropertySources().addFirst(new MapPropertySource("middlewareAutoConfig", props));
        }
    }
}

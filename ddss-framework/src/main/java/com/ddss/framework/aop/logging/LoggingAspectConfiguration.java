package com.ddss.framework.aop.logging;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;

/**
 * LoggingAspect 装配：仅 dev profile 下注册（移植自 iuap-data-common 的 LoggingAspectConfiguration）
 *
 * @author ddss（移植）
 */
@Configuration
@EnableAspectJAutoProxy
public class LoggingAspectConfiguration {

    @Bean
    @Profile({"dev", "local"})
    public LoggingAspect loggingAspect(Environment env) {
        return new LoggingAspect(env);
    }
}

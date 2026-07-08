package com.ddss;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;

import javax.annotation.PostConstruct;
import java.util.Arrays;
import java.util.List;

/**
 * DDSS 启动程序
 *
 * @author ddss
 */
@EnableDiscoveryClient
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class DdssApplication {
    private static final Logger log = LoggerFactory.getLogger(DdssApplication.class);

    private final Environment environment;

    public DdssApplication(Environment environment) {
        this.environment = environment;
    }

    @PostConstruct
    public void init() {
        log.info("activeProfiles: {}", Arrays.asList(environment.getActiveProfiles()));
    }

    public static void main(String[] args) {
        ConfigurableApplicationContext ctx = SpringApplication.run(DdssApplication.class, args);
        Environment env = ctx.getEnvironment();
        String port = env.getProperty("server.port");
        String contextPath = env.getProperty("server.servlet.context-path", "/");
        log.info("\n------------------------------------------------------------");
        log.info("  DDSS 启动成功!");
        log.info("  地址: http://127.0.0.1:{}{}", port, "/".equals(contextPath) ? "" : contextPath);
        log.info("  Bean 数量: {}", ctx.getBeanDefinitionCount());
        log.info("  操作系统: {}", System.getProperty("os.name"));
        log.info("------------------------------------------------------------");
    }
}

package com.ddss.web.core.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import org.springframework.util.StreamUtils;

import javax.sql.DataSource;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * H2 数据库初始化。仅当 ddss.middleware.mysql.enabled=false 时逐条执行 SQL。
 */
@Component
public class H2DataInitializer implements InitializingBean {

    private static final Logger log = LoggerFactory.getLogger(H2DataInitializer.class);

    private final DataSource dataSource;

    @Value("${ddss.middleware.mysql.enabled:true}")
    private boolean mysqlEnabled;

    public H2DataInitializer(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        if (mysqlEnabled) return;

        log.info("H2 初始化开始...");
        try (Connection conn = dataSource.getConnection()) {
            List<String> schema = loadSql("h2/schema.sql");
            List<String> data = loadSql("h2/data.sql");
            try (Statement stmt = conn.createStatement()) {
                for (String sql : schema) executeSafely(stmt, sql);
                for (String sql : data) executeSafely(stmt, sql);
            }
            log.info("H2 初始化完成（{} 条 schema + {} 条 data）", schema.size(), data.size());
        } catch (Exception e) {
            log.error("H2 初始化失败", e);
            throw e;
        }
    }

    private List<String> loadSql(String path) throws Exception {
        String content;
        try (InputStream in = new ClassPathResource(path).getInputStream()) {
            content = StreamUtils.copyToString(in, StandardCharsets.UTF_8);
        }
        List<String> statements = new ArrayList<>();
        StringBuilder buf = new StringBuilder();
        for (String line : content.split("\n")) {
            String trimmed = line.trim();
            if (trimmed.isEmpty() || trimmed.startsWith("--")) continue;
            buf.append(line).append("\n");
            if (trimmed.endsWith(";")) {
                statements.add(buf.toString().trim());
                buf.setLength(0);
            }
        }
        if (buf.length() > 0) statements.add(buf.toString().trim());
        return statements;
    }

    private void executeSafely(Statement stmt, String sql) {
        try {
            stmt.execute(sql);
        } catch (Exception e) {
            log.warn("H2 SQL 执行失败（跳过）: {}", e.getMessage());
            log.debug("失败的 SQL: {}", sql.substring(0, Math.min(200, sql.length())));
        }
    }
}

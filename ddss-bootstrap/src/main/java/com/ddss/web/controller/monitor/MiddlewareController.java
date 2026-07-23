package com.ddss.web.controller.monitor;

import com.ddss.common.core.domain.AjaxResult;
import com.ddss.server.minio.util.MinioUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.data.redis.connection.RedisConnection;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URL;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * 中间件状态监控
 */
@RestController
@RequestMapping("/monitor/middleware")
public class MiddlewareController {

    private static final int TIMEOUT_MS = 3000;

    @Autowired
    private Environment env;

    @Autowired(required = false)
    private DataSource dataSource;

    @Autowired(required = false)
    private RedisTemplate<String, String> redisTemplate;

    @Autowired(required = false)
    private MinioUtil minioUtil;

    @Value("${ddss.middleware.mysql.enabled:true}")
    private boolean mysqlEnabled;

    @Value("${ddss.middleware.redis.enabled:true}")
    private boolean redisEnabled;

    @Value("${ddss.middleware.minio.enabled:true}")
    private boolean minioEnabled;

    @Value("${ddss.middleware.nacos.enabled:true}")
    private boolean nacosEnabled;

    @Value("${ddss.middleware.kafka.enabled:true}")
    private boolean kafkaEnabled;

    @Value("${ddss.middleware.xxl-job.enabled:true}")
    private boolean xxlJobEnabled;

    @Value("${spring.cloud.nacos.config.server-addr:}")
    private String nacosServerAddr;

    @Value("${minio.endpoint:}")
    private String minioEndpoint;

    @Value("${minio.bucket-name:}")
    private String minioBucket;

    @Value("${xxl.job.admin.addresses:}")
    private String xxlJobAdmin;

    @PreAuthorize("@ss.hasPermi('monitor:middleware:list')")
    @GetMapping()
    public AjaxResult getInfo() {
        List<Map<String, Object>> list = new ArrayList<>();
        list.add(checkMysql());
        list.add(checkRedis());
        list.add(checkMinio());
        list.add(checkNacos());
        list.add(checkKafka());
        list.add(checkXxlJob());
        return AjaxResult.success(list);
    }

    private Map<String, Object> checkMysql() {
        Map<String, Object> item = base("MySQL", "mysql", "关系型数据库", mysqlEnabled);
        String url = env.getProperty("spring.datasource.dynamic.datasource.master.url", "");
        item.put("endpoint", maskJdbcUrl(url));

        if (!mysqlEnabled) {
            item.put("status", "DISABLED");
            item.put("message", "已在配置中关闭");
            return item;
        }
        if (dataSource == null) {
            item.put("status", "DOWN");
            item.put("message", "DataSource 未注入");
            return item;
        }

        long start = System.currentTimeMillis();
        try (Connection conn = dataSource.getConnection()) {
            boolean valid = conn.isValid(3);
            if (!valid) {
                try (Statement st = conn.createStatement()) {
                    st.setQueryTimeout(3);
                    st.execute("SELECT 1");
                    valid = true;
                }
            }
            long latency = System.currentTimeMillis() - start;
            item.put("latencyMs", latency);
            if (valid) {
                DatabaseMetaData meta = conn.getMetaData();
                item.put("status", "UP");
                item.put("message", "连接正常");
                Map<String, Object> detail = new LinkedHashMap<>();
                detail.put("product", meta.getDatabaseProductName());
                detail.put("version", meta.getDatabaseProductVersion());
                detail.put("driver", meta.getDriverName());
                detail.put("catalog", conn.getCatalog());
                item.put("detail", detail);
            } else {
                item.put("status", "DOWN");
                item.put("message", "连接校验失败");
            }
        } catch (Exception e) {
            item.put("status", "DOWN");
            item.put("latencyMs", System.currentTimeMillis() - start);
            item.put("message", safeMsg(e));
        }
        return item;
    }

    private Map<String, Object> checkRedis() {
        Map<String, Object> item = base("Redis", "redis", "缓存 / 会话", redisEnabled);
        String nodes = env.getProperty("spring.redis.sentinel.nodes",
                env.getProperty("spring.redis.host", ""));
        String port = env.getProperty("spring.redis.port", "");
        if (nodes != null && !nodes.isEmpty()) {
            item.put("endpoint", nodes);
            item.put("mode", env.getProperty("spring.redis.sentinel.master") != null ? "Sentinel" : "Standalone");
        } else if (port != null && !port.isEmpty()) {
            item.put("endpoint", env.getProperty("spring.redis.host", "localhost") + ":" + port);
            item.put("mode", "Standalone");
        } else {
            item.put("endpoint", "-");
        }

        if (!redisEnabled) {
            item.put("status", "DISABLED");
            item.put("message", "已在配置中关闭");
            return item;
        }
        if (redisTemplate == null) {
            item.put("status", "DOWN");
            item.put("message", "RedisTemplate 未注入");
            return item;
        }

        long start = System.currentTimeMillis();
        try {
            String pong = redisTemplate.execute((RedisCallback<String>) connection -> {
                try {
                    return connection.ping();
                } catch (Exception ex) {
                    throw new RuntimeException(ex);
                }
            });
            long latency = System.currentTimeMillis() - start;
            item.put("latencyMs", latency);

            Map<String, Object> detail = new LinkedHashMap<>();
            try {
                Properties info = redisTemplate.execute((RedisCallback<Properties>) RedisConnection::info);
                if (info != null) {
                    detail.put("version", info.getProperty("redis_version"));
                    detail.put("mode", info.getProperty("redis_mode"));
                    detail.put("clients", info.getProperty("connected_clients"));
                    detail.put("usedMemory", info.getProperty("used_memory_human"));
                    detail.put("uptimeDays", info.getProperty("uptime_in_days"));
                }
                Long dbSize = redisTemplate.execute((RedisCallback<Long>) RedisConnection::dbSize);
                if (dbSize != null) {
                    detail.put("dbSize", dbSize);
                }
            } catch (Exception ignored) {
            }
            item.put("detail", detail);
            item.put("status", "UP");
            item.put("message", pong != null ? "PONG" : "连接正常");
        } catch (Exception e) {
            item.put("status", "DOWN");
            item.put("latencyMs", System.currentTimeMillis() - start);
            item.put("message", safeMsg(e));
        }
        return item;
    }

    private Map<String, Object> checkMinio() {
        Map<String, Object> item = base("MinIO", "minio", "对象存储", minioEnabled);
        item.put("endpoint", blankToDash(minioEndpoint));
        item.put("bucket", blankToDash(minioBucket));

        if (!minioEnabled) {
            item.put("status", "DISABLED");
            item.put("message", "已在配置中关闭");
            return item;
        }
        if (minioUtil == null) {
            item.put("status", "DOWN");
            item.put("message", "MinioUtil 未注入");
            return item;
        }

        long start = System.currentTimeMillis();
        try {
            boolean exists = minioUtil.bucketExists(minioBucket);
            long latency = System.currentTimeMillis() - start;
            item.put("latencyMs", latency);
            Map<String, Object> detail = new LinkedHashMap<>();
            detail.put("bucket", minioBucket);
            detail.put("bucketExists", exists);
            try {
                detail.put("bucketCount", minioUtil.listBuckets().size());
            } catch (Exception ignored) {
            }
            item.put("detail", detail);
            item.put("status", "UP");
            item.put("message", exists ? "Bucket 可用" : "已连接，Bucket 不存在");
        } catch (Exception e) {
            item.put("status", "DOWN");
            item.put("latencyMs", System.currentTimeMillis() - start);
            item.put("message", safeMsg(e));
        }
        return item;
    }

    private Map<String, Object> checkNacos() {
        Map<String, Object> item = base("Nacos", "nacos", "配置 / 注册中心", nacosEnabled);
        item.put("endpoint", blankToDash(nacosServerAddr));
        item.put("namespace", blankToDash(env.getProperty("spring.cloud.nacos.config.namespace", "")));
        item.put("group", blankToDash(env.getProperty("spring.cloud.nacos.config.group", "")));

        if (!nacosEnabled) {
            item.put("status", "DISABLED");
            item.put("message", "已在配置中关闭");
            return item;
        }
        if (nacosServerAddr == null || nacosServerAddr.trim().isEmpty()) {
            item.put("status", "DOWN");
            item.put("message", "未配置 server-addr");
            return item;
        }

        long start = System.currentTimeMillis();
        try {
            String addr = nacosServerAddr.split(",")[0].trim();
            String base = addr.startsWith("http") ? addr : ("http://" + addr);
            // 优先 readiness，失败再试 TCP
            boolean ok = httpOk(base + "/nacos/v1/console/health/readiness")
                    || httpOk(base + "/nacos/")
                    || tcpOk(addr);
            long latency = System.currentTimeMillis() - start;
            item.put("latencyMs", latency);
            if (ok) {
                item.put("status", "UP");
                item.put("message", "服务可达");
            } else {
                item.put("status", "DOWN");
                item.put("message", "无法连通 Nacos");
            }
        } catch (Exception e) {
            item.put("status", "DOWN");
            item.put("latencyMs", System.currentTimeMillis() - start);
            item.put("message", safeMsg(e));
        }
        return item;
    }

    private Map<String, Object> checkKafka() {
        Map<String, Object> item = base("Kafka", "kafka", "消息队列", kafkaEnabled);
        String servers = env.getProperty("spring.kafka.producer.bootstrap-servers",
                env.getProperty("spring.kafka.bootstrap-servers", ""));
        item.put("endpoint", blankToDash(servers));

        if (!kafkaEnabled) {
            item.put("status", "DISABLED");
            item.put("message", "已在配置中关闭");
            return item;
        }
        if (servers == null || servers.trim().isEmpty()) {
            item.put("status", "DOWN");
            item.put("message", "未配置 bootstrap-servers");
            return item;
        }

        long start = System.currentTimeMillis();
        try {
            String first = servers.split(",")[0].trim();
            boolean ok = tcpOk(first);
            long latency = System.currentTimeMillis() - start;
            item.put("latencyMs", latency);
            if (ok) {
                item.put("status", "UP");
                item.put("message", "Broker 端口可达");
            } else {
                item.put("status", "DOWN");
                item.put("message", "无法连接 Broker");
            }
        } catch (Exception e) {
            item.put("status", "DOWN");
            item.put("latencyMs", System.currentTimeMillis() - start);
            item.put("message", safeMsg(e));
        }
        return item;
    }

    private Map<String, Object> checkXxlJob() {
        Map<String, Object> item = base("XXL-Job", "xxl-job", "分布式任务调度", xxlJobEnabled);
        item.put("endpoint", blankToDash(xxlJobAdmin));

        if (!xxlJobEnabled) {
            item.put("status", "DISABLED");
            item.put("message", "已在配置中关闭");
            return item;
        }
        if (xxlJobAdmin == null || xxlJobAdmin.trim().isEmpty()) {
            item.put("status", "DOWN");
            item.put("message", "未配置 admin.addresses");
            return item;
        }

        long start = System.currentTimeMillis();
        try {
            String first = xxlJobAdmin.split(",")[0].trim();
            boolean ok = httpOk(first) || tcpOkFromUrl(first);
            long latency = System.currentTimeMillis() - start;
            item.put("latencyMs", latency);
            if (ok) {
                item.put("status", "UP");
                item.put("message", "Admin 可达");
            } else {
                item.put("status", "DOWN");
                item.put("message", "无法连通 Admin");
            }
        } catch (Exception e) {
            item.put("status", "DOWN");
            item.put("latencyMs", System.currentTimeMillis() - start);
            item.put("message", safeMsg(e));
        }
        return item;
    }

    private Map<String, Object> base(String name, String code, String type, boolean enabled) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("name", name);
        item.put("code", code);
        item.put("type", type);
        item.put("enabled", enabled);
        item.put("status", "UNKNOWN");
        item.put("latencyMs", null);
        item.put("message", "");
        item.put("detail", new LinkedHashMap<>());
        return item;
    }

    private boolean httpOk(String urlStr) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(urlStr);
            conn = (HttpURLConnection) url.openConnection();
            conn.setConnectTimeout(TIMEOUT_MS);
            conn.setReadTimeout(TIMEOUT_MS);
            conn.setRequestMethod("GET");
            conn.setInstanceFollowRedirects(true);
            int code = conn.getResponseCode();
            // 2xx/3xx/401/403 都说明服务在
            return code > 0 && code < 500;
        } catch (Exception e) {
            return false;
        } finally {
            if (conn != null) {
                try {
                    InputStream is = conn.getErrorStream();
                    if (is != null) {
                        is.close();
                    }
                } catch (Exception ignored) {
                }
                conn.disconnect();
            }
        }
    }

    private boolean tcpOk(String hostPort) {
        String hp = hostPort.trim();
        if (hp.startsWith("http://")) {
            hp = hp.substring(7);
        } else if (hp.startsWith("https://")) {
            hp = hp.substring(8);
        }
        int slash = hp.indexOf('/');
        if (slash > 0) {
            hp = hp.substring(0, slash);
        }
        String host;
        int port;
        int colon = hp.lastIndexOf(':');
        if (colon > 0) {
            host = hp.substring(0, colon);
            port = Integer.parseInt(hp.substring(colon + 1).replaceAll("[^0-9]", ""));
        } else {
            host = hp;
            port = 80;
        }
        try (Socket socket = new Socket()) {
            socket.connect(new InetSocketAddress(host, port), TIMEOUT_MS);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private boolean tcpOkFromUrl(String url) {
        try {
            URL u = new URL(url.contains("://") ? url : ("http://" + url));
            int port = u.getPort() > 0 ? u.getPort() : ("https".equals(u.getProtocol()) ? 443 : 80);
            try (Socket socket = new Socket()) {
                socket.connect(new InetSocketAddress(u.getHost(), port), TIMEOUT_MS);
                return true;
            }
        } catch (Exception e) {
            return false;
        }
    }

    private String maskJdbcUrl(String url) {
        if (url == null || url.isEmpty()) {
            return "-";
        }
        // jdbc:mysql://host:port/db?...
        int q = url.indexOf('?');
        String base = q > 0 ? url.substring(0, q) : url;
        return base.replace("jdbc:", "");
    }

    private String blankToDash(String s) {
        return (s == null || s.trim().isEmpty()) ? "-" : s.trim();
    }

    private String safeMsg(Exception e) {
        Throwable t = e;
        while (t.getCause() != null && t.getCause() != t) {
            t = t.getCause();
        }
        String msg = t.getMessage();
        if (msg == null || msg.isEmpty()) {
            msg = t.getClass().getSimpleName();
        }
        if (msg.length() > 200) {
            msg = msg.substring(0, 200) + "...";
        }
        return msg;
    }
}

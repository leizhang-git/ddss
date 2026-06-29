package com.ddss.server.minio.config;

import io.minio.MinioClient;
import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MinIO 配置（可通过 ddss.middleware.minio.enabled 开关控制）
 *
 * @Author zhanglei
 * @Date 2025/12/11 10:11
 */
@Data
@Configuration
@ConditionalOnProperty(name = "ddss.middleware.minio.enabled", havingValue = "true", matchIfMissing = true)
public class MinioConfig {

    @Value("${minio.endpoint}")
    private String endpoint;

    @Value("${minio.access-key}")
    private String accessKey;

    @Value("${minio.secret-key}")
    private String secretKey;

    @Value("${minio.secure:false}")
    private boolean secure;

    @Bean
    public MinioClient minioClient() {
        return MinioClient.builder()
                .endpoint(endpoint, 9000, secure)
                .credentials(accessKey, secretKey)
                .build();
    }

}

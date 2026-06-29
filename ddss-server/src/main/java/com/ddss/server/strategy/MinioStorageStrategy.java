package com.ddss.server.strategy;

import com.ddss.common.strategy.StorageStrategy;
import com.ddss.server.minio.util.MinioUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.Map;

@Component("minioStorageStrategy")
public class MinioStorageStrategy implements StorageStrategy {

    @Autowired
    private MinioUtil minioUtil;

    @Value("${minio.bucket-name}")
    private String defaultBucketName;

    @Override
    public String upload(MultipartFile file, String path) {
        Map<String, String> result = minioUtil.uploadFile(file, defaultBucketName);
        if (result == null) {
            throw new RuntimeException("MinIO upload failed");
        }
        return result.get("fileName");
    }

    @Override
    public InputStream download(String path, String fileName) {
        return minioUtil.downloadFile(defaultBucketName, fileName);
    }

    @Override
    public boolean delete(String path, String fileName) {
        try {
            minioUtil.deleteFile(defaultBucketName, fileName);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public String getType() {
        return "minio";
    }
}

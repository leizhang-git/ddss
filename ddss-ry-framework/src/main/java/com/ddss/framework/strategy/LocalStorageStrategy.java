package com.ddss.framework.strategy;

import com.ddss.common.config.DdssConfig;
import com.ddss.common.strategy.StorageStrategy;
import com.ddss.common.utils.file.FileUploadUtils;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

@Component("localStorageStrategy")
public class LocalStorageStrategy implements StorageStrategy {

    @Override
    public String upload(MultipartFile file, String path) {
        try {
            return FileUploadUtils.upload(DdssConfig.getProfile() + File.separator + path, file);
        } catch (Exception e) {
            throw new RuntimeException("Local file upload failed", e);
        }
    }

    @Override
    public InputStream download(String path, String fileName) {
        try {
            String fullPath = DdssConfig.getProfile() + path + File.separator + fileName;
            File file = new File(fullPath);
            if (!file.exists()) {
                throw new RuntimeException("File not found: " + fullPath);
            }
            return new FileInputStream(file);
        } catch (Exception e) {
            throw new RuntimeException("Local file download failed", e);
        }
    }

    @Override
    public boolean delete(String path, String fileName) {
        String fullPath = DdssConfig.getProfile() + path + File.separator + fileName;
        File file = new File(fullPath);
        return file.exists() && file.delete();
    }

    @Override
    public String getType() {
        return "local";
    }
}

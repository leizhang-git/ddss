package com.ddss.common.strategy;

import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;

public interface StorageStrategy {

    String upload(MultipartFile file, String path);

    InputStream download(String path, String fileName);

    boolean delete(String path, String fileName);

    String getType();
}

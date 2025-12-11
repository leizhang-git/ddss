package com.ddss.server.web;

import com.ddss.common.core.domain.AjaxResult;
import com.ddss.server.minio.util.MinioUtil;
import org.apache.commons.compress.utils.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

/**
 * @Author zhanglei
 * @Date 2025/12/11 10:15
 */
@RestController
@RequestMapping("/api/v1/file")
public class DDSSFileController {

    @Autowired
    private MinioUtil minioUtil;

    @PostMapping("/minio/upload")
    public AjaxResult uploadFile(@RequestParam("file") MultipartFile file) {
        Map<String, String> fileInfo = minioUtil.uploadFile(file);
        return AjaxResult.success(fileInfo);
    }

    @GetMapping("/download/{fileName}")
    public void downloadFile(@PathVariable("fileName") String fileName, HttpServletResponse response) {
        try (InputStream inputStream = minioUtil.downloadFile(fileName)) {
            // 设置响应头
            response.setContentType(MediaType.APPLICATION_OCTET_STREAM_VALUE);
            response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + URLEncoder.encode(fileName, StandardCharsets.UTF_8.name()));

            // 将输入流拷贝到输出流
            IOUtils.copy(inputStream, response.getOutputStream());
            response.flushBuffer();
        } catch (Exception e) {
            // 处理异常，例如记录日志并返回错误信息
            throw new RuntimeException("文件下载失败", e);
        }
    }

}

package com.ddss.server.web;

import com.ddss.common.annotation.Log;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.server.minio.util.MinioUtil;
import io.minio.messages.Item;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

/**
 * MinIO资源管理Controller
 */
@RestController
@RequestMapping("/resource/minio")
@ConditionalOnProperty(name = "ddss.middleware.minio.enabled", havingValue = "true", matchIfMissing = true)
public class MinioResourceController extends BaseController {

    @Autowired
    private MinioUtil minioUtil;

    /**
     * 查询MinIO资源列表
     */
    @GetMapping("/list")
    public TableDataInfo list() {
        // 获取所有bucket并遍历
        List<Item> allItems = new ArrayList<>();
        try {
            io.minio.messages.Bucket[] buckets = minioUtil.listBuckets().toArray(new io.minio.messages.Bucket[0]);
            for (io.minio.messages.Bucket bucket : buckets) {
                List<Item> items = minioUtil.listObjects(bucket.name());
                allItems.addAll(items);
            }
        } catch (Exception e) {
            throw new RuntimeException("获取MinIO文件列表失败", e);
        }
        
        List<Map<String, Object>> list = allItems.stream()
                .filter(item -> !item.isDir())
                .map(item -> {
                    Map<String, Object> map = new LinkedHashMap<>();
                    map.put("objectName", item.objectName());
                    map.put("fileSize", formatFileSize(item.size()));
                    map.put("size", item.size());
                    map.put("lastModified", item.lastModified());
                    // 根据对象名称提取文件类型
                    String ext = getFileExtension(item.objectName());
                    map.put("fileType", ext);
                    // 生成7天有效期的预览URL
                    map.put("previewUrl", minioUtil.getObjectUrl(item.objectName(), 7));
                    return map;
                })
                .collect(Collectors.toList());
        // 按最后修改时间倒序排列
        list.sort((a, b) -> ((Date) b.get("lastModified")).compareTo((Date) a.get("lastModified")));
        return getDataTable(list);
    }

    /**
     * 下载MinIO文件
     */
    @GetMapping("/download")
    public void download(@RequestParam("objectName") String objectName, HttpServletResponse response) {
        try (InputStream inputStream = minioUtil.downloadFile(objectName)) {
            // 从原始文件名中提取显示名称（去掉UUID前缀）
            String displayName = objectName;
            response.setContentType(MediaType.APPLICATION_OCTET_STREAM_VALUE);
            response.setHeader(HttpHeaders.CONTENT_DISPOSITION,
                    "attachment; filename=" + URLEncoder.encode(displayName, StandardCharsets.UTF_8.name()));
            int len;
            byte[] buffer = new byte[4096];
            while ((len = inputStream.read(buffer)) != -1) {
                response.getOutputStream().write(buffer, 0, len);
            }
            response.flushBuffer();
        } catch (Exception e) {
            throw new RuntimeException("文件下载失败: " + objectName, e);
        }
    }

    /**
     * 获取文件预览URL
     */
    @GetMapping("/previewUrl")
    public AjaxResult getPreviewUrl(@RequestParam("objectName") String objectName) {
        String url = minioUtil.getObjectUrl(objectName, 7);
        return success(url);
    }

    /**
     * 删除MinIO文件
     */
    @Log(title = "MinIO资源管理", businessType = BusinessType.DELETE)
    @DeleteMapping
    public AjaxResult remove(@RequestParam("objectName") String objectName) {
        minioUtil.deleteFile(objectName);
        return success();
    }

    /**
     * 格式化文件大小
     */
    private String formatFileSize(long size) {
        if (size < 1024) {
            return size + " B";
        } else if (size < 1024 * 1024) {
            return String.format("%.1f KB", size / 1024.0);
        } else if (size < 1024 * 1024 * 1024) {
            return String.format("%.1f MB", size / (1024.0 * 1024));
        } else {
            return String.format("%.1f GB", size / (1024.0 * 1024 * 1024));
        }
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) {
            return "未知";
        }
        return fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
    }
}

package com.ddss.web.controller.video;

import com.ddss.common.annotation.Log;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.server.domain.po.DdssResource;
import com.ddss.server.minio.util.MinioUtil;
import com.ddss.server.service.DdssResourceService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * 资源管理Controller（MinIO 关闭时，下载功能降级返回错误提示）
 */
@RestController
@RequestMapping("/video/resource")
@ConditionalOnProperty(name = "ddss.middleware.minio.enabled", havingValue = "true", matchIfMissing = true)
public class ResourceController extends BaseController {

    private static final Logger log = LoggerFactory.getLogger(ResourceController.class);

    @Autowired
    private DdssResourceService resourceService;

    @Autowired
    private MinioUtil minioUtil;

    /**
     * 查询资源列表（支持分页和模糊检索）
     */
    @PreAuthorize("@ss.hasPermi('video:resource:list')")
    @GetMapping("/list")
    public TableDataInfo list(DdssResource resource) {
        startPage();
        List<DdssResource> list = resourceService.selectResourceList(resource);
        return getDataTable(list);
    }

    /**
     * 根据资源ID获取详细信息
     */
    @PreAuthorize("@ss.hasPermi('video:resource:query')")
    @GetMapping(value = "/{resourceId}")
    public AjaxResult getInfo(@PathVariable("resourceId") Long resourceId) {
        return success(resourceService.selectResourceById(resourceId));
    }

    /**
     * 新增资源
     */
    @PreAuthorize("@ss.hasPermi('video:resource:add')")
    @Log(title = "资源管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody DdssResource resource) {
        resource.setCreateBy(getUsername());
        return toAjax(resourceService.insertResource(resource));
    }

    /**
     * 修改资源
     */
    @PreAuthorize("@ss.hasPermi('video:resource:edit')")
    @Log(title = "资源管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody DdssResource resource) {
        resource.setUpdateBy(getUsername());
        return toAjax(resourceService.updateResource(resource));
    }

    /**
     * 删除资源
     */
    @PreAuthorize("@ss.hasPermi('video:resource:remove')")
    @Log(title = "资源管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{resourceIds}")
    public AjaxResult remove(@PathVariable Long[] resourceIds) {
        return toAjax(resourceService.deleteResourceByIds(resourceIds));
    }

    /**
     * 下载资源文件（从MinIO）
     */
    @GetMapping("/download")
    public void download(HttpServletResponse response, @RequestParam String objectName) throws Exception {
        // 从MinIO获取文件流
        InputStream inputStream = minioUtil.downloadFile(objectName);
        
        // 设置响应头
        String fileName = objectName.substring(objectName.lastIndexOf("/") + 1);
        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "attachment; filename=" + URLEncoder.encode(fileName, "UTF-8"));
        
        // 写入响应
        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = inputStream.read(buffer)) != -1) {
            response.getOutputStream().write(buffer, 0, bytesRead);
        }
        response.getOutputStream().flush();
        inputStream.close();
    }

    /**
     * 批量下载资源文件（打包成ZIP）
     */
    @PostMapping("/batchDownload")
    public void batchDownload(HttpServletResponse response, @RequestBody List<String> filePaths) throws Exception {
        if (filePaths == null || filePaths.isEmpty()) {
            return;
        }

        // 设置响应头
        response.setContentType("application/zip");
        String zipFileName = "resources_" + System.currentTimeMillis() + ".zip";
        response.setHeader("Content-Disposition", "attachment; filename=" + URLEncoder.encode(zipFileName, StandardCharsets.UTF_8.name()));

        // 创建ZIP输出流 - 使用Java内置ZipOutputStream
        ZipOutputStream zipOut = new ZipOutputStream(response.getOutputStream());

        int successCount = 0;
        int failCount = 0;

        for (String filePath : filePaths) {
            if (filePath == null || filePath.trim().isEmpty()) {
                continue;
            }

            InputStream inputStream = null;
            try {
                // 从MinIO获取文件流
                inputStream = minioUtil.downloadFile(filePath);

                // 提取文件名
                String fileName = filePath.substring(filePath.lastIndexOf("/") + 1);

                // 创建ZIP条目
                ZipEntry entry = new ZipEntry(fileName);
                zipOut.putNextEntry(entry);

                // 写入文件内容
                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    zipOut.write(buffer, 0, bytesRead);
                }

                zipOut.closeEntry();
                successCount++;
            } catch (Exception e) {
                failCount++;
                log.error("批量下载时文件处理失败: {}", filePath, e);
            } finally {
                if (inputStream != null) {
                    try {
                        inputStream.close();
                    } catch (Exception ignored) {
                    }
                }
            }
        }

        log.info("批量下载完成：成功 {} 个文件，失败 {} 个文件", successCount, failCount);

        // 完成ZIP输出（不关闭底层流，由容器处理）
        zipOut.finish();
        response.flushBuffer();
    }
}

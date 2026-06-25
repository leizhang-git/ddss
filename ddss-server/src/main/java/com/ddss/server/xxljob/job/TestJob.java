package com.ddss.server.xxljob.job;

import com.ddss.server.domain.KafkaMessage;
import com.ddss.server.domain.po.DdssResource;
import com.ddss.server.kafka.KafkaProducer;
import com.ddss.server.minio.util.MinioUtil;
import com.ddss.server.service.DdssResourceService;
import com.xxl.job.core.context.XxlJobHelper;
import com.xxl.job.core.handler.annotation.XxlJob;
import io.minio.messages.Item;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * MinIO资源同步任务 - 每10分钟从MinIO同步文件到资源管理表
 *
 * @Author zhanglei
 * @Date 2025/12/12 14:34
 */
@Component
public class TestJob {

    private static final Logger log = LoggerFactory.getLogger(TestJob.class);

    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Resource
    private KafkaProducer kafkaProducer;

    @Resource
    private MinioUtil minioUtil;

    @Resource
    private DdssResourceService resourceService;

    @XxlJob("syncMinioResourceJobHandler")
    protected void syncMinioResource() {
        try {
            XxlJobHelper.log("开始同步MinIO资源到资源表...");
            log.info("【MinIO资源同步任务】开始执行...");

            // 1. 从 MinIO app bucket 获取所有文件
            String bucketName = "app";
            List<Item> minioItems = minioUtil.listObjects(bucketName);
            List<Item> files = minioItems.stream()
                    .filter(item -> !item.isDir())
                    .collect(Collectors.toList());

            XxlJobHelper.log("MinIO bucket [{}] 中共有 {} 个文件", bucketName, files.size());
            log.info("MinIO bucket [{}] 中共有 {} 个文件", bucketName, files.size());

            // 2. 获取数据库中已有的资源路径索引
            List<DdssResource> existingResources = resourceService.list();
            Set<String> existingPaths = existingResources.stream()
                    .map(DdssResource::getFilePath)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toSet());

            // 3. 新增数据库中不存在的MinIO文件
            int insertCount = 0;
            for (Item item : files) {
                String objectName = item.objectName();
                if (!existingPaths.contains(objectName)) {
                    DdssResource resource = new DdssResource();
                    resource.setResourceName(objectName);
                    resource.setFilePath(objectName);
                    resource.setFileSize(formatFileSize(item.size()));
                    resource.setFileType(getFileExtension(objectName));
                    resource.setStatus("0");
                    resource.setCreateBy("system");
                    resourceService.insertResource(resource);
                    insertCount++;
                    log.info("新增资源: {}", objectName);
                }
            }

            // 4. 删除数据库中已不存在于MinIO中的记录
            Set<String> minioPaths = files.stream()
                    .map(Item::objectName)
                    .collect(Collectors.toSet());
            int deleteCount = 0;
            List<Long> toDeleteIds = new ArrayList<>();
            for (DdssResource resource : existingResources) {
                if (resource.getFilePath() != null && !minioPaths.contains(resource.getFilePath())) {
                    toDeleteIds.add(resource.getResourceId());
                }
            }
            if (!toDeleteIds.isEmpty()) {
                resourceService.deleteResourceByIds(toDeleteIds.toArray(new Long[0]));
                deleteCount = toDeleteIds.size();
            }

            XxlJobHelper.log("同步完成，新增 {} 条，删除 {} 条", insertCount, deleteCount);
            log.info("【MinIO资源同步任务】同步完成，新增 {} 条，删除 {} 条", insertCount, deleteCount);
            XxlJobHelper.handleSuccess("同步完成，新增 " + insertCount + " 条，删除 " + deleteCount + " 条");

        } catch (Exception e) {
            XxlJobHelper.log("同步MinIO资源失败: {}", e.getMessage());
            log.error("【MinIO资源同步任务】执行异常", e);
            XxlJobHelper.handleFail("同步失败：" + e.getMessage());
        }
    }

    @XxlJob("kafkaHelloWorldJob")
    protected void kafkaHelloWorldJob() {
        try {
            // 1. 构建测试消息（包含时间戳）
            String timestamp = LocalDateTime.now().format(DATE_TIME_FORMATTER);
            String message = String.format("HelloWorld - %s", timestamp);
            String messageKey = "test-key-" + System.currentTimeMillis();

            // 2. 打印任务执行日志
            XxlJobHelper.log("XXL-Job 触发Kafka测试任务，发送消息：{}", message);
            log.info("【Kafka测试任务】准备发送消息，key：{}，内容：{}", messageKey, message);

            // 3. 构造KafkaMessage
            KafkaMessage kafkaMessage = new KafkaMessage();
            kafkaMessage.setKey(messageKey);
            kafkaMessage.setData(message);
            kafkaMessage.setTopic(kafkaProducer.getProducerTopic());

            // 4. 调用生产者方法（复用你的线程池异步发送）
            kafkaProducer.sendSingleMessage(kafkaMessage);

            // 5. 标记任务执行成功
            XxlJobHelper.handleSuccess("消息已提交到线程池，发送队列已接收！发送内容：" + message);
            log.info("【Kafka测试任务】消息提交完成 ✅");

        } catch (Exception e) {
            XxlJobHelper.handleFail("消息提交失败：" + e.getMessage());
            log.error("【Kafka测试任务】消息提交异常 ❌", e);
            throw new RuntimeException(e);
        }
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

package com.ddss.server.xxljob.job;

import com.ddss.server.domain.KafkaMessage;
import com.ddss.server.kafka.KafkaCustomer;
import com.ddss.server.kafka.KafkaProducer;
import com.xxl.job.core.context.XxlJobHelper;
import com.xxl.job.core.handler.annotation.XxlJob;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * @Author zhanglei
 * @Date 2025/12/12 14:34
 */
@Component
public class TestJob {

    private static final Logger log = LoggerFactory.getLogger(TestJob.class);

    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");


    @Resource
    private KafkaProducer kafkaProducer;

    @XxlJob("testJobHandler")
    protected void testJobHandler() {
        System.out.println("testJobHandler");
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
}

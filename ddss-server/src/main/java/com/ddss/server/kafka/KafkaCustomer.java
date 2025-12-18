package com.ddss.server.kafka;

import com.ddss.server.domain.KafkaMessage;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;

/**
 * @Auth zhanglei
 * @Date 2023/2/18 22:12
 */
@Component
@RefreshScope
public class KafkaCustomer {

    private static final Logger log = LoggerFactory.getLogger(KafkaCustomer.class);

    @Resource
    private KafkaMessagePool kafkaMessagePool;

    @KafkaListener(topics = "${kafka.consumer.topic}")
    public void listen(ConsumerRecord<String,String> consumer) {
        try {
            String topic = consumer.topic();
            String key = consumer.key();
            String value = consumer.value();
            long offset = consumer.offset();
            int partition = consumer.partition();

            // 打印消费日志（核心：验证是否消费到XXL-Job发送的HelloWorld）
            log.info("Kafka消息消费成功 📥 | 主题：{} | 分区：{} | Offset：{} | Key：{} | 内容：{}",
                    topic, partition, offset, key, value);

            // 存入消息池（复用原有逻辑）
            KafkaMessage kafkaMessage = new KafkaMessage();
            kafkaMessage.setTopic(topic);
            kafkaMessage.setKey(key);
            kafkaMessage.setData(value);
            kafkaMessagePool.sendMessages(kafkaMessage);

        } catch (Exception e) {
            log.error("Kafka消息消费异常 ❌ | 主题：{} | Key：{}",
                    consumer.topic(), consumer.key(), e);
        }
    }
}


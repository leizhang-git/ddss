package com.ddss.server.kafka;

import com.ddss.server.context.IContextInfoProxy;
import com.ddss.server.domain.KafkaMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.util.concurrent.Callable;
import java.util.concurrent.Future;

/**
 * @Auth zhanglei
 * @Date 2023/2/18 22:12
 */
@Configuration
@Component
public class KafkaProducer {

    private final Logger log = LoggerFactory.getLogger(KafkaProducer.class);

    @Autowired
    private KafkaTemplate<String,String> kafkaTemplate;

    @Resource
    private KafkaMessagePool kafkaMessagePool;

    private boolean isExit;

    @Resource
    private ThreadPoolTaskExecutor commonThreadPoolExecutor;

    @Value("${kafka.producer.topic}")
    private String producerTopic;
    // 记录异步发送任务的Future，便于关闭时控制
    private Future<?> sendFuture;

    @PostConstruct
    public void init() {
        // 启动异步发送任务
        startAsyncSend();
        isExit = false;
    }

    /**
     * 异步发送消息（核心优化）
     */
    private void startAsyncSend() {
        // 调用你提供的execute方法提交任务
        sendFuture = execute(() -> {
            while (!isExit) {
                try {
                    KafkaMessage messages = kafkaMessagePool.getMessages();
                    if (messages != null) {
                        // 发送消息到Kafka，并监听发送结果
                        kafkaTemplate.send(producerTopic, messages.getKey(), messages.getData())
                                .addCallback(
                                        success -> log.info("Kafka消息发送成功 📤 | 主题：{} | Key：{} | Offset：{}",
                                                producerTopic, messages.getKey(), success.getRecordMetadata().offset()),
                                        failure -> log.error("Kafka消息发送失败 ❌ | 主题：{} | Key：{}",
                                                producerTopic, messages.getKey(), failure)
                                );
                    } else {
                        // 无消息时休眠100ms，避免空轮询消耗CPU
                        Thread.sleep(100);
                    }
                } catch (InterruptedException e) {
                    log.warn("Kafka发送线程被中断", e);
                    Thread.currentThread().interrupt();
                } catch (Exception e) {
                    log.error("Kafka发送消息异常", e);
                }
            }
            return null;
        });
    }

    /**
     * 对外提供发送单个消息的方法（供XXL-Job调用）
     */
    public void sendSingleMessage(KafkaMessage message) {
        if (message != null) {
            kafkaMessagePool.sendMessages(message);
            log.info("消息已加入发送队列 | Key：{} | 内容：{}", message.getKey(), message.getData());
        }
    }

    public void close() {
        isExit = true;
        // 取消未完成的任务
        if (sendFuture != null && !sendFuture.isDone()) {
            sendFuture.cancel(true);
        }
        log.info("Kafka生产者异步任务已关闭");
    }

    // Getter方法（供XXL-Job获取生产者主题）
    public String getProducerTopic() {
        return producerTopic;
    }

    private Future<?> execute(Callable<?> loader){
        return commonThreadPoolExecutor.submit(()->{
            Object result;
            try {
                result = loader.call();
            }catch (Exception e){
                result = null;
            }finally {
                IContextInfoProxy.reset();
            }
            return result;
        });
    }
}

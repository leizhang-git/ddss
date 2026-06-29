package com.ddss.server.kafka;

import com.ddss.server.domain.KafkaMessage;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

/**
 * @Auth zhanglei
 * @Date 2023/2/18 22:11
 */
@Component
@Configuration
@ConditionalOnProperty(name = "ddss.middleware.kafka.enabled", havingValue = "true", matchIfMissing = true)
public class KafkaMessagePool {

    private Queue<KafkaMessage> messageQueue;

    @PostConstruct
    public void init() {
        messageQueue = new ConcurrentLinkedQueue<>();
    }

    public void sendMessages(KafkaMessage message) {
        messageQueue.add(message);
    }

    public KafkaMessage getMessages() {
        return messageQueue.poll();
    }
}

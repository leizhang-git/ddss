package com.ddss.server.domain;

import lombok.Data;

/**
 * @Auth zhanglei
 * @Date 2023/2/18 22:10
 */
@Data
public class KafkaMessage {

    private String topic;

    private String key;

    private String data;
}

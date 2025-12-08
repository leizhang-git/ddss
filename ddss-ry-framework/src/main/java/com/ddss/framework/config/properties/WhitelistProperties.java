package com.ddss.framework.config.properties;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * @Author zhanglei
 * @Date 2025/12/8 18:57
 */
@Component
@ConfigurationProperties(prefix = "whitelist")
public class WhitelistProperties {

    /**
     * 白名单URL列表
     */
    private List<String> urls = new ArrayList<>();

    public List<String> getUrls() {
        return urls;
    }

    public void setUrls(List<String> urls) {
        this.urls = urls;
    }
}
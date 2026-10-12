package com.ddss.framework.strategy;

import com.ddss.common.config.DdssConfig;
import com.ddss.common.strategy.CaptchaStrategy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Set;

@Component
public class CaptchaStrategyContext {

    @Autowired
    private Map<String, CaptchaStrategy> strategyMap;

    /** 根据 DdssConfig 配置自动选择策略 */
    public CaptchaStrategy getStrategy() {
        String type = DdssConfig.getCaptchaType();
        return getStrategy(type);
    }

    public CaptchaStrategy getStrategy(String type) {
        CaptchaStrategy strategy = "math".equals(type)
                ? strategyMap.get("mathCaptchaStrategy")
                : strategyMap.get("charCaptchaStrategy");
        if (strategy == null) {
            // 降级：返回第一个可用策略
            strategy = strategyMap.values().iterator().next();
        }
        return strategy;
    }

    public Set<String> getAvailableTypes() {
        return strategyMap.keySet();
    }
}

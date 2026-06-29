package com.ddss.common.strategy;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.PostConstruct;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class StorageStrategyContext {

    private final Map<String, StorageStrategy> strategyMap = new HashMap<>();

    @Autowired
    private List<StorageStrategy> strategies;

    @PostConstruct
    public void init() {
        for (StorageStrategy strategy : strategies) {
            strategyMap.put(strategy.getType(), strategy);
        }
    }

    public StorageStrategy getStrategy(String type) {
        StorageStrategy strategy = strategyMap.get(type);
        if (strategy == null) {
            throw new IllegalArgumentException("No storage strategy found for type: " + type);
        }
        return strategy;
    }

    public StorageStrategy getDefaultStrategy() {
        StorageStrategy localStrategy = strategyMap.get("local");
        if (localStrategy != null) {
            return localStrategy;
        }
        return strategies.isEmpty() ? null : strategies.get(0);
    }

    public String upload(MultipartFile file, String path) {
        return getDefaultStrategy().upload(file, path);
    }

    public InputStream download(String path, String fileName) {
        return getDefaultStrategy().download(path, fileName);
    }

    public boolean delete(String path, String fileName) {
        return getDefaultStrategy().delete(path, fileName);
    }
}

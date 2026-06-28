package com.ddss.common.utils;

import com.alibaba.fastjson2.JSONArray;
import com.ddss.common.constant.CacheConstants;
import com.ddss.common.core.domain.entity.SysDictData;
import com.ddss.common.core.redis.RedisCache;
import com.ddss.common.utils.spring.SpringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 字典工具类（增强版）
 *
 * @author ddss
 */
public class DictUtils {

    public static final String SEPARATOR = ",";

    /** 字典缓存过期时间：2 小时 */
    private static final long DICT_CACHE_TTL = 7200;

    public static void setDictCache(String key, List<SysDictData> dictDatas) {
        SpringUtils.getBean(RedisCache.class).setCacheObjectWithJitter(getCacheKey(key), dictDatas, DICT_CACHE_TTL);
    }

    /**
     * 获取字典缓存（带穿透/击穿防护）
     *
     * @param key        字典类型
     * @param supplier   数据库查询降级函数
     */
    public static List<SysDictData> getDictCache(String key, java.util.function.Supplier<List<SysDictData>> supplier) {
        String cacheKey = getCacheKey(key);
        RedisCache redisCache = SpringUtils.getBean(RedisCache.class);
        JSONArray arrayCache = redisCache.getCacheObject(cacheKey);
        if (StringUtils.isNotNull(arrayCache)) {
            return arrayCache.toList(SysDictData.class);
        }
        // 缓存未命中，查库 + 回填
        if (supplier != null) {
            List<SysDictData> data = supplier.get();
            if (data != null && !data.isEmpty()) {
                redisCache.setCacheObjectWithJitter(cacheKey, data, DICT_CACHE_TTL);
            } else {
                redisCache.setNullCache(cacheKey);
            }
            return data;
        }
        return null;
    }

    /**
     * 获取字典缓存（兼容旧调用，不自动回填）
     */
    public static List<SysDictData> getDictCache(String key) {
        JSONArray arrayCache = SpringUtils.getBean(RedisCache.class).getCacheObject(getCacheKey(key));
        if (StringUtils.isNotNull(arrayCache)) {
            return arrayCache.toList(SysDictData.class);
        }
        return null;
    }

    public static String getDictLabel(String dictType, String dictValue) {
        if (StringUtils.isEmpty(dictValue)) {
            return StringUtils.EMPTY;
        }
        return getDictLabel(dictType, dictValue, SEPARATOR);
    }

    public static String getDictValue(String dictType, String dictLabel) {
        if (StringUtils.isEmpty(dictLabel)) {
            return StringUtils.EMPTY;
        }
        return getDictValue(dictType, dictLabel, SEPARATOR);
    }

    public static String getDictLabel(String dictType, String dictValue, String separator) {
        List<SysDictData> datas = getDictCache(dictType);
        if (StringUtils.isNull(datas) || StringUtils.isEmpty(dictValue)) {
            return StringUtils.EMPTY;
        }
        Map<String, String> dictMap = datas.stream().collect(HashMap::new, (map, dict) -> map.put(dict.getDictValue(), dict.getDictLabel()), Map::putAll);
        if (!StringUtils.contains(dictValue, separator)) {
            return dictMap.getOrDefault(dictValue, StringUtils.EMPTY);
        }
        StringBuilder labelBuilder = new StringBuilder();
        for (String seperatedValue : dictValue.split(separator)) {
            if (dictMap.containsKey(seperatedValue)) {
                labelBuilder.append(dictMap.get(seperatedValue)).append(separator);
            }
        }
        return StringUtils.removeEnd(labelBuilder.toString(), separator);
    }

    public static String getDictValue(String dictType, String dictLabel, String separator) {
        List<SysDictData> datas = getDictCache(dictType);
        if (StringUtils.isNull(datas) || StringUtils.isEmpty(dictLabel)) {
            return StringUtils.EMPTY;
        }
        Map<String, String> dictMap = datas.stream().collect(HashMap::new, (map, dict) -> map.put(dict.getDictLabel(), dict.getDictValue()), Map::putAll);
        if (!StringUtils.contains(dictLabel, separator)) {
            return dictMap.getOrDefault(dictLabel, StringUtils.EMPTY);
        }
        StringBuilder valueBuilder = new StringBuilder();
        for (String seperatedValue : dictLabel.split(separator)) {
            if (dictMap.containsKey(seperatedValue)) {
                valueBuilder.append(dictMap.get(seperatedValue)).append(separator);
            }
        }
        return StringUtils.removeEnd(valueBuilder.toString(), separator);
    }

    public static String getDictValues(String dictType) {
        StringBuilder propertyString = new StringBuilder();
        List<SysDictData> datas = getDictCache(dictType);
        if (StringUtils.isNull(datas)) {
            return StringUtils.EMPTY;
        }
        for (SysDictData dict : datas) {
            propertyString.append(dict.getDictValue()).append(SEPARATOR);
        }
        return StringUtils.stripEnd(propertyString.toString(), SEPARATOR);
    }

    public static String getDictLabels(String dictType) {
        StringBuilder propertyString = new StringBuilder();
        List<SysDictData> datas = getDictCache(dictType);
        if (StringUtils.isNull(datas)) {
            return StringUtils.EMPTY;
        }
        for (SysDictData dict : datas) {
            propertyString.append(dict.getDictLabel()).append(SEPARATOR);
        }
        return StringUtils.stripEnd(propertyString.toString(), SEPARATOR);
    }

    public static void removeDictCache(String key) {
        SpringUtils.getBean(RedisCache.class).deleteObject(getCacheKey(key));
    }

    /**
     * 清空字典缓存（使用 scan 替代 keys，避免阻塞）
     */
    public static void clearDictCache() {
        SpringUtils.getBean(RedisCache.class).deleteByPattern(CacheConstants.SYS_DICT_KEY + "*");
    }

    public static String getCacheKey(String configKey) {
        return CacheConstants.SYS_DICT_KEY + configKey;
    }
}

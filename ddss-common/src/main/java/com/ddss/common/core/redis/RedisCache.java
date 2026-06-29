package com.ddss.common.core.redis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.*;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

/**
 * Redis 工具类（增强版：穿透/击穿/雪崩防护）
 *
 * @author ddss
 */
@SuppressWarnings(value = {"unchecked", "rawtypes"})
@Component
public class RedisCache {

    @Autowired
    public RedisTemplate redisTemplate;

    // ==================== 基础操作 ====================

    public <T> void setCacheObject(final String key, final T value) {
        redisTemplate.opsForValue().set(key, value);
    }

    public <T> void setCacheObject(final String key, final T value, final Integer timeout, final TimeUnit timeUnit) {
        redisTemplate.opsForValue().set(key, value, timeout, timeUnit);
    }

    /**
     * 带随机抖动的缓存写入（防雪崩：避免大量 key 同时过期）
     *
     * @param ttl 基础过期时间（秒）
     */
    public <T> void setCacheObjectWithJitter(final String key, final T value, final long ttl) {
        long actualTtl = addJitter(ttl);
        redisTemplate.opsForValue().set(key, value, actualTtl, TimeUnit.SECONDS);
    }

    public boolean expire(final String key, final long timeout) {
        return expire(key, timeout, TimeUnit.SECONDS);
    }

    public boolean expire(final String key, final long timeout, final TimeUnit unit) {
        return redisTemplate.expire(key, timeout, unit);
    }

    public long getExpire(final String key) {
        return redisTemplate.getExpire(key);
    }

    public Boolean hasKey(String key) {
        return redisTemplate.hasKey(key);
    }

    public <T> T getCacheObject(final String key) {
        ValueOperations<String, T> operation = redisTemplate.opsForValue();
        return operation.get(key);
    }

    public boolean deleteObject(final String key) {
        return redisTemplate.delete(key);
    }

    public boolean deleteObject(final Collection collection) {
        return redisTemplate.delete(collection) > 0;
    }

    // ==================== 缓存穿透防护 ====================

    private static final String NULL_VALUE = "__NULL__";
    private static final long NULL_TTL = 300; // 空值缓存 5 分钟

    /**
     * 缓存空值（防穿透：阻止不存在的 key 反复查 DB）
     */
    public void setNullCache(final String key) {
        setCacheObjectWithJitter(key, NULL_VALUE, NULL_TTL);
    }

    /**
     * 判断是否为缓存的空值标记
     */
    public boolean isNullCache(final String key) {
        Object value = getCacheObject(key);
        return NULL_VALUE.equals(value);
    }

    // ==================== 防击穿：互斥锁 ====================

    private static final String LOCK_SUFFIX = ":lock";
    private static final long LOCK_EXPIRE = 10; // 锁超时 10 秒

    /**
     * 尝试获取互斥锁（防击穿：热点 key 过期时只有一条线程重建缓存）
     */
    public boolean tryLock(String key) {
        String lockKey = key + LOCK_SUFFIX;
        Boolean success = redisTemplate.opsForValue()
                .setIfAbsent(lockKey, "1", LOCK_EXPIRE, TimeUnit.SECONDS);
        return Boolean.TRUE.equals(success);
    }

    /**
     * 释放互斥锁
     */
    public void unlock(String key) {
        redisTemplate.delete(key + LOCK_SUFFIX);
    }

    // ==================== Cache-Aside 通用模板 ====================

    /**
     * Cache-Aside 模式：读缓存 → 未命中则查库并回填（带穿透防护）
     *
     * @param key      缓存键
     * @param supplier 数据库查询函数
     * @param ttl      缓存过期时间（秒），会自动加随机抖动
     * @return 缓存数据
     */
    public <T> T getOrSet(final String key, final Supplier<T> supplier, final long ttl) {
        // 1. 查缓存
        Object cached = getCacheObject(key);
        if (cached != null) {
            if (NULL_VALUE.equals(cached)) {
                return null; // 缓存的空值标记，直接返回 null
            }
            return (T) cached;
        }

        // 2. 缓存未命中，查数据库
        T value = supplier.get();
        if (value != null) {
            // 有数据：写入缓存（带抖动 TTL）
            setCacheObjectWithJitter(key, value, ttl);
        } else {
            // 无数据：缓存空值标记（防穿透）
            setNullCache(key);
        }
        return value;
    }

    /**
     * Cache-Aside + 互斥锁模式（防击穿）
     *
     * 热点 key 过期时，只有获取到锁的线程去重建缓存，其他线程自旋等待。
     *
     * @param key      缓存键
     * @param supplier 数据库查询函数
     * @param ttl      缓存过期时间（秒）
     * @return 缓存数据
     */
    public <T> T getOrSetWithLock(final String key, final Supplier<T> supplier, final long ttl) {
        // 1. 先查缓存
        Object cached = getCacheObject(key);
        if (cached != null) {
            if (NULL_VALUE.equals(cached)) {
                return null;
            }
            return (T) cached;
        }

        // 2. 未命中，尝试获取互斥锁
        if (tryLock(key)) {
            try {
                // 双重检查：获取锁后可能别的线程已经重建好了
                cached = getCacheObject(key);
                if (cached != null) {
                    if (NULL_VALUE.equals(cached)) {
                        return null;
                    }
                    return (T) cached;
                }

                // 查库并回填
                T value = supplier.get();
                if (value != null) {
                    setCacheObjectWithJitter(key, value, ttl);
                } else {
                    setNullCache(key);
                }
                return value;
            } finally {
                unlock(key);
            }
        }

        // 3. 没获取到锁，短暂等待后重试读缓存
        try {
            Thread.sleep(50);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        return getOrSet(key, supplier, ttl); // 递归走一次无锁流程
    }

    // ==================== 安全 scan 替代 keys ====================

    /**
     * 使用 scan 命令获取匹配的 key（替代阻塞的 keys 命令）
     *
     * @param pattern 匹配模式，如 "sys_config:*"
     * @return 匹配的 key 集合
     */
    public Set<String> scanKeys(final String pattern) {
        Set<String> keys = new HashSet<>();
        redisTemplate.execute((RedisCallback<Object>) connection -> {
            try (Cursor<byte[]> cursor = connection.scan(
                    ScanOptions.scanOptions().match(pattern).count(100).build())) {
                while (cursor.hasNext()) {
                    keys.add(new String(cursor.next()));
                }
            } catch (Exception e) {
                throw new RuntimeException("scan keys error", e);
            }
            return null;
        });
        return keys;
    }

    /**
     * 使用 scan 命令删除匹配的 key
     */
    public void deleteByPattern(final String pattern) {
        Set<String> keys = scanKeys(pattern);
        if (!keys.isEmpty()) {
            redisTemplate.delete(keys);
        }
    }

    // ==================== TTL 随机抖动 ====================

    /**
     * 在基础 TTL 上添加 ±20% 随机偏移（防雪崩）
     */
    private long addJitter(long baseTtl) {
        double jitter = 0.8 + Math.random() * 0.4; // 0.8 ~ 1.2
        return Math.max(1, (long) (baseTtl * jitter));
    }

    // ==================== List / Set / Hash 操作 ====================

    public <T> long setCacheList(final String key, final List<T> dataList) {
        Long count = redisTemplate.opsForList().rightPushAll(key, dataList);
        return count == null ? 0 : count;
    }

    public <T> List<T> getCacheList(final String key) {
        return redisTemplate.opsForList().range(key, 0, -1);
    }

    public <T> BoundSetOperations<String, T> setCacheSet(final String key, final Set<T> dataSet) {
        BoundSetOperations<String, T> setOperation = redisTemplate.boundSetOps(key);
        for (T item : dataSet) {
            setOperation.add(item);
        }
        return setOperation;
    }

    public <T> Set<T> getCacheSet(final String key) {
        return redisTemplate.opsForSet().members(key);
    }

    public <T> void setCacheMap(final String key, final Map<String, T> dataMap) {
        if (dataMap != null) {
            redisTemplate.opsForHash().putAll(key, dataMap);
        }
    }

    public <T> Map<String, T> getCacheMap(final String key) {
        return redisTemplate.opsForHash().entries(key);
    }

    public <T> void setCacheMapValue(final String key, final String hKey, final T value) {
        redisTemplate.opsForHash().put(key, hKey, value);
    }

    public <T> T getCacheMapValue(final String key, final String hKey) {
        HashOperations<String, String, T> opsForHash = redisTemplate.opsForHash();
        return opsForHash.get(key, hKey);
    }

    public <T> List<T> getMultiCacheMapValue(final String key, final Collection<Object> hKeys) {
        return redisTemplate.opsForHash().multiGet(key, hKeys);
    }

    public boolean deleteCacheMapValue(final String key, final String hKey) {
        return redisTemplate.opsForHash().delete(key, hKey) > 0;
    }

    /**
     * @deprecated 生产环境请使用 {@link #scanKeys(String)} 替代
     */
    @Deprecated
    public Collection<String> keys(final String pattern) {
        return redisTemplate.keys(pattern);
    }
}

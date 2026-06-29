package com.ddss.common.core.redis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.*;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;

/**
 * Redis 工具类（增强版：穿透/击穿/雪崩防护）
 * 当 ddss.middleware.redis.enabled=false 时，所有 Redis 操作静默降级（返回空/不执行）
 *
 * @author ddss
 */
@SuppressWarnings(value = {"unchecked", "rawtypes"})
@Component
public class RedisCache {

    @Autowired(required = false)
    public RedisTemplate redisTemplate;

    private boolean isAvailable() {
        return redisTemplate != null;
    }

    // ==================== 基础操作 ====================

    public <T> void setCacheObject(final String key, final T value) {
        if (!isAvailable()) return;
        redisTemplate.opsForValue().set(key, value);
    }

    public <T> void setCacheObject(final String key, final T value, final Integer timeout, final TimeUnit timeUnit) {
        if (!isAvailable()) return;
        redisTemplate.opsForValue().set(key, value, timeout, timeUnit);
    }

    public <T> void setCacheObjectWithJitter(final String key, final T value, final long ttl) {
        if (!isAvailable()) return;
        long actualTtl = addJitter(ttl);
        redisTemplate.opsForValue().set(key, value, actualTtl, TimeUnit.SECONDS);
    }

    public boolean expire(final String key, final long timeout) {
        if (!isAvailable()) return false;
        return expire(key, timeout, TimeUnit.SECONDS);
    }

    public boolean expire(final String key, final long timeout, final TimeUnit unit) {
        if (!isAvailable()) return false;
        return redisTemplate.expire(key, timeout, unit);
    }

    public long getExpire(final String key) {
        if (!isAvailable()) return -2L;
        return redisTemplate.getExpire(key);
    }

    public Boolean hasKey(String key) {
        if (!isAvailable()) return false;
        return redisTemplate.hasKey(key);
    }

    public <T> T getCacheObject(final String key) {
        if (!isAvailable()) return null;
        ValueOperations<String, T> operation = redisTemplate.opsForValue();
        return operation.get(key);
    }

    public boolean deleteObject(final String key) {
        if (!isAvailable()) return false;
        return redisTemplate.delete(key);
    }

    public boolean deleteObject(final Collection collection) {
        if (!isAvailable()) return false;
        return redisTemplate.delete(collection) > 0;
    }

    // ==================== 缓存穿透防护 ====================

    private static final String NULL_VALUE = "__NULL__";
    private static final long NULL_TTL = 300;

    public void setNullCache(final String key) {
        setCacheObjectWithJitter(key, NULL_VALUE, NULL_TTL);
    }

    public boolean isNullCache(final String key) {
        Object value = getCacheObject(key);
        return NULL_VALUE.equals(value);
    }

    // ==================== 防击穿：互斥锁 ====================

    private static final String LOCK_SUFFIX = ":lock";
    private static final long LOCK_EXPIRE = 10;

    public boolean tryLock(String key) {
        if (!isAvailable()) return false;
        String lockKey = key + LOCK_SUFFIX;
        Boolean success = redisTemplate.opsForValue()
                .setIfAbsent(lockKey, "1", LOCK_EXPIRE, TimeUnit.SECONDS);
        return Boolean.TRUE.equals(success);
    }

    public void unlock(String key) {
        if (!isAvailable()) return;
        redisTemplate.delete(key + LOCK_SUFFIX);
    }

    // ==================== Cache-Aside 通用模板 ====================

    /**
     * Cache-Aside 模式。Redis 不可用时自动降级为直接查库。
     */
    public <T> T getOrSet(final String key, final Supplier<T> supplier, final long ttl) {
        if (!isAvailable()) return supplier.get();

        Object cached = getCacheObject(key);
        if (cached != null) {
            if (NULL_VALUE.equals(cached)) return null;
            return (T) cached;
        }
        T value = supplier.get();
        if (value != null) {
            setCacheObjectWithJitter(key, value, ttl);
        } else {
            setNullCache(key);
        }
        return value;
    }

    /**
     * Cache-Aside + 互斥锁模式。Redis 不可用时自动降级为直接查库。
     */
    public <T> T getOrSetWithLock(final String key, final Supplier<T> supplier, final long ttl) {
        if (!isAvailable()) return supplier.get();

        Object cached = getCacheObject(key);
        if (cached != null) {
            if (NULL_VALUE.equals(cached)) return null;
            return (T) cached;
        }

        if (tryLock(key)) {
            try {
                cached = getCacheObject(key);
                if (cached != null) {
                    if (NULL_VALUE.equals(cached)) return null;
                    return (T) cached;
                }
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

        try { Thread.sleep(50); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
        return getOrSet(key, supplier, ttl);
    }

    // ==================== 安全 scan 替代 keys ====================

    public Set<String> scanKeys(final String pattern) {
        if (!isAvailable()) return Collections.emptySet();
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

    public void deleteByPattern(final String pattern) {
        if (!isAvailable()) return;
        Set<String> keys = scanKeys(pattern);
        if (!keys.isEmpty()) {
            redisTemplate.delete(keys);
        }
    }

    // ==================== TTL 随机抖动 ====================

    private long addJitter(long baseTtl) {
        double jitter = 0.8 + Math.random() * 0.4;
        return Math.max(1, (long) (baseTtl * jitter));
    }

    // ==================== List / Set / Hash ====================

    public <T> long setCacheList(final String key, final List<T> dataList) {
        if (!isAvailable()) return 0;
        Long count = redisTemplate.opsForList().rightPushAll(key, dataList);
        return count == null ? 0 : count;
    }

    public <T> List<T> getCacheList(final String key) {
        if (!isAvailable()) return Collections.emptyList();
        return redisTemplate.opsForList().range(key, 0, -1);
    }

    public <T> BoundSetOperations<String, T> setCacheSet(final String key, final Set<T> dataSet) {
        if (!isAvailable()) return null;
        BoundSetOperations<String, T> setOperation = redisTemplate.boundSetOps(key);
        for (T item : dataSet) setOperation.add(item);
        return setOperation;
    }

    public <T> Set<T> getCacheSet(final String key) {
        if (!isAvailable()) return Collections.emptySet();
        return redisTemplate.opsForSet().members(key);
    }

    public <T> void setCacheMap(final String key, final Map<String, T> dataMap) {
        if (!isAvailable()) return;
        if (dataMap != null) redisTemplate.opsForHash().putAll(key, dataMap);
    }

    public <T> Map<String, T> getCacheMap(final String key) {
        if (!isAvailable()) return Collections.emptyMap();
        return redisTemplate.opsForHash().entries(key);
    }

    public <T> void setCacheMapValue(final String key, final String hKey, final T value) {
        if (!isAvailable()) return;
        redisTemplate.opsForHash().put(key, hKey, value);
    }

    public <T> T getCacheMapValue(final String key, final String hKey) {
        if (!isAvailable()) return null;
        HashOperations<String, String, T> opsForHash = redisTemplate.opsForHash();
        return opsForHash.get(key, hKey);
    }

    public <T> List<T> getMultiCacheMapValue(final String key, final Collection<Object> hKeys) {
        if (!isAvailable()) return Collections.emptyList();
        return redisTemplate.opsForHash().multiGet(key, hKeys);
    }

    public boolean deleteCacheMapValue(final String key, final String hKey) {
        if (!isAvailable()) return false;
        return redisTemplate.opsForHash().delete(key, hKey) > 0;
    }

    /** @deprecated 生产环境请使用 {@link #scanKeys(String)} 替代 */
    @Deprecated
    public Collection<String> keys(final String pattern) {
        if (!isAvailable()) return Collections.emptyList();
        return redisTemplate.keys(pattern);
    }
}

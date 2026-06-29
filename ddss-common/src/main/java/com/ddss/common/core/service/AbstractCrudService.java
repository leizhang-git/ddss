package com.ddss.common.core.service;

import com.ddss.common.core.redis.RedisCache;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

public abstract class AbstractCrudService<T, ID> {

    private static final Logger log = LoggerFactory.getLogger(AbstractCrudService.class);

    @Autowired
    protected RedisCache redisCache;

    // ==================== Abstract methods (subclasses must implement) ====================

    protected abstract T doSelectById(ID id);

    protected abstract List<T> doSelectList(T entity);

    protected abstract int doInsert(T entity);

    protected abstract int doUpdate(T entity);

    protected abstract int doDeleteById(ID id);

    protected abstract ID extractId(T entity);

    protected abstract String getEntityName();

    // ==================== Cache key helpers ====================

    protected String buildCacheKey(ID id) {
        return getEntityName() + ":" + id;
    }

    protected String buildListCacheKey() {
        return getEntityName() + ":list";
    }

    protected long getCacheTtl() {
        return 3600;
    }

    // ==================== Template methods ====================

    public T selectById(ID id) {
        String cacheKey = buildCacheKey(id);
        return redisCache.getOrSetWithLock(cacheKey, () -> doSelectById(id), getCacheTtl());
    }

    public List<T> selectList(T entity) {
        String cacheKey = buildListCacheKey();
        return redisCache.getOrSet(cacheKey, () -> doSelectList(entity), getCacheTtl());
    }

    public int insert(T entity) {
        int rows = doInsert(entity);
        if (rows > 0) {
            clearListCache();
        }
        return rows;
    }

    public int update(T entity) {
        int rows = doUpdate(entity);
        if (rows > 0) {
            clearIdCache(extractId(entity));
            clearListCache();
        }
        return rows;
    }

    public int deleteById(ID id) {
        int rows = doDeleteById(id);
        if (rows > 0) {
            clearIdCache(id);
            clearListCache();
        }
        return rows;
    }

    public boolean existsById(ID id) {
        return selectById(id) != null;
    }

    // ==================== Cache eviction helpers ====================

    protected void clearIdCache(ID id) {
        String cacheKey = buildCacheKey(id);
        redisCache.deleteObject(cacheKey);
    }

    protected void clearListCache() {
        String pattern = buildListCacheKey() + "*";
        redisCache.deleteByPattern(pattern);
    }
}

package com.ddss.system.service.impl;

import com.ddss.common.annotation.DataSource;
import com.ddss.common.constant.CacheConstants;
import com.ddss.common.constant.UserConstants;
import com.ddss.common.core.redis.RedisCache;
import com.ddss.common.core.text.Convert;
import com.ddss.common.enums.DataSourceType;
import com.ddss.common.exception.ServiceException;
import com.ddss.common.utils.StringUtils;
import com.ddss.system.domain.SysConfig;
import com.ddss.system.mapper.SysConfigMapper;
import com.ddss.system.service.ISysConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.DependsOn;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.List;

/**
 * 参数配置 服务层实现
 *
 * @author ddss
 */
@Service
@DependsOn("h2DataInitializer")
public class SysConfigServiceImpl implements ISysConfigService {

    /** 配置缓存过期时间：1 小时 */
    private static final long CONFIG_CACHE_TTL = 3600;

    @Autowired
    private SysConfigMapper configMapper;

    @Autowired
    private RedisCache redisCache;

    @PostConstruct
    public void init() {
        loadingConfigCache();
    }

    @Override
    @DataSource(DataSourceType.MASTER)
    public SysConfig selectConfigById(Long configId) {
        SysConfig config = new SysConfig();
        config.setConfigId(configId);
        return configMapper.selectConfig(config);
    }

    /**
     * 根据键名查询参数配置信息（带穿透/击穿防护）
     */
    @Override
    public String selectConfigByKey(String configKey) {
        String cacheKey = getCacheKey(configKey);
        return redisCache.getOrSetWithLock(cacheKey, () -> {
            SysConfig config = new SysConfig();
            config.setConfigKey(configKey);
            SysConfig retConfig = configMapper.selectConfig(config);
            return retConfig != null ? retConfig.getConfigValue() : null;
        }, CONFIG_CACHE_TTL);
    }

    @Override
    public boolean selectCaptchaEnabled() {
        String captchaEnabled = selectConfigByKey("sys.account.captchaEnabled");
        if (StringUtils.isEmpty(captchaEnabled)) {
            return true;
        }
        return Convert.toBool(captchaEnabled);
    }

    @Override
    public List<SysConfig> selectConfigList(SysConfig config) {
        return configMapper.selectConfigList(config);
    }

    @Override
    public int insertConfig(SysConfig config) {
        int row = configMapper.insertConfig(config);
        if (row > 0) {
            redisCache.setCacheObjectWithJitter(getCacheKey(config.getConfigKey()), config.getConfigValue(), CONFIG_CACHE_TTL);
        }
        return row;
    }

    @Override
    public int updateConfig(SysConfig config) {
        SysConfig temp = configMapper.selectConfigById(config.getConfigId());
        if (!StringUtils.equals(temp.getConfigKey(), config.getConfigKey())) {
            redisCache.deleteObject(getCacheKey(temp.getConfigKey()));
        }
        int row = configMapper.updateConfig(config);
        if (row > 0) {
            redisCache.setCacheObjectWithJitter(getCacheKey(config.getConfigKey()), config.getConfigValue(), CONFIG_CACHE_TTL);
        }
        return row;
    }

    @Override
    public void deleteConfigByIds(Long[] configIds) {
        for (Long configId : configIds) {
            SysConfig config = selectConfigById(configId);
            if (StringUtils.equals(UserConstants.YES, config.getConfigType())) {
                throw new ServiceException(String.format("内置参数【%1$s】不能删除 ", config.getConfigKey()));
            }
            configMapper.deleteConfigById(configId);
            redisCache.deleteObject(getCacheKey(config.getConfigKey()));
        }
    }

    @Override
    public void loadingConfigCache() {
        List<SysConfig> configsList = configMapper.selectConfigList(new SysConfig());
        for (SysConfig config : configsList) {
            redisCache.setCacheObjectWithJitter(getCacheKey(config.getConfigKey()), config.getConfigValue(), CONFIG_CACHE_TTL);
        }
    }

    @Override
    public void clearConfigCache() {
        redisCache.deleteByPattern(CacheConstants.SYS_CONFIG_KEY + "*");
    }

    @Override
    public void resetConfigCache() {
        clearConfigCache();
        loadingConfigCache();
    }

    @Override
    public boolean checkConfigKeyUnique(SysConfig config) {
        Long configId = StringUtils.isNull(config.getConfigId()) ? -1L : config.getConfigId();
        SysConfig info = configMapper.checkConfigKeyUnique(config.getConfigKey());
        if (StringUtils.isNotNull(info) && info.getConfigId().longValue() != configId.longValue()) {
            return UserConstants.NOT_UNIQUE;
        }
        return UserConstants.UNIQUE;
    }

    private String getCacheKey(String configKey) {
        return CacheConstants.SYS_CONFIG_KEY + configKey;
    }
}

package com.ddss.server.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ddss.common.utils.StringUtils;
import com.ddss.server.domain.po.DdssResource;
import com.ddss.server.mapper.DdssResourceMapper;
import com.ddss.server.service.DdssResourceService;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

/**
 * 资源管理Service实现类
 */
@Service
public class DdssResourceServiceImpl extends ServiceImpl<DdssResourceMapper, DdssResource> implements DdssResourceService {
    
    @Override
    public List<DdssResource> selectResourceList(DdssResource resource) {
        QueryWrapper<DdssResource> queryWrapper = new QueryWrapper<>();
        
        // 模糊查询资源名称
        if (StringUtils.isNotEmpty(resource.getResourceName())) {
            queryWrapper.like("resource_name", resource.getResourceName());
        }
        
        // 精确查询状态
        if (StringUtils.isNotEmpty(resource.getStatus())) {
            queryWrapper.eq("status", resource.getStatus());
        }
        
        // 按创建时间倒序排列
        queryWrapper.orderByDesc("create_time");
        
        return this.list(queryWrapper);
    }
    
    @Override
    public DdssResource selectResourceById(Long resourceId) {
        return this.getById(resourceId);
    }
    
    @Override
    public int insertResource(DdssResource resource) {
        return this.save(resource) ? 1 : 0;
    }
    
    @Override
    public int updateResource(DdssResource resource) {
        return this.updateById(resource) ? 1 : 0;
    }
    
    @Override
    public int deleteResourceByIds(Long[] resourceIds) {
        return this.removeByIds(Arrays.asList(resourceIds)) ? 1 : 0;
    }
}

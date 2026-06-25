package com.ddss.server.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.ddss.server.domain.po.DdssResource;

import java.util.List;

/**
 * 资源管理Service
 */
public interface DdssResourceService extends IService<DdssResource> {
    
    /**
     * 查询资源列表
     * @param resource 资源信息
     * @return 资源集合
     */
    List<DdssResource> selectResourceList(DdssResource resource);
    
    /**
     * 根据资源ID查询资源
     * @param resourceId 资源ID
     * @return 资源对象
     */
    DdssResource selectResourceById(Long resourceId);
    
    /**
     * 新增资源
     * @param resource 资源信息
     * @return 结果
     */
    int insertResource(DdssResource resource);
    
    /**
     * 修改资源
     * @param resource 资源信息
     * @return 结果
     */
    int updateResource(DdssResource resource);
    
    /**
     * 批量删除资源
     * @param resourceIds 需要删除的资源ID数组
     * @return 结果
     */
    int deleteResourceByIds(Long[] resourceIds);
}

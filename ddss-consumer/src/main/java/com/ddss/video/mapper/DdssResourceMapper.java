package com.ddss.video.mapper;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ddss.video.domain.DdssResource;
import org.apache.ibatis.annotations.Mapper;

/**
 * 资源管理Mapper
 */
@DS("ddss")
@Mapper
public interface DdssResourceMapper extends BaseMapper<DdssResource> {
}

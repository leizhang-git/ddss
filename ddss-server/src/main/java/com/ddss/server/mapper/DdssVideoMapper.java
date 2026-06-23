package com.ddss.server.mapper;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ddss.server.domain.po.DdssVideo;
import org.apache.ibatis.annotations.Mapper;

/**
 * 视频管理Mapper
 */
@DS("ddss")
@Mapper
public interface DdssVideoMapper extends BaseMapper<DdssVideo> {
}

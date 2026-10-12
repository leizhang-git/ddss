package com.ddss.video.mapper;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ddss.video.domain.DdssVideo;
import org.apache.ibatis.annotations.Mapper;

/**
 * 视频管理Mapper
 */
@DS("ddss")
@Mapper
public interface DdssVideoMapper extends BaseMapper<DdssVideo> {
}

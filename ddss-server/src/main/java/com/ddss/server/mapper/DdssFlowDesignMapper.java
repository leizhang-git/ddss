package com.ddss.server.mapper;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ddss.server.domain.po.DdssFlowDesign;
import org.apache.ibatis.annotations.Mapper;

/**
 * 流程模型 Mapper
 *
 * @author ddss
 */
@DS("ddss")
@Mapper
public interface DdssFlowDesignMapper extends BaseMapper<DdssFlowDesign> {

}
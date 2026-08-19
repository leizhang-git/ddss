package com.ddss.server.mapper;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ddss.server.domain.po.DdssLeave;
import org.apache.ibatis.annotations.Mapper;

/**
 * 请假申请单 Mapper
 *
 * @author ddss
 */
@DS("ddss")
@Mapper
public interface DdssLeaveMapper extends BaseMapper<DdssLeave> {

}
package com.ddss.server.mapper;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ddss.server.domain.po.SysFinance;
import org.apache.ibatis.annotations.Mapper;

@DS("ddss")
@Mapper
public interface SysFinanceMapper extends BaseMapper<SysFinance> {
}

package com.ddss.finance.mapper;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ddss.finance.domain.SysFinance;
import org.apache.ibatis.annotations.Mapper;

@DS("ddss")
@Mapper
public interface SysFinanceMapper extends BaseMapper<SysFinance> {
}

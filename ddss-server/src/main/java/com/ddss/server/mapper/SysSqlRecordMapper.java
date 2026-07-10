package com.ddss.server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ddss.server.domain.po.SysSqlRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * SQL记录 Mapper
 *
 * @author ddss
 */
@Mapper
public interface SysSqlRecordMapper extends BaseMapper<SysSqlRecord> {
}

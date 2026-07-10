package com.ddss.server.service;

import com.ddss.server.domain.po.SysSqlRecord;

import java.util.List;

/**
 * SQL记录 Service接口
 *
 * @author ddss
 */
public interface SysSqlRecordService {

    List<SysSqlRecord> selectList(SysSqlRecord record);

    SysSqlRecord selectById(Long sqlId);

    int insert(SysSqlRecord record);

    int update(SysSqlRecord record);

    int deleteByIds(Long[] sqlIds);
}

package com.ddss.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ddss.common.utils.StringUtils;
import com.ddss.server.domain.po.SysSqlRecord;
import com.ddss.server.mapper.SysSqlRecordMapper;
import com.ddss.server.service.SysSqlRecordService;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

/**
 * SQL记录 ServiceImpl
 *
 * @author ddss
 */
@Service
public class SysSqlRecordServiceImpl extends ServiceImpl<SysSqlRecordMapper, SysSqlRecord> implements SysSqlRecordService {

    @Override
    public List<SysSqlRecord> selectList(SysSqlRecord record) {
        QueryWrapper<SysSqlRecord> qw = new QueryWrapper<>();
        if (StringUtils.isNotEmpty(record.getPurpose())) {
            qw.like("purpose", record.getPurpose());
        }
        if (StringUtils.isNotEmpty(record.getSqlContent())) {
            qw.like("sql_content", record.getSqlContent());
        }
        qw.orderByDesc("create_time");
        return this.list(qw);
    }

    @Override
    public SysSqlRecord selectById(Long sqlId) {
        return this.getById(sqlId);
    }

    @Override
    public int insert(SysSqlRecord record) {
        return this.save(record) ? 1 : 0;
    }

    @Override
    public int update(SysSqlRecord record) {
        return this.updateById(record) ? 1 : 0;
    }

    @Override
    public int deleteByIds(Long[] sqlIds) {
        return this.removeByIds(Arrays.asList(sqlIds)) ? 1 : 0;
    }
}

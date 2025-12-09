package com.ddss.server.mapper;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.ddss.server.domain.po.DdssSysUser;
import org.apache.ibatis.annotations.Mapper;

/**
 * @Author zhanglei
 * @Date 2025/12/9 08:58
 */
@DS("ddss")
@Mapper
public interface DdssSysUserMapper extends BaseMapper<DdssSysUser> {
}

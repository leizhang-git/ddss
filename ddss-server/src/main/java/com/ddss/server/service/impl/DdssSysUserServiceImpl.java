package com.ddss.server.service.impl;

import com.baomidou.dynamic.datasource.annotation.DS;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ddss.common.utils.uuid.IdUtils;
import com.ddss.server.mapper.DdssSysUserMapper;
import com.ddss.server.domain.po.DdssSysUser;
import com.ddss.server.service.DdssSysUserService;
import org.apache.commons.compress.utils.Lists;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * @Author zhanglei
 * @Date 2025/12/9 09:42
 */
@DS("ddss")
@Service
public class DdssSysUserServiceImpl extends ServiceImpl<DdssSysUserMapper, DdssSysUser> implements DdssSysUserService {

    @Override
    public void testCreateManyData() {
        List<DdssSysUser> objects = Lists.newArrayList();
        for (int i = 400000; i < 500000; i++) {
            DdssSysUser ddssSysUser = new DdssSysUser();
            ddssSysUser.setUserId(IdUtils.simpleUUID());
            ddssSysUser.setDeptId("01");
            ddssSysUser.setUserName("test---" + i);
            ddssSysUser.setNickName("test---" + i);
            ddssSysUser.setEmail("testEmail---" + i);
            ddssSysUser.setPhonenumber("testPhone---" + i);
            ddssSysUser.setSex("0");
            ddssSysUser.setAvatar("testAvatar---" + i);
            ddssSysUser.setPassword("testPassword---" + i);
            ddssSysUser.setStatus("0");
            ddssSysUser.setDelFlag("0");
            ddssSysUser.setLoginIp("testLoginIp---" + i);
            ddssSysUser.setLoginDate(LocalDateTime.now());
            ddssSysUser.setPwdUpdateDate(LocalDateTime.now());
            ddssSysUser.setCreateBy("testCreateBy---" + i);
            ddssSysUser.setCreateTime(LocalDateTime.now());
            ddssSysUser.setUpdateBy("testUpdateBy---" + i);
            ddssSysUser.setUpdateTime(LocalDateTime.now());
            ddssSysUser.setRemark("testRemark---" + i);
            objects.add(ddssSysUser);
        }
        this.saveBatch(objects);
    }
}

package com.ddss.server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.ddss.common.utils.StringUtils;
import com.ddss.server.domain.po.DdssVideo;
import com.ddss.server.mapper.DdssVideoMapper;
import com.ddss.server.service.DdssVideoService;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;

/**
 * 视频管理Service实现类
 */
@Service
public class DdssVideoServiceImpl extends ServiceImpl<DdssVideoMapper, DdssVideo> implements DdssVideoService {

    @Override
    public List<DdssVideo> selectVideoList(DdssVideo video) {
        QueryWrapper<DdssVideo> queryWrapper = new QueryWrapper<>();
        
        // 模糊查询视频名称
        if (StringUtils.isNotEmpty(video.getVideoName())) {
            queryWrapper.like("video_name", video.getVideoName());
        }
        
        // 精确查询状态
        if (StringUtils.isNotEmpty(video.getStatus())) {
            queryWrapper.eq("status", video.getStatus());
        }
        
        // 按创建时间倒序排列
        queryWrapper.orderByDesc("create_time");
        
        return this.list(queryWrapper);
    }

    @Override
    public DdssVideo selectVideoById(Long videoId) {
        return this.getById(videoId);
    }

    @Override
    public int insertVideo(DdssVideo video) {
        return this.save(video) ? 1 : 0;
    }

    @Override
    public int updateVideo(DdssVideo video) {
        return this.updateById(video) ? 1 : 0;
    }

    @Override
    public int deleteVideoByIds(Long[] videoIds) {
        return this.removeByIds(Arrays.asList(videoIds)) ? videoIds.length : 0;
    }
}

package com.ddss.server.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.ddss.server.domain.po.DdssVideo;

import java.util.List;

/**
 * 视频管理Service接口
 */
public interface DdssVideoService {

    /**
     * 查询视频列表（支持分页和模糊查询）
     *
     * @param video 查询条件
     * @return 视频列表
     */
    List<DdssVideo> selectVideoList(DdssVideo video);

    /**
     * 根据ID查询视频
     *
     * @param videoId 视频ID
     * @return 视频信息
     */
    DdssVideo selectVideoById(Long videoId);

    /**
     * 新增视频
     *
     * @param video 视频信息
     * @return 结果
     */
    int insertVideo(DdssVideo video);

    /**
     * 修改视频
     *
     * @param video 视频信息
     * @return 结果
     */
    int updateVideo(DdssVideo video);

    /**
     * 删除视频
     *
     * @param videoIds 视频ID数组
     * @return 结果
     */
    int deleteVideoByIds(Long[] videoIds);
}

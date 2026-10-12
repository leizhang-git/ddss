package com.ddss.video.web.rest;

import com.ddss.common.annotation.Log;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.R;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.video.domain.DdssVideo;
import com.ddss.video.service.DdssVideoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 视频管理
 */
@RestController
@RequestMapping("/video")
public class VideoResource extends BaseController {

    @Autowired
    private DdssVideoService videoService;

    /**
     * 查询视频列表（支持分页和模糊检索）
     */
    @PreAuthorize("@ss.hasPermi('video:list')")
    @GetMapping("/list")
    public TableDataInfo list(DdssVideo video) {
        return pageQuery(() -> videoService.selectVideoList(video));
    }

    /**
     * 根据视频ID获取详细信息
     */
    @PreAuthorize("@ss.hasPermi('video:query')")
    @GetMapping(value = "/{videoId}")
    public R<DdssVideo> getInfo(@PathVariable("videoId") Long videoId) {
        return R.ok(videoService.selectVideoById(videoId));
    }

    /**
     * 新增视频
     */
    @PreAuthorize("@ss.hasPermi('video:add')")
    @Log(title = "视频管理", businessType = BusinessType.INSERT)
    @PostMapping
    public R<Void> add(@RequestBody DdssVideo video) {
        video.setCreateBy(getUsername());
        return toResult(videoService.insertVideo(video));
    }

    /**
     * 修改视频
     */
    @PreAuthorize("@ss.hasPermi('video:edit')")
    @Log(title = "视频管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public R<Void> edit(@RequestBody DdssVideo video) {
        video.setUpdateBy(getUsername());
        return toResult(videoService.updateVideo(video));
    }

    /**
     * 删除视频
     */
    @PreAuthorize("@ss.hasPermi('video:remove')")
    @Log(title = "视频管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{videoIds}")
    public R<Void> remove(@PathVariable Long[] videoIds) {
        return toResult(videoService.deleteVideoByIds(videoIds));
    }
}

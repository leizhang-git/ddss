package com.ddss.web.controller.video;

import com.ddss.common.annotation.Log;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.server.domain.po.DdssVideo;
import com.ddss.server.service.DdssVideoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 视频管理Controller
 */
@RestController
@RequestMapping("/video")
public class VideoController extends BaseController {

    @Autowired
    private DdssVideoService videoService;

    /**
     * 查询视频列表（支持分页和模糊检索）
     */
    @PreAuthorize("@ss.hasPermi('video:list')")
    @GetMapping("/list")
    public TableDataInfo list(DdssVideo video) {
        startPage();
        List<DdssVideo> list = videoService.selectVideoList(video);
        return getDataTable(list);
    }

    /**
     * 根据视频ID获取详细信息
     */
    @PreAuthorize("@ss.hasPermi('video:query')")
    @GetMapping(value = "/{videoId}")
    public AjaxResult getInfo(@PathVariable("videoId") Long videoId) {
        return success(videoService.selectVideoById(videoId));
    }

    /**
     * 新增视频
     */
    @PreAuthorize("@ss.hasPermi('video:add')")
    @Log(title = "视频管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody DdssVideo video) {
        video.setCreateBy(getUsername());
        return toAjax(videoService.insertVideo(video));
    }

    /**
     * 修改视频
     */
    @PreAuthorize("@ss.hasPermi('video:edit')")
    @Log(title = "视频管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody DdssVideo video) {
        video.setUpdateBy(getUsername());
        return toAjax(videoService.updateVideo(video));
    }

    /**
     * 删除视频
     */
    @PreAuthorize("@ss.hasPermi('video:remove')")
    @Log(title = "视频管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{videoIds}")
    public AjaxResult remove(@PathVariable Long[] videoIds) {
        return toAjax(videoService.deleteVideoByIds(videoIds));
    }
}

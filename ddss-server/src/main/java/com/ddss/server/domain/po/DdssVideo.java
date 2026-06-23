package com.ddss.server.domain.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 视频管理实体类
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName(value = "ddss_video")
public class DdssVideo {

    /**
     * 视频ID
     */
    @TableId(value = "video_id", type = IdType.AUTO)
    private Long videoId;

    /**
     * 视频名称
     */
    @TableField(value = "video_name")
    private String videoName;

    /**
     * 视频URL
     */
    @TableField(value = "video_url")
    private String videoUrl;

    /**
     * 封面图URL
     */
    @TableField(value = "cover_image")
    private String coverImage;

    /**
     * 时长(秒)
     */
    @TableField(value = "duration")
    private Integer duration;

    /**
     * 文件大小
     */
    @TableField(value = "file_size")
    private String fileSize;

    /**
     * 状态（0正常 1停用）
     */
    @TableField(value = "status")
    private String status;

    /**
     * 备注
     */
    @TableField(value = "remark")
    private String remark;

    /**
     * 创建者
     */
    @TableField(value = "create_by")
    private String createBy;

    /**
     * 创建时间
     */
    @TableField(value = "create_time")
    private LocalDateTime createTime;

    /**
     * 更新者
     */
    @TableField(value = "update_by")
    private String updateBy;

    /**
     * 更新时间
     */
    @TableField(value = "update_time")
    private LocalDateTime updateTime;

}

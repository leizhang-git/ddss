package com.ddss.server.domain.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 资源管理实体类
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName(value = "ddss_resource")
public class DdssResource {
    
    /**
     * 资源ID
     */
    @TableId(value = "resource_id", type = IdType.AUTO)
    private Long resourceId;
    
    /**
     * 资源名称
     */
    @TableField(value = "resource_name")
    private String resourceName;
    
    /**
     * 文件大小
     */
    @TableField(value = "file_size")
    private String fileSize;
    
    /**
     * 文件类型
     */
    @TableField(value = "file_type")
    private String fileType;
    
    /**
     * 文件路径
     */
    @TableField(value = "file_path")
    private String filePath;
    
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
    private String createTime;
    
    /**
     * 更新者
     */
    @TableField(value = "update_by")
    private String updateBy;
    
    /**
     * 更新时间
     */
    @TableField(value = "update_time")
    private String updateTime;
}

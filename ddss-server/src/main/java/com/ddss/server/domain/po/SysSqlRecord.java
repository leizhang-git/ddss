package com.ddss.server.domain.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

/**
 * SQL记录表 sys_sql_record
 *
 * @author ddss
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@TableName(value = "sys_sql_record")
public class SysSqlRecord {

    @TableId(value = "sql_id", type = IdType.AUTO)
    private Long sqlId;

    @TableField(value = "purpose")
    private String purpose;

    @TableField(value = "sql_content")
    private String sqlContent;

    @TableField(value = "create_by")
    private String createBy;

    @TableField(value = "create_time")
    private Date createTime;

    @TableField(value = "update_by")
    private String updateBy;

    @TableField(value = "update_time")
    private Date updateTime;

    @TableField(value = "remark")
    private String remark;
}

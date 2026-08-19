package com.ddss.server.workflow.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

/**
 * 流程定义视图对象
 *
 * @author ddss
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class WorkflowDefinitionVO {

    /** 流程定义ID */
    private String definitionId;

    /** 流程定义 Key */
    private String key;

    /** 流程名称 */
    private String name;

    /** 版本号 */
    private Integer version;

    /** 部署ID */
    private String deploymentId;

    /** 资源文件名称 */
    private String resourceName;

    /** 分类 */
    private String category;

    /** 部署时间 */
    private Date deploymentTime;

}
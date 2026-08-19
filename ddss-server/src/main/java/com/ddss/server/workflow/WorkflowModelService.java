package com.ddss.server.workflow;

import com.ddss.server.domain.po.DdssFlowDesign;

import java.util.List;

/**
 * 流程模型服务（设计器：保存/发布/导入/导出）
 *
 * @author ddss
 */
public interface WorkflowModelService {

    /**
     * 流程模型分页列表
     */
    List<DdssFlowDesign> selectModelList(DdssFlowDesign model);

    /**
     * 流程模型详情
     */
    DdssFlowDesign selectModelById(Long flowId);

    /**
     * 新建流程模型（默认模板）
     */
    boolean insertModel(DdssFlowDesign model, String currentUser);

    /**
     * 修改流程模型（流程名称/Key）
     */
    boolean updateModel(DdssFlowDesign model, String currentUser);

    /**
     * 保存设计器 XML（草稿）
     */
    boolean saveModelXml(Long flowId, String bpmnXml, String currentUser);

    /**
     * 发布流程：部署 BPMN 到 Flowable 引擎
     */
    boolean publishModel(Long flowId, String currentUser);

    /**
     * 删除流程模型
     */
    boolean deleteModelByIds(Long[] flowIds);

    /**
     * 导入 BPMN 文件生成流程模型
     */
    DdssFlowDesign importModel(String fileName, byte[] content, String currentUser);

    /**
     * 获取模型 XML 内容
     */
    String getModelXml(Long flowId);

    /**
     * 获取默认模板 XML
     */
    String getDefaultTemplate();

}
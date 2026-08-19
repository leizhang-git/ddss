package com.ddss.web.controller.workflow;

import com.ddss.common.annotation.Log;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.common.exception.ServiceException;
import com.ddss.common.utils.StringUtils;
import com.ddss.server.domain.po.DdssFlowDesign;
import com.ddss.server.workflow.WorkflowModelService;
import com.ddss.server.workflow.vo.WorkflowModelXmlBody;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * 流程模型管理（设计器）
 *
 * @author ddss
 */
@RestController
@RequestMapping("/workflow/model")
public class WorkflowModelController extends BaseController {

    @Autowired
    private WorkflowModelService workflowModelService;

    /**
     * 流程模型列表
     */
    @PreAuthorize("@ss.hasPermi('workflow:model:list')")
    @GetMapping("/list")
    public TableDataInfo list(DdssFlowDesign model) {
        startPage();
        List<DdssFlowDesign> list = workflowModelService.selectModelList(model);
        return getDataTable(list);
    }

    /**
     * 流程模型详情
     */
    @PreAuthorize("@ss.hasPermi('workflow:model:list')")
    @GetMapping("/{flowId}")
    public AjaxResult getInfo(@PathVariable Long flowId) {
        return success(workflowModelService.selectModelById(flowId));
    }

    /**
     * 获取默认模板 XML
     */
    @PreAuthorize("@ss.hasPermi('workflow:model:list')")
    @GetMapping("/template")
    public AjaxResult template() {
        return AjaxResult.success(workflowModelService.getDefaultTemplate());
    }

    /**
     * 获取模型 XML（设计器加载 / 导出）
     */
    @PreAuthorize("@ss.hasPermi('workflow:model:list')")
    @GetMapping("/{flowId}/xml")
    public AjaxResult xml(@PathVariable Long flowId) {
        return AjaxResult.success(workflowModelService.getModelXml(flowId));
    }

    /**
     * 新建流程模型
     */
    @Log(title = "流程模型", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('workflow:model:add')")
    @PostMapping
    public AjaxResult add(@RequestBody DdssFlowDesign model) {
        return toAjax(workflowModelService.insertModel(model, getUsername()));
    }

    /**
     * 修改流程模型（流程名称/Key）
     */
    @Log(title = "流程模型", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('workflow:model:edit')")
    @PutMapping
    public AjaxResult edit(@RequestBody DdssFlowDesign model) {
        return toAjax(workflowModelService.updateModel(model, getUsername()));
    }

    /**
     * 保存设计器 XML（草稿）
     */
    @Log(title = "流程模型", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('workflow:model:edit')")
    @PutMapping("/saveXml")
    public AjaxResult saveXml(@RequestBody WorkflowModelXmlBody body) {
        return toAjax(workflowModelService.saveModelXml(body.getFlowId(), body.getBpmnXml(), getUsername()));
    }

    /**
     * 发布流程（部署到引擎）
     */
    @Log(title = "流程模型", businessType = BusinessType.UPDATE)
    @PreAuthorize("@ss.hasPermi('workflow:model:publish')")
    @PostMapping("/publish/{flowId}")
    public AjaxResult publish(@PathVariable Long flowId) {
        return toAjax(workflowModelService.publishModel(flowId, getUsername()));
    }

    /**
     * 导入 BPMN 文件生成流程模型
     */
    @Log(title = "流程模型", businessType = BusinessType.IMPORT)
    @PreAuthorize("@ss.hasPermi('workflow:model:import')")
    @PostMapping("/import")
    public AjaxResult importModel(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ServiceException("请选择要导入的 BPMN 文件");
        }
        String fileName = file.getOriginalFilename();
        if (StringUtils.isEmpty(fileName)
                || !(fileName.endsWith(".bpmn20.xml") || fileName.endsWith(".bpmn"))) {
            throw new ServiceException("仅支持 .bpmn20.xml / .bpmn 文件");
        }
        try {
            DdssFlowDesign model = workflowModelService.importModel(fileName, file.getBytes(), getUsername());
            return AjaxResult.success(model);
        } catch (Exception e) {
            if (e instanceof ServiceException) {
                throw (ServiceException) e;
            }
            throw new ServiceException("BPMN 文件导入失败");
        }
    }

    /**
     * 删除流程模型
     */
    @Log(title = "流程模型", businessType = BusinessType.DELETE)
    @PreAuthorize("@ss.hasPermi('workflow:model:remove')")
    @DeleteMapping("/{flowIds}")
    public AjaxResult remove(@PathVariable Long[] flowIds) {
        return toAjax(workflowModelService.deleteModelByIds(flowIds));
    }

}
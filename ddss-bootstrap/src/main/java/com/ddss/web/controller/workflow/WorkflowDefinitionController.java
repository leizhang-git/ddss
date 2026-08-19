package com.ddss.web.controller.workflow;

import com.ddss.common.annotation.Log;
import com.ddss.common.constant.HttpStatus;
import com.ddss.common.core.controller.BaseController;
import com.ddss.common.core.domain.AjaxResult;
import com.ddss.common.core.page.TableDataInfo;
import com.ddss.common.enums.BusinessType;
import com.ddss.common.exception.ServiceException;
import com.ddss.common.utils.StringUtils;
import com.ddss.server.workflow.WorkflowDefinitionService;
import com.ddss.server.workflow.vo.WorkflowDefinitionVO;
import com.ddss.server.workflow.vo.WorkflowPage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * 流程定义管理
 *
 * @author ddss
 */
@RestController
@RequestMapping("/workflow/definition")
public class WorkflowDefinitionController extends BaseController {

    @Autowired
    private WorkflowDefinitionService workflowDefinitionService;

    /**
     * 流程定义列表
     */
    @PreAuthorize("@ss.hasPermi('workflow:definition:list')")
    @GetMapping("/list")
    public TableDataInfo list(@RequestParam(defaultValue = "1") int pageNum,
                              @RequestParam(defaultValue = "10") int pageSize) {
        WorkflowPage<WorkflowDefinitionVO> page = workflowDefinitionService.selectDefinitionList(pageNum, pageSize);
        TableDataInfo data = new TableDataInfo();
        data.setCode(HttpStatus.SUCCESS);
        data.setMsg("查询成功");
        data.setRows(page.getRows());
        data.setTotal(page.getTotal());
        return data;
    }

    /**
     * 部署流程定义（上传 BPMN 文件）
     */
    @Log(title = "流程定义", businessType = BusinessType.INSERT)
    @PreAuthorize("@ss.hasPermi('workflow:definition:add')")
    @PostMapping("/deploy")
    public AjaxResult deploy(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ServiceException("请选择要部署的 BPMN 文件");
        }
        String fileName = file.getOriginalFilename();
        if (StringUtils.isEmpty(fileName)
                || !(fileName.endsWith(".bpmn20.xml") || fileName.endsWith(".bpmn"))) {
            throw new ServiceException("仅支持 .bpmn20.xml / .bpmn 文件");
        }
        String content;
        try {
            content = new String(file.getBytes(), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new ServiceException("读取 BPMN 文件失败");
        }
        String deploymentId = workflowDefinitionService.deployProcess(fileName, content);
        return AjaxResult.success("操作成功", (Object) deploymentId);
    }

    /**
     * 查看流程定义 XML
     */
    @PreAuthorize("@ss.hasPermi('workflow:definition:list')")
    @GetMapping("/xml")
    public AjaxResult xml(@RequestParam String deploymentId, @RequestParam String resourceName) {
        return AjaxResult.success("操作成功", (Object) workflowDefinitionService.getDefinitionXml(deploymentId, resourceName));
    }

    /**
     * 删除流程定义
     */
    @Log(title = "流程定义", businessType = BusinessType.DELETE)
    @PreAuthorize("@ss.hasPermi('workflow:definition:remove')")
    @DeleteMapping("/{deploymentId}")
    public AjaxResult remove(@PathVariable String deploymentId) {
        workflowDefinitionService.deleteDefinition(deploymentId);
        return success();
    }

}
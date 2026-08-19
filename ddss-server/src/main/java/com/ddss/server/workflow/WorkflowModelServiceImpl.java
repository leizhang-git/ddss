package com.ddss.server.workflow;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.ddss.common.exception.ServiceException;
import com.ddss.common.utils.StringUtils;
import com.ddss.server.domain.po.DdssFlowDesign;
import com.ddss.server.mapper.DdssFlowDesignMapper;
import org.flowable.bpmn.converter.BpmnXMLConverter;
import org.flowable.bpmn.model.BpmnModel;
import org.flowable.bpmn.model.Process;
import org.flowable.common.engine.api.FlowableException;
import org.flowable.engine.RepositoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StreamUtils;

import java.io.InputStream;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.List;

import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamReader;

/**
 * 流程模型服务实现
 *
 * @author ddss
 */
@Service
public class WorkflowModelServiceImpl implements WorkflowModelService {

    /** 默认模板资源 */
    private static final String TEMPLATE_PATH = "model/template.bpmn20.xml";

    @Autowired
    private DdssFlowDesignMapper flowDesignMapper;

    @Autowired
    private RepositoryService repositoryService;

    @Override
    public List<DdssFlowDesign> selectModelList(DdssFlowDesign model) {
        QueryWrapper<DdssFlowDesign> wrapper = new QueryWrapper<>();
        if (model != null) {
            if (StringUtils.isNotEmpty(model.getFlowName())) {
                wrapper.like("flow_name", model.getFlowName());
            }
            if (StringUtils.isNotEmpty(model.getFlowKey())) {
                wrapper.like("flow_key", model.getFlowKey());
            }
            if (StringUtils.isNotEmpty(model.getStatus())) {
                wrapper.eq("status", model.getStatus());
            }
        }
        wrapper.orderByDesc("update_time");
        return flowDesignMapper.selectList(wrapper);
    }

    @Override
    public DdssFlowDesign selectModelById(Long flowId) {
        return flowDesignMapper.selectById(flowId);
    }

    @Override
    public boolean insertModel(DdssFlowDesign model, String currentUser) {
        if (model == null || StringUtils.isEmpty(model.getFlowKey())) {
            throw new ServiceException("流程Key不能为空");
        }
        if (StringUtils.isEmpty(model.getFlowName())) {
            throw new ServiceException("流程名称不能为空");
        }
        checkKeyUnique(model.getFlowKey(), null);
        DdssFlowDesign entity = new DdssFlowDesign();
        entity.setFlowKey(model.getFlowKey().trim());
        entity.setFlowName(model.getFlowName().trim());
        entity.setBpmnXml(StringUtils.isNotEmpty(model.getBpmnXml())
                ? model.getBpmnXml() : getDefaultTemplate());
        entity.setVersion(1);
        entity.setStatus(WorkflowConstants.MODEL_STATUS_DRAFT);
        entity.setCreateBy(currentUser);
        entity.setCreateTime(LocalDateTime.now());
        entity.setUpdateBy(currentUser);
        entity.setUpdateTime(LocalDateTime.now());
        return flowDesignMapper.insert(entity) > 0;
    }

    @Override
    public boolean updateModel(DdssFlowDesign model, String currentUser) {
        if (model == null || model.getFlowId() == null) {
            throw new ServiceException("流程模型ID不能为空");
        }
        DdssFlowDesign entity = new DdssFlowDesign();
        entity.setFlowId(model.getFlowId());
        if (StringUtils.isNotEmpty(model.getFlowKey())) {
            checkKeyUnique(model.getFlowKey(), model.getFlowId());
            entity.setFlowKey(model.getFlowKey().trim());
        }
        if (StringUtils.isNotEmpty(model.getFlowName())) {
            entity.setFlowName(model.getFlowName().trim());
        }
        entity.setUpdateBy(currentUser);
        entity.setUpdateTime(LocalDateTime.now());
        return flowDesignMapper.updateById(entity) > 0;
    }

    @Override
    public boolean saveModelXml(Long flowId, String bpmnXml, String currentUser) {
        if (flowId == null) {
            throw new ServiceException("流程模型ID不能为空");
        }
        if (StringUtils.isEmpty(bpmnXml)) {
            throw new ServiceException("流程 XML 不能为空");
        }
        DdssFlowDesign entity = new DdssFlowDesign();
        entity.setFlowId(flowId);
        entity.setBpmnXml(bpmnXml);
        entity.setUpdateBy(currentUser);
        entity.setUpdateTime(LocalDateTime.now());
        return flowDesignMapper.updateById(entity) > 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean publishModel(Long flowId, String currentUser) {
        DdssFlowDesign model = flowDesignMapper.selectById(flowId);
        if (model == null) {
            throw new ServiceException("流程模型不存在");
        }
        if (StringUtils.isEmpty(model.getBpmnXml())) {
            throw new ServiceException("请先在设计器中保存流程");
        }
        try {
            String deploymentId = repositoryService.createDeployment()
                    .name(model.getFlowName() + ".bpmn20.xml")
                    .addString(model.getFlowKey() + ".bpmn20.xml", model.getBpmnXml())
                    .deploy()
                    .getId();
            DdssFlowDesign update = new DdssFlowDesign();
            update.setFlowId(flowId);
            update.setDeploymentId(deploymentId);
            update.setStatus(WorkflowConstants.MODEL_STATUS_PUBLISHED);
            update.setVersion(model.getVersion() == null ? 1 : model.getVersion() + 1);
            update.setUpdateBy(currentUser);
            update.setUpdateTime(LocalDateTime.now());
            flowDesignMapper.updateById(update);
        } catch (FlowableException e) {
            throw new ServiceException("流程发布失败：" + e.getMessage());
        }
        return true;
    }

    @Override
    public boolean deleteModelByIds(Long[] flowIds) {
        if (flowIds == null || flowIds.length == 0) {
            return false;
        }
        for (Long flowId : flowIds) {
            flowDesignMapper.deleteById(flowId);
        }
        return true;
    }

    @Override
    public DdssFlowDesign importModel(String fileName, byte[] content, String currentUser) {
        if (content == null || content.length == 0) {
            throw new ServiceException("请选择要导入的 BPMN 文件");
        }
        BpmnModel bpmnModel;
        String xmlContent = new String(content, StandardCharsets.UTF_8);
        try {
            // 以字节流解析 BPMN（校验合法性并校验原生 model）
            XMLStreamReader reader = XMLInputFactory.newInstance().createXMLStreamReader(new StringReader(xmlContent));
            bpmnModel = new BpmnXMLConverter().convertToBpmnModel(reader);
        } catch (FlowableException | javax.xml.stream.XMLStreamException e) {
            throw new ServiceException("BPMN 文件解析失败，请确认文件内容合法");
        }
        Process process = bpmnModel == null ? null : bpmnModel.getMainProcess();
        if (process == null || StringUtils.isEmpty(process.getId())) {
            throw new ServiceException("BPMN 文件中未找到 process 定义");
        }
        String flowKey = process.getId();
        String flowName = StringUtils.isNotEmpty(process.getName()) ? process.getName()
                : (StringUtils.isNotEmpty(fileName) ? fileName : flowKey);
        checkKeyUnique(flowKey, null);

        DdssFlowDesign entity = new DdssFlowDesign();
        entity.setFlowKey(flowKey);
        entity.setFlowName(flowName);
        entity.setBpmnXml(xmlContent);
        entity.setVersion(1);
        entity.setStatus(WorkflowConstants.MODEL_STATUS_DRAFT);
        entity.setCreateBy(currentUser);
        entity.setCreateTime(LocalDateTime.now());
        entity.setUpdateBy(currentUser);
        entity.setUpdateTime(LocalDateTime.now());
        flowDesignMapper.insert(entity);
        return entity;
    }

    @Override
    public String getModelXml(Long flowId) {
        DdssFlowDesign model = flowDesignMapper.selectById(flowId);
        if (model == null) {
            throw new ServiceException("流程模型不存在");
        }
        return model.getBpmnXml();
    }

    @Override
    public String getDefaultTemplate() {
        try (InputStream in = new ClassPathResource(TEMPLATE_PATH).getInputStream()) {
            return StreamUtils.copyToString(in, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new ServiceException("加载流程模板失败");
        }
    }

    /**
     * 校验流程Key唯一（排除自身）
     */
    private void checkKeyUnique(String flowKey, Long excludeFlowId) {
        QueryWrapper<DdssFlowDesign> wrapper = new QueryWrapper<>();
        wrapper.eq("flow_key", flowKey.trim());
        if (excludeFlowId != null) {
            wrapper.ne("flow_id", excludeFlowId);
        }
        if (flowDesignMapper.selectCount(wrapper) > 0) {
            throw new ServiceException("流程Key「" + flowKey + "」已存在，请更换");
        }
    }

}
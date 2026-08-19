<template>
  <div class="workflow-designer">
    <!-- 顶部工具栏 -->
    <div class="designer-toolbar">
      <div class="toolbar-left">
        <el-button icon="el-icon-back" size="mini" @click="handleBack">返回</el-button>
        <el-divider direction="vertical" />
        <span class="title">{{ modelName }}</span>
        <el-tag v-if="modelStatus === '1'" size="mini" type="success">已发布</el-tag>
        <el-tag v-else size="mini" type="warning">草稿</el-tag>
      </div>
      <div class="toolbar-right">
        <el-button size="mini" @click="handleImport">
          <i class="el-icon-upload2" /> 导入
        </el-button>
        <el-button size="mini" @click="handleExportXml">
          <i class="el-icon-download" /> 导出XML
        </el-button>
        <el-button size="mini" @click="handleExportSvg">
          <i class="el-icon-picture-outline" /> 导出SVG
        </el-button>
        <el-button v-hasPermi="['workflow:model:edit']" type="primary" size="mini" plain @click="handleSave">
          <i class="el-icon-check" /> 保存
        </el-button>
        <el-button v-hasPermi="['workflow:model:publish']" type="success" size="mini" @click="handlePublish">
          <i class="el-icon-upload2" /> 发布
        </el-button>
      </div>
    </div>

    <!-- 画布 + 属性面板 -->
    <div class="designer-body">
      <div ref="canvas" class="canvas"></div>
      <div class="properties-panel" id="js-properties-panel"></div>
    </div>

    <input
      ref="importInput"
      type="file"
      accept=".bpmn20.xml,.bpmn"
      style="display: none"
      @change="handleFileChange"
    />
  </div>
</template>

<script>
// 兼容 webpack4 构建：静态 require 模块与样式
const BpmnModeler = require('bpmn-js/lib/Modeler').default
const propertiesPanelModule = require('bpmn-js-properties-panel')
const propertiesProviderModule = require('bpmn-js-properties-panel/lib/provider/bpmn')

require('bpmn-js/dist/assets/diagram-js.css')
require('bpmn-js/dist/assets/bpmn-font/css/bpmn.css')
require('bpmn-js/dist/assets/bpmn-font/css/bpmn-codes.css')
require('bpmn-js/dist/assets/bpmn-font/css/bpmn-embedded.css')
require('bpmn-js-properties-panel/dist/assets/bpmn-js-properties-panel.css')
require('@/styles/bpmn-panel.css')

import { getModel, getModelXml, saveModelXml, publishModel } from '@/api/workflowModel'

export default {
  name: 'WorkflowDesigner',
  data() {
    return {
      modelId: this.$route.params && this.$route.params.flowId,
      modelName: '',
      modelStatus: '',
      modelKey: '',
      bpmnModeler: null
    }
  },
  async mounted() {
    await this.init()
  },
  beforeDestroy() {
    if (this.bpmnModeler) {
      this.bpmnModeler.destroy()
    }
  },
  methods: {
    async init() {
      const modelInfo = await getModel(this.modelId)
      this.modelName = modelInfo.data.flowName || ''
      this.modelStatus = modelInfo.data.status || '0'
      this.modelKey = modelInfo.data.flowKey || ''
      document.title = '流程设计器 - ' + this.modelName

      this.createModeler()
      const xml = await getModelXml(this.modelId)
      await this.bpmnModeler.importXML(xml)
      this.bpmnModeler.get('canvas').zoom('fit-viewport', 'auto')
    },

    createModeler() {
      this.bpmnModeler = new BpmnModeler({
        container: this.$refs.canvas,
        propertiesPanel: {
          parent: '#js-properties-panel'
        },
        additionalModules: [
          propertiesPanelModule,
          propertiesProviderModule
        ]
      })
    },

    async handleSave() {
      try {
        const { xml } = await this.bpmnModeler.saveXML({ format: true })
        await saveModelXml({ flowId: this.modelId, bpmnXml: xml })
        this.$message.success('保存成功')
      } catch (e) {
        this.$message.error('保存失败：' + (e.message || e))
      }
    },

    async handlePublish() {
      try {
        const { xml } = await this.bpmnModeler.saveXML({ format: true })
        await saveModelXml({ flowId: this.modelId, bpmnXml: xml })
      } catch (e) {
        this.$message.error('保存失败，无法发布：' + (e.message || e))
        return
      }
      this.$modal.confirm('确认发布该流程？发布后将部署到工作流引擎并立即可用。').then(() => {
        return publishModel(this.modelId)
      }).then(() => {
        this.modelStatus = '1'
        this.$message.success('发布成功')
      }).catch(() => {})
    },

    handleImport() {
      this.$refs.importInput.value = ''
      this.$refs.importInput.click()
    },

    handleFileChange(event) {
      const file = event.target.files[0]
      if (!file) return
      const reader = new FileReader()
      reader.onload = e => {
        this.bpmnModeler.importXML(e.target.result).then(() => {
          this.bpmnModeler.get('canvas').zoom('fit-viewport', 'auto')
          this.$message.success('导入成功，请保存后生效')
        }).catch(err => {
          this.$message.error('导入失败：' + (err.message || err))
        })
      }
      reader.readAsText(file)
    },

    async handleExportXml() {
      try {
        const { xml } = await this.bpmnModeler.saveXML({ format: true })
        this.downloadFile(xml, (this.modelKey || 'process') + '.bpmn20.xml', 'text/xml')
      } catch (e) {
        this.$message.error('导出失败：' + (e.message || e))
      }
    },

    async handleExportSvg() {
      try {
        const { svg } = await this.bpmnModeler.saveSVG()
        this.downloadFile(svg, (this.modelKey || 'process') + '.svg', 'image/svg+xml')
      } catch (e) {
        this.$message.error('导出失败：' + (e.message || e))
      }
    },

    downloadFile(content, name, type) {
      const blob = new Blob([content], { type })
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = name
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      window.URL.revokeObjectURL(url)
    },

    handleBack() {
      this.$router.push({ path: '/workflow/model' })
    }
  }
}
</script>

<style scoped>
.workflow-designer {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 84px);
  background: #fff;
  border-radius: 4px;
  border: 1px solid #ebeef5;
}
.designer-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  border-bottom: 1px solid #ebeef5;
  background: #f8f9fb;
}
.toolbar-left {
  display: flex;
  align-items: center;
}
.toolbar-left .title {
  font-size: 15px;
  font-weight: 600;
  margin: 0 8px;
}
.toolbar-right {
  display: flex;
  align-items: center;
}
.toolbar-right .el-button + .el-button {
  margin-left: 8px;
}
.designer-body {
  display: flex;
  flex: 1;
  min-height: 0;
}
.canvas {
  flex: 1;
  min-width: 0;
  background: #f2f4f7;
}
.properties-panel {
  width: 300px;
  border-left: 1px solid #ebeef5;
  overflow: auto;
  background: #f8f9fb;
}
.panel-placeholder {
  padding: 40px 20px;
  color: #909399;
  text-align: center;
  font-size: 13px;
  line-height: 1.8;
}
</style>
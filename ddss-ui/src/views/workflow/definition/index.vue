<template>
  <div class="app-container workflow-definition-page">
    <!-- 工具栏 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button v-hasPermi="['workflow:definition:add']" icon="el-icon-upload2" plain size="mini" type="primary" @click="handleDeploy">部署流程</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          v-hasPermi="['workflow:definition:remove']"
          :disabled="multiple"
          icon="el-icon-delete"
          plain
          size="mini"
          type="danger"
          @click="handleDelete"
        >删除</el-button>
      </el-col>
      <right-toolbar @queryTable="getList" />
    </el-row>

    <el-alert
      title="启动时已自动部署演示流程「请假申请流程(leaveDemo)」，也可在此上传 .bpmn20.xml 文件手动部署。"
      type="info"
      :closable="false"
      show-icon
      style="margin-bottom: 12px"
    />

    <!-- 数据表格 -->
    <el-table v-loading="loading" :data="list" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="流程名称" prop="name" min-width="160" show-overflow-tooltip />
      <el-table-column label="流程Key" prop="key" width="130" align="center" />
      <el-table-column label="版本" prop="version" width="70" align="center">
        <template slot-scope="scope">
          <el-tag size="mini">v{{ scope.row.version }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="资源文件" prop="resourceName" min-width="180" show-overflow-tooltip />
      <el-table-column label="部署时间" prop="deploymentTime" width="165" align="center">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.deploymentTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button icon="el-icon-document" size="mini" type="text" @click="handleViewXml(scope.row)">查看XML</el-button>
          <el-button icon="el-icon-download" size="mini" type="text" @click="handleExport(scope.row)">导出</el-button>
          <el-button v-hasPermi="['workflow:definition:remove']" icon="el-icon-delete" size="mini" type="text" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination
      v-show="total > 0"
      :limit.sync="queryParams.pageSize"
      :page.sync="queryParams.pageNum"
      :total="total"
      @pagination="getList"
    />

    <!-- 部署文件选择 -->
    <input
      ref="deployInput"
      type="file"
      accept=".bpmn20.xml,.bpmn"
      style="display: none"
      @change="handleFileChange"
    />

    <!-- 查看 XML 对话框 -->
    <el-dialog title="流程定义 XML" :visible.sync="xmlOpen" width="720px" append-to-body>
      <pre class="xml-viewer">{{ xmlContent }}</pre>
      <div slot="footer">
        <el-button type="primary" @click="xmlOpen = false">关 闭</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listDefinition, deployDefinition, getDefinitionXml, delDefinition } from '@/api/workflow'

export default {
  name: 'WorkflowDefinition',
  data() {
    return {
      loading: false,
      multiple: true,
      total: 0,
      list: [],
      ids: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10
      },
      xmlOpen: false,
      xmlContent: ''
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listDefinition(this.queryParams).then(res => {
        this.list = res.rows
        this.total = res.total
        this.loading = false
      })
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.deploymentId)
      this.multiple = !selection.length
    },
    handleDeploy() {
      this.$refs.deployInput.value = ''
      this.$refs.deployInput.click()
    },
    handleFileChange(event) {
      const file = event.target.files[0]
      if (!file) return
      const formData = new FormData()
      formData.append('file', file)
      deployDefinition(formData).then(() => {
        this.$message.success('部署成功')
        this.getList()
      })
      this.$refs.deployInput.value = ''
    },
    handleViewXml(row) {
      getDefinitionXml(row.deploymentId, row.resourceName).then(res => {
        this.xmlContent = res.data || ''
        this.xmlOpen = true
      })
    },
    handleExport(row) {
      getDefinitionXml(row.deploymentId, row.resourceName).then(res => {
        const content = res.data || ''
        const blob = new Blob([content], { type: 'text/xml' })
        const url = window.URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = (row.key || 'process') + '.bpmn20.xml'
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        window.URL.revokeObjectURL(url)
      })
    },
    handleDelete(row) {
      const deploymentIds = row.deploymentId ? [row.deploymentId] : this.ids
      this.$modal.confirm('确认删除选中的流程定义？存在运行中实例的流程将无法删除。').then(() => {
        return delDefinition(deploymentIds.join(','))
      }).then(() => {
        this.getList()
        this.$message.success('删除成功')
      }).catch(() => {})
    }
  }
}
</script>

<style scoped>
.xml-viewer {
  max-height: 480px;
  overflow: auto;
  margin: 0;
  padding: 12px;
  background: #1e1e1e;
  color: #d4d4d4;
  border-radius: 4px;
  font-family: 'SF Mono', Consolas, monospace;
  font-size: 12px;
  line-height: 1.6;
  white-space: pre-wrap;
  word-break: break-all;
}
</style>
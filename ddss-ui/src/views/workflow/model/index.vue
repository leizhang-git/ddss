<template>
  <div class="app-container workflow-model-page">
    <!-- 搜索栏 -->
    <el-form v-show="showSearch" ref="queryForm" :model="queryParams" size="small" inline>
      <el-form-item label="流程名称" prop="flowName">
        <el-input
          v-model="queryParams.flowName"
          clearable
          placeholder="请输入流程名称"
          style="width: 220px"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="流程Key" prop="flowKey">
        <el-input
          v-model="queryParams.flowKey"
          clearable
          placeholder="请输入流程Key"
          style="width: 220px"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" clearable placeholder="全部" style="width: 130px">
          <el-option label="草稿" value="0" />
          <el-option label="已发布" value="1" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button icon="el-icon-search" size="mini" type="primary" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 工具栏 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button v-hasPermi="['workflow:model:add']" icon="el-icon-plus" plain size="mini" type="primary" @click="handleAdd">新建流程</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button v-hasPermi="['workflow:model:import']" icon="el-icon-upload2" plain size="mini" type="success" @click="handleImport">导入流程</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          v-hasPermi="['workflow:model:remove']"
          :disabled="multiple"
          icon="el-icon-delete"
          plain
          size="mini"
          type="danger"
          @click="handleDelete"
        >删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" />
    </el-row>

    <!-- 数据表格 -->
    <el-table v-loading="loading" :data="list" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="流程名称" prop="flowName" min-width="160" show-overflow-tooltip />
      <el-table-column label="流程Key" prop="flowKey" width="130" align="center" />
      <el-table-column label="版本" prop="version" width="70" align="center">
        <template slot-scope="scope">
          <el-tag size="mini" type="info">v{{ scope.row.version }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="状态" prop="status" width="90" align="center">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status === '1' ? 'success' : 'warning'">
            {{ scope.row.status === '1' ? '已发布' : '草稿' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建者" prop="createBy" width="110" align="center" />
      <el-table-column label="更新时间" prop="updateTime" width="160" align="center">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.updateTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button icon="el-icon-edit-outline" size="mini" type="text" @click="handleDesign(scope.row)">设计</el-button>
          <el-button v-hasPermi="['workflow:model:publish']" icon="el-icon-upload2" size="mini" type="text" @click="handlePublish(scope.row)">发布</el-button>
          <el-button v-hasPermi="['workflow:model:edit']" icon="el-icon-edit" size="mini" type="text" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button v-hasPermi="['workflow:model:remove']" icon="el-icon-delete" size="mini" type="text" @click="handleDelete(scope.row)">删除</el-button>
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

    <!-- 新建流程对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="480px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="流程名称" prop="flowName">
          <el-input v-model="form.flowName" placeholder="请输入流程名称，如：请假审批流程" />
        </el-form-item>
        <el-form-item label="流程Key" prop="flowKey">
          <el-input v-model="form.flowKey" placeholder="请输入唯一Key，如：leaveDemo" />
        </el-form-item>
      </el-form>
      <div slot="footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>

    <!-- 隐藏的上传框 -->
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
import { listModel, addModel, editModel, publishModel, delModel, importModel } from '@/api/workflowModel'

export default {
  name: 'WorkflowModel',
  data() {
    return {
      loading: false,
      showSearch: true,
      multiple: true,
      open: false,
      title: '',
      total: 0,
      list: [],
      ids: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        flowName: undefined,
        flowKey: undefined,
        status: undefined
      },
      form: {},
      rules: {
        flowName: [{ required: true, message: '流程名称不能为空', trigger: 'blur' }],
        flowKey: [
          { required: true, message: '流程Key不能为空', trigger: 'blur' },
          { pattern: /^[A-Za-z][A-Za-z0-9_]*$/, message: '必须以字母开头，仅含字母/数字/下划线', trigger: 'blur' }
        ]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listModel(this.queryParams).then(res => {
        this.list = res.rows
        this.total = res.total
        this.loading = false
      })
    },
    cancel() {
      this.open = false
      this.reset()
    },
    reset() {
      this.form = {
        flowId: undefined,
        flowName: undefined,
        flowKey: undefined
      }
      this.resetForm('form')
    },
    handleQuery() {
      this.queryParams.pageNum = 1
      this.getList()
    },
    resetQuery() {
      this.resetForm('queryForm')
      this.handleQuery()
    },
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.flowId)
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '新建流程模型'
    },
    handleUpdate(row) {
      this.reset()
      this.form = {
        flowId: row.flowId,
        flowName: row.flowName,
        flowKey: row.flowKey
      }
      this.open = true
      this.title = '修改流程模型'
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        if (this.form.flowId != null) {
          editModel(this.form).then(() => {
            this.$message.success('修改成功')
            this.open = false
            this.getList()
          })
        } else {
          addModel(this.form).then(() => {
            this.$message.success('创建成功，点击「设计」打开流程设计器')
            this.open = false
            this.getList()
          })
        }
      })
    },
    handleDesign(row) {
      this.$router.push({ path: '/workflow/model-edit/index/' + row.flowId })
    },
    handlePublish(row) {
      this.$modal.confirm('确认发布流程「' + row.flowName + '」？发布后将部署到工作流引擎并立即可用。').then(() => {
        return publishModel(row.flowId)
      }).then(() => {
        this.getList()
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
      const formData = new FormData()
      formData.append('file', file)
      importModel(formData).then(res => {
        this.$message.success('导入成功，可直接在设计器中编辑')
        this.getList()
        if (res.data && res.data.flowId) {
          this.$router.push({ path: '/workflow/model-edit/index/' + res.data.flowId })
        }
      }).finally(() => {
        this.$refs.importInput.value = ''
      })
    },
    handleDelete(row) {
      const flowIds = row.flowId ? [row.flowId] : this.ids
      this.$modal.confirm('确认删除选中的流程模型？').then(() => {
        return delModel(flowIds.join(','))
      }).then(() => {
        this.getList()
        this.$message.success('删除成功')
      }).catch(() => {})
    }
  }
}
</script>
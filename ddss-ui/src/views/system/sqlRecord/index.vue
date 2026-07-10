<template>
  <div class="app-container sql-record-page">
    <!-- 搜索栏 -->
    <el-form v-show="showSearch" ref="queryForm" :inline="true" :model="queryParams" size="small">
      <el-form-item label="作用" prop="purpose">
        <el-input v-model="queryParams.purpose" clearable placeholder="请输入作用关键词" style="width: 240px" @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item label="SQL内容" prop="sqlContent">
        <el-input v-model="queryParams.sqlContent" clearable placeholder="请输入SQL关键词" style="width: 240px" @keyup.enter.native="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button icon="el-icon-search" size="mini" type="primary" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 工具栏 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button v-hasPermi="['system:sql:add']" icon="el-icon-plus" plain size="mini" type="primary" @click="handleAdd">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button v-hasPermi="['system:sql:edit']" :disabled="single" icon="el-icon-edit" plain size="mini" type="success" @click="handleUpdate">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button v-hasPermi="['system:sql:remove']" :disabled="multiple" icon="el-icon-delete" plain size="mini" type="danger" @click="handleDelete">删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList" />
    </el-row>

    <!-- 数据表格 -->
    <el-table v-loading="loading" :data="list" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="作用" prop="purpose" min-width="200" show-overflow-tooltip />
      <el-table-column label="SQL" prop="sqlContent" min-width="400" show-overflow-tooltip>
        <template slot-scope="scope">
          <code class="sql-preview">{{ scope.row.sqlContent }}</code>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="createTime" width="160" align="center">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button v-hasPermi="['system:sql:edit']" icon="el-icon-edit" size="mini" type="text" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button v-hasPermi="['system:sql:remove']" icon="el-icon-delete" size="mini" type="text" @click="handleDelete(scope.row)">删除</el-button>
          <el-button icon="el-icon-document-copy" size="mini" type="text" @click="handleCopy(scope.row)">复制</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :limit.sync="queryParams.pageSize" :page.sync="queryParams.pageNum" :total="total" @pagination="getList" />

    <!-- 新增/修改对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="700px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="作用" prop="purpose">
          <el-input v-model="form.purpose" placeholder="请简要描述这条SQL的作用" />
        </el-form-item>
        <el-form-item label="SQL" prop="sqlContent">
          <el-input v-model="form.sqlContent" type="textarea" :rows="12" placeholder="请输入SQL语句" style="font-family: 'SF Mono', Consolas, monospace; font-size: 13px" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="备注（可选）" />
        </el-form-item>
      </el-form>
      <div slot="footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listSqlRecord, getSqlRecord, addSqlRecord, updateSqlRecord, delSqlRecord } from '@/api/sqlRecord'

export default {
  name: 'SqlRecord',
  data() {
    return {
      loading: false,
      showSearch: true,
      single: true,
      multiple: true,
      open: false,
      title: '',
      total: 0,
      list: [],
      ids: [],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        purpose: undefined,
        sqlContent: undefined
      },
      form: {},
      rules: {
        purpose: [{ required: true, message: '作用不能为空', trigger: 'blur' }],
        sqlContent: [{ required: true, message: 'SQL内容不能为空', trigger: 'blur' }]
      }
    }
  },
  created() {
    this.getList()
  },
  methods: {
    getList() {
      this.loading = true
      listSqlRecord(this.queryParams).then(res => {
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
        sqlId: undefined,
        purpose: undefined,
        sqlContent: undefined,
        remark: undefined
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
      this.ids = selection.map(item => item.sqlId)
      this.single = selection.length !== 1
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '新增SQL记录'
    },
    handleUpdate(row) {
      this.reset()
      const sqlId = row.sqlId || this.ids[0]
      getSqlRecord(sqlId).then(res => {
        this.form = res.data
        this.open = true
        this.title = '修改SQL记录'
      })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        if (this.form.sqlId != null) {
          updateSqlRecord(this.form).then(() => {
          this.$message.success('修改成功')
          this.open = false
          this.getList()
          })
        } else {
          addSqlRecord(this.form).then(() => {
          this.$message.success('新增成功')
          this.open = false
          this.getList()
          })
        }
      })
    },
    handleDelete(row) {
      const sqlIds = row.sqlId ? [row.sqlId] : this.ids
      this.$modal.confirm('确认删除选中的SQL记录？').then(() => {
        return delSqlRecord(sqlIds.join(','))
      }).then(() => {
        this.getList()
        this.$message.success('删除成功')
      }).catch(() => {})
    },
    handleCopy(row) {
      const textarea = document.createElement('textarea')
      textarea.value = row.sqlContent
      textarea.style.position = 'fixed'
      textarea.style.opacity = '0'
      document.body.appendChild(textarea)
      textarea.select()
      try {
        document.execCommand('copy')
        this.$message.success('SQL已复制到剪贴板')
      } catch (e) {
        this.$message.error('复制失败，请手动选择复制')
      }
      document.body.removeChild(textarea)
    }
  }
}
</script>

<style scoped>
.sql-preview {
  display: inline-block;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-family: 'SF Mono', Consolas, monospace;
  font-size: 12px;
  color: #0071e3;
  background: #e8f0fe;
  padding: 2px 8px;
  border-radius: 4px;
}
</style>

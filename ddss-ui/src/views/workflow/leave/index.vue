<template>
  <div class="app-container workflow-leave-page">
    <!-- 搜索栏 -->
    <el-form v-show="showSearch" ref="queryForm" :model="queryParams" size="small" inline>
      <el-form-item label="请假事由" prop="reason">
        <el-input
          v-model="queryParams.reason"
          clearable
          placeholder="请输入请假事由关键词"
          style="width: 240px"
          @keyup.enter.native="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" clearable placeholder="全部" style="width: 140px">
          <el-option
            v-for="dict in statusOptions"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
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
        <el-button v-hasPermi="['workflow:leave:add']" icon="el-icon-plus" plain size="mini" type="primary" @click="handleAdd">发起请假</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          v-hasPermi="['workflow:leave:remove']"
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
      <el-table-column label="请假事由" prop="reason" min-width="200" show-overflow-tooltip />
      <el-table-column label="天数" prop="leaveDays" width="70" align="center" />
      <el-table-column label="开始日期" prop="startDate" width="110" align="center" />
      <el-table-column label="部门经理(一级)" prop="leader" width="110" align="center" />
      <el-table-column label="总经理(二级)" prop="boss" width="110" align="center" />
      <el-table-column label="状态" prop="status" width="90" align="center">
        <template slot-scope="scope">
          <el-tag :type="statusTagType(scope.row.status)">{{ statusLabel(scope.row.status) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" prop="createTime" width="160" align="center">
        <template slot-scope="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="120" align="center" class-name="small-padding fixed-width">
        <template slot-scope="scope">
          <el-button v-hasPermi="['workflow:leave:remove']" icon="el-icon-delete" size="mini" type="text" @click="handleDelete(scope.row)">删除</el-button>
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

    <!-- 发起请假对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="560px" append-to-body :close-on-click-modal="false">
      <el-alert
        title="演示说明：提交后将启动「请假申请流程」，依次由所选部门经理、总经理审批，任一环节驳回即流程终止。"
        type="info"
        :closable="false"
        show-icon
        style="margin-bottom: 16px"
      />
      <el-form ref="form" :model="form" :rules="rules" label-width="110px">
        <el-form-item label="请假事由" prop="reason">
          <el-input v-model="form.reason" type="textarea" :rows="3" placeholder="请输入请假事由" />
        </el-form-item>
        <el-form-item label="请假天数" prop="leaveDays">
          <el-input-number v-model="form.leaveDays" :min="0.5" :max="30" :step="0.5" style="width: 200px" />
        </el-form-item>
        <el-form-item label="开始日期" prop="startDate">
          <el-date-picker
            v-model="form.startDate"
            type="date"
            value-format="yyyy-MM-dd"
            placeholder="请选择开始日期"
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item label="部门经理(一级)" prop="leader">
          <el-select v-model="form.leader" clearable filterable placeholder="请选择一级审批人" style="width: 280px">
            <el-option
              v-for="item in userOptions"
              :key="item.userId"
              :label="item.nickName || item.userName"
              :value="item.userName"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="总经理(二级)" prop="boss">
          <el-select v-model="form.boss" clearable filterable placeholder="请选择二级审批人" style="width: 280px">
            <el-option
              v-for="item in userOptions"
              :key="item.userId"
              :label="item.nickName || item.userName"
              :value="item.userName"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <div slot="footer">
        <el-button type="primary" @click="submitForm">提交申请</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listLeave, addLeave, delLeave, listUserOptions } from '@/api/workflow'

export default {
  name: 'WorkflowLeave',
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
      userOptions: [],
      statusOptions: [
        { value: '0', label: '待审批' },
        { value: '1', label: '已通过' },
        { value: '2', label: '已驳回' }
      ],
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        reason: undefined,
        status: undefined
      },
      form: {},
      rules: {
        reason: [{ required: true, message: '请假事由不能为空', trigger: 'blur' }],
        leaveDays: [{ required: true, message: '请假天数不能为空', trigger: 'blur' }],
        startDate: [{ required: true, message: '开始日期不能为空', trigger: 'change' }],
        leader: [{ required: true, message: '请选择一级审批人', trigger: 'change' }],
        boss: [{ required: true, message: '请选择二级审批人', trigger: 'change' }]
      }
    }
  },
  created() {
    this.getList()
    this.getUserOptions()
  },
  methods: {
    getList() {
      this.loading = true
      listLeave(this.queryParams).then(res => {
        this.list = res.rows
        this.total = res.total
        this.loading = false
      })
    },
    getUserOptions() {
      listUserOptions().then(res => {
        this.userOptions = res.data || []
      })
    },
    statusLabel(status) {
      const item = this.statusOptions.find(o => o.value === status)
      return item ? item.label : status
    },
    statusTagType(status) {
      if (status === '0') return 'primary'
      if (status === '1') return 'success'
      if (status === '2') return 'danger'
      return 'info'
    },
    cancel() {
      this.open = false
      this.reset()
    },
    reset() {
      this.form = {
        reason: undefined,
        leaveDays: undefined,
        startDate: undefined,
        leader: undefined,
        boss: undefined
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
      this.ids = selection.map(item => item.leaveId)
      this.multiple = !selection.length
    },
    handleAdd() {
      this.reset()
      this.open = true
      this.title = '发起请假申请'
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        if (this.form.leader === this.form.boss) {
          this.$message.warning('一级审批人与二级审批人不能是同一个账号')
          return
        }
        addLeave(this.form).then(() => {
          this.$message.success('提交成功，请等待审批')
          this.open = false
          this.getList()
        })
      })
    },
    handleDelete(row) {
      const leaveIds = row.leaveId ? [row.leaveId] : this.ids
      this.$modal.confirm('确认删除选中的请假申请？流程未结束时将同步终止。').then(() => {
        return delLeave(leaveIds.join(','))
      }).then(() => {
        this.getList()
        this.$message.success('删除成功')
      }).catch(() => {})
    }
  }
}
</script>

<style scoped>
.workflow-leave-page .el-dialog .el-alert {
  margin-bottom: 12px;
}
</style>
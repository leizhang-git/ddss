<template>
  <div class="app-container workflow-todo-page">
    <el-tabs v-model="activeTab" type="border-card" @tab-click="handleTabClick">
      <!-- 待办任务 -->
      <el-tab-pane label="我的待办" name="todo">
        <el-table v-loading="loading" :data="todoList">
          <el-table-column label="审批节点" prop="taskName" width="140" align="center">
            <template slot-scope="scope">
              <el-tag size="mini">{{ scope.row.taskName }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="申请人" prop="applyUserName" width="120" align="center" />
          <el-table-column label="请假事由" prop="reason" min-width="180" show-overflow-tooltip />
          <el-table-column label="天数" prop="leaveDays" width="70" align="center" />
          <el-table-column label="开始日期" prop="startDate" width="110" align="center" />
          <el-table-column label="任务创建时间" prop="taskCreateTime" width="165" align="center">
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.taskCreateTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120" align="center" class-name="small-padding fixed-width">
            <template slot-scope="scope">
              <el-button v-hasPermi="['workflow:task:approve']" icon="el-icon-check" size="mini" type="text" @click="handleApprove(scope.row)">审批</el-button>
            </template>
          </el-table-column>
        </el-table>
        <pagination
          v-show="todoTotal > 0"
          :limit.sync="todoParams.pageSize"
          :page.sync="todoParams.pageNum"
          :total="todoTotal"
          @pagination="getTodoList"
        />
      </el-tab-pane>

      <!-- 已办任务 -->
      <el-tab-pane label="我的已办" name="done">
        <el-table v-loading="doneLoading" :data="doneList">
          <el-table-column label="审批节点" prop="taskName" width="140" align="center">
            <template slot-scope="scope">
              <el-tag size="mini">{{ scope.row.taskName }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="申请人" prop="applyUserName" width="120" align="center" />
          <el-table-column label="请假事由" prop="reason" min-width="180" show-overflow-tooltip />
          <el-table-column label="天数" prop="leaveDays" width="70" align="center" />
          <el-table-column label="结论" prop="approved" width="90" align="center">
            <template slot-scope="scope">
              <el-tag :type="scope.row.approved ? 'success' : 'danger'">
                {{ scope.row.approved ? '通过' : '驳回' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="审批意见" prop="comment" min-width="120" show-overflow-tooltip />
          <el-table-column label="完成时间" prop="finishTime" width="165" align="center">
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.finishTime) }}</span>
            </template>
          </el-table-column>
        </el-table>
        <pagination
          v-show="doneTotal > 0"
          :limit.sync="doneParams.pageSize"
          :page.sync="doneParams.pageNum"
          :total="doneTotal"
          @pagination="getDoneList"
        />
      </el-tab-pane>
    </el-tabs>

    <!-- 审批对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="520px" append-to-body :close-on-click-modal="false">
      <el-form ref="approveForm" :model="approveForm" :rules="approveRules" label-width="110px">
        <el-form-item label="请假事由">
          <span>{{ currentTask.reason }}</span>
        </el-form-item>
        <el-form-item label="申请人">
          <span>{{ currentTask.applyUserName }}（{{ currentTask.applicant }}）</span>
        </el-form-item>
        <el-form-item label="请假天数">
          <span>{{ currentTask.leaveDays }} 天，自 {{ currentTask.startDate }} 起</span>
        </el-form-item>
        <el-form-item label="审批结果" prop="approved">
          <el-radio-group v-model="approveForm.approved">
            <el-radio :label="true">通过</el-radio>
            <el-radio :label="false">驳回</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审批意见" prop="comment">
          <el-input v-model="approveForm.comment" type="textarea" :rows="3" placeholder="请输入审批意见（可选）" />
        </el-form-item>
      </el-form>
      <div slot="footer">
        <el-button type="primary" @click="submitApprove">确定</el-button>
        <el-button @click="cancelApprove">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { listTodo, listDone, approveTask } from '@/api/workflow'

export default {
  name: 'WorkflowTodo',
  data() {
    return {
      activeTab: 'todo',
      loading: false,
      doneLoading: false,
      todoList: [],
      doneList: [],
      todoTotal: 0,
      doneTotal: 0,
      todoParams: { pageNum: 1, pageSize: 10 },
      doneParams: { pageNum: 1, pageSize: 10 },
      currentTask: {},
      open: false,
      title: '',
      approveForm: {
        taskId: undefined,
        approved: true,
        comment: undefined
      },
      approveRules: {
        approved: [{ required: true, message: '请选择审批结果', trigger: 'change' }]
      }
    }
  },
  created() {
    this.getTodoList()
  },
  methods: {
    handleTabClick(tab) {
      if (tab.name === 'done') {
        this.getDoneList()
      } else {
        this.getTodoList()
      }
    },
    getTodoList() {
      this.loading = true
      listTodo(this.todoParams).then(res => {
        this.todoList = res.rows
        this.todoTotal = res.total
        this.loading = false
      })
    },
    getDoneList() {
      this.doneLoading = true
      listDone(this.doneParams).then(res => {
        this.doneList = res.rows
        this.doneTotal = res.total
        this.doneLoading = false
      })
    },
    handleApprove(row) {
      this.currentTask = row
      this.approveForm = {
        taskId: row.taskId,
        approved: true,
        comment: undefined
      }
      this.open = true
      this.title = '审批 - ' + row.taskName
      this.$nextTick(() => this.resetForm('approveForm'))
    },
    cancelApprove() {
      this.open = false
    },
    submitApprove() {
      this.$refs.approveForm.validate(valid => {
        if (!valid) return
        approveTask(this.approveForm).then(() => {
          this.$message.success('审批完成')
          this.open = false
          this.getTodoList()
        })
      })
    }
  }
}
</script>

<style scoped>
.workflow-todo-page .el-tabs__content {
  padding-top: 12px;
}
</style>
<template>
  <div class="app-container">
    <el-form v-show="showSearch" ref="queryForm" :inline="true" :model="queryParams" size="small">
      <el-form-item label="欠款方" prop="creditorName">
        <el-input v-model="queryParams.creditorName" clearable placeholder="欠款方名称" style="width:200px" @keyup.enter.native="handleQuery"/>
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" clearable placeholder="选择状态" style="width:160px">
          <el-option label="还款中" value="0"/>
          <el-option label="已结清" value="1"/>
          <el-option label="逾期" value="2"/>
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button icon="el-icon-search" size="mini" type="primary" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button v-hasPermi="['finance:add']" icon="el-icon-plus" plain size="mini" type="primary" @click="handleAdd">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button v-hasPermi="['finance:edit']" :disabled="single" icon="el-icon-edit" plain size="mini" type="success" @click="handleUpdate">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button v-hasPermi="['finance:remove']" :disabled="multiple" icon="el-icon-delete" plain size="mini" type="danger" @click="handleDelete">删除</el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="financeList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center"/>
      <el-table-column label="欠款方" prop="creditorName" min-width="140"/>
      <el-table-column label="借款总额(元)" prop="loanAmount" width="140" align="right"/>
      <el-table-column label="月还款额(元)" prop="monthlyPayment" width="130" align="right"/>
      <el-table-column label="利率(%)" prop="interestRate" width="100" align="right"/>
      <el-table-column label="借款日期" prop="loanDate" width="120"/>
      <el-table-column label="还款结束" prop="repaymentEndDate" width="120"/>
      <el-table-column label="剩余未还(元)" prop="remainingAmount" width="140" align="right"/>
      <el-table-column label="状态" prop="status" width="100" align="center">
        <template slot-scope="scope">
          <el-tag v-if="scope.row.status === '0'" type="warning">还款中</el-tag>
          <el-tag v-else-if="scope.row.status === '1'" type="success">已结清</el-tag>
          <el-tag v-else-if="scope.row.status === '2'" type="danger">逾期</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="备注" prop="remark" min-width="120" show-overflow-tooltip/>
      <el-table-column label="操作" width="150" align="center" fixed="right">
        <template slot-scope="scope">
          <el-button v-hasPermi="['finance:edit']" icon="el-icon-edit" size="mini" type="text" @click="handleUpdate(scope.row)">修改</el-button>
          <el-button v-hasPermi="['finance:remove']" icon="el-icon-delete" size="mini" type="text" style="color:#f56c6c" @click="handleDelete(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total>0" :total="total" :page.sync="queryParams.pageNum" :limit.sync="queryParams.pageSize" @pagination="getList"/>

    <!-- 新增/修改弹窗 -->
    <el-dialog :title="title" :visible.sync="open" width="700px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="110px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="欠款方名称" prop="creditorName">
              <el-input v-model="form.creditorName" placeholder="请输入"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="借款总额" prop="loanAmount">
              <el-input-number v-model="form.loanAmount" :min="0" :precision="2" style="width:100%" controls-position="right"/>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="借款日期" prop="loanDate">
              <el-date-picker v-model="form.loanDate" type="date" placeholder="选择日期" value-format="yyyy-MM-dd" style="width:100%"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="还款开始日期">
              <el-date-picker v-model="form.repaymentStartDate" type="date" placeholder="选择日期" value-format="yyyy-MM-dd" style="width:100%"/>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="还款结束日期">
              <el-date-picker v-model="form.repaymentEndDate" type="date" placeholder="选择日期" value-format="yyyy-MM-dd" style="width:100%"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="借款期限(月)">
              <el-input-number v-model="form.loanTerm" :min="0" style="width:100%" controls-position="right"/>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="每月几号还款">
              <el-input-number v-model="form.repaymentDay" :min="1" :max="31" style="width:100%" controls-position="right"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="月还款额">
              <el-input-number v-model="form.monthlyPayment" :min="0" :precision="2" style="width:100%" controls-position="right"/>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="利率(%)">
              <el-input-number v-model="form.interestRate" :min="0" :precision="2" style="width:100%" controls-position="right"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="利息总额">
              <el-input-number v-model="form.interestAmount" :min="0" :precision="2" style="width:100%" controls-position="right"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="提前结清金额">
              <el-input-number v-model="form.earlySettlementAmount" :min="0" :precision="2" style="width:100%" controls-position="right"/>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="剩余未还">
              <el-input-number v-model="form.remainingAmount" :min="0" :precision="2" style="width:100%" controls-position="right"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="已还金额">
              <el-input-number v-model="form.paidAmount" :min="0" :precision="2" style="width:100%" controls-position="right"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="状态" prop="status">
              <el-select v-model="form.status" style="width:100%">
                <el-option label="还款中" value="0"/>
                <el-option label="已结清" value="1"/>
                <el-option label="逾期" value="2"/>
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="2"/>
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
import { listFinance, getFinance, addFinance, updateFinance, delFinance } from '@/api/finance'

export default {
  name: 'Finance',
  data() {
    return {
      loading: false, showSearch: true, open: false, title: '', total: 0,
      financeList: [], ids: [], single: true, multiple: true,
      queryParams: { pageNum: 1, pageSize: 10, creditorName: null, status: null },
      form: {},
      rules: {
        creditorName: [{ required: true, message: '欠款方名称不能为空', trigger: 'blur' }],
        loanAmount: [{ required: true, message: '借款总额不能为空', trigger: 'blur' }],
        status: [{ required: true, message: '状态不能为空', trigger: 'change' }]
      }
    }
  },
  created() { this.getList() },
  methods: {
    getList() {
      this.loading = true
      listFinance(this.queryParams).then(res => {
        this.financeList = res.rows; this.total = res.total; this.loading = false
      })
    },
    resetQuery() { this.queryParams = { pageNum: 1, pageSize: 10, creditorName: null, status: null }; this.handleQuery() },
    handleQuery() { this.queryParams.pageNum = 1; this.getList() },
    handleSelectionChange(selection) { this.ids = selection.map(i => i.financeId); this.single = selection.length !== 1; this.multiple = !selection.length },
    handleAdd() { this.reset(); this.open = true; this.title = '新增财务记录' },
    handleUpdate(row) {
      this.reset()
      const id = row.financeId || this.ids[0]
      getFinance(id).then(res => { this.form = res.data; this.open = true; this.title = '修改财务记录' })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        if (this.form.financeId) {
          updateFinance(this.form).then(() => { this.$modal.msgSuccess('修改成功'); this.open = false; this.getList() })
        } else {
          addFinance(this.form).then(() => { this.$modal.msgSuccess('新增成功'); this.open = false; this.getList() })
        }
      })
    },
    handleDelete(row) {
      const ids = row.financeId || this.ids.join(',')
      this.$modal.confirm('确认删除该记录？').then(() => {
        return delFinance(ids)
      }).then(() => { this.getList(); this.$modal.msgSuccess('删除成功') })
    },
    cancel() { this.open = false; this.reset() },
    reset() { this.form = { status: '0' }; if (this.$refs.form) this.$refs.form.resetFields() }
  }
}
</script>

<template>
  <div class="app-container">
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button v-hasPermi="['finance:add']" icon="el-icon-plus" plain size="mini" type="primary" @click="handleAdd">新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button v-hasPermi="['finance:edit']" icon="el-icon-edit" plain size="mini" type="success" @click="handleUpdate()">修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button v-hasPermi="['finance:remove']" icon="el-icon-delete" plain size="mini" type="danger" @click="handleDelete()">删除</el-button>
      </el-col>
    </el-row>

    <!-- 展开式月还款表 -->
    <div class="table-wrapper">
    <el-table v-loading="loading" :data="financeList" border stripe size="small"
      show-summary :summary-method="getSummaries" max-height="500"
      @selection-change="handleSelectionChange" highlight-current-row>
      <el-table-column type="selection" width="40" align="center" fixed="left"/>
      <el-table-column label="名称" prop="creditorName" width="140" fixed="left"/>
      <el-table-column label="便宜" width="110" align="right" fixed="left">
        <template slot-scope="s">{{ cheap(s.row) }}</template>
      </el-table-column>
      <el-table-column label="提前结清" prop="earlySettlementAmount" width="110" align="right"/>
      <el-table-column label="总" prop="loanAmount" width="110" align="right"/>
      <el-table-column label="日期" prop="repaymentStartDate" width="110" align="center"/>
      <el-table-column v-for="m in months" :key="m" :label="m" width="100" align="right">
        <template slot-scope="s">
          <span :style="{color: payThisMonth(s.row, m) > 0 ? '#e6a23c' : '#c0c4cc'}">
            {{ payThisMonth(s.row, m) || '' }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="剩余" prop="remainingAmount" width="110" align="right" fixed="right"/>
      <el-table-column label="状态" width="80" align="center" fixed="right">
        <template slot-scope="s">
          <el-tag v-if="s.row.status==='0'" type="warning" size="small">还款中</el-tag>
          <el-tag v-else-if="s.row.status==='1'" type="success" size="small">结清</el-tag>
          <el-tag v-else-if="s.row.status==='2'" type="danger" size="small">逾期</el-tag>
        </template>
      </el-table-column>
    </el-table>
    </div>

    <!-- 弹窗表单 -->
    <el-dialog :title="title" :visible.sync="open" width="780px" append-to-body :close-on-click-modal="false">
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="名称" prop="creditorName">
              <el-input v-model="form.creditorName" placeholder="欠款方"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="提前结清">
              <el-input-number v-model="form.earlySettlementAmount" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="总借款额" prop="loanAmount">
              <el-input-number v-model="form.loanAmount" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="便宜多少">
              <el-input :value="formatSaving" readonly style="font-weight:bold;color:#67c23a"/>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="还款开始">
              <el-date-picker v-model="form.repaymentStartDate" type="date" placeholder="选择" value-format="yyyy-MM-dd" style="width:100%" @change="autoCalc"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="几号还">
              <el-input-number v-model="form.repaymentDay" :min="1" :max="31" style="width:100%" controls-position="right"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="期限(月)">
              <el-input-number v-model="form.loanTerm" :min="0" style="width:100%" controls-position="right" @change="autoCalc"/>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="月还">
              <el-input-number v-model="form.monthlyPayment" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="利率(%)">
              <el-input-number v-model="form.interestRate" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="已还">
              <el-input-number v-model="form.paidAmount" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="利息总额">
              <el-input-number v-model="form.interestAmount" :min="0" :precision="2" style="width:100%" controls-position="right" @change="autoCalc"/>
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="剩余未还">
              <el-input-number v-model="form.remainingAmount" :min="0" :precision="2" style="width:100%" controls-position="right"/>
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
    const now = new Date()
    const months = []
    for (let i = 0; i < 9; i++) {
      const d = new Date(now.getFullYear(), now.getMonth() + i, 1)
      months.push((d.getMonth() + 1) + '月')
    }
    return {
      loading: false, open: false, title: '', total: 0, months,
      financeList: [], ids: [], single: true, multiple: true,
      form: {},
      rules: {
        creditorName: [{ required: true, message: '必填', trigger: 'blur' }],
        loanAmount: [{ required: true, message: '必填', trigger: 'blur' }],
        status: [{ required: true, message: '必填', trigger: 'change' }]
      }
    }
  },
  created() { this.getList() },
  computed: {
    formatSaving() {
      const a = Number(this.form.loanAmount) || 0
      const b = Number(this.form.earlySettlementAmount) || 0
      return a && b ? '¥' + (a - b >= 0 ? (a - b).toFixed(2) : '0.00') : ''
    }
  },
  methods: {
    cheap(row) {
      const a = Number(row.loanAmount) || 0
      const b = Number(row.earlySettlementAmount) || 0
      return a && b ? (a - b >= 0 ? (a - b).toFixed(2) : '0') : ''
    },
    /** 汇总行 */
    getSummaries(param) {
      const { columns, data } = param
      const sums = new Array(columns.length).fill('')
      sums[1] = '合计'
      columns.forEach((col, i) => {
        if (i <= 1) return
        const prop = (col.property || '') + (col.label || '')
        // 月份列
        if (col.label && /^\d+月$/.test(col.label)) {
          let t = 0; data.forEach(r => { t += Number(this.payThisMonth(r, col.label)) || 0 })
          if (t > 0) sums[i] = t.toFixed(2)
        }
        // 便宜列
        else if (col.label === '便宜') {
          let t = 0; data.forEach(r => { const a = Number(r.loanAmount)||0; const b = Number(r.earlySettlementAmount)||0; t += a-b })
          sums[i] = t.toFixed(2)
        }
        // 金额列
        else if (['总','提前结清','剩余'].includes(col.label)) {
          const total = data.reduce((s, r) => s + (Number(r[col.property]) || 0), 0)
          sums[i] = total.toFixed(2)
        }
      })
      return sums
    },
    /** 判断某月是否需要还款，返回金额 */
    payThisMonth(row, monthLabel) {
      const start = row.repaymentStartDate
      const day = row.repaymentDay
      const amount = row.monthlyPayment
      if (!start || !day || !amount) return 0
      const m = parseInt(monthLabel)
      if (!m) return 0
      const now = new Date()
      const curYear = now.getFullYear()
      const target = new Date(m <= now.getMonth() + 1 ? curYear + 1 : curYear, m - 1, day)
      // 检查是否在还款范围内且还款日已过或等于今天
      const startDate = new Date(start)
      const loanEnd = new Date(start)
      loanEnd.setMonth(loanEnd.getMonth() + (row.loanTerm || 0))
      // 仅在还款期间内且当天是还款日时显示
      if (target >= startDate && target <= loanEnd) {
        return Number(amount).toFixed(2)
      }
      return 0
    },
    getList() {
      this.loading = true
      listFinance({ pageNum: 1, pageSize: 999 }).then(res => {
        this.financeList = res.rows || []; this.loading = false
      })
    },
    handleSelectionChange(sel) { this.ids = sel.map(i => i.financeId); this.single = sel.length !== 1; this.multiple = !sel.length },
    handleAdd() { this.form = { status: '0' }; this.open = true; this.title = '新增'; if (this.$refs.form) this.$refs.form.resetFields() },
    handleUpdate() {
      const id = this.ids[0]
      if (!id) { this.$message.warning('请先选中一条'); return }
      this.form = { status: '0' }
      getFinance(id).then(res => { this.form = res.data; this.open = true; this.title = '修改' })
    },
    submitForm() {
      this.$refs.form.validate(valid => {
        if (!valid) return
        const act = this.form.financeId ? updateFinance : addFinance
        act(this.form).then(() => { this.$modal.msgSuccess('成功'); this.open = false; this.getList() })
      })
    },
    handleDelete() {
      const ids = this.ids
      if (!ids.length) { this.$message.warning('请先选中'); return }
      this.$modal.confirm('确认删除？').then(() => delFinance(ids.join(','))).then(() => { this.getList(); this.$modal.msgSuccess('已删除') })
    },
    cancel() { this.open = false },
    autoCalc() {
      const f = this.form
      const L = Number(f.loanAmount) || 0; const P = Number(f.paidAmount) || 0
      const R = Number(f.interestRate) || 0; const T = f.loanTerm || 0
      const M = Number(f.monthlyPayment) || 0; const I = Number(f.interestAmount) || 0
      if (L && P) f.remainingAmount = (L - P >= 0 ? L - P : 0).toFixed(2)
      if (L && R && T) f.interestAmount = (L * (R / 100) * (T / 12)).toFixed(2)
      if (L && I && T) f.monthlyPayment = Number(((L + I) / T).toFixed(2))
      if (M && T && L && !I) f.interestAmount = (M * T - L > 0 ? M * T - L : 0).toFixed(2)
      if (f.repaymentStartDate && T) {
        const d = new Date(f.repaymentStartDate); d.setMonth(d.getMonth() + T)
        f.repaymentEndDate = d.toISOString().slice(0, 10)
      }
    }
  }
}
</script>

<style scoped>
.table-wrapper { overflow-x: auto }
::v-deep .el-table__footer-wrapper td { font-weight: 600; font-size: 13px; background: #f5f7fa; color: #303133 }
::v-deep .el-table__footer-wrapper .cell { padding: 6px 10px }
</style>

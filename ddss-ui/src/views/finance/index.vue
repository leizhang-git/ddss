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
      <el-table-column label="总" width="110" align="right">
        <template slot-scope="s">{{ totalRepay(s.row) }}</template>
      </el-table-column>
      <el-table-column label="日期" prop="repaymentStartDate" width="110" align="center"/>
      <el-table-column v-for="m in months" :key="m" :label="m" width="90" align="center">
        <template slot-scope="s">
          <span v-if="!isPaid(s.row, m) && payThisMonth(s.row, m) > 0"
            style="cursor:pointer;color:#f56c6c;font-weight:bold"
            :title="'点击标记已还'"
            @click="togglePay(s.row, m)">
            {{ Number(payThisMonth(s.row, m)).toFixed(2) }}
          </span>
          <span v-else-if="isPaid(s.row, m) && payThisMonth(s.row, m) > 0"
            style="cursor:pointer;color:#c0c4cc"
            title="已还，点击撤回"
            @click="togglePay(s.row, m)">
            -
          </span>
          <span v-else style="color:#e8eaed">-</span>
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
    const months = []
    return {
      loading: false, open: false, title: '',
      financeList: [], ids: [], single: true, multiple: true, months,
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
    totalRepay(row) {
      const m = Number(row.monthlyPayment) || 0
      const t = row.loanTerm || 0
      return m && t ? (m * t).toFixed(2) : ''
    },
    /** 汇总行 */
    getSummaries(param) {
      const { columns, data } = param
      const sums = new Array(columns.length).fill('')
      sums[1] = '合计'
      columns.forEach((col, i) => {
        if (i <= 1) return
        if (col.label && /^\d+月$/.test(col.label)) {
          let t = 0; data.forEach(r => { t += Number(this.payThisMonth(r, col.label)) || 0 })
          if (t > 0) sums[i] = t.toFixed(2)
        } else if (col.label === '便宜') {
          let t = 0; data.forEach(r => { const a = Number(r.loanAmount)||0; const b = Number(r.earlySettlementAmount)||0; t += a-b })
          sums[i] = t.toFixed(2)
        } else if (col.label === '总') {
          let t = 0; data.forEach(r => { const v = Number(this.totalRepay(r))||0; t += v })
          sums[i] = t.toFixed(2)
        } else if (col.label === '提前结清' || col.label === '剩余') {
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
      // 确定月份对应的年份：从当前月开始，简单处理为超过12的是次年
      const now = new Date()
      const curMon = now.getMonth() + 1
      const curYr = now.getFullYear()
      const targetYr = m >= curMon ? curYr : curYr + 1
      const target = new Date(targetYr, m - 1, day)
      const startDate = new Date(start)
      const endDate = new Date(start)
      endDate.setMonth(endDate.getMonth() + (row.loanTerm || 0))
      if (target >= startDate && target <= endDate) return Number(amount).toFixed(2)
      return 0
    },
    getList() {
      this.loading = true
      listFinance({ pageNum: 1, pageSize: 999 }).then(res => {
        this.financeList = (res.rows || []).map(r => ({
          ...r,
          _paidSet: new Set((r.paidMonths || '').split(',').filter(Boolean))
        }))
        this.buildMonths()
        this.loading = false
      })
    },
    isPaid(row, m) { return row._paidSet && row._paidSet.has(m) },
    canPay(row, m) {
      // 必须按顺序还款：前面的月份全部还了，当前月才能还
      const amount = Number(this.payThisMonth(row, m))
      if (!amount) return false
      const months = this.months
      for (let i = 0; i < months.length; i++) {
        if (months[i] === m) return true // 到了当前月，前面的都没问题
        const famt = Number(this.payThisMonth(row, months[i]))
        if (famt > 0 && !row._paidSet.has(months[i])) return false // 前面有未还的
        if (famt > 0 && row._paidSet.has(months[i])) continue
      }
      return true
    },
    togglePay(row, m) {
      const amount = Number(this.payThisMonth(row, m))
      if (!amount) return
      if (row._paidSet.has(m)) {
        this.$modal.confirm(`撤销 ${m} 的还款（¥${amount.toFixed(2)}）？`).then(() => {
          row._paidSet.delete(m)
          this.savePay(row, amount)
        }).catch(() => {})
      } else {
        if (!this.canPay(row, m)) {
          this.$message.warning('请按顺序还款，前面的月份还未还完')
          return
        }
        this.$modal.confirm(`确认已还 ${m} 还款 ¥${amount.toFixed(2)}？`).then(() => {
          row._paidSet.add(m)
          this.savePay(row, amount)
        }).catch(() => {})
      }
    },
    savePay(row, amount) {
      row.paidMonths = [...row._paidSet].join(',')
      const count = row._paidSet.size
      row.paidAmount = (count * Number(row.monthlyPayment)).toFixed(2)
      row.remainingAmount = Math.max(0, (Number(row.loanAmount) || 0) - Number(row.paidAmount)).toFixed(2)
      updateFinance(row).catch(() => {})
    },
    buildMonths() {
      const now = new Date()
      let maxDate = new Date(now.getFullYear(), now.getMonth() + 6, 1) // 至少未来6个月
      this.financeList.forEach(r => {
        if (!r.repaymentStartDate || !r.loanTerm) return
        const end = new Date(r.repaymentStartDate)
        end.setMonth(end.getMonth() + r.loanTerm)
        if (end > maxDate) maxDate = end
      })
      const months = []
      const cur = new Date(now.getFullYear(), now.getMonth(), 1)
      while (cur <= maxDate) {
        months.push((cur.getMonth() + 1) + '月')
        cur.setMonth(cur.getMonth() + 1)
      }
      this.months = months
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
    },
    /** 打开编辑时从 paidMonths 反推已还金额 */
    syncPaidFromMonths(row) {
      if (!row.paidMonths || !row.monthlyPayment) return
      const months = row.paidMonths.split(',').filter(Boolean)
      row.paidAmount = (months.length * Number(row.monthlyPayment)).toFixed(2)
      row.remainingAmount = Math.max(0, (Number(row.loanAmount) || 0) - Number(row.paidAmount)).toFixed(2)
    }
  }
}
</script>

<style scoped>
.table-wrapper { overflow-x: auto }
::v-deep .el-table__footer-wrapper td { font-weight: 600; font-size: 13px; background: #f5f7fa; color: #303133 }
::v-deep .el-table__footer-wrapper .cell { padding: 6px 10px }
</style>

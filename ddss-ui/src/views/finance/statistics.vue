<template>
  <div class="app-container">
    <el-row :gutter="20" class="stats-cards">
      <el-col :xs="12" :sm="6">
        <div class="card card-indigo">
          <div class="card-icon"><i class="el-icon-document"></i></div>
          <div class="card-body">
            <div class="card-value">{{ summary.totalCount || 0 }}</div>
            <div class="card-label">借款笔数</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6">
        <div class="card card-blue">
          <div class="card-icon"><i class="el-icon-coin"></i></div>
          <div class="card-body">
            <div class="card-value">{{ fmt(summary.totalLoan) }}</div>
            <div class="card-label">借款总额(万)</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6">
        <div class="card card-amber">
          <div class="card-icon"><i class="el-icon-wallet"></i></div>
          <div class="card-body">
            <div class="card-value">{{ fmt(summary.totalRemaining) }}</div>
            <div class="card-label">剩余未还(万)</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6">
        <div class="card card-emerald">
          <div class="card-icon"><i class="el-icon-data-line"></i></div>
          <div class="card-body">
            <div class="card-value">{{ fmt(summary.totalInterest) }}</div>
            <div class="card-label">利息总额(万)</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24" :lg="8">
        <el-card shadow="hover" class="chart-card">
          <div slot="header" class="chart-header"><span class="chart-title">状态分布</span></div>
          <div ref="pieChart" style="height:300px"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="16">
        <el-card shadow="hover" class="chart-card">
          <div slot="header" class="chart-header"><span class="chart-title">欠款方借款分布</span></div>
          <div ref="barChart" style="height:300px"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="chart-row">
      <el-col :span="24">
        <el-card shadow="hover" class="chart-card">
          <div slot="header" class="chart-header"><span class="chart-title">每月还款趋势</span></div>
          <div ref="trendChart" style="height:300px"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row class="chart-row">
      <el-col :span="24">
        <el-card shadow="hover" class="chart-card">
          <div slot="header" class="chart-header">
            <span class="chart-title">欠款明细</span>
            <el-button size="mini" type="primary" plain @click="refreshAll">刷新</el-button>
          </div>
          <el-table :data="creditorList" size="small" stripe>
            <el-table-column label="欠款方" prop="name"/>
            <el-table-column label="借款总额(元)" prop="loanAmount" align="right">
              <template slot-scope="s">{{ s.row.loanAmount | numFilter }}</template>
            </el-table-column>
            <el-table-column label="剩余未还(元)" prop="remainingAmount" align="right">
              <template slot-scope="s">{{ s.row.remainingAmount | numFilter }}</template>
            </el-table-column>
            <el-table-column label="已还比例" align="center" width="160">
              <template slot-scope="s">
                <el-progress :percentage="calcPercent(s.row)" :color="progressColor(s.row)"/>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import * as echarts from 'echarts'
import { getSummary, getGroupByCreditor, getMonthlyTrend } from '@/api/finance'

export default {
  name: 'FinanceStatistics',
  filters: {
    numFilter(v) { return v ? Number(v).toLocaleString() : '0' }
  },
  data() {
    return { summary: {}, creditorList: [], trendList: [], pieChart: null, barChart: null, trendChart: null }
  },
  mounted() { this.refreshAll(); window.addEventListener('resize', this.handleResize) },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleResize)
    if (this.pieChart) { this.pieChart.dispose(); this.pieChart = null }
    if (this.barChart) { this.barChart.dispose(); this.barChart = null }
    if (this.trendChart) { this.trendChart.dispose(); this.trendChart = null }
  },
  methods: {
    handleResize() {
      if (this.pieChart) this.pieChart.resize()
      if (this.barChart) this.barChart.resize()
      if (this.trendChart) this.trendChart.resize()
    },
    refreshAll() {
      getSummary().then(r => { this.summary = r.data || {}; this.$nextTick(() => this.initPie()) })
      getGroupByCreditor().then(r => { this.creditorList = r.data || []; this.$nextTick(() => this.initBar()) })
      getMonthlyTrend().then(r => { this.trendList = r.data || []; this.$nextTick(() => this.initTrend()) })
    },
    fmt(v) { return v ? (Number(v) / 10000).toFixed(2) : '0.00' },
    calcPercent(row) {
      if (!row.loanAmount || Number(row.loanAmount) === 0) return 0
      const paid = Number(row.loanAmount) - Number(row.remainingAmount || 0)
      return Math.round((paid / Number(row.loanAmount)) * 100)
    },
    progressColor(row) { const p = this.calcPercent(row); return p >= 100 ? '#34c759' : p >= 50 ? '#0071e3' : '#ff9f0a' },
    initPie() {
      if (!this.$refs.pieChart) return
      if (!this.pieChart) this.pieChart = echarts.init(this.$refs.pieChart)
      this.pieChart.setOption({
        tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
        legend: { bottom: 0, data: ['还款中', '已结清', '逾期'] },
        color: ['#ff9f0a', '#34c759', '#ff3b30'],
        series: [{
          type: 'pie', radius: ['40%', '70%'], center: ['50%', '45%'],
          data: [
            { value: this.summary.repayingCount || 0, name: '还款中' },
            { value: this.summary.settledCount || 0, name: '已结清' },
            { value: this.summary.overdueCount || 0, name: '逾期' }
          ],
          itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 }
        }]
      })
    },
    initBar() {
      if (!this.$refs.barChart) return
      if (!this.barChart) this.barChart = echarts.init(this.$refs.barChart)
      this.barChart.setOption({
        tooltip: { trigger: 'axis' },
        legend: { data: ['借款总额(万)', '剩余未还(万)'] },
        grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
        xAxis: { type: 'category', data: this.creditorList.map(i => i.name), axisLabel: { rotate: 15 } },
        yAxis: { type: 'value' },
        series: [
          { name: '借款总额(万)', type: 'bar', data: this.creditorList.map(i => (i.loanAmount / 10000).toFixed(2)), itemStyle: { color: '#0071e3', borderRadius: [4, 4, 0, 0] } },
          { name: '剩余未还(万)', type: 'bar', data: this.creditorList.map(i => (i.remainingAmount / 10000).toFixed(2)), itemStyle: { color: '#ff9f0a', borderRadius: [4, 4, 0, 0] } }
        ]
      })
    },
    initTrend() {
      if (!this.$refs.trendChart) return
      if (!this.trendChart) this.trendChart = echarts.init(this.$refs.trendChart)
      this.trendChart.setOption({
        tooltip: { trigger: 'axis' },
        grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
        xAxis: { type: 'category', data: this.trendList.map(i => i.name) },
        yAxis: { type: 'value', name: '月还款额(元)' },
        series: [{
          type: 'line', name: '月还款额', smooth: true,
          data: this.trendList.map(i => i.value),
          areaStyle: { color: new echarts.graphic.LinearGradient(0,0,0,1, [{offset:0,color:'rgba(0,113,227,0.3)'},{offset:1,color:'rgba(0,113,227,0.05)'}]) },
          itemStyle: { color: '#0071e3' }
        }]
      })
    }
  }
}
</script>

<style scoped>
.stats-cards { margin-bottom: 20px }
.stats-cards .card {
  border-radius: 14px;
  padding: 20px;
  color: #fff;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s ease;
  cursor: default;
  margin-bottom: 16px;
}
.stats-cards .card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}
.stats-cards .card-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.stats-cards .card-icon i { font-size: 24px; }
.stats-cards .card-body { flex: 1; }
.card-value { font-size: 26px; font-weight: 700; margin-bottom: 4px; }
.card-label { font-size: 13px; opacity: .85; }

.card-indigo  { background: linear-gradient(135deg, #0071e3, #2997ff); }
.card-blue    { background: linear-gradient(135deg, #5e5ce6, #8e8e93); }
.card-amber   { background: linear-gradient(135deg, #ff9f0a, #ffd60a); }
.card-emerald { background: linear-gradient(135deg, #34c759, #30d158); }

.chart-row { margin-bottom: 20px }
.chart-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  transition: box-shadow 0.3s;
  margin-bottom: 16px;
}
.chart-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.chart-title {
  font-weight: 600;
  font-size: 15px;
  color: #1d1d1f;
}

::v-deep .el-table {
  th { background: #f5f5f7; color: #6e6e73; font-weight: 600 }
  border-radius: 8px;
}
</style>

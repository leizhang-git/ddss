<template>
  <div class="app-container">
    <!-- 汇总卡片 -->
    <el-row :gutter="20" class="stats-cards">
      <el-col :xs="12" :sm="6">
        <div class="card card-blue">
          <div class="card-value">{{ summary.totalCount || 0 }}</div>
          <div class="card-label">借款笔数</div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6">
        <div class="card card-red">
          <div class="card-value">{{ fmt(summary.totalLoan) }}</div>
          <div class="card-label">借款总额(万)</div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6">
        <div class="card card-orange">
          <div class="card-value">{{ fmt(summary.totalRemaining) }}</div>
          <div class="card-label">剩余未还(万)</div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6">
        <div class="card card-green">
          <div class="card-value">{{ fmt(summary.totalInterest) }}</div>
          <div class="card-label">利息总额(万)</div>
        </div>
      </el-col>
    </el-row>

    <!-- 状态分布 + 欠款方分布 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24" :lg="8">
        <el-card shadow="never">
          <div slot="header"><span>状态分布</span></div>
          <div ref="pieChart" style="height:300px"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="16">
        <el-card shadow="never">
          <div slot="header"><span>欠款方借款分布</span></div>
          <div ref="barChart" style="height:300px"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 月还款趋势 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="24">
        <el-card shadow="never">
          <div slot="header"><span>每月还款趋势</span></div>
          <div ref="trendChart" style="height:300px"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 明细列表 -->
    <el-row class="chart-row">
      <el-col :span="24">
        <el-card shadow="never">
          <div slot="header">
            <span>欠款明细</span>
            <el-button size="mini" type="primary" style="float:right" @click="refreshAll">刷新</el-button>
          </div>
          <el-table :data="creditorList" size="small">
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
  mounted() { this.refreshAll() },
  beforeDestroy() {
    if (this.pieChart) { this.pieChart.dispose(); this.pieChart = null }
    if (this.barChart) { this.barChart.dispose(); this.barChart = null }
    if (this.trendChart) { this.trendChart.dispose(); this.trendChart = null }
  },
  methods: {
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
    progressColor(row) { const p = this.calcPercent(row); return p >= 100 ? '#67c23a' : p >= 50 ? '#409eff' : '#e6a23c' },
    initPie() {
      if (!this.$refs.pieChart) return
      if (this.pieChart) this.pieChart.dispose()
      this.pieChart = echarts.init(this.$refs.pieChart)
      this.pieChart.setOption({
        tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
        legend: { bottom: 0, data: ['还款中', '已结清', '逾期'] },
        color: ['#e6a23c', '#67c23a', '#f56c6c'],
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
      if (this.barChart) this.barChart.dispose()
      this.barChart = echarts.init(this.$refs.barChart)
      this.barChart.setOption({
        tooltip: { trigger: 'axis' },
        legend: { data: ['借款总额(万)', '剩余未还(万)'] },
        grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
        xAxis: { type: 'category', data: this.creditorList.map(i => i.name), axisLabel: { rotate: 15 } },
        yAxis: { type: 'value' },
        series: [
          { name: '借款总额(万)', type: 'bar', data: this.creditorList.map(i => (i.loanAmount / 10000).toFixed(2)), itemStyle: { color: '#409eff' } },
          { name: '剩余未还(万)', type: 'bar', data: this.creditorList.map(i => (i.remainingAmount / 10000).toFixed(2)), itemStyle: { color: '#f56c6c' } }
        ]
      })
    },
    initTrend() {
      if (!this.$refs.trendChart) return
      if (this.trendChart) this.trendChart.dispose()
      this.trendChart = echarts.init(this.$refs.trendChart)
      this.trendChart.setOption({
        tooltip: { trigger: 'axis' },
        grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
        xAxis: { type: 'category', data: this.trendList.map(i => i.name) },
        yAxis: { type: 'value', name: '月还款额(元)' },
        series: [{
          type: 'line', name: '月还款额', smooth: true,
          data: this.trendList.map(i => i.value),
          areaStyle: { color: new echarts.graphic.LinearGradient(0,0,0,1, [{offset:0,color:'rgba(64,158,255,0.3)'},{offset:1,color:'rgba(64,158,255,0.05)'}]) },
          itemStyle: { color: '#409eff' }
        }]
      })
    }
  }
}
</script>

<style scoped>
.stats-cards { margin-bottom: 20px }
.stats-cards .card { border-radius: 10px; padding: 20px; color: #fff; text-align: center }
.stats-cards .card-blue { background: linear-gradient(135deg, #409eff, #2d6cbf) }
.stats-cards .card-red { background: linear-gradient(135deg, #f56c6c, #c03636) }
.stats-cards .card-orange { background: linear-gradient(135deg, #e6a23c, #b87e2a) }
.stats-cards .card-green { background: linear-gradient(135deg, #67c23a, #4a8f2a) }
.card-value { font-size: 28px; font-weight: 700; margin-bottom: 6px }
.card-label { font-size: 13px; opacity: .85 }
.chart-row { margin-bottom: 20px }
</style>

<template>
  <div class="app-container middleware-page">
    <!-- 顶栏 -->
    <div class="hero-bar">
      <div class="hero-left">
        <div class="hero-icon"><i class="el-icon-monitor"></i></div>
        <div>
          <h3 class="page-title">中间件监控中心</h3>
          <p class="page-desc">
            实时探测 MySQL / Redis / MinIO / Nacos / Kafka / XXL-Job
            <span v-if="lastTime" class="last-time">· 上次检测 {{ lastTime }}</span>
          </p>
        </div>
      </div>
      <div class="hero-right">
        <div v-if="autoRefresh" class="countdown">{{ countdown }}s 后刷新</div>
        <el-select v-model="refreshInterval" size="small" style="width: 110px; margin-right: 10px" :disabled="!autoRefresh">
          <el-option :value="10" label="每 10 秒" />
          <el-option :value="15" label="每 15 秒" />
          <el-option :value="30" label="每 30 秒" />
          <el-option :value="60" label="每 60 秒" />
        </el-select>
        <el-switch v-model="autoRefresh" active-text="自动" style="margin-right: 12px" />
        <el-button icon="el-icon-refresh" size="small" type="primary" :loading="loading" @click="refreshAll">立即检测</el-button>
      </div>
    </div>

    <!-- 概览 KPI -->
    <el-row :gutter="16" class="kpi-row">
      <el-col :xs="12" :sm="6" :md="4">
        <div class="kpi-card score" :class="scoreLevel">
          <div class="kpi-ring">
            <div ref="scoreChart" class="mini-chart"></div>
          </div>
          <div class="kpi-meta">
            <div class="kpi-label">健康评分</div>
            <div class="kpi-sub">{{ scoreTip }}</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6" :md="5">
        <div class="kpi-card up">
          <div class="kpi-icon"><i class="el-icon-success"></i></div>
          <div>
            <div class="kpi-num">{{ countBy('UP') }}</div>
            <div class="kpi-label">运行正常</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6" :md="5">
        <div class="kpi-card down">
          <div class="kpi-icon"><i class="el-icon-error"></i></div>
          <div>
            <div class="kpi-num">{{ countBy('DOWN') }}</div>
            <div class="kpi-label">连接异常</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="6" :md="5">
        <div class="kpi-card disabled">
          <div class="kpi-icon"><i class="el-icon-remove-outline"></i></div>
          <div>
            <div class="kpi-num">{{ countBy('DISABLED') }}</div>
            <div class="kpi-label">配置关闭</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="5">
        <div class="kpi-card latency">
          <div class="kpi-icon"><i class="el-icon-odometer"></i></div>
          <div>
            <div class="kpi-num">{{ avgLatency }}<small>ms</small></div>
            <div class="kpi-label">平均延迟</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 图表区 -->
    <el-row :gutter="16" class="chart-row">
      <el-col :xs="24" :lg="8">
        <el-card shadow="never" class="chart-card">
          <div slot="header" class="card-hd">
            <span><i class="el-icon-pie-chart"></i> 状态分布</span>
          </div>
          <div ref="pieChart" class="chart-box"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card shadow="never" class="chart-card">
          <div slot="header" class="card-hd">
            <span><i class="el-icon-data-analysis"></i> 延迟对比</span>
          </div>
          <div ref="barChart" class="chart-box"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card shadow="never" class="chart-card">
          <div slot="header" class="card-hd">
            <span><i class="el-icon-data-line"></i> 延迟趋势</span>
            <el-tag size="mini" type="info">最近 {{ historyLabels.length }} 次</el-tag>
          </div>
          <div ref="lineChart" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 中间件卡片 -->
    <div class="section-title">
      <span>组件详情</span>
      <el-radio-group v-model="filterStatus" size="mini">
        <el-radio-button label="ALL">全部</el-radio-button>
        <el-radio-button label="UP">正常</el-radio-button>
        <el-radio-button label="DOWN">异常</el-radio-button>
        <el-radio-button label="DISABLED">关闭</el-radio-button>
      </el-radio-group>
    </div>

    <el-row :gutter="16">
      <el-col
        v-for="item in filteredList"
        :key="item.code"
        :xs="24"
        :sm="12"
        :lg="8"
        class="card-box"
      >
        <el-card shadow="hover" :class="['mw-card', statusClass(item.status)]" v-loading="loading && !list.length">
          <div class="mw-top">
            <div class="mw-identity">
              <div class="mw-avatar" :class="statusClass(item.status)">
                <i :class="iconOf(item.code)"></i>
              </div>
              <div>
                <div class="mw-name">{{ item.name }}</div>
                <div class="mw-type">{{ item.type }}</div>
              </div>
            </div>
            <div class="mw-status-wrap">
              <span class="pulse-dot" :class="statusClass(item.status)"></span>
              <el-tag :type="tagType(item.status)" size="mini" effect="dark">{{ statusText(item.status) }}</el-tag>
            </div>
          </div>

          <div class="mw-gauge-row">
            <div :ref="'gauge_' + item.code" class="gauge-mini"></div>
            <div class="mw-latency-info">
              <div class="lat-val" :class="latencyLevel(item.latencyMs)">
                {{ item.latencyMs != null ? item.latencyMs : '-' }}
                <small v-if="item.latencyMs != null">ms</small>
              </div>
              <div class="lat-label">响应延迟</div>
              <el-progress
                v-if="item.latencyMs != null"
                :percentage="latencyPercent(item.latencyMs)"
                :color="latencyColor(item.latencyMs)"
                :show-text="false"
                :stroke-width="6"
              />
            </div>
          </div>

          <div class="mw-body">
            <div class="mw-row">
              <span class="label"><i class="el-icon-link"></i> 地址</span>
              <span class="value mono" :title="item.endpoint">{{ item.endpoint || '-' }}</span>
            </div>
            <div class="mw-row">
              <span class="label"><i class="el-icon-chat-line-square"></i> 说明</span>
              <span class="value" :title="item.message">{{ item.message || '-' }}</span>
            </div>
            <template v-if="item.detail && Object.keys(item.detail).length">
              <div class="detail-grid">
                <div v-for="(val, key) in item.detail" :key="key" class="detail-item">
                  <div class="d-label">{{ detailLabel(key) }}</div>
                  <div class="d-value" :title="String(val)">{{ formatDetail(val) }}</div>
                </div>
              </div>
            </template>
          </div>

          <div class="mw-footer">
            <el-button type="text" size="mini" icon="el-icon-refresh" @click="refreshOne(item)">重新探测</el-button>
            <el-button type="text" size="mini" icon="el-icon-document-copy" @click="copyEndpoint(item)">复制地址</el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 明细表 -->
    <el-card shadow="never" class="table-card">
      <div slot="header" class="card-hd">
        <span><i class="el-icon-s-grid"></i> 检测明细表</span>
        <el-button type="text" size="mini" icon="el-icon-download" @click="exportCsv">导出 CSV</el-button>
      </div>
      <el-table :data="list" stripe size="small" v-loading="loading" empty-text="暂无数据">
        <el-table-column label="组件" min-width="120">
          <template slot-scope="{ row }">
            <i :class="iconOf(row.code)" style="margin-right: 6px; color: #0071e3"></i>
            <b>{{ row.name }}</b>
          </template>
        </el-table-column>
        <el-table-column prop="type" label="类型" width="130" />
        <el-table-column label="状态" width="100" align="center">
          <template slot-scope="{ row }">
            <el-tag :type="tagType(row.status)" size="mini" effect="plain">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="延迟" width="110" align="center" sortable :sort-method="sortLatency">
          <template slot-scope="{ row }">
            <span :class="['lat-cell', latencyLevel(row.latencyMs)]">
              {{ row.latencyMs != null ? row.latencyMs + ' ms' : '-' }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="endpoint" label="连接地址" min-width="200" show-overflow-tooltip />
        <el-table-column prop="message" label="探测结果" min-width="160" show-overflow-tooltip />
        <el-table-column label="关键指标" min-width="180">
          <template slot-scope="{ row }">
            <span v-if="!row.detail || !Object.keys(row.detail).length" class="text-muted">-</span>
            <el-tag
              v-for="(val, key) in pickDetail(row.detail)"
              :key="key"
              size="mini"
              type="info"
              style="margin: 2px 4px 2px 0"
            >{{ detailLabel(key) }}: {{ formatDetail(val) }}</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import { getMiddleware } from '@/api/monitor/middleware'
import * as echarts from 'echarts'

const DETAIL_LABELS = {
  product: '产品',
  version: '版本',
  driver: '驱动',
  catalog: '库名',
  mode: '模式',
  clients: '连接数',
  usedMemory: '内存',
  uptimeDays: '运行天',
  dbSize: 'Key数',
  bucket: 'Bucket',
  bucketExists: '存在',
  bucketCount: '桶数量'
}

const COLORS = {
  up: '#10b981',
  down: '#ef4444',
  disabled: '#9ca3af',
  brand: '#0071e3',
  warn: '#f59e0b'
}

const MAX_HISTORY = 12

export default {
  name: 'Middleware',
  data() {
    return {
      loading: false,
      list: [],
      autoRefresh: true,
      refreshInterval: 15,
      countdown: 15,
      timer: null,
      countTimer: null,
      lastTime: '',
      filterStatus: 'ALL',
      historyLabels: [],
      historyMap: {},
      charts: {
        score: null,
        pie: null,
        bar: null,
        line: null,
        gauges: {}
      }
    }
  },
  computed: {
    filteredList() {
      if (this.filterStatus === 'ALL') return this.list
      return this.list.filter(i => i.status === this.filterStatus)
    },
    healthScore() {
      const active = this.list.filter(i => i.status !== 'DISABLED')
      if (!active.length) {
        const allDis = this.list.length && this.list.every(i => i.status === 'DISABLED')
        return allDis ? 0 : 100
      }
      const up = active.filter(i => i.status === 'UP').length
      let score = Math.round((up / active.length) * 100)
      // 延迟惩罚
      const lats = active.filter(i => i.latencyMs != null).map(i => i.latencyMs)
      if (lats.length) {
        const avg = lats.reduce((a, b) => a + b, 0) / lats.length
        if (avg > 2000) score = Math.max(0, score - 15)
        else if (avg > 1000) score = Math.max(0, score - 8)
        else if (avg > 500) score = Math.max(0, score - 3)
      }
      return score
    },
    scoreLevel() {
      const s = this.healthScore
      if (s >= 90) return 'excellent'
      if (s >= 70) return 'good'
      if (s >= 40) return 'warn'
      return 'bad'
    },
    scoreTip() {
      return { excellent: '状态优秀', good: '整体良好', warn: '需要关注', bad: '存在故障' }[this.scoreLevel]
    },
    avgLatency() {
      const arr = this.list.filter(i => i.latencyMs != null).map(i => i.latencyMs)
      if (!arr.length) return '-'
      return Math.round(arr.reduce((a, b) => a + b, 0) / arr.length)
    }
  },
  watch: {
    autoRefresh(val) {
      this.resetTimers()
      if (val) this.startTimers()
    },
    refreshInterval() {
      if (this.autoRefresh) {
        this.resetTimers()
        this.startTimers()
      }
    },
    list() {
      this.$nextTick(() => this.renderAllCharts())
    }
  },
  mounted() {
    this.initCharts()
    window.addEventListener('resize', this.handleResize)
    this.refreshAll()
    if (this.autoRefresh) this.startTimers()
  },
  beforeDestroy() {
    this.resetTimers()
    window.removeEventListener('resize', this.handleResize)
    Object.keys(this.charts).forEach(k => {
      if (k === 'gauges') {
        Object.values(this.charts.gauges).forEach(c => c && c.dispose())
      } else if (this.charts[k]) {
        this.charts[k].dispose()
      }
    })
  },
  methods: {
    initCharts() {
      this.charts.score = echarts.init(this.$refs.scoreChart)
      this.charts.pie = echarts.init(this.$refs.pieChart)
      this.charts.bar = echarts.init(this.$refs.barChart)
      this.charts.line = echarts.init(this.$refs.lineChart)
    },
    handleResize() {
      Object.keys(this.charts).forEach(k => {
        if (k === 'gauges') {
          Object.values(this.charts.gauges).forEach(c => c && c.resize())
        } else if (this.charts[k]) {
          this.charts[k].resize()
        }
      })
    },
    startTimers() {
      this.countdown = this.refreshInterval
      this.countTimer = setInterval(() => {
        this.countdown -= 1
        if (this.countdown <= 0) this.countdown = this.refreshInterval
      }, 1000)
      this.timer = setInterval(() => this.refreshAll(true), this.refreshInterval * 1000)
    },
    resetTimers() {
      if (this.timer) clearInterval(this.timer)
      if (this.countTimer) clearInterval(this.countTimer)
      this.timer = null
      this.countTimer = null
      this.countdown = this.refreshInterval
    },
    refreshAll(silent) {
      if (!silent) this.loading = true
      getMiddleware().then(res => {
        this.list = res.data || []
        this.lastTime = this.formatNow()
        this.pushHistory()
        this.loading = false
        if (this.autoRefresh) this.countdown = this.refreshInterval
      }).catch(() => {
        this.loading = false
      })
    },
    refreshOne() {
      this.refreshAll()
    },
    pushHistory() {
      const label = this.formatNow().slice(11, 19)
      this.historyLabels.push(label)
      if (this.historyLabels.length > MAX_HISTORY) this.historyLabels.shift()

      this.list.forEach(item => {
        if (!this.historyMap[item.code]) this.historyMap[item.code] = []
        const arr = this.historyMap[item.code]
        arr.push(item.latencyMs != null ? item.latencyMs : null)
        if (arr.length > MAX_HISTORY) arr.shift()
      })
    },
    renderAllCharts() {
      this.renderScore()
      this.renderPie()
      this.renderBar()
      this.renderLine()
      this.renderGauges()
    },
    renderScore() {
      if (!this.charts.score) return
      const s = this.healthScore
      const color = s >= 90 ? COLORS.up : s >= 70 ? COLORS.brand : s >= 40 ? COLORS.warn : COLORS.down
      this.charts.score.setOption({
        series: [{
          type: 'gauge',
          startAngle: 210,
          endAngle: -30,
          min: 0,
          max: 100,
          radius: '100%',
          center: ['50%', '55%'],
          progress: { show: true, width: 10, itemStyle: { color } },
          axisLine: { lineStyle: { width: 10, color: [[1, '#e5e7eb']] } },
          axisTick: { show: false },
          splitLine: { show: false },
          axisLabel: { show: false },
          pointer: { show: false },
          anchor: { show: false },
          title: { show: false },
          detail: {
            valueAnimation: true,
            fontSize: 22,
            fontWeight: 700,
            color,
            offsetCenter: [0, '10%'],
            formatter: '{value}'
          },
          data: [{ value: s }]
        }]
      }, true)
    },
    renderPie() {
      if (!this.charts.pie) return
      const data = [
        { name: '正常', value: this.countBy('UP'), itemStyle: { color: COLORS.up } },
        { name: '异常', value: this.countBy('DOWN'), itemStyle: { color: COLORS.down } },
        { name: '关闭', value: this.countBy('DISABLED'), itemStyle: { color: COLORS.disabled } }
      ].filter(d => d.value > 0)
      this.charts.pie.setOption({
        tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
        legend: { bottom: 0, textStyle: { color: '#6b7280', fontSize: 12 } },
        series: [{
          type: 'pie',
          radius: ['42%', '68%'],
          center: ['50%', '45%'],
          avoidLabelOverlap: true,
          itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
          label: { show: true, formatter: '{b}\n{c}', fontSize: 12, color: '#374151' },
          data: data.length ? data : [{ name: '暂无', value: 1, itemStyle: { color: '#e5e7eb' } }],
          animationDuration: 800
        }]
      }, true)
    },
    renderBar() {
      if (!this.charts.bar) return
      const names = this.list.map(i => i.name)
      const vals = this.list.map(i => i.latencyMs != null ? i.latencyMs : 0)
      const colors = this.list.map(i => {
        if (i.status === 'DOWN') return COLORS.down
        if (i.status === 'DISABLED') return COLORS.disabled
        if (i.latencyMs == null) return COLORS.disabled
        if (i.latencyMs > 1000) return COLORS.warn
        return COLORS.brand
      })
      this.charts.bar.setOption({
        tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' }, formatter: p => `${p[0].name}<br/>延迟: ${p[0].value} ms` },
        grid: { left: 48, right: 16, top: 24, bottom: 40 },
        xAxis: {
          type: 'category',
          data: names,
          axisLabel: { color: '#6b7280', fontSize: 11, rotate: names.length > 4 ? 20 : 0 },
          axisLine: { lineStyle: { color: '#e5e7eb' } }
        },
        yAxis: {
          type: 'value',
          name: 'ms',
          nameTextStyle: { color: '#9ca3af', fontSize: 11 },
          axisLabel: { color: '#9ca3af' },
          splitLine: { lineStyle: { color: '#f3f4f6', type: 'dashed' } }
        },
        series: [{
          type: 'bar',
          barWidth: 22,
          data: vals.map((v, i) => ({
            value: v,
            itemStyle: {
              color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                { offset: 0, color: colors[i] },
                { offset: 1, color: colors[i] + '99' }
              ]),
              borderRadius: [6, 6, 0, 0]
            }
          })),
          label: { show: true, position: 'top', fontSize: 11, color: '#6b7280', formatter: p => p.value ? p.value : '' }
        }]
      }, true)
    },
    renderLine() {
      if (!this.charts.line) return
      const palette = ['#0071e3', '#10b981', '#f59e0b', '#8b5cf6', '#ef4444', '#06b6d4']
      const series = this.list.map((item, idx) => ({
        name: item.name,
        type: 'line',
        smooth: true,
        showSymbol: true,
        symbolSize: 6,
        data: this.historyMap[item.code] || [],
        lineStyle: { width: 2 },
        itemStyle: { color: palette[idx % palette.length] },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: palette[idx % palette.length] + '33' },
            { offset: 1, color: palette[idx % palette.length] + '05' }
          ])
        }
      }))
      this.charts.line.setOption({
        tooltip: { trigger: 'axis' },
        legend: { bottom: 0, type: 'scroll', textStyle: { fontSize: 11, color: '#6b7280' } },
        grid: { left: 48, right: 16, top: 24, bottom: 48 },
        xAxis: {
          type: 'category',
          data: this.historyLabels,
          boundaryGap: false,
          axisLabel: { color: '#9ca3af', fontSize: 10 },
          axisLine: { lineStyle: { color: '#e5e7eb' } }
        },
        yAxis: {
          type: 'value',
          name: 'ms',
          nameTextStyle: { color: '#9ca3af', fontSize: 11 },
          axisLabel: { color: '#9ca3af' },
          splitLine: { lineStyle: { color: '#f3f4f6', type: 'dashed' } }
        },
        series
      }, true)
    },
    renderGauges() {
      this.list.forEach(item => {
        const refs = this.$refs['gauge_' + item.code]
        const el = Array.isArray(refs) ? refs[0] : refs
        if (!el) return
        if (!this.charts.gauges[item.code]) {
          this.charts.gauges[item.code] = echarts.init(el)
        }
        const chart = this.charts.gauges[item.code]
        const score = item.status === 'UP' ? 100 : item.status === 'DISABLED' ? 30 : 0
        const color = item.status === 'UP' ? COLORS.up : item.status === 'DISABLED' ? COLORS.disabled : COLORS.down
        chart.setOption({
          series: [{
            type: 'gauge',
            startAngle: 90,
            endAngle: -270,
            min: 0,
            max: 100,
            radius: '90%',
            pointer: { show: false },
            progress: { show: true, overlap: false, roundCap: true, clip: false, width: 8, itemStyle: { color } },
            axisLine: { lineStyle: { width: 8, color: [[1, '#f3f4f6']] } },
            splitLine: { show: false },
            axisTick: { show: false },
            axisLabel: { show: false },
            title: { show: false },
            detail: {
              fontSize: 13,
              fontWeight: 600,
              color,
              offsetCenter: [0, '0%'],
              formatter: () => item.status === 'UP' ? 'OK' : item.status === 'DISABLED' ? 'OFF' : 'ERR'
            },
            data: [{ value: score }]
          }]
        }, true)
      })
    },
    countBy(status) {
      return this.list.filter(i => i.status === status).length
    },
    statusText(s) {
      return { UP: '正常', DOWN: '异常', DISABLED: '已关闭', UNKNOWN: '未知' }[s] || s
    },
    tagType(s) {
      return { UP: 'success', DOWN: 'danger', DISABLED: 'info', UNKNOWN: 'warning' }[s] || 'info'
    },
    statusClass(s) {
      return { UP: 'is-up', DOWN: 'is-down', DISABLED: 'is-disabled' }[s] || ''
    },
    iconOf(code) {
      return {
        mysql: 'el-icon-coin',
        redis: 'el-icon-s-data',
        minio: 'el-icon-folder-opened',
        nacos: 'el-icon-connection',
        kafka: 'el-icon-message-solid',
        'xxl-job': 'el-icon-timer'
      }[code] || 'el-icon-monitor'
    },
    detailLabel(key) {
      return DETAIL_LABELS[key] || key
    },
    formatDetail(val) {
      if (typeof val === 'boolean') return val ? '是' : '否'
      return val
    },
    pickDetail(detail) {
      if (!detail) return {}
      const keys = Object.keys(detail).slice(0, 3)
      const o = {}
      keys.forEach(k => { o[k] = detail[k] })
      return o
    },
    latencyLevel(ms) {
      if (ms == null) return ''
      if (ms > 1000) return 'bad'
      if (ms > 300) return 'warn'
      return 'good'
    },
    latencyPercent(ms) {
      if (ms == null) return 0
      return Math.min(100, Math.round(ms / 20))
    },
    latencyColor(ms) {
      if (ms > 1000) return COLORS.down
      if (ms > 300) return COLORS.warn
      return COLORS.up
    },
    sortLatency(a, b) {
      return (a.latencyMs || 0) - (b.latencyMs || 0)
    },
    formatNow() {
      const d = new Date()
      const p = n => (n < 10 ? '0' + n : '' + n)
      return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`
    },
    copyEndpoint(item) {
      const text = item.endpoint || ''
      if (!text || text === '-') {
        this.$message.warning('无地址可复制')
        return
      }
      if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(() => this.$message.success('已复制')).catch(() => this.fallbackCopy(text))
      } else {
        this.fallbackCopy(text)
      }
    },
    fallbackCopy(text) {
      const ta = document.createElement('textarea')
      ta.value = text
      document.body.appendChild(ta)
      ta.select()
      document.execCommand('copy')
      document.body.removeChild(ta)
      this.$message.success('已复制')
    },
    exportCsv() {
      if (!this.list.length) {
        this.$message.warning('暂无数据')
        return
      }
      const header = ['组件', '类型', '状态', '延迟(ms)', '地址', '说明']
      const rows = this.list.map(i => [
        i.name, i.type, this.statusText(i.status),
        i.latencyMs != null ? i.latencyMs : '',
        (i.endpoint || '').replace(/,/g, ';'),
        (i.message || '').replace(/,/g, ';')
      ])
      const csv = [header, ...rows].map(r => r.join(',')).join('\n')
      const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `middleware_${Date.now()}.csv`
      a.click()
      URL.revokeObjectURL(url)
    }
  }
}
</script>

<style lang="scss" scoped>
@import '~@/assets/styles/variables.scss';

.middleware-page {
  .hero-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: $space-4;
    margin-bottom: $space-5;
    padding: $space-5 $space-6;
    background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 55%, #0c4a6e 100%);
    border-radius: $radius-lg;
    color: #fff;
    box-shadow: 0 8px 24px rgba(15, 23, 42, 0.25);
  }

  .hero-left {
    display: flex;
    align-items: center;
    gap: $space-4;
  }

  .hero-icon {
    width: 48px;
    height: 48px;
    border-radius: 14px;
    background: rgba(255, 255, 255, 0.12);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
  }

  .page-title {
    margin: 0 0 4px;
    font-size: 20px;
    font-weight: 700;
    color: #fff;
  }

  .page-desc {
    margin: 0;
    font-size: 13px;
    color: rgba(255, 255, 255, 0.7);
  }

  .last-time { color: rgba(255, 255, 255, 0.55); }

  .hero-right {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 4px;

    ::v-deep .el-switch__label { color: rgba(255, 255, 255, 0.75); }
    ::v-deep .el-switch__label.is-active { color: #fff; }
    ::v-deep .el-input__inner {
      background: rgba(255, 255, 255, 0.1);
      border-color: rgba(255, 255, 255, 0.2);
      color: #fff;
    }
  }

  .countdown {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.65);
    margin-right: 8px;
    font-variant-numeric: tabular-nums;
  }

  // KPI
  .kpi-row { margin-bottom: $space-2; }

  .kpi-card {
    display: flex;
    align-items: center;
    gap: $space-3;
    background: $bg-surface;
    border: 1px solid $border-lighter;
    border-radius: $radius-lg;
    padding: $space-4;
    margin-bottom: $space-4;
    min-height: 88px;
    transition: transform 0.2s, box-shadow 0.2s;

    &:hover {
      transform: translateY(-2px);
      box-shadow: $shadow-md;
    }

    .kpi-icon {
      width: 44px;
      height: 44px;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 22px;
      flex-shrink: 0;
    }

    .kpi-num {
      font-size: 28px;
      font-weight: 700;
      line-height: 1.1;
      color: $text-primary;

      small {
        font-size: 13px;
        font-weight: 500;
        margin-left: 2px;
        color: $text-secondary;
      }
    }

    .kpi-label {
      font-size: 12px;
      color: $text-secondary;
      margin-top: 2px;
    }

    .kpi-sub {
      font-size: 12px;
      color: $text-secondary;
    }

    .kpi-ring {
      width: 72px;
      height: 72px;
      flex-shrink: 0;
    }

    .mini-chart {
      width: 100%;
      height: 100%;
    }

    &.up .kpi-icon { background: rgba(16, 185, 129, 0.12); color: $success; }
    &.up .kpi-num { color: $success; }
    &.down .kpi-icon { background: rgba(239, 68, 68, 0.12); color: $danger; }
    &.down .kpi-num { color: $danger; }
    &.disabled .kpi-icon { background: $gray-100; color: $gray-400; }
    &.disabled .kpi-num { color: $gray-400; }
    &.latency .kpi-icon { background: rgba(0, 113, 227, 0.1); color: $brand; }
    &.latency .kpi-num { color: $brand; }

    &.score.excellent .kpi-label { color: $success; }
    &.score.good .kpi-label { color: $brand; }
    &.score.warn .kpi-label { color: $warning; }
    &.score.bad .kpi-label { color: $danger; }
  }

  // charts
  .chart-row { margin-bottom: $space-2; }

  .chart-card {
    margin-bottom: $space-4;
    border-radius: $radius-lg !important;
    border: 1px solid $border-lighter !important;

    ::v-deep .el-card__header {
      padding: 14px 18px;
      border-bottom: 1px solid $border-lighter;
    }

    ::v-deep .el-card__body {
      padding: 8px 12px 12px;
    }
  }

  .card-hd {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-weight: 600;
    font-size: 14px;
    color: $text-primary;

    i {
      margin-right: 6px;
      color: $brand;
    }
  }

  .chart-box {
    height: 260px;
    width: 100%;
  }

  .section-title {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin: $space-2 0 $space-4;
    font-size: 16px;
    font-weight: 600;
    color: $text-primary;
  }

  // middleware cards
  .mw-card {
    margin-bottom: $space-4;
    border-radius: $radius-lg !important;
    border: 1px solid $border-lighter !important;
    overflow: hidden;
    transition: box-shadow 0.25s, transform 0.25s;

    &:hover {
      box-shadow: $shadow-lg !important;
      transform: translateY(-2px);
    }

    &.is-up { border-top: 3px solid $success !important; }
    &.is-down { border-top: 3px solid $danger !important; }
    &.is-disabled { border-top: 3px solid $gray-300 !important; }

    ::v-deep .el-card__body {
      padding: $space-5;
    }
  }

  .mw-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: $space-4;
  }

  .mw-identity {
    display: flex;
    align-items: center;
    gap: $space-3;
  }

  .mw-avatar {
    width: 44px;
    height: 44px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    background: $brand-bg;
    color: $brand;

    &.is-up { background: rgba(16, 185, 129, 0.12); color: $success; }
    &.is-down { background: rgba(239, 68, 68, 0.12); color: $danger; }
    &.is-disabled { background: $gray-100; color: $gray-400; }
  }

  .mw-name {
    font-size: 16px;
    font-weight: 700;
    color: $text-primary;
  }

  .mw-type {
    font-size: 12px;
    color: $text-secondary;
    margin-top: 2px;
  }

  .mw-status-wrap {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .pulse-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: $gray-300;

    &.is-up {
      background: $success;
      box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.5);
      animation: pulse-green 2s infinite;
    }
    &.is-down {
      background: $danger;
      animation: pulse-red 1.5s infinite;
    }
  }

  .mw-gauge-row {
    display: flex;
    align-items: center;
    gap: $space-4;
    padding: $space-3;
    background: $bg-subtle;
    border-radius: $radius-base;
    margin-bottom: $space-4;
  }

  .gauge-mini {
    width: 72px;
    height: 72px;
    flex-shrink: 0;
  }

  .mw-latency-info {
    flex: 1;
    min-width: 0;

    .lat-val {
      font-size: 26px;
      font-weight: 700;
      line-height: 1.1;
      color: $text-primary;

      small {
        font-size: 12px;
        font-weight: 500;
        margin-left: 2px;
        color: $text-secondary;
      }

      &.good { color: $success; }
      &.warn { color: $warning; }
      &.bad { color: $danger; }
    }

    .lat-label {
      font-size: 12px;
      color: $text-secondary;
      margin: 4px 0 8px;
    }
  }

  .mw-body {
    .mw-row {
      display: flex;
      align-items: flex-start;
      padding: 8px 0;
      border-bottom: 1px dashed $border-lighter;
      font-size: 13px;

      .label {
        width: 64px;
        flex-shrink: 0;
        color: $text-secondary;

        i { margin-right: 4px; }
      }

      .value {
        flex: 1;
        min-width: 0;
        color: $text-primary;
        word-break: break-all;
        font-weight: 500;

        &.mono {
          font-family: $font-mono;
          font-size: 12px;
        }
      }
    }
  }

  .detail-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
    margin-top: 12px;
  }

  .detail-item {
    background: $bg-subtle;
    border-radius: 8px;
    padding: 8px 10px;

    .d-label {
      font-size: 11px;
      color: $text-secondary;
      margin-bottom: 2px;
    }

    .d-value {
      font-size: 13px;
      font-weight: 600;
      color: $text-primary;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }

  .mw-footer {
    margin-top: 12px;
    padding-top: 10px;
    border-top: 1px solid $border-lighter;
    display: flex;
    justify-content: flex-end;
    gap: 4px;
  }

  .table-card {
    margin-top: $space-2;
    border-radius: $radius-lg !important;
    border: 1px solid $border-lighter !important;

    ::v-deep .el-card__header {
      padding: 14px 18px;
    }
  }

  .lat-cell {
    font-weight: 600;
    &.good { color: $success; }
    &.warn { color: $warning; }
    &.bad { color: $danger; }
  }

  .text-muted { color: $gray-400; }
}

@keyframes pulse-green {
  0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.5); }
  70% { box-shadow: 0 0 0 8px rgba(16, 185, 129, 0); }
  100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
}

@keyframes pulse-red {
  0% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.5); }
  70% { box-shadow: 0 0 0 8px rgba(239, 68, 68, 0); }
  100% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
}

@media (max-width: 768px) {
  .middleware-page {
    .hero-bar { padding: 16px; }
    .chart-box { height: 220px; }
  }
}
</style>

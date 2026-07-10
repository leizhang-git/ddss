<template>
  <div class="dashboard-container">
    <!-- 顶部统计卡片 -->
    <el-row :gutter="24" class="stats-row">
      <el-col :xs="24" :sm="12" :lg="6">
        <div class="stat-card stat-card-blue">
          <div class="stat-card-inner">
            <div class="stat-icon">
              <svg-icon icon-class="video"/>
            </div>
            <div class="stat-content">
              <div class="stat-label">视频资源</div>
              <div class="stat-value">
                <count-to :start-val="0" :end-val="1256" :duration="2000"/>
              </div>
              <div class="stat-trend up">
                <i class="el-icon-top"></i> 12.5%
              </div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :lg="6">
        <div class="stat-card stat-card-green">
          <div class="stat-card-inner">
            <div class="stat-icon">
              <svg-icon icon-class="peoples"/>
            </div>
            <div class="stat-content">
              <div class="stat-label">用户总数</div>
              <div class="stat-value">
                <count-to :start-val="0" :end-val="3842" :duration="2000"/>
              </div>
              <div class="stat-trend up">
                <i class="el-icon-top"></i> 8.2%
              </div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :lg="6">
        <div class="stat-card stat-card-orange">
          <div class="stat-card-inner">
            <div class="stat-icon">
              <svg-icon icon-class="message"/>
            </div>
            <div class="stat-content">
              <div class="stat-label">系统消息</div>
              <div class="stat-value">
                <count-to :start-val="0" :end-val="156" :duration="2000"/>
              </div>
              <div class="stat-trend down">
                <i class="el-icon-bottom"></i> 3.1%
              </div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :lg="6">
        <div class="stat-card stat-card-purple">
          <div class="stat-card-inner">
            <div class="stat-icon">
              <svg-icon icon-class="server"/>
            </div>
            <div class="stat-content">
              <div class="stat-label">服务器</div>
              <div class="stat-value server-status">
                <span class="dot online"></span> 正常
              </div>
              <div class="stat-trend">
                运行 32天
              </div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="24" class="chart-row">
      <el-col :xs="24" :lg="16">
        <el-card shadow="never" class="chart-card">
          <div slot="header" class="card-header">
            <span class="card-title">数据趋势</span>
            <el-radio-group v-model="chartPeriod" size="mini" @change="updateLineChart">
              <el-radio-button label="week">近7天</el-radio-button>
              <el-radio-button label="month">近30天</el-radio-button>
            </el-radio-group>
          </div>
          <line-chart :chart-data="lineChartData" height="320px"/>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card shadow="never" class="chart-card">
          <div slot="header" class="card-header">
            <span class="card-title">资源分类占比</span>
          </div>
          <pie-chart height="320px" class="pie-chart-wrapper"/>
        </el-card>
      </el-col>
    </el-row>

    <!-- 底部信息 -->
    <el-row :gutter="24" class="bottom-row">
      <el-col :xs="24" :lg="8">
        <el-card shadow="never" class="chart-card">
          <div slot="header" class="card-header">
            <span class="card-title">系统信息</span>
          </div>
          <div class="system-info">
            <div class="info-item">
              <span class="info-label">系统名称</span>
              <span class="info-value">DDSS 管理系统</span>
            </div>
            <div class="info-item">
              <span class="info-label">版本号</span>
              <el-tag size="small" type="success">v{{ version }}</el-tag>
            </div>
            <div class="info-item">
              <span class="info-label">前端技术</span>
              <span class="info-value">Vue 2 + Element UI</span>
            </div>
            <div class="info-item">
              <span class="info-label">后端框架</span>
              <span class="info-value">Spring Boot</span>
            </div>
            <div class="info-item">
              <span class="info-label">数据库</span>
              <span class="info-value">MySQL + Redis</span>
            </div>
            <div class="info-item">
              <span class="info-label">运行环境</span>
              <span class="info-value" :style="{color: '#34c759'}">正常运行中</span>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card shadow="never" class="chart-card">
          <div slot="header" class="card-header">
            <span class="card-title">快捷操作</span>
          </div>
          <div class="quick-actions">
            <div class="action-item" @click="$router.push('/video')">
              <div class="action-icon bg-blue">
                <svg-icon icon-class="video"/>
              </div>
              <span>视频管理</span>
            </div>
            <div class="action-item" @click="goUser">
              <div class="action-icon bg-green">
                <svg-icon icon-class="user"/>
              </div>
              <span>用户管理</span>
            </div>
            <div class="action-item" @click="goSystem">
              <div class="action-icon bg-orange">
                <svg-icon icon-class="system"/>
              </div>
              <span>系统管理</span>
            </div>
            <div class="action-item" @click="goMonitor">
              <div class="action-icon bg-purple">
                <svg-icon icon-class="monitor"/>
              </div>
              <span>系统监控</span>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card shadow="never" class="chart-card">
          <div slot="header" class="card-header">
            <span class="card-title">DDSS 数据驱动决策系统</span>
          </div>
          <div class="about-section">
            <p class="about-text">
              DDSS (Data-Driven Decision Support System) 是一款面向企业级应用的综合管理平台，
              提供视频资源管理、用户管理、系统监控等功能模块。
            </p>
            <div class="tech-tags">
              <el-tag size="small" type="">Spring Boot</el-tag>
              <el-tag size="small" type="success">Vue 2</el-tag>
              <el-tag size="small" type="warning">Element UI</el-tag>
              <el-tag size="small" type="danger">MyBatis-Plus</el-tag>
              <el-tag size="small" type="info">Redis</el-tag>
              <el-tag size="small" type="">ECharts</el-tag>
              <el-tag size="small" type="success">MinIO</el-tag>
              <el-tag size="small" type="warning">Nacos</el-tag>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import CountTo from 'vue-count-to'
import LineChart from './dashboard/LineChart'
import PieChart from './dashboard/PieChart'

const weekExpected = [200, 230, 310, 280, 350, 400, 380]
const weekActual = [180, 250, 290, 300, 320, 380, 420]
const monthExpected = [150, 180, 220, 260, 240, 300, 350, 280, 320, 360, 400, 380, 420, 450, 470, 500, 480, 520, 550, 530, 570, 600, 620, 650, 630, 660, 690, 720, 700, 750]
const monthActual = [120, 160, 200, 240, 220, 280, 330, 300, 310, 340, 380, 400, 410, 430, 460, 480, 500, 510, 540, 550, 560, 580, 610, 640, 650, 670, 680, 700, 720, 780]

export default {
  name: 'Index',
  components: {
    CountTo,
    LineChart,
    PieChart
  },
  data() {
    return {
      version: '1.0.0',
      chartPeriod: 'week',
      lineChartData: {
        expectedData: weekExpected,
        actualData: weekActual
      }
    }
  },
  methods: {
    updateLineChart(period) {
      if (period === 'week') {
        this.lineChartData = {
          expectedData: weekExpected,
          actualData: weekActual
        }
      } else {
        this.lineChartData = {
          expectedData: monthExpected,
          actualData: monthActual
        }
      }
    },
    goUser() {
      this.$router.push('/system/user')
    },
    goSystem() {
      this.$router.push('/system/menu')
    },
    goMonitor() {
      this.$router.push('/monitor/server')
    }
  }
}
</script>

<style lang="scss" scoped>
@import '~@/assets/styles/variables.scss';

.dashboard-container {
  padding: $space-6;
  background: $bg-base;
  min-height: calc(100vh - #{$header-height} - #{$tags-height});

  // 统计卡片
  .stats-row {
    margin-bottom: $space-6;

    .stat-card {
      border-radius: $radius-lg;
      overflow: hidden;
      transition: all $duration-base $ease;
      margin-bottom: $space-4;

      &:hover {
        transform: translateY(-4px);
        box-shadow: $shadow-lg;
      }

      .stat-card-inner {
        padding: $space-6;
        display: flex;
        align-items: center;
        color: #fff;
        position: relative;
        overflow: hidden;

        &::after {
          content: '';
          position: absolute;
          right: -15px;
          top: -15px;
          width: 80px;
          height: 80px;
          border-radius: 50%;
          background: rgba(255, 255, 255, 0.1);
        }
      }

      .stat-icon {
        width: 56px;
        height: 56px;
        border-radius: $radius-base;
        background: rgba(255, 255, 255, 0.2);
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: $space-4;
        flex-shrink: 0;

        .svg-icon {
          font-size: 28px;
          width: 28px;
          height: 28px;
        }
      }

      .stat-content {
        flex: 1;
        min-width: 0;

        .stat-label {
          font-size: $fs-sm;
          opacity: 0.85;
          margin-bottom: $space-1;
        }

        .stat-value {
          font-size: $fs-3xl;
          font-weight: $fw-bold;
          line-height: 1.2;
        }

        .server-status {
          font-size: $fs-lg;
          display: flex;
          align-items: center;
          gap: $space-2;

          .dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            display: inline-block;

            &.online {
              background: #fff;
              box-shadow: 0 0 8px rgba(255, 255, 255, 0.6);
              animation: pulse-dot 2s infinite;
            }
          }
        }

        .stat-trend {
          font-size: $fs-xs;
          margin-top: $space-1;
          opacity: 0.9;

          &.up { color: rgba(255, 255, 255, 0.95); }
          &.down { color: rgba(255, 255, 255, 0.8); }
        }
      }
    }

    .stat-card-blue   { background: linear-gradient(135deg, #0071e3, #2997ff); }
    .stat-card-green  { background: linear-gradient(135deg, #34c759, #30d158); }
    .stat-card-orange { background: linear-gradient(135deg, #ff9f0a, #ffd60a); }
    .stat-card-purple { background: linear-gradient(135deg, #5e5ce6, #8e8e93); }
  }

  .chart-row {
    margin-bottom: $space-6;
  }

  .bottom-row {
    margin-bottom: $space-6;
  }

  .chart-card {
    border-radius: $radius-lg;
    overflow: hidden;
    margin-bottom: $space-4;
    border: none;
    box-shadow: $shadow-xs;

    ::v-deep .el-card__header {
      border-bottom: 1px solid $border-lighter;
      padding: $space-4 $space-5;
    }

    ::v-deep .el-card__body {
      padding: $space-5;
    }

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;

      .card-title {
        font-size: $fs-md;
        font-weight: $fw-semibold;
        color: $text-primary;
        position: relative;
        padding-left: $space-3;

        &::before {
          content: '';
          position: absolute;
          left: 0;
          top: 50%;
          transform: translateY(-50%);
          width: 3px;
          height: 16px;
          background: $brand;
          border-radius: $radius-full;
        }
      }
    }

    .pie-chart-wrapper {
      display: flex;
      justify-content: center;
    }
  }

  // 系统信息
  .system-info {
    .info-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: $space-3 0;
      border-bottom: 1px dashed $border-lighter;

      &:last-child {
        border-bottom: none;
      }

      .info-label {
        color: $text-secondary;
        font-size: $fs-sm;
      }

      .info-value {
        color: $text-primary;
        font-size: $fs-sm;
        font-weight: $fw-medium;
      }
    }
  }

  // 快捷操作
  .quick-actions {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: $space-4;

    .action-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: $space-4 $space-2;
      border-radius: $radius-base;
      cursor: pointer;
      transition: all $duration-base $ease;
      background: $bg-subtle;

      &:hover {
        background: $brand-bg;
        transform: translateY(-2px);
        box-shadow: $shadow-sm;

        .action-icon {
          transform: scale(1.1);
        }
      }

      .action-icon {
        width: 44px;
        height: 44px;
        border-radius: $radius-sm;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: $space-2;
        transition: transform $duration-base $ease;

        &.bg-blue   { background: rgba(0, 113, 227, 0.1); }
        &.bg-green  { background: rgba(52, 199, 89, 0.1); }
        &.bg-orange { background: rgba(255, 159, 10, 0.1); }
        &.bg-purple { background: rgba(94, 92, 230, 0.1); }

        .svg-icon {
          font-size: 22px;
          width: 22px;
          height: 22px;
        }
      }

      span {
        font-size: $fs-xs;
        color: $text-secondary;
        font-weight: $fw-medium;
      }
    }
  }

  // 关于
  .about-section {
    .about-text {
      color: $text-secondary;
      font-size: $fs-sm;
      line-height: 1.8;
      margin: 0 0 $space-4 0;
    }

    .tech-tags {
      display: flex;
      flex-wrap: wrap;
      gap: $space-2;

      .el-tag {
        border-radius: $radius-xs;
      }
    }
  }
}

@keyframes pulse-dot {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

@media (max-width: 768px) {
  .dashboard-container {
    padding: $space-4;

    .quick-actions {
      grid-template-columns: repeat(2, 1fr);
    }
  }
}
</style>

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
              <span class="info-value" :style="{color: '#10b981'}">正常运行中</span>
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
.dashboard-container {
  padding: 24px;
  background: #F3F4F6;
  min-height: calc(100vh - 84px);

  // 统计卡片
  .stats-row {
    margin-bottom: 24px;

    .stat-card {
      border-radius: 12px;
      overflow: hidden;
      transition: all 0.3s ease;
      margin-bottom: 16px;

      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
      }

      .stat-card-inner {
        padding: 24px;
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
        border-radius: 12px;
        background: rgba(255, 255, 255, 0.2);
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 16px;
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
          font-size: 13px;
          opacity: 0.85;
          margin-bottom: 4px;
        }

        .stat-value {
          font-size: 26px;
          font-weight: 700;
          line-height: 1.2;
        }

        .server-status {
          font-size: 16px;
          display: flex;
          align-items: center;
          gap: 6px;

          .dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            display: inline-block;

            &.online {
              background: #10b981;
              box-shadow: 0 0 8px rgba(16, 185, 129, 0.6);
              animation: pulse-dot 2s infinite;
            }
          }
        }

        .stat-trend {
          font-size: 12px;
          margin-top: 4px;
          opacity: 0.9;

          &.up {
            color: rgba(255, 255, 255, 0.95);
          }

          &.down {
            color: rgba(255, 255, 255, 0.8);
          }
        }
      }
    }

    .stat-card-blue {
      background: linear-gradient(135deg, #4f46e5, #6366f1);
    }

    .stat-card-green {
      background: linear-gradient(135deg, #10b981, #34d399);
    }

    .stat-card-orange {
      background: linear-gradient(135deg, #f59e0b, #fbbf24);
    }

    .stat-card-purple {
      background: linear-gradient(135deg, #8b5cf6, #a78bfa);
    }
  }

  // 图表卡片
  .chart-row {
    margin-bottom: 24px;
  }

  .bottom-row {
    margin-bottom: 24px;
  }

  .chart-card {
    border-radius: 12px;
    overflow: hidden;
    margin-bottom: 16px;
    border: none;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);

    ::v-deep .el-card__header {
      border-bottom: 1px solid #f0f2f5;
      padding: 16px 20px;
    }

    ::v-deep .el-card__body {
      padding: 20px;
    }

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;

      .card-title {
        font-size: 16px;
        font-weight: 600;
        color: #303133;
        position: relative;
        padding-left: 12px;

        &::before {
          content: '';
          position: absolute;
          left: 0;
          top: 50%;
          transform: translateY(-50%);
          width: 3px;
          height: 16px;
          background: #4f46e5;
          border-radius: 2px;
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
      padding: 10px 0;
      border-bottom: 1px dashed #ebeef5;

      &:last-child {
        border-bottom: none;
      }

      .info-label {
        color: #6B7280;
        font-size: 13px;
      }

      .info-value {
        color: #303133;
        font-size: 13px;
        font-weight: 500;
      }
    }
  }

  // 快捷操作
  .quick-actions {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;

    .action-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 16px 8px;
      border-radius: 10px;
      cursor: pointer;
      transition: all 0.3s ease;
      background: #fafafa;

      &:hover {
        background: #EEF2FF;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(79, 70, 229, 0.15);

        .action-icon {
          transform: scale(1.1);
        }
      }

      .action-icon {
        width: 44px;
        height: 44px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 8px;
        transition: transform 0.3s ease;

        &.bg-blue {
          background: rgba(79, 70, 229, 0.1);
        }

        &.bg-green {
          background: rgba(16, 185, 129, 0.1);
        }

        &.bg-orange {
          background: rgba(245, 158, 11, 0.1);
        }

        &.bg-purple {
          background: rgba(139, 92, 246, 0.1);
        }

        .svg-icon {
          font-size: 22px;
          width: 22px;
          height: 22px;
        }
      }

      span {
        font-size: 12px;
        color: #606266;
        font-weight: 500;
      }
    }
  }

  // 关于
  .about-section {
    .about-text {
      color: #606266;
      font-size: 13px;
      line-height: 1.8;
      margin: 0 0 16px 0;
    }

    .tech-tags {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;

      .el-tag {
        border-radius: 4px;
      }
    }
  }
}

@keyframes pulse-dot {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.4;
  }
}

@media (max-width: 768px) {
  .dashboard-container {
    padding: 12px;

    .quick-actions {
      grid-template-columns: repeat(2, 1fr);
    }
  }
}
</style>

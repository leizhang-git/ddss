<template>
  <div :class="className" :style="{height:height,width:width}"/>
</template>

<script>
import * as echarts from 'echarts'
import resize from './mixins/resize'

require('echarts/theme/macarons')

export default {
  mixins: [resize],
  props: {
    className: {
      type: String,
      default: 'chart'
    },
    width: {
      type: String,
      default: '100%'
    },
    height: {
      type: String,
      default: '300px'
    }
  },
  data() {
    return {
      chart: null
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.initChart()
    })
  },
  beforeDestroy() {
    if (!this.chart) {
      return
    }
    this.chart.dispose()
    this.chart = null
  },
  methods: {
    initChart() {
      this.chart = echarts.init(this.$el, 'macarons')

      this.chart.setOption({
        tooltip: {
          trigger: 'item',
          formatter: '{a} <br/>{b} : {c} ({d}%)'
        },
        legend: {
          left: 'center',
          bottom: '10',
          data: ['监控视频', '宣传视频', '培训视频', '会议视频', '其他'],
          textStyle: {
            color: '#606266'
          }
        },
        color: ['#4f46e5', '#10b981', '#f59e0b', '#8b5cf6', '#ef4444'],
        series: [
          {
            name: '资源分类',
            type: 'pie',
            roseType: 'radius',
            radius: [15, 85],
            center: ['50%', '42%'],
            data: [
              {value: 520, name: '监控视频'},
              {value: 340, name: '宣传视频'},
              {value: 210, name: '培训视频'},
              {value: 120, name: '会议视频'},
              {value: 66, name: '其他'}
            ],
            animationEasing: 'cubicInOut',
            animationDuration: 2600,
            itemStyle: {
              borderRadius: 4,
              borderColor: '#fff',
              borderWidth: 2
            }
          }
        ]
      })
    }
  }
}
</script>

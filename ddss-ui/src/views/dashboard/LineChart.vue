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
      default: '350px'
    },
    autoResize: {
      type: Boolean,
      default: true
    },
    chartData: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      chart: null
    }
  },
  watch: {
    chartData: {
      deep: true,
      handler(val) {
        this.setOptions(val)
      }
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
      this.setOptions(this.chartData)
    },
    setOptions({expectedData, actualData, xAxisData} = {}) {
      const labels = xAxisData || ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      this.chart.setOption({
        xAxis: {
          data: labels,
          boundaryGap: false,
          axisTick: {
            show: false
          },
          axisLine: {
            lineStyle: {
              color: '#dcdfe6'
            }
          },
          axisLabel: {
            color: '#9CA3AF'
          }
        },
        grid: {
          left: 10,
          right: 20,
          bottom: 20,
          top: 30,
          containLabel: true
        },
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'cross'
          },
          padding: [5, 10]
        },
        yAxis: {
          axisTick: {
            show: false
          },
          axisLine: {
            show: false
          },
          splitLine: {
            lineStyle: {
              color: '#F3F4F6'
            }
          }
        },
        legend: {
          data: ['棰勬湡鏁版嵁', '瀹為檯鏁版嵁'],
          textStyle: {
            color: '#606266'
          }
        },
        series: [{
          name: '棰勬湡鏁版嵁',
          itemStyle: {
            normal: {
              color: '#0071e3',
              lineStyle: {
                color: '#0071e3',
                width: 2
              }
            }
          },
          smooth: true,
          type: 'line',
          data: expectedData,
          animationDuration: 2800,
          animationEasing: 'cubicInOut'
        },
        {
          name: '瀹為檯鏁版嵁',
          smooth: true,
          type: 'line',
          itemStyle: {
            normal: {
              color: '#34c759',
              lineStyle: {
                color: '#34c759',
                width: 2
              },
              areaStyle: {
                color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                  {offset: 0, color: 'rgba(16, 185, 129, 0.2)'},
                  {offset: 1, color: 'rgba(16, 185, 129, 0.02)'}
                ])
              }
            }
          },
          data: actualData,
          animationDuration: 2800,
          animationEasing: 'quadraticOut'
        }]
      })
    }
  }
}
</script>

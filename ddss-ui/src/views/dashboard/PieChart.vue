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
          data: ['鐩戞帶瑙嗛', '瀹ｄ紶瑙嗛', '鍩硅瑙嗛', '浼氳瑙嗛', '鍏朵粬'],
          textStyle: {
            color: '#606266'
          }
        },
        color: ['#0071e3', '#34c759', '#ff9f0a', '#2997ff', '#ff3b30'],
        series: [
          {
            name: '璧勬簮鍒嗙被',
            type: 'pie',
            roseType: 'radius',
            radius: [15, 85],
            center: ['50%', '42%'],
            data: [
              {value: 520, name: '鐩戞帶瑙嗛'},
              {value: 340, name: '瀹ｄ紶瑙嗛'},
              {value: 210, name: '鍩硅瑙嗛'},
              {value: 120, name: '浼氳瑙嗛'},
              {value: 66, name: '鍏朵粬'}
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

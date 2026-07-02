import request from '@/utils/request'

// 查询财务列表
export function listFinance(query) {
  return request({ url: '/finance/list', method: 'get', params: query })
}

// 查询财务详细
export function getFinance(financeId) {
  return request({ url: '/finance/' + financeId, method: 'get' })
}

// 新增
export function addFinance(data) {
  return request({ url: '/finance', method: 'post', data })
}

// 修改
export function updateFinance(data) {
  return request({ url: '/finance', method: 'put', data })
}

// 删除
export function delFinance(financeId) {
  return request({ url: '/finance/' + financeId, method: 'delete' })
}

// 统计汇总
export function getSummary() {
  return request({ url: '/finance/summary', method: 'get' })
}

// 按欠款方分组
export function getGroupByCreditor() {
  return request({ url: '/finance/groupByCreditor', method: 'get' })
}

// 月还款趋势
export function getMonthlyTrend() {
  return request({ url: '/finance/monthlyTrend', method: 'get' })
}

// 导出Excel
export function exportFinance() {
  return request({ url: '/finance/export', method: 'get', responseType: 'blob' })
}

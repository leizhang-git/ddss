import request from '@/utils/request'

// 获取中间件状态
export function getMiddleware() {
  return request({
    url: '/monitor/middleware',
    method: 'get'
  })
}

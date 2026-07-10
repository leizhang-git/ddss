import request from '@/utils/request'

// SQL记录列表
export function listSqlRecord(query) {
  return request({
    url: '/system/sqlRecord/list',
    method: 'get',
    params: query
  })
}

// SQL记录详情
export function getSqlRecord(sqlId) {
  return request({
    url: '/system/sqlRecord/' + sqlId,
    method: 'get'
  })
}

// 新增SQL记录
export function addSqlRecord(data) {
  return request({
    url: '/system/sqlRecord',
    method: 'post',
    data: data
  })
}

// 修改SQL记录
export function updateSqlRecord(data) {
  return request({
    url: '/system/sqlRecord',
    method: 'put',
    data: data
  })
}

// 删除SQL记录
export function delSqlRecord(sqlIds) {
  return request({
    url: '/system/sqlRecord/' + sqlIds,
    method: 'delete'
  })
}

import request from '@/utils/request'

// ==================== 请假申请 ====================

// 我的请假申请列表
export function listLeave(query) {
  return request({
    url: '/workflow/leave/list',
    method: 'get',
    params: query
  })
}

// 请假申请详情
export function getLeave(leaveId) {
  return request({
    url: '/workflow/leave/' + leaveId,
    method: 'get'
  })
}

// 发起请假（启动流程实例）
export function addLeave(data) {
  return request({
    url: '/workflow/leave',
    method: 'post',
    data: data
  })
}

// 删除请假申请
export function delLeave(leaveIds) {
  return request({
    url: '/workflow/leave/' + leaveIds,
    method: 'delete'
  })
}

// 审批人下拉
export function listUserOptions() {
  return request({
    url: '/workflow/leave/userOptions',
    method: 'get'
  })
}

// ==================== 待办/已办任务 ====================

// 我的待办
export function listTodo(query) {
  return request({
    url: '/workflow/task/todo',
    method: 'get',
    params: query
  })
}

// 我的已办
export function listDone(query) {
  return request({
    url: '/workflow/task/done',
    method: 'get',
    params: query
  })
}

// 审批任务（同意/驳回）
export function approveTask(data) {
  return request({
    url: '/workflow/task/approve',
    method: 'post',
    data: data
  })
}

// ==================== 流程定义 ====================

// 流程定义列表
export function listDefinition(query) {
  return request({
    url: '/workflow/definition/list',
    method: 'get',
    params: query
  })
}

// 部署流程定义（上传 BPMN 文件）
export function deployDefinition(data) {
  return request({
    url: '/workflow/definition/deploy',
    method: 'post',
    data: data
  })
}

// 查看流程定义 XML
export function getDefinitionXml(deploymentId, resourceName) {
  return request({
    url: '/workflow/definition/xml',
    method: 'get',
    params: { deploymentId: deploymentId, resourceName: resourceName }
  })
}

// 删除流程定义
export function delDefinition(deploymentId) {
  return request({
    url: '/workflow/definition/' + deploymentId,
    method: 'delete'
  })
}
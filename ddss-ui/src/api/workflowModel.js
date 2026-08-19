import request from '@/utils/request'

// 流程模型列表
export function listModel(query) {
  return request({
    url: '/workflow/model/list',
    method: 'get',
    params: query
  })
}

// 流程模型详情
export function getModel(flowId) {
  return request({
    url: '/workflow/model/' + flowId,
    method: 'get'
  })
}

// 默认模板 XML
export function getModelTemplate() {
  return request({
    url: '/workflow/model/template',
    method: 'get'
  })
}

// 获取模型 XML
export function getModelXml(flowId) {
  return request({
    url: '/workflow/model/' + flowId + '/xml',
    method: 'get'
  })
}

// 新建流程模型
export function addModel(data) {
  return request({
    url: '/workflow/model',
    method: 'post',
    data: data
  })
}

// 修改流程模型（名称/Key）
export function editModel(data) {
  return request({
    url: '/workflow/model',
    method: 'put',
    data: data
  })
}

// 保存设计器 XML（草稿）
export function saveModelXml(data) {
  return request({
    url: '/workflow/model/saveXml',
    method: 'put',
    data: data
  })
}

// 发布流程
export function publishModel(flowId) {
  return request({
    url: '/workflow/model/publish/' + flowId,
    method: 'post'
  })
}

// 删除流程模型
export function delModel(flowIds) {
  return request({
    url: '/workflow/model/' + flowIds,
    method: 'delete'
  })
}

// 导入 BPMN 文件生成流程模型
export function importModel(data) {
  return request({
    url: '/workflow/model/import',
    method: 'post',
    data: data
  })
}
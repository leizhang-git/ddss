import request from '@/utils/request'

// 查询MinIO资源列表
export function listMinioResource() {
  return request({
    url: '/resource/minio/list',
    method: 'get'
  })
}

// 下载MinIO文件
export function downloadMinioFile(objectName) {
  return request({
    url: '/resource/minio/download',
    method: 'get',
    params: { objectName: objectName },
    responseType: 'blob'
  })
}

// 获取MinIO文件预览URL
export function getMinioPreviewUrl(objectName) {
  return request({
    url: '/resource/minio/previewUrl',
    method: 'get',
    params: { objectName: objectName }
  })
}

// 删除MinIO文件
export function delMinioResource(objectName) {
  return request({
    url: '/resource/minio',
    method: 'delete',
    params: { objectName: objectName }
  })
}

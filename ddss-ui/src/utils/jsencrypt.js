import JSEncrypt from 'jsencrypt/bin/jsencrypt.min'

// 浏览器端只保留公钥；私钥必须留在服务端，不能随前端构建产物发布。
const publicKey = process.env.VUE_APP_RSA_PUBLIC_KEY || ''

/**
 * 使用服务端下发或构建时注入的公钥加密数据。
 * 注意：公钥加密只用于传输保护，不能替代 HTTPS 或服务端认证。
 */
export function encrypt(txt) {
  if (!publicKey) {
    throw new Error('RSA 公钥未配置')
  }
  const encryptor = new JSEncrypt()
  encryptor.setPublicKey(publicKey)
  return encryptor.encrypt(txt)
}

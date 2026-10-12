import Cookies from 'js-cookie'

const TokenKey = 'Admin-Token'

export function getToken() {
  return Cookies.get(TokenKey)
}

export function setToken(token) {
  return Cookies.set(TokenKey, token, {
    sameSite: 'Lax',
    secure: process.env.NODE_ENV === 'production'
  })
}

export function removeToken() {
  return Cookies.remove(TokenKey)
}

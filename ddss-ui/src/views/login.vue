<template>
  <div class="login-container">
    <div class="bg-layer">
      <div class="bg-gradient"></div>
      <div class="bg-glow bg-glow-1"></div>
      <div class="bg-glow bg-glow-2"></div>
    </div>

    <div class="login-card">
      <div class="card-inner">
        <div class="brand">
          <img src="../assets/logo/logo.png" alt="Logo" class="logo" />
          <h1 class="title">{{ title }}</h1>
          <p class="subtitle">数据驱动的决策支持系统</p>
        </div>

        <el-form ref="loginForm" :model="loginForm" @keyup.enter.native="handleLogin">
          <div class="field">
            <i class="el-icon-user"></i>
            <el-input v-model="loginForm.username" placeholder="用户名" type="text" size="large" clearable />
          </div>

          <div class="field">
            <i class="el-icon-lock"></i>
            <el-input
              v-model="loginForm.password"
              placeholder="密码"
              :type="passwordVisible ? 'text' : 'password'"
              size="large"
              show-password
            />
          </div>

          <div v-if="captchaEnabled" class="field captcha-field">
            <i class="el-icon-picture-outline"></i>
            <el-input v-model="loginForm.code" placeholder="验证码" size="large" class="captcha-input" />
            <span v-if="mathCaptcha" class="captcha-box" @click="getCode" title="点击刷新">
              {{ captchaTip }}
            </span>
            <img v-else :src="codeUrl" class="captcha-box captcha-img" @click="getCode" title="点击刷新" />
          </div>

          <div class="options">
            <el-checkbox v-model="loginForm.rememberMe">记住密码</el-checkbox>
            <router-link v-if="register" to="/register" class="register-link">立即注册</router-link>
          </div>

          <el-button type="primary" size="large" class="login-btn" :loading="loading" @click="handleLogin">
            <span v-if="!loading">登 录</span>
            <span v-else>登录中...</span>
          </el-button>
        </el-form>
      </div>
    </div>

    <div class="footer">© 2025 {{ title }}</div>
  </div>
</template>

<script>
import { getCodeImg } from "@/api/login"
import Cookies from "js-cookie"
import { decrypt, encrypt } from '@/utils/jsencrypt'
import defaultSettings from '@/settings'

export default {
  name: "Login",
  data() {
    return {
      title: process.env.VUE_APP_TITLE,
      codeUrl: "",
      captchaTip: "看不清？点击刷新",
      passwordVisible: false,
      captchaUuid: "",
      mathCaptcha: "",
      loginForm: {
        username: "admin",
        password: "admin123",
        rememberMe: false,
        code: "",
        uuid: ""
      },
      loading: false,
      captchaEnabled: true,
      register: false,
      redirect: undefined
    }
  },
  watch: {
    $route: {
      handler(route) {
        this.redirect = route.query && route.query.redirect
      },
      immediate: true
    }
  },
  created() {
    this.getCode()
    this.getCookie()
  },
  methods: {
    getCode() {
      getCodeImg().then(res => {
        this.captchaEnabled = res.captchaEnabled === undefined ? true : res.captchaEnabled
        if (this.captchaEnabled) {
          this.captchaUuid = res.uuid
          if (res.type && res.math) {
            this.mathCaptcha = res.math
            this.codeUrl = ''
            this.captchaTip = `${res.math} = ?`
          } else {
            this.codeUrl = "data:image/gif;base64," + res.img
            this.mathCaptcha = ''
            this.captchaTip = "看不清？点击刷新"
          }
        }
      }).catch(() => {
        this.$message.error('验证码加载失败')
      })
    },

    getCookie() {
      const username = Cookies.get("username")
      const password = Cookies.get("password")
      const rememberMe = Cookies.get('rememberMe')
      this.loginForm = {
        username: username === undefined ? this.loginForm.username : username,
        password: password === undefined ? this.loginForm.password : decrypt(password),
        rememberMe: rememberMe === undefined ? false : Boolean(rememberMe)
      }
    },

    handleLogin() {
      this.loading = true
      setTimeout(() => {
        if (this.loginForm.rememberMe) {
          Cookies.set("username", this.loginForm.username, { expires: 30 })
          Cookies.set("password", encrypt(this.loginForm.password), { expires: 30 })
          Cookies.set('rememberMe', this.loginForm.rememberMe, { expires: 30 })
        } else {
          Cookies.remove("username")
          Cookies.remove("password")
          Cookies.remove('rememberMe')
        }
        const loginData = { ...this.loginForm, uuid: this.captchaUuid }
        this.$store.dispatch("Login", loginData).then(() => {
          this.$message.success('登录成功')
          this.$router.push({ path: this.redirect || "/" }).catch(() => {})
        }).catch((error) => {
          this.loading = false
          if (error.message && error.message.includes('验证码')) {
            this.$message.error('验证码错误或已失效')
          } else if (error.code === 401) {
            this.$message.error('用户名或密码错误')
          } else {
            this.$message.error('登录失败：' + (error.message || '未知错误'))
          }
          this.getCode()
        })
      }, 300)
    }
  }
}
</script>

<style lang="scss" scoped>
$primary: #4f46e5;
$primary-dark: #4338ca;
$primary-light: #6366f1;
$secondary: #8b5cf6;

.login-container {
  position: relative;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;

  .bg-layer {
    position: absolute;
    inset: 0;
    z-index: 0;

    .bg-gradient {
      position: absolute;
      inset: 0;
      background: linear-gradient(135deg, #0f0c29 0%, #1a1040 40%, #24243e 100%);
    }

    .bg-glow {
      position: absolute;
      border-radius: 50%;
      filter: blur(100px);
      animation: glow 8s ease-in-out infinite;

      &.bg-glow-1 {
        width: 500px;
        height: 500px;
        background: radial-gradient(circle, rgba(79, 70, 229, 0.4), transparent 70%);
        top: -150px;
        left: -100px;
      }

      &.bg-glow-2 {
        width: 400px;
        height: 400px;
        background: radial-gradient(circle, rgba(139, 92, 246, 0.3), transparent 70%);
        bottom: -100px;
        right: -80px;
        animation-delay: -4s;
      }
    }
  }

  .login-card {
    position: relative;
    z-index: 1;
    width: 90%;
    max-width: 440px;
    animation: slideUp 0.6s ease-out;

    .card-inner {
      background: rgba(255, 255, 255, 0.97);
      backdrop-filter: blur(20px);
      border-radius: 20px;
      padding: 48px 40px 40px;
      box-shadow: 0 20px 60px -15px rgba(0, 0, 0, 0.3),
                  0 0 0 1px rgba(255, 255, 255, 0.1);
    }
  }

  .brand {
    text-align: center;
    margin-bottom: 36px;

    .logo {
      width: 64px;
      height: 64px;
      border-radius: 16px;
      filter: drop-shadow(0 8px 20px rgba(79, 70, 229, 0.3));
      margin-bottom: 16px;
    }

    .title {
      font-size: 26px;
      font-weight: 700;
      margin: 0 0 6px;
      background: linear-gradient(135deg, $primary, $secondary);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      letter-spacing: -0.5px;
    }

    .subtitle {
      font-size: 13px;
      color: #6b7280;
      margin: 0;
    }
  }

  .field {
    position: relative;
    margin-bottom: 18px;

    > i {
      position: absolute;
      left: 14px;
      top: 50%;
      transform: translateY(-50%);
      font-size: 16px;
      color: #9ca3af;
      z-index: 2;
      transition: color 0.3s;
    }

    &:focus-within > i {
      color: $primary;
    }

    ::v-deep .el-input__inner {
      padding-left: 42px;
      height: 46px;
      line-height: 46px;
      border: 2px solid #e5e7eb;
      border-radius: 12px;
      font-size: 15px;
      background: #f9fafb;
      transition: all 0.25s ease;

      &:focus {
        border-color: $primary;
        background: #fff;
        box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
      }
    }

    &.captcha-field {
      .captcha-input {
        width: 60%;
      }

      .captcha-box {
        position: absolute;
        right: 6px;
        top: 50%;
        transform: translateY(-50%);
        height: 38px;
        min-width: 120px;
        padding: 0 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        border: 2px solid #e5e7eb;
        border-radius: 10px;
        font-size: 15px;
        font-weight: 600;
        color: #1f2937;
        background: #f3f4f6;
        cursor: pointer;
        transition: all 0.25s;
        box-sizing: border-box;

        &:hover {
          border-color: $primary;
          color: $primary;
        }
      }

      .captcha-img {
        padding: 0;
        object-fit: cover;
      }
    }
  }

  .options {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;

    ::v-deep .el-checkbox__label {
      font-size: 14px;
      color: #6b7280;
    }

    ::v-deep .el-checkbox__inner {
      border-radius: 5px;
      border-width: 2px;
    }

    ::v-deep .el-checkbox__input.is-checked .el-checkbox__inner {
      background-color: $primary;
      border-color: $primary;
    }

    .register-link {
      font-size: 14px;
      color: $primary;
      text-decoration: none;
      font-weight: 500;

      &:hover {
        color: $primary-dark;
      }
    }
  }

  .login-btn {
    width: 100%;
    height: 46px;
    font-size: 16px;
    font-weight: 600;
    border-radius: 12px;
    border: none;
    background: linear-gradient(135deg, $primary, $primary-light);
    box-shadow: 0 4px 14px rgba(79, 70, 229, 0.35);
    transition: all 0.25s ease;
    letter-spacing: 2px;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(79, 70, 229, 0.45);
    }

    &:active {
      transform: translateY(0);
    }
  }

  .footer {
    position: absolute;
    bottom: 24px;
    z-index: 1;
    color: rgba(255, 255, 255, 0.6);
    font-size: 13px;
  }
}

@keyframes glow {
  0%, 100% { opacity: 0.6; transform: scale(1); }
  50% { opacity: 0.9; transform: scale(1.08); }
}

@keyframes slideUp {
  from { transform: translateY(40px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

@media (max-width: 480px) {
  .login-container .login-card .card-inner {
    padding: 36px 24px 32px;
  }
}
</style>

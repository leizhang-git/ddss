<template>
  <div class="login-page">
    <!-- 左侧品牌展示区 -->
    <aside class="brand-side">
      <div class="brand-bg">
        <div class="aurora aurora-1"></div>
        <div class="aurora aurora-2"></div>
        <div class="aurora aurora-3"></div>
        <div class="grid-overlay"></div>
        <div class="orbital-ring"></div>
      </div>

      <div class="brand-content">
        <div class="brand-logo">
          <img src="../assets/logo/logo.png" alt="Logo" />
        </div>
        <h1 class="brand-title">{{ title }}</h1>
        <p class="brand-slogan">数据驱动的决策支持系统</p>

        <ul class="brand-features">
          <li v-for="f in features" :key="f.title">
            <i :class="f.icon"></i>
            <div>
              <h4>{{ f.title }}</h4>
              <p>{{ f.desc }}</p>
            </div>
          </li>
        </ul>
      </div>

      <div class="brand-footer">
        <span>© 2025 {{ title }}</span>
      </div>
    </aside>

    <!-- 右侧登录区 -->
    <main class="form-side">
      <div class="form-wrapper">
        <div class="form-header">
          <h2>欢迎回来</h2>
          <p>请登录您的账户以继续</p>
        </div>

        <el-form ref="loginForm" :model="loginForm" @keyup.enter.native="handleLogin">
          <div class="field">
            <label>用户名</label>
            <div class="input-box">
              <i class="el-icon-user"></i>
              <el-input v-model="loginForm.username" placeholder="请输入用户名" type="text" clearable />
            </div>
          </div>

          <div class="field">
            <label>密码</label>
            <div class="input-box">
              <i class="el-icon-lock"></i>
              <el-input
                v-model="loginForm.password"
                placeholder="请输入密码"
                :type="passwordVisible ? 'text' : 'password'"
                show-password
              />
            </div>
          </div>

          <div v-if="captchaEnabled" class="field">
            <label>验证码</label>
            <div class="captcha-row">
              <div class="input-box captcha-input">
                <i class="el-icon-picture-outline"></i>
                <el-input v-model="loginForm.code" placeholder="请输入验证码" />
              </div>
              <div class="captcha-box" @click="getCode" title="点击刷新">
                <span v-if="mathCaptcha" class="captcha-text">{{ captchaTip }}</span>
                <img v-else :src="codeUrl" alt="验证码" />
              </div>
            </div>
          </div>

          <div class="form-options">
            <el-checkbox v-model="loginForm.rememberMe">记住密码</el-checkbox>
            <router-link v-if="register" to="/register" class="link">立即注册</router-link>
          </div>

          <el-button type="primary" class="submit-btn" :loading="loading" @click="handleLogin">
            <span v-if="!loading">登 录</span>
            <span v-else>登录中...</span>
          </el-button>
        </el-form>

        <div class="form-footer">
          <span>DDSS Management System</span>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import { getCodeImg } from "@/api/login"
import Cookies from "js-cookie"
import { decrypt, encrypt } from '@/utils/jsencrypt'

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
      redirect: undefined,
      features: [
        { icon: 'el-icon-data-analysis', title: '智能分析', desc: '多维度数据可视化决策' },
        { icon: 'el-icon-finance', title: '财务管理', desc: '全链路借款还款追踪' },
        { icon: 'el-icon-cpu', title: '高性能架构', desc: '微服务 + 中间件可插拔' }
      ]
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
$primary-light: #6366f1;
$secondary: #8b5cf6;

.login-page {
  display: flex;
  min-height: 100vh;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

/* ============ 左侧品牌区 ============ */
.brand-side {
  position: relative;
  width: 52%;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 60px 64px;
  overflow: hidden;
  color: #fff;
  background: #0a0a1a;
  flex-shrink: 0;

  .brand-bg {
    position: absolute;
    inset: 0;
    z-index: 0;

    .aurora {
      position: absolute;
      border-radius: 50%;
      filter: blur(90px);
      mix-blend-mode: screen;

      &.aurora-1 {
        width: 600px; height: 600px;
        background: radial-gradient(circle, #4f46e5, transparent 65%);
        top: -200px; left: -150px;
        animation: drift1 18s ease-in-out infinite;
      }
      &.aurora-2 {
        width: 500px; height: 500px;
        background: radial-gradient(circle, #8b5cf6, transparent 65%);
        bottom: -180px; right: -100px;
        animation: drift2 22s ease-in-out infinite;
      }
      &.aurora-3 {
        width: 400px; height: 400px;
        background: radial-gradient(circle, #06b6d4, transparent 65%);
        top: 40%; left: 50%;
        animation: drift3 26s ease-in-out infinite;
      }
    }

    .grid-overlay {
      position: absolute;
      inset: 0;
      background-image:
        linear-gradient(rgba(99, 102, 241, 0.07) 1px, transparent 1px),
        linear-gradient(90deg, rgba(99, 102, 241, 0.07) 1px, transparent 1px);
      background-size: 48px 48px;
      mask-image: radial-gradient(ellipse at center, #000 30%, transparent 75%);
    }

    .orbital-ring {
      position: absolute;
      top: 50%; left: 50%;
      width: 600px; height: 600px;
      margin: -300px 0 0 -300px;
      border: 1px solid rgba(99, 102, 241, 0.1);
      border-radius: 50%;
      animation: spin 60s linear infinite;

      &::before {
        content: '';
        position: absolute;
        top: -3px; left: 50%;
        width: 6px; height: 6px;
        margin-left: -3px;
        background: $primary-light;
        border-radius: 50%;
        box-shadow: 0 0 20px $primary-light;
      }
    }
  }

  .brand-content {
    position: relative;
    z-index: 1;
    max-width: 420px;
  }

  .brand-logo {
    width: 56px; height: 56px;
    margin-bottom: 28px;
    border-radius: 14px;
    overflow: hidden;
    box-shadow: 0 8px 24px rgba(79, 70, 229, 0.4);

    img { width: 100%; height: 100%; display: block; }
  }

  .brand-title {
    font-size: 38px;
    font-weight: 800;
    margin: 0 0 10px;
    letter-spacing: -1px;
    background: linear-gradient(135deg, #fff 30%, #a5b4fc 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .brand-slogan {
    font-size: 16px;
    color: rgba(255, 255, 255, 0.6);
    margin: 0 0 48px;
    line-height: 1.6;
  }

  .brand-features {
    list-style: none;
    padding: 0;
    margin: 0;

    li {
      display: flex;
      align-items: flex-start;
      gap: 16px;
      padding: 16px 0;
      border-top: 1px solid rgba(255, 255, 255, 0.08);

      &:last-child {
        border-bottom: 1px solid rgba(255, 255, 255, 0.08);
      }

      i {
        font-size: 22px;
        color: $primary-light;
        margin-top: 2px;
        flex-shrink: 0;
      }

      h4 {
        font-size: 15px;
        font-weight: 600;
        margin: 0 0 4px;
        color: #fff;
      }

      p {
        font-size: 13px;
        color: rgba(255, 255, 255, 0.5);
        margin: 0;
      }
    }
  }

  .brand-footer {
    position: absolute;
    bottom: 32px;
    left: 64px;
    z-index: 1;
    font-size: 13px;
    color: rgba(255, 255, 255, 0.35);
  }
}

/* ============ 右侧登录区 ============ */
.form-side {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 40px;
  background: #fff;

  .form-wrapper {
    width: 100%;
    max-width: 380px;
    animation: fadeIn 0.7s ease;
  }

  .form-header {
    margin-bottom: 36px;

    h2 {
      font-size: 28px;
      font-weight: 700;
      color: #111827;
      margin: 0 0 8px;
      letter-spacing: -0.5px;
    }

    p {
      font-size: 14px;
      color: #6b7280;
      margin: 0;
    }
  }

  .field {
    margin-bottom: 20px;

    > label {
      display: block;
      font-size: 13px;
      font-weight: 600;
      color: #374151;
      margin-bottom: 8px;
    }

    .input-box {
      position: relative;

      > i {
        position: absolute;
        left: 14px;
        top: 50%;
        transform: translateY(-50%);
        font-size: 16px;
        color: #9ca3af;
        z-index: 2;
        transition: color 0.25s;
      }

      &:focus-within > i {
        color: $primary;
      }

      ::v-deep .el-input__inner {
        padding-left: 42px;
        height: 48px;
        line-height: 48px;
        border: 1.5px solid #e5e7eb;
        border-radius: 12px;
        font-size: 15px;
        background: #f9fafb;
        transition: all 0.2s ease;

        &:hover {
          border-color: #c7d2fe;
        }

        &:focus {
          border-color: $primary;
          background: #fff;
          box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.08);
        }
      }
    }

    .captcha-row {
      display: flex;
      gap: 10px;

      .captcha-input { flex: 1; }
    }

    .captcha-box {
      width: 130px;
      height: 48px;
      border: 1.5px solid #e5e7eb;
      border-radius: 12px;
      background: #f9fafb;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      overflow: hidden;
      transition: all 0.25s;
      flex-shrink: 0;

      &:hover {
        border-color: $primary;
        box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.08);
      }

      .captcha-text {
        font-size: 15px;
        font-weight: 600;
        color: #374151;
      }

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
    }
  }

  .form-options {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 28px;

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

    .link {
      font-size: 14px;
      color: $primary;
      text-decoration: none;
      font-weight: 500;

      &:hover { color: $primary-light; }
    }
  }

  .submit-btn {
    width: 100%;
    height: 48px;
    font-size: 16px;
    font-weight: 600;
    border-radius: 12px;
    border: none;
    background: linear-gradient(135deg, $primary, $primary-light);
    box-shadow: 0 6px 18px rgba(79, 70, 229, 0.3);
    transition: all 0.25s ease;
    letter-spacing: 3px;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 28px rgba(79, 70, 229, 0.4);
    }

    &:active {
      transform: translateY(0);
    }
  }

  .form-footer {
    margin-top: 40px;
    text-align: center;
    font-size: 12px;
    color: #d1d5db;
    letter-spacing: 1px;
  }
}

/* ============ 动画 ============ */
@keyframes drift1 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(60px, 40px) scale(1.1); }
}
@keyframes drift2 {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(-50px, -60px) scale(1.15); }
}
@keyframes drift3 {
  0%, 100% { transform: translate(-50%, -50%) scale(1); opacity: 0.7; }
  50% { transform: translate(-40%, -60%) scale(1.2); opacity: 0.4; }
}
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* ============ 响应式 ============ */
@media (max-width: 960px) {
  .login-page {
    flex-direction: column;
  }

  .brand-side {
    width: 100%;
    min-height: auto;
    padding: 48px 32px 36px;

    .brand-features { display: none; }
    .brand-slogan { margin-bottom: 0; }
    .brand-footer { display: none; }
  }

  .form-side {
    padding: 32px 24px 48px;
  }
}

@media (max-width: 480px) {
  .brand-side {
    padding: 36px 24px 24px;

    .brand-title { font-size: 28px; }
    .brand-slogan { font-size: 14px; }
  }

  .form-side .form-wrapper { max-width: 100%; }
}
</style>

<template>
  <div class="login-container">
    <!-- 动态背景 -->
    <div class="background">
      <div class="bg-animation"></div>
      <div class="bg-grid"></div>
      <div class="bg-glow bg-glow-1"></div>
      <div class="bg-glow bg-glow-2"></div>
      <div class="noise-overlay"></div>
      <div class="particles">
        <div v-for="n in 30" :key="n" class="particle" :style="getParticleStyle(n)"></div>
      </div>
      <div class="tech-lines">
        <div v-for="n in 6" :key="'line'+n" class="tech-line" :style="getTechLineStyle(n)"></div>
      </div>
    </div>

    <!-- 登录卡片 -->
    <div class="login-card">
      <div class="card-content">
        <!-- Logo区域 -->
        <div class="logo-section">
          <div class="logo-wrapper">
            <img src="../assets/logo/logo.png" alt="Logo" class="logo">
            <div class="logo-glow"></div>
          </div>
          <div class="brand-info">
            <h1 class="system-title">{{ title }}</h1>
            <p class="system-subtitle">数据驱动的决策支持系统</p>
            <div class="version-tag">v{{ version }}</div>
          </div>
        </div>

        <!-- 登录表单 -->
        <el-form
          ref="loginForm"
          :model="loginForm"
          class="login-form"
          @keyup.enter.native="handleLogin"
        >
          <!-- 用户名输入 -->
          <div class="form-group">
            <div class="input-wrapper">
              <i class="input-icon el-icon-user"></i>
              <el-input
                v-model="loginForm.username"
                placeholder="请输入用户名"
                type="text"
                size="large"
                clearable
              />
            </div>
          </div>

          <!-- 密码输入 -->
          <div class="form-group">
            <div class="input-wrapper">
              <i class="input-icon el-icon-lock"></i>
              <el-input
                v-model="loginForm.password"
                placeholder="请输入密码"
                :type="passwordVisible ? 'text' : 'password'"
                size="large"
                clearable
                show-password
              />
            </div>
          </div>

          <!-- 验证码 -->
          <div v-if="captchaEnabled" class="form-group">
            <div class="input-wrapper captcha-input-wrapper">
              <i class="input-icon el-icon-picture-outline"></i>
              <el-input
                v-model="loginForm.code"
                placeholder="验证码"
                size="large"
                class="captcha-input"
              />
              <div class="captcha-display">
                <span v-if="mathCaptcha" class="captcha-text" @click="getCode">
                  {{ captchaTip }}
                </span>
                <img
                  v-else
                  :src="codeUrl"
                  class="captcha-img"
                  @click="getCode"
                  :title="`${captchaTip}，点击刷新`"
                />
                <div class="captcha-info">
                  <span class="captcha-refresh" @click="getCode">
                    <i class="el-icon-refresh"></i>
                  </span>
                  <span v-if="captchaTimeLeft" class="captcha-time">
                    {{ formatTime(captchaTimeLeft) }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- 记住密码 -->
          <div class="form-options">
            <el-checkbox v-model="loginForm.rememberMe" class="custom-checkbox">
              <span class="checkbox-text">记住密码</span>
            </el-checkbox>
            <div v-if="register" class="register-link">
              <router-link to="/register" class="register-btn">立即注册</router-link>
            </div>
          </div>

          <!-- 登录按钮 -->
          <el-button
            type="primary"
            size="large"
            class="login-btn"
            :loading="loading"
            @click="handleLogin"
          >
            <span v-if="!loading">登 录</span>
            <span v-else>
              <i class="el-icon-loading"></i>
              登录中...
            </span>
          </el-button>

          <!-- 分隔线 -->
          <div class="divider">
            <div class="divider-line"></div>
            <span class="divider-text">其他登录方式</span>
            <div class="divider-line"></div>
          </div>

          <!-- 其他登录方式 -->
          <div class="other-login">
            <div class="login-methods">
              <el-tooltip content="短信验证码登录" placement="top">
                <div class="login-method sms" @click="smsLogin">
                  <i class="el-icon-mobile-phone"></i>
                </div>
              </el-tooltip>
              <el-tooltip content="扫码登录" placement="top">
                <div class="login-method qr" @click="qrLogin">
                  <i class="el-icon-qrcode"></i>
                </div>
              </el-tooltip>
              <el-tooltip content="微信登录" placement="top">
                <div class="login-method wechat" @click="wechatLogin">
                  <i class="el-icon-icon-wechat"></i>
                </div>
              </el-tooltip>
            </div>
          </div>
        </el-form>
      </div>
    </div>

    <!-- 底部信息 -->
    <div class="login-footer">
      <div class="footer-content">
        <span class="copyright">© 2024 {{ title }}. All rights reserved.</span>
        <div class="footer-links">
          <a href="javascript:;" @click="showHelp" class="footer-link">帮助中心</a>
          <span class="divider">|</span>
          <a href="javascript:;" @click="showPrivacy" class="footer-link">隐私政策</a>
          <span class="divider">|</span>
          <a href="javascript:;" @click="showTerms" class="footer-link">服务条款</a>
        </div>
      </div>
    </div>

    <!-- 加载遮罩 -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner-circle"></div>
        <div class="spinner-circle"></div>
        <div class="spinner-circle"></div>
      </div>
    </div>
  </div>
</template>

<script>
import {getCodeImg} from "@/api/login"
import Cookies from "js-cookie"
import {decrypt, encrypt} from '@/utils/jsencrypt'
import defaultSettings from '@/settings'

export default {
  name: "Login",
  data() {
    return {
      title: process.env.VUE_APP_TITLE,
      footerContent: defaultSettings.footerContent,
      version: "2.0",
      codeUrl: "",
      captchaTip: "看不清？点击刷新",
      passwordVisible: false,
      captchaUuid: "",
      mathCaptcha: "",
      captchaTimeLeft: 300, // 5分钟倒计时
      captchaTimer: null,
      loginForm: {
        username: "admin",
        password: "admin123",
        rememberMe: false,
        code: "",
        uuid: ""
      },
      loginRules: {},
      loading: false,
      // 验证码开关
      captchaEnabled: true,
      // 注册开关
      register: false,
      redirect: undefined
    }
  },
  watch: {
    $route: {
      handler: function (route) {
        this.redirect = route.query && route.query.redirect
      },
      immediate: true
    }
  },
  created() {
    this.getCode()
    this.getCookie()

    // 添加页面加载动画
    this.pageLoaded = false
    setTimeout(() => {
      this.pageLoaded = true
    }, 500)
  },
  mounted() {
    // 监听回车键
    document.addEventListener('keydown', this.handleKeyPress)
  },
  beforeDestroy() {
    document.removeEventListener('keydown', this.handleKeyPress)
    // 清除验证码倒计时
    if (this.captchaTimer) {
      clearInterval(this.captchaTimer)
      this.captchaTimer = null
    }
  },
  methods: {
    // 获取粒子样式
    getParticleStyle(index) {
      const size = Math.random() * 4 + 2
      const left = Math.random() * 100
      const animationDelay = Math.random() * 15
      const animationDuration = Math.random() * 25 + 8
      return {
        width: `${size}px`,
        height: `${size}px`,
        left: `${left}%`,
        top: `${Math.random() * 100}%`,
        animationDelay: `${animationDelay}s`,
        animationDuration: `${animationDuration}s`,
        opacity: Math.random() * 0.6 + 0.2
      }
    },

    // 获取科技线条样式
    getTechLineStyle(index) {
      const top = 15 + (index - 1) * 14
      const width = Math.random() * 200 + 100
      return {
        top: `${top}%`,
        left: `${Math.random() * 60}%`,
        width: `${width}px`,
        animationDelay: `${Math.random() * 5}s`,
        animationDuration: `${Math.random() * 4 + 3}s`,
        transform: `rotate(${Math.random() * 30 - 15}deg)`
      }
    },

    // 格式化时间显示
    formatTime(seconds) {
      const mins = Math.floor(seconds / 60)
      const secs = seconds % 60
      return `${mins}:${secs.toString().padStart(2, '0')}`
    },

    // 切换密码可见性
    togglePassword() {
      this.passwordVisible = !this.passwordVisible
    },

    // 获取验证码
    getCode() {
      // 清除之前的计时器
      if (this.captchaTimer) {
        clearInterval(this.captchaTimer)
        this.captchaTimer = null
      }

      getCodeImg().then(res => {
        this.captchaEnabled = res.captchaEnabled === undefined ? true : res.captchaEnabled
        if (this.captchaEnabled) {
          this.captchaUuid = res.uuid
          this.captchaTimeLeft = 300 // 重置倒计时为5分钟

          // 检查是否有计算题相关字段
          if (res.type && res.math) {
            // 计算题验证码
            this.mathCaptcha = res.math
            this.codeUrl = ''
            this.captchaTip = `计算题：${res.math} = ?`
          } else {
            // 图片验证码
            this.codeUrl = "data:image/gif;base64," + res.img
            this.mathCaptcha = ''
            this.captchaTip = "看不清？点击刷新"
          }

          // 启动倒计时
          this.startCaptchaTimer()
        }
      }).catch(() => {
        this.$message.error('验证码加载失败，请刷新页面重试')
      })
    },

    // 启动验证码倒计时
    startCaptchaTimer() {
      this.captchaTimer = setInterval(() => {
        if (this.captchaTimeLeft > 0) {
          this.captchaTimeLeft--
          // 剩余30秒时提醒用户
          if (this.captchaTimeLeft === 30) {
            this.$notify({
              title: '验证码即将过期',
              message: '验证码将在30秒后失效，请及时登录',
              type: 'warning',
              duration: 3000
            })
          }
        } else {
          // 验证码过期，自动刷新
          clearInterval(this.captchaTimer)
          this.captchaTimer = null
          this.getCode()
        }
      }, 1000)
    },

    // 获取Cookie
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

    // 处理登录
    handleLogin() {
      this.$refs.loginForm.validate(valid => {
        if (valid) {
          this.loading = true

          // 短暂延迟显示加载效果，提升用户体验
          setTimeout(() => {
            if (this.loginForm.rememberMe) {
              Cookies.set("username", this.loginForm.username, {expires: 30})
              Cookies.set("password", encrypt(this.loginForm.password), {expires: 30})
              Cookies.set('rememberMe', this.loginForm.rememberMe, {expires: 30})
            } else {
              Cookies.remove("username")
              Cookies.remove("password")
              Cookies.remove('rememberMe')
            }

            // 确保uuid被正确设置
            const loginData = {
              ...this.loginForm,
              uuid: this.captchaUuid
            }

            this.$store.dispatch("Login", loginData).then(() => {
              // 登录成功动画
              this.$notify({
                title: '登录成功',
                message: '欢迎回来！',
                type: 'success',
                duration: 2000
              })

              this.$router.push({path: this.redirect || "/"}).catch(() => {
              })
            }).catch((error) => {
              this.loading = false
              this.handleLoginError(error)
              // 重新获取验证码
              this.getCode()
            })
          }, 500)
        }
      })
    },

    // 处理登录错误
    handleLoginError(error) {
      // 根据错误类型处理
      if (error.message && error.message.includes('验证码已失效')) {
        this.$message.error('验证码已失效，请重新获取')
        this.getCode()
      } else if (error.code === 401) {
        this.$message.error('用户名或密码错误')
      } else if (error.code === 403) {
        this.$message.error('账号已被禁用，请联系管理员')
      } else if (error.message && error.message.includes('验证码')) {
        this.$message.error('验证码错误，请重新输入')
        this.getCode()
      } else {
        this.$message.error('登录失败：' + (error.message || '未知错误'))
      }

      // 重新获取验证码
      if (this.captchaEnabled) {
        this.getCode()
      }
    },

    // 监听回车键
    handleKeyPress(e) {
      // Enter键
      if (e.keyCode === 13 && !this.loading) {
        this.handleLogin()
      }
    },

    // 短信登录
    smsLogin() {
      this.$message.info('短信登录功能开发中...')
    },

    // 扫码登录
    qrLogin() {
      this.$message.info('扫码登录功能开发中...')
    },

    // 微信登录
    wechatLogin() {
      this.$message.info('微信登录功能开发中...')
    },

    // 显示帮助
    showHelp() {
      this.$message.info('帮助文档正在准备中...')
    },

    // 显示隐私政策
    showPrivacy() {
      window.open('/privacy', '_blank')
    },

    // 显示服务条款
    showTerms() {
      window.open('/terms', '_blank')
    }
  }
}
</script>

<style lang="scss" scoped>
// 背景动画
.login-container {
  position: relative;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;

  // 动态背景
  .background {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    z-index: 0;

    .bg-animation {
      position: absolute;
      width: 100%;
      height: 100%;
      background: linear-gradient(135deg, #0c0c1d 0%, #1a1040 25%, #0d1b3e 50%, #1a0a2e 75%, #0c0c1d 100%);
      background-size: 400% 400%;
      animation: gradient 20s ease infinite;
    }

    .bg-grid {
      position: absolute;
      width: 100%;
      height: 100%;
      background-image:
        linear-gradient(rgba(64, 158, 255, 0.03) 1px, transparent 1px),
        linear-gradient(90deg, rgba(64, 158, 255, 0.03) 1px, transparent 1px);
      background-size: 60px 60px;
      animation: gridMove 20s linear infinite;
    }

    .bg-glow {
      position: absolute;
      border-radius: 50%;
      filter: blur(80px);
      opacity: 0.15;
      animation: glowPulse 8s ease-in-out infinite;

      &.bg-glow-1 {
        width: 400px;
        height: 400px;
        background: radial-gradient(circle, #409eff, transparent);
        top: -100px;
        left: -100px;
      }

      &.bg-glow-2 {
        width: 300px;
        height: 300px;
        background: radial-gradient(circle, #9b59b6, transparent);
        bottom: -50px;
        right: -50px;
        animation-delay: -4s;
      }
    }

    .noise-overlay {
      position: absolute;
      width: 100%;
      height: 100%;
      opacity: 0.03;
      background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
    }

    .particles {
      position: absolute;
      width: 100%;
      height: 100%;

      .particle {
        position: absolute;
        background: rgba(64, 158, 255, 0.6);
        border-radius: 50%;
        animation: float 20s infinite linear;
        box-shadow: 0 0 10px rgba(64, 158, 255, 0.3);
      }
    }

    .tech-lines {
      position: absolute;
      width: 100%;
      height: 100%;
      overflow: hidden;

      .tech-line {
        position: absolute;
        height: 1px;
        background: linear-gradient(90deg, transparent, rgba(64, 158, 255, 0.15), rgba(155, 89, 182, 0.15), transparent);
        animation: techLineMove 4s ease-in-out infinite;
      }
    }
  }

  // 登录卡片
  .login-card {
    position: relative;
    z-index: 1;
    width: 90%;
    max-width: 420px;
    margin: 20px;
    animation: slideUp 0.6s ease-out;

    .card-content {
      background: rgba(255, 255, 255, 0.95);
      backdrop-filter: blur(20px);
      border-radius: 24px;
      padding: 40px;
      box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
      border: 1px solid rgba(255, 255, 255, 0.18);

      // Logo区域
      .logo-section {
        text-align: center;
        margin-bottom: 40px;

        .logo-wrapper {
          position: relative;
          margin-bottom: 20px;
          display: inline-block;
          animation: pulse 3s ease-in-out infinite;

          .logo {
            width: 80px;
            height: 80px;
            border-radius: 20px;
            filter: drop-shadow(0 10px 25px rgba(0, 0, 0, 0.1));
            transition: transform 0.3s ease;
          }

          .logo-glow {
            position: absolute;
            top: -10px;
            left: -10px;
            right: -10px;
            bottom: -10px;
            background: radial-gradient(circle, rgba(79, 70, 229, 0.3) 0%, transparent 70%);
            border-radius: 30px;
            animation: pulse 2s ease-in-out infinite;
          }
        }

        .brand-info {
          .system-title {
            font-size: 28px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 8px;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
          }

          .system-subtitle {
            font-size: 14px;
            color: var(--text-secondary);
            font-weight: 400;
            margin-bottom: 16px;
          }

          .version-tag {
            display: inline-block;
            padding: 4px 12px;
            background: var(--bg-secondary);
            color: var(--text-light);
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
            letter-spacing: 0.5px;
          }
        }
      }

      // 表单样式
      .login-form {
        .form-group {
          margin-bottom: 20px;

          .input-wrapper {
            position: relative;
            transition: all 0.3s ease;

            &:hover {
              transform: translateY(-2px);
            }

            .input-icon {
              position: absolute;
              left: 16px;
              top: 50%;
              transform: translateY(-50%);
              color: var(--text-light);
              font-size: 18px;
              z-index: 1;
              transition: color 0.3s ease;
            }

            ::v-deep .el-input {
              .el-input__inner {
                padding-left: 46px;
                height: 48px;
                line-height: 48px;
                border: 2px solid var(--border-color);
                border-radius: 12px;
                font-size: 15px;
                transition: all 0.3s ease;
                background: var(--bg-primary);

                &:focus {
                  border-color: var(--primary-color);
                  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
                }

                &::placeholder {
                  color: var(--text-light);
                }
              }

              .el-input__prefix {
                left: 16px;
              }
            }
          }

          // 验证码特殊样式
          .input-wrapper.captcha-input-wrapper {
            .captcha-display {
              position: absolute;
              right: 12px;
              top: 50%;
              transform: translateY(-50%);
              display: flex;
              align-items: center;
              gap: 8px;

              .captcha-img {
                height: 36px;
                border-radius: 8px;
                cursor: pointer;
                transition: all 0.3s ease;
                border: 2px solid var(--border-color);
                box-shadow: var(--shadow-sm);

                &:hover {
                  transform: scale(1.05);
                  border-color: var(--primary-color);
                  box-shadow: var(--shadow-md);
                }
              }

              .captcha-text {
                padding: 6px 12px;
                background: var(--bg-secondary);
                border: 2px solid var(--border-color);
                border-radius: 8px;
                font-size: 16px;
                font-weight: 500;
                color: var(--text-primary);
                cursor: pointer;
                transition: all 0.3s ease;
                box-shadow: var(--shadow-sm);

                &:hover {
                  background: var(--primary-color);
                  color: white;
                  border-color: var(--primary-color);
                  transform: translateY(-2px);
                  box-shadow: var(--shadow-md);
                }
              }

              .captcha-info {
                display: flex;
                align-items: center;
                gap: 6px;
                margin-left: 4px;

                .captcha-refresh {
                  width: 28px;
                  height: 28px;
                  border-radius: 6px;
                  background: var(--bg-secondary);
                  border: 1px solid var(--border-color);
                  display: flex;
                  align-items: center;
                  justify-content: center;
                  cursor: pointer;
                  transition: all 0.3s ease;

                  &:hover {
                    background: var(--primary-color);
                    border-color: var(--primary-color);
                    color: white;
                    transform: rotate(180deg);
                  }

                  i {
                    font-size: 14px;
                  }
                }

                .captcha-time {
                  font-size: 12px;
                  color: var(--text-light);
                  font-weight: 500;
                  background: var(--bg-secondary);
                  padding: 2px 8px;
                  border-radius: 4px;
                  border: 1px solid var(--border-color);
                }
              }
            }
          }
        }

        // 表单选项
        .form-options {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 24px;

          .custom-checkbox {
            ::v-deep .el-checkbox__input {
              .el-checkbox__inner {
                border-radius: 6px;
                border: 2px solid var(--border-color);
                transition: all 0.3s ease;
              }

              &.is-checked {
                .el-checkbox__inner {
                  background: var(--primary-color);
                  border-color: var(--primary-color);
                }
              }

              &.is-focus:not(.is-checked) .el-checkbox__inner {
                border-color: var(--primary-color);
              }
            }

            ::v-deep .el-checkbox__label {
              color: var(--text-secondary);
              font-size: 14px;
            }
          }

          .register-link {
            .register-btn {
              color: var(--primary-color);
              text-decoration: none;
              font-size: 14px;
              font-weight: 500;
              transition: all 0.3s ease;
              position: relative;

              &::after {
                content: '';
                position: absolute;
                bottom: -2px;
                left: 0;
                width: 0;
                height: 2px;
                background: var(--primary-color);
                transition: width 0.3s ease;
              }

              &:hover {
                color: var(--primary-dark);

                &::after {
                  width: 100%;
                }
              }
            }
          }
        }

        // 登录按钮
        .login-btn {
          width: 100%;
          height: 48px;
          font-size: 16px;
          font-weight: 600;
          border-radius: 12px;
          background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
          border: none;
          transition: all 0.3s ease;
          box-shadow: 0 4px 15px rgba(79, 70, 229, 0.4);
          position: relative;
          overflow: hidden;

          &::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
          }

          &:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(79, 70, 229, 0.5);

            &::before {
              left: 100%;
            }
          }

          &:active {
            transform: translateY(0);
            box-shadow: 0 2px 10px rgba(79, 70, 229, 0.3);
          }

          ::v-deep .el-icon-loading {
            margin-right: 8px;
          }
        }

        // 分隔线
        .divider {
          display: flex;
          align-items: center;
          margin: 24px 0;
          position: relative;

          .divider-line {
            flex: 1;
            height: 1px;
            background: var(--border-color);
          }

          .divider-text {
            margin: 0 12px;
            color: var(--text-light);
            font-size: 13px;
            font-weight: 500;
            letter-spacing: 0.5px;
          }
        }

        // 其他登录方式
        .other-login {
          .login-methods {
            display: flex;
            justify-content: center;
            gap: 16px;

            .login-method {
              width: 44px;
              height: 44px;
              border-radius: 10px;
              background: var(--bg-secondary);
              display: flex;
              align-items: center;
              justify-content: center;
              cursor: pointer;
              transition: all 0.3s ease;
              border: 1px solid var(--border-color);
              position: relative;
              overflow: hidden;

              i {
                font-size: 20px;
                color: var(--text-secondary);
                transition: all 0.3s ease;
              }

              &::before {
                content: '';
                position: absolute;
                top: 50%;
                left: 50%;
                width: 0;
                height: 0;
                background: rgba(79, 70, 229, 0.1);
                border-radius: 50%;
                transform: translate(-50%, -50%);
                transition: width 0.3s ease, height 0.3s ease;
              }

              &:hover {
                background: var(--primary-color);
                border-color: var(--primary-color);
                transform: translateY(-3px);
                box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);

                &::before {
                  width: 48px;
                  height: 48px;
                }

                i {
                  color: white;
                }
              }

              &.sms {
                &:hover {
                  background: #3b82f6;
                  border-color: #3b82f6;
                }
              }

              &.qr {
                &:hover {
                  background: #10b981;
                  border-color: #10b981;
                }
              }

              &.wechat {
                &:hover {
                  background: #07c160;
                  border-color: #07c160;
                }
              }
            }
          }
        }
      }
    }
  }

  // 底部信息
  .login-footer {
    position: absolute;
    bottom: 20px;
    text-align: center;
    z-index: 1;
    color: rgba(255, 255, 255, 0.8);
    font-size: 13px;

    .footer-content {
      .copyright {
        display: block;
        margin-bottom: 8px;
        opacity: 0.9;
      }

      .footer-links {
        .footer-link {
          color: rgba(255, 255, 255, 0.8);
          text-decoration: none;
          margin: 0 8px;
          transition: all 0.3s ease;
          position: relative;

          &::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 0;
            height: 1px;
            background: rgba(255, 255, 255, 0.8);
            transition: width 0.3s ease;
          }

          &:hover {
            color: white;

            &::after {
              width: 100%;
            }
          }
        }

        .divider {
          color: rgba(255, 255, 255, 0.5);
          margin: 0 8px;
        }
      }
    }
  }

  }

// 加载遮罩
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(5px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;

  .loading-spinner {
    position: relative;
    width: 60px;
    height: 60px;

    .spinner-circle {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: 3px solid transparent;
      border-top-color: white;
      border-radius: 50%;
      animation: rotate 1.2s cubic-bezier(0.68, -0.55, 0.265, 1.55) infinite;

      &:nth-child(1) {
        animation-delay: 0s;
      }

      &:nth-child(2) {
        animation-delay: 0.15s;
        animation-direction: reverse;
        border-top-color: var(--primary-light);
      }

      &:nth-child(3) {
        animation-delay: 0.3s;
        border-top-color: var(--secondary-color);
      }
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .login-container {
    .login-card {
      width: 95%;
      margin: 10px;
      padding: 30px 20px;

      .card-content {
        .logo-section {
          margin-bottom: 30px;

          .logo-wrapper {
            .logo {
              width: 60px;
              height: 60px;
            }
          }

          .brand-info {
            .system-title {
              font-size: 24px;
            }

            .system-subtitle {
              font-size: 13px;
            }
          }
        }

        .login-form {
          .login-methods {
            gap: 12px;

            .login-method {
              width: 44px;
              height: 44px;
            }
          }
        }
      }
    }
  }
}

@media (max-width: 480px) {
  .login-container {
    .login-card {
      width: 100%;
      margin: 0;
      border-radius: 0;
      min-height: 100vh;

      .card-content {
        padding: 25px 20px;
        border-radius: 0;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
        justify-content: center;

        .logo-section {
          margin-bottom: 30px;
        }

        .login-form {
          width: 100%;
        }
      }
    }
  }
}
</style>
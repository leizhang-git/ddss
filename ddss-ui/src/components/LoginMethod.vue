<template>
  <div class="login-method-modal">
    <el-dialog
      title="选择登录方式"
      :visible.sync="visible"
      width="400px"
      :modal-append-to-body="false"
      @closed="handleClose"
      :close-on-click-modal="false"
    >
      <div class="login-method-content">
        <!-- 当前登录方式 -->
        <div class="current-method">
          <div class="method-header">
            <i class="el-icon-user"></i>
            <span>当前方式：账号密码登录</span>
          </div>
          <div class="method-desc">
            使用用户名和密码登录系统
          </div>
        </div>

        <div class="divider"></div>

        <!-- 其他登录方式 -->
        <div class="other-methods">
          <h3 class="methods-title">其他登录方式</h3>

          <!-- 短信登录 -->
          <div class="method-item" @click="selectMethod('sms')">
            <div class="method-icon">
              <i class="el-icon-mobile-phone"></i>
            </div>
            <div class="method-info">
              <div class="method-name">短信验证码登录</div>
              <div class="method-desc">通过手机短信验证码登录</div>
            </div>
            <div class="method-arrow">
              <i class="el-icon-right"></i>
            </div>
          </div>

          <!-- 微信登录 -->
          <div class="method-item wechat" @click="selectMethod('wechat')">
            <div class="method-icon">
              <i class="el-icon-icon-wechat"></i>
            </div>
            <div class="method-info">
              <div class="method-name">微信扫码登录</div>
              <div class="method-desc">使用微信扫码快速登录</div>
            </div>
            <div class="method-arrow">
              <i class="el-icon-right"></i>
            </div>
          </div>

          <!-- 支付宝登录 -->
          <div class="method-item alipay" @click="selectMethod('alipay')">
            <div class="method-icon">
              <i class="el-icon-alipay"></i>
            </div>
            <div class="method-info">
              <div class="method-name">支付宝登录</div>
              <div class="method-desc">使用支付宝账号登录</div>
            </div>
            <div class="method-arrow">
              <i class="el-icon-right"></i>
            </div>
          </div>

          <!-- 扫码登录 -->
          <div class="method-item qr" @click="selectMethod('qr')">
            <div class="method-icon">
              <i class="el-icon-qrcode"></i>
            </div>
            <div class="method-info">
              <div class="method-name">扫码登录</div>
              <div class="method-desc">使用手机APP扫码登录</div>
            </div>
            <div class="method-arrow">
              <i class="el-icon-right"></i>
            </div>
          </div>
        </div>
      </div>

      <div slot="footer" class="dialog-footer">
        <el-button @click="cancel">取消</el-button>
      </div>
    </el-dialog>

    <!-- 短信登录组件 -->
    <div v-if="showSmsLogin" class="sms-login-overlay">
      <div class="sms-login-card">
        <div class="sms-header">
          <h3>短信验证码登录</h3>
          <i class="el-icon-close" @click="closeSmsLogin"></i>
        </div>
        <div class="sms-content">
          <div class="phone-input">
            <el-input
              v-model="smsForm.phone"
              placeholder="请输入手机号"
              maxlength="11"
              @input="validatePhone"
            >
              <i slot="prefix" class="el-icon-mobile-phone"></i>
            </el-input>
            <div v-if="errors.phone" class="error-tip">{{ errors.phone }}</div>
          </div>
          <div class="code-input">
            <el-input
              v-model="smsForm.code"
              placeholder="验证码"
              maxlength="6"
              @input="validateCode"
            >
              <i slot="prefix" class="el-icon-message"></i>
            </el-input>
            <el-button
              :disabled="!canSendCode"
              @click="sendCode"
              size="small"
              class="send-code-btn"
            >
              {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
            </el-button>
          </div>
          <div class="sms-actions">
            <el-button
              type="primary"
              :loading="smsLoading"
              @click="handleSmsLogin"
              class="login-btn"
            >
              登录
            </el-button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LoginMethod',
  data() {
    return {
      visible: false,
      showSmsLogin: false,
      smsLoading: false,
      countdown: 0,
      timer: null,
      smsForm: {
        phone: '',
        code: ''
      },
      errors: {
        phone: '',
        code: ''
      },
      methods: {
        sms: '短信登录',
        wechat: '微信登录',
        alipay: '支付宝登录',
        qr: '扫码登录'
      }
    }
  },
  computed: {
    canSendCode() {
      return this.smsForm.phone && /^1[3-9]\d{9}$/.test(this.smsForm.phone) && this.countdown === 0
    }
  },
  methods: {
    // 打开模态框
    open() {
      this.visible = true
    },

    // 关闭模态框
    close() {
      this.visible = false
      this.showSmsLogin = false
    },

    // 关闭处理
    handleClose() {
      this.showSmsLogin = false
      this.smsForm = {
        phone: '',
        code: ''
      }
      this.errors = {
        phone: '',
        code: ''
      }
      this.clearTimer()
    },

    // 取消选择
    cancel() {
      this.close()
    },

    // 选择登录方式
    selectMethod(method) {
      if (method === 'sms') {
        this.showSmsLogin = true
      } else {
        this.$emit('select', method)
        this.close()
      }
    },

    // 验证手机号
    validatePhone() {
      if (!this.smsForm.phone) {
        this.errors.phone = '请输入手机号'
      } else if (!/^1[3-9]\d{9}$/.test(this.smsForm.phone)) {
        this.errors.phone = '请输入正确的手机号'
      } else {
        this.errors.phone = ''
      }
    },

    // 验证验证码
    validateCode() {
      if (!this.smsForm.code) {
        this.errors.code = '请输入验证码'
      } else if (this.smsForm.code.length !== 6) {
        this.errors.code = '验证码长度为6位'
      } else {
        this.errors.code = ''
      }
    },

    // 发送验证码
    sendCode() {
      if (!this.canSendCode) return

      this.$http.post('/auth/send-sms-code', {
        phone: this.smsForm.phone
      }).then(() => {
        this.countdown = 60
        this.startTimer()
        this.$message.success('验证码已发送')
      }).catch(error => {
        this.$message.error(error.message || '发送失败')
      })
    },

    // 开始倒计时
    startTimer() {
      this.timer = setInterval(() => {
        this.countdown--
        if (this.countdown <= 0) {
          this.clearTimer()
        }
      }, 1000)
    },

    // 清除倒计时
    clearTimer() {
      if (this.timer) {
        clearInterval(this.timer)
        this.timer = null
      }
      this.countdown = 0
    },

    // 处理短信登录
    handleSmsLogin() {
      this.validatePhone()
      this.validateCode()

      if (!this.errors.phone && !this.errors.code) {
        this.smsLoading = true

        this.$http.post('/auth/sms-login', {
          phone: this.smsForm.phone,
          code: this.smsForm.code
        }).then(() => {
          this.$message.success('登录成功')
          this.$emit('login-success')
          this.close()
        }).catch(error => {
          this.$message.error(error.message || '登录失败')
        }).finally(() => {
          this.smsLoading = false
        })
      }
    },

    // 关闭短信登录
    closeSmsLogin() {
      this.showSmsLogin = false
    }
  },

  beforeDestroy() {
    this.clearTimer()
  }
}
</script>

<style lang="scss" scoped>
.login-method-modal {
  .login-method-content {
    padding: 20px 0;

    .current-method {
      .method-header {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 8px;

        i {
          color: #4f46e5;
          font-size: 18px;
        }

        span {
          font-size: 16px;
          font-weight: 500;
          color: #1f2937;
        }
      }

      .method-desc {
        color: #6b7280;
        font-size: 14px;
        line-height: 1.5;
      }
    }

    .divider {
      height: 1px;
      background: #e5e7eb;
      margin: 20px 0;
    }

    .methods-title {
      font-size: 16px;
      font-weight: 500;
      color: #1f2937;
      margin-bottom: 16px;
    }

    .method-item {
      display: flex;
      align-items: center;
      padding: 16px;
      border-radius: 12px;
      cursor: pointer;
      transition: all 0.3s ease;
      margin-bottom: 12px;
      background: #f9fafb;
      border: 2px solid transparent;

      &:hover {
        background: #ffffff;
        border-color: #e5e7eb;
        transform: translateX(5px);
      }

      &.wechat {
        &:hover {
          background: #f0f9ff;
          border-color: #07c160;
        }

        .method-icon {
          background: #07c160;
          color: #ffffff;
        }
      }

      &.alipay {
        &:hover {
          background: #fff7ed;
          border-color: #1677ff;
        }

        .method-icon {
          background: #1677ff;
          color: #ffffff;
        }
      }

      &.qr {
        &:hover {
          background: #f3f4f6;
          border-color: #4f46e5;
        }

        .method-icon {
          background: #4f46e5;
          color: #ffffff;
        }
      }

      .method-icon {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        background: #4f46e5;
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        margin-right: 16px;
      }

      .method-info {
        flex: 1;

        .method-name {
          font-size: 16px;
          font-weight: 500;
          color: #1f2937;
          margin-bottom: 4px;
        }

        .method-desc {
          font-size: 14px;
          color: #6b7280;
          line-height: 1.4;
        }
      }

      .method-arrow {
        color: #9ca3af;
        font-size: 16px;
        transition: color 0.3s ease;
      }

      &:hover .method-arrow {
        color: #4f46e5;
      }
    }
  }
}

// 短信登录覆盖层
.sms-login-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;

  .sms-login-card {
    background: #ffffff;
    border-radius: 16px;
    width: 90%;
    max-width: 380px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);

    .sms-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 20px;
      border-bottom: 1px solid #e5e7eb;

      h3 {
        font-size: 18px;
        font-weight: 600;
        color: #1f2937;
      }

      .el-icon-close {
        font-size: 20px;
        color: #9ca3af;
        cursor: pointer;
        transition: color 0.3s ease;

        &:hover {
          color: #4f46e5;
        }
      }
    }

    .sms-content {
      padding: 20px;

      .phone-input,
      .code-input {
        margin-bottom: 16px;

        .el-input {
          .el-input__inner {
            height: 44px;
            border-radius: 8px;
          }

          .el-input__prefix {
            .el-input__icon {
              font-size: 16px;
              color: #9ca3af;
            }
          }
        }

        .error-tip {
          color: #ef4444;
          font-size: 12px;
          margin-top: 4px;
        }
      }

      .send-code-btn {
        width: 120px;
        height: 36px;
        border-radius: 8px;
        background: #4f46e5;
        color: #ffffff;
        border: none;
        font-size: 14px;
        transition: all 0.3s ease;

        &:hover:not(:disabled) {
          background: #3730a3;
        }

        &:disabled {
          background: #e5e7eb;
          color: #9ca3af;
          cursor: not-allowed;
        }
      }

      .sms-actions {
        margin-top: 24px;

        .login-btn {
          width: 100%;
          height: 44px;
          border-radius: 8px;
          background: #4f46e5;
          color: #ffffff;
          border: none;
          font-size: 16px;
          font-weight: 500;
          transition: all 0.3s ease;

          &:hover {
            background: #3730a3;
          }

          .el-icon-loading {
            margin-right: 8px;
          }
        }
      }
    }
  }
}

// 响应式
@media (max-width: 480px) {
  .login-method-modal {
    .login-method-content {
      .method-item {
        padding: 12px;
      }
    }
  }
}
</style>
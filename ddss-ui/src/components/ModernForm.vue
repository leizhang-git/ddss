<template>
  <div class="modern-form">
    <!-- 表单头部 -->
    <div class="form-header" v-if="title || description">
      <h2 class="form-title">{{ title }}</h2>
      <p v-if="description" class="form-description">{{ description }}</p>
    </div>

    <!-- 进度指示器（分段表单时显示） -->
    <div v-if="showProgress && steps.length > 1" class="form-progress">
      <el-steps :active="currentStep" finish-status="success" align-center>
        <el-step v-for="(step, index) in steps" :key="index" :title="step.title">
          <template #description>
            <span class="step-description">{{ step.description }}</span>
          </template>
        </el-step>
      </el-steps>
    </div>

    <!-- 表单内容 -->
    <el-form
      ref="form"
      :model="formData"
      :rules="formRules"
      :label-width="labelWidth"
      :label-position="labelPosition"
      class="form-content"
    >
      <div v-if="showProgress && steps.length > 1">
        <!-- 第一步：基本信息 -->
        <div v-show="currentStep === 0" class="form-step">
          <slot name="step1">
            <div class="form-section">
              <h3 class="section-title">基本信息</h3>
              <el-row :gutter="20">
                <el-col :span="12">
                  <el-form-item label="名称" prop="name">
                    <el-input
                      v-model="formData.name"
                      placeholder="请输入名称"
                      clearable
                    />
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="编码" prop="code">
                    <el-input
                      v-model="formData.code"
                      placeholder="请输入编码"
                      clearable
                    />
                  </el-form-item>
                </el-col>
              </el-row>

              <el-form-item label="描述" prop="description">
                <el-input
                  v-model="formData.description"
                  type="textarea"
                  :rows="3"
                  placeholder="请输入描述"
                />
              </el-form-item>

              <el-form-item label="状态" prop="status">
                <el-radio-group v-model="formData.status">
                  <el-radio :label="1">启用</el-radio>
                  <el-radio :label="0">禁用</el-radio>
                </el-radio-group>
              </el-form-item>
            </div>
          </slot>
        </div>

        <!-- 第二步：详细信息 -->
        <div v-show="currentStep === 1" class="form-step">
          <slot name="step2">
            <div class="form-section">
              <h3 class="section-title">详细信息</h3>

              <el-form-item label="分类" prop="category">
                <el-select v-model="formData.category" placeholder="请选择分类">
                  <el-option
                    v-for="item in categoryOptions"
                    :key="item.value"
                    :label="item.label"
                    :value="item.value"
                  />
                </el-select>
              </el-form-item>

              <el-form-item label="标签" prop="tags">
                <el-select
                  v-model="formData.tags"
                  multiple
                  filterable
                  allow-create
                  default-first-option
                  placeholder="请选择标签"
                >
                  <el-option
                    v-for="item in tagOptions"
                    :key="item"
                    :label="item"
                    :value="item"
                  />
                </el-select>
              </el-form-item>

              <el-form-item label="优先级" prop="priority">
                <el-slider
                  v-model="formData.priority"
                  :min="1"
                  :max="10"
                  show-stops
                />
              </el-form-item>

              <el-form-item label="附件" prop="attachments">
                <file-upload
                  v-model="formData.attachments"
                  :limit="5"
                  :file-size="10"
                  :file-type="['jpg', 'png', 'pdf', 'doc', 'docx']"
                />
              </el-form-item>
            </div>
          </slot>
        </div>

        <!-- 第三步：高级设置 -->
        <div v-show="currentStep === 2" class="form-step">
          <slot name="step3">
            <div class="form-section">
              <h3 class="section-title">高级设置</h3>

              <el-form-item label="权限设置" prop="permissions">
                <el-checkbox-group v-model="formData.permissions">
                  <el-checkbox label="read">读取权限</el-checkbox>
                  <el-checkbox label="write">写入权限</el-checkbox>
                  <el-checkbox label="delete">删除权限</el-checkbox>
                  <el-checkbox label="admin">管理员权限</el-checkbox>
                </el-checkbox-group>
              </el-form-item>

              <el-form-item label="通知设置" prop="notifications">
                <el-switch
                  v-model="formData.notifications.email"
                  active-text="邮件通知"
                />
                <el-switch
                  v-model="formData.notifications.sms"
                  active-text="短信通知"
                  style="margin-left: 20px"
                />
              </el-form-item>

              <el-form-item label="自动保存" prop="autoSave">
                <el-switch v-model="formData.autoSave" />
                <span class="help-text">每30秒自动保存表单数据</span>
              </el-form-item>
            </div>
          </slot>
        </div>
      </div>

      <!-- 普通表单（不分段） -->
      <div v-else>
        <slot></slot>
      </div>
    </el-form>

    <!-- 表单底部操作 -->
    <div class="form-footer">
      <div class="form-actions">
        <!-- 上一步按钮（分段表单） -->
        <el-button
          v-if="showProgress && currentStep > 0"
          @click="prevStep"
        >
          上一步
        </el-button>

        <!-- 草稿按钮 -->
        <el-button
          v-if="showDraft"
          type="info"
          @click="saveDraft"
        >
          保存草稿
        </el-button>

        <!-- 下一步按钮（分段表单） -->
        <el-button
          v-if="showProgress && currentStep < steps.length - 1"
          type="primary"
          @click="nextStep"
        >
          下一步
        </el-button>

        <!-- 提交按钮 -->
        <el-button
          v-if="showProgress && currentStep === steps.length - 1"
          type="primary"
          :loading="submitting"
          @click="handleSubmit"
        >
          {{ submitting ? '提交中...' : '提交' }}
        </el-button>

        <!-- 普通表单提交按钮 -->
        <el-button
          v-else
          type="primary"
          :loading="submitting"
          @click="handleSubmit"
        >
          {{ submitting ? '提交中...' : '提交' }}
        </el-button>

        <!-- 取消按钮 -->
        <el-button @click="handleCancel">取消</el-button>
      </div>

      <!-- 表单统计 -->
      <div v-if="showStatistics" class="form-statistics">
        <span class="stat-item">
          <i class="el-icon-time"></i>
          已用时：{{ formatTime(spentTime) }}
        </span>
        <span class="stat-item">
          <i class="el-icon-edit"></i>
          已填写：{{ completedFields }}/{{ totalFields }}
        </span>
        <span v-if="autoSave" class="stat-item auto-save">
          <i class="el-icon-check"></i>
          自动保存于：{{ lastSaved }}
        </span>
      </div>
    </div>
  </div>
</template>

<script>
import FileUpload from './FileUpload/index.vue'

export default {
  name: 'ModernForm',
  components: {
    FileUpload
  },
  props: {
    // 表单标题
    title: {
      type: String,
      default: ''
    },
    // 表单描述
    description: {
      type: String,
      default: ''
    },
    // 是否显示进度条
    showProgress: {
      type: Boolean,
      default: false
    },
    // 步骤配置
    steps: {
      type: Array,
      default: () => []
    },
    // 标签宽度
    labelWidth: {
      type: String,
      default: '120px'
    },
    // 标签位置
    labelPosition: {
      type: String,
      default: 'right'
    },
    // 是否显示草稿按钮
    showDraft: {
      type: Boolean,
      default: true
    },
    // 是否显示统计信息
    showStatistics: {
      type: Boolean,
      default: false
    },
    // 是否自动保存
    autoSave: {
      type: Boolean,
      default: false
    },
    // 自动保存间隔（秒）
    autoSaveInterval: {
      type: Number,
      default: 30
    }
  },
  data() {
    return {
      currentStep: 0,
      submitting: false,
      spentTime: 0,
      timer: null,
      lastSaved: '',
      formData: {},
      formRules: {},
      categoryOptions: [
        { value: 'tech', label: '技术' },
        { value: 'business', label: '业务' },
        { value: 'management', label: '管理' },
        { value: 'other', label: '其他' }
      ],
      tagOptions: ['重要', '紧急', '待处理', '已完成', '进行中']
    }
  },
  computed: {
    // 计算总字段数
    totalFields() {
      // 这里可以根据表单字段动态计算
      return 10
    },
    // 计算已填写字段数
    completedFields() {
      if (!this.formData) return 0
      return Object.values(this.formData).filter(value =>
        value !== null && value !== undefined && value !== '' &&
        (Array.isArray(value) ? value.length > 0 : true)
      ).length
    }
  },
  mounted() {
    // 开始计时
    if (this.showStatistics) {
      this.startTimer()
    }

    // 自动保存
    if (this.autoSave) {
      this.setupAutoSave()
    }

    // 从本地存储恢复草稿
    this.loadDraft()
  },
  beforeDestroy() {
    this.clearTimer()
    this.clearAutoSave()
  },
  methods: {
    // 下一步
    nextStep() {
      this.$refs.form.validate(valid => {
        if (valid) {
          this.currentStep++
          this.$emit('step-change', this.currentStep)
        }
      })
    },

    // 上一步
    prevStep() {
      this.currentStep--
      this.$emit('step-change', this.currentStep)
    },

    // 提交表单
    handleSubmit() {
      this.$refs.form.validate(valid => {
        if (valid) {
          this.submitting = true

          // 这里可以添加提交前的数据处理
          const submitData = {
            ...this.formData,
            step: this.showProgress ? this.currentStep + 1 : 1,
            spentTime: this.spentTime,
            completedAt: new Date().toISOString()
          }

          // 触发提交事件
          this.$emit('submit', submitData)

          // 模拟提交
          setTimeout(() => {
            this.submitting = false
            this.$message.success('提交成功')
            this.clearDraft()
          }, 1500)
        }
      })
    },

    // 保存草稿
    saveDraft() {
      const draftData = {
        ...this.formData,
        currentStep: this.currentStep,
        savedAt: new Date().toISOString()
      }

      localStorage.setItem('formDraft', JSON.stringify(draftData))
      this.lastSaved = new Date().toLocaleTimeString()
      this.$message.success('草稿已保存')
    },

    // 加载草稿
    loadDraft() {
      const draft = localStorage.getItem('formDraft')
      if (draft) {
        const draftData = JSON.parse(draft)
        this.formData = { ...this.formData, ...draftData }
        this.currentStep = draftData.currentStep || 0
        this.lastSaved = new Date(draftData.savedAt).toLocaleTimeString()
        this.$emit('draft-loaded', draftData)
      }
    },

    // 清除草稿
    clearDraft() {
      localStorage.removeItem('formDraft')
    },

    // 取消表单
    handleCancel() {
      this.$confirm('确定要取消填写吗？未保存的数据将会丢失。', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.$emit('cancel')
      }).catch(() => {})
    },

    // 计时器相关
    startTimer() {
      this.timer = setInterval(() => {
        this.spentTime++
      }, 1000)
    },

    clearTimer() {
      if (this.timer) {
        clearInterval(this.timer)
        this.timer = null
      }
    },

    // 格式化时间
    formatTime(seconds) {
      const hours = Math.floor(seconds / 3600)
      const minutes = Math.floor((seconds % 3600) / 60)
      const secs = seconds % 60

      if (hours > 0) {
        return `${hours}小时${minutes}分钟`
      } else if (minutes > 0) {
        return `${minutes}分钟${secs}秒`
      } else {
        return `${secs}秒`
      }
    },

    // 自动保存
    setupAutoSave() {
      this.autoSaveTimer = setInterval(() => {
        this.saveDraft()
      }, this.autoSaveInterval * 1000)
    },

    clearAutoSave() {
      if (this.autoSaveTimer) {
        clearInterval(this.autoSaveTimer)
        this.autoSaveTimer = null
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.modern-form {
  background: #ffffff;
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
  transition: all 0.3s ease;

  // 表单头部
  .form-header {
    margin-bottom: 32px;
    text-align: center;
    padding-bottom: 24px;
    border-bottom: 1px solid #e5e7eb;

    .form-title {
      font-size: 24px;
      font-weight: 600;
      color: #1f2937;
      margin-bottom: 8px;
    }

    .form-description {
      font-size: 16px;
      color: #6b7280;
      line-height: 1.5;
    }
  }

  // 进度条
  .form-progress {
    margin-bottom: 40px;
    padding: 0 20px;

    ::v-deep .el-steps {
      .el-step__title {
        font-weight: 500;
      }

      .step-description {
        font-size: 12px;
        color: #6b7280;
        margin-top: 4px;
      }
    }
  }

  // 表单内容
  .form-content {
    .form-section {
      .section-title {
        font-size: 18px;
        font-weight: 600;
        color: #374151;
        margin-bottom: 24px;
        padding-bottom: 12px;
        border-bottom: 2px solid #e5e7eb;
      }

      ::v-deep .el-form-item__label {
        font-weight: 500;
        color: #374151;
      }

      ::v-deep .el-input,
      ::v-deep .el-textarea,
      ::v-deep .el-select {
        .el-input__inner,
        .el-textarea__inner {
          border-radius: 8px;
          border: 1px solid #e5e7eb;
          transition: all 0.3s ease;

          &:focus {
            border-color: #4f46e5;
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
          }
        }
      }

      .help-text {
        margin-left: 8px;
        font-size: 12px;
        color: #9ca3af;
      }
    }
  }

  // 表单底部
  .form-footer {
    margin-top: 40px;
    padding-top: 24px;
    border-top: 1px solid #e5e7eb;
    display: flex;
    justify-content: space-between;
    align-items: center;

    .form-actions {
      display: flex;
      gap: 12px;
    }

    .form-statistics {
      display: flex;
      gap: 24px;
      font-size: 14px;

      .stat-item {
        color: #6b7280;
        display: flex;
        align-items: center;
        gap: 6px;

        i {
          font-size: 16px;
        }

        &.auto-save {
          color: #10b981;
        }
      }
    }
  }

  // 动画效果
  .form-step {
    animation: fadeIn 0.5s ease;
  }
}

// 响应式设计
@media (max-width: 768px) {
  .modern-form {
    padding: 20px;

    .form-footer {
      flex-direction: column;
      gap: 16px;

      .form-actions {
        width: 100%;
        justify-content: center;

        .el-button {
          width: 120px;
        }
      }
    }
  }
}

// 动画
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
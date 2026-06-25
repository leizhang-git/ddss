<template>
  <div class="navbar-container">
    <div class="modern-navbar" :class="{ 'navbar-shadow': showShadow }">
    <!-- 左侧区域 -->
    <div class="navbar-left">
      <!-- 折叠按钮 -->
      <div class="navbar-item" @click="toggleSideBar">
        <i :class="['hamburger-icon', sidebar.opened ? 'is-active' : '']">
          <span></span>
          <span></span>
          <span></span>
        </i>
        <span class="tooltip-text">菜单</span>
      </div>

      <!-- 面包屑导航 -->
      <breadcrumb v-if="!topNav" class="breadcrumb-wrapper"/>
      <top-nav v-if="topNav" class="topmenu-wrapper"/>

      <!-- 搜索框 -->
      <div v-if="showSearch" class="search-wrapper">
        <el-input
          v-model="searchQuery"
          placeholder="全局搜索..."
          prefix-icon="el-icon-search"
          clearable
          @input="handleSearch"
          @clear="clearSearch"
          class="global-search"
        />
      </div>
    </div>

    <!-- 右侧区域 -->
    <div class="navbar-right">
      <!-- 全局通知 -->
      <el-badge :value="notificationCount" :hidden="notificationCount === 0" class="navbar-item">
        <el-tooltip content="消息通知" placement="bottom">
          <div class="notification-bell" @click="showNotifications">
            <i class="el-icon-bell"></i>
            <span v-if="notificationCount > 0" class="notification-dot"></span>
          </div>
        </el-tooltip>
      </el-badge>

      <!-- 快捷操作 -->
      <div class="navbar-item" @click="toggleFullscreen">
        <el-tooltip content="全屏" placement="bottom">
          <i class="fullscreen-icon">
            <i class="el-icon-full-screen"></i>
          </i>
        </el-tooltip>
      </div>

      <!-- 主题切换 -->
      <div class="navbar-item" @click="toggleTheme">
        <el-tooltip :content="isDark ? '切换浅色主题' : '切换深色主题'" placement="bottom">
          <i class="theme-icon">
            <i :class="['el-icon-' + (isDark ? 'sun' : 'moon')]" />
          </i>
        </el-tooltip>
      </div>

      <!-- 系统设置 -->
      <el-tooltip content="系统设置" placement="bottom">
        <div class="navbar-item" @click="showSettings">
          <i class="settings-icon">
            <i class="el-icon-setting"></i>
          </i>
        </div>
      </el-tooltip>

      <!-- 用户菜单 -->
      <el-dropdown
        class="user-dropdown"
        trigger="click"
        @command="handleCommand"
      >
        <div class="user-info">
          <img :src="avatar" class="user-avatar">
          <div class="user-details">
            <span class="user-name">{{ nickName }}</span>
            <span class="user-role">{{ userRole }}</span>
          </div>
          <i class="el-icon-arrow-down user-arrow"></i>
        </div>
        <el-dropdown-menu slot="dropdown">
          <div class="dropdown-header">
            <img :src="avatar" class="dropdown-avatar">
            <div class="dropdown-info">
              <div class="dropdown-name">{{ nickName }}</div>
              <div class="dropdown-role">{{ userRole }}</div>
            </div>
          </div>
          <el-dropdown-item divided command="profile">
            <i class="el-icon-user"></i> 个人中心
          </el-dropdown-item>
          <el-dropdown-item command="settings">
            <i class="el-icon-setting"></i> 布局设置
          </el-dropdown-item>
          <el-dropdown-item command="theme">
            <i :class="['el-icon-' + (isDark ? 'sun' : 'moon')]"></i> {{ isDark ? '浅色主题' : '深色主题' }}
          </el-dropdown-item>
          <el-dropdown-item divided command="logout">
            <i class="el-icon-switch-button"></i> 退出登录
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>

  <!-- 通知弹窗 -->
  <el-dialog
    title="消息通知"
    :visible.sync="notificationVisible"
    width="360px"
    custom-class="notification-dialog"
  >
    <div class="notification-list">
      <div v-if="notifications.length === 0" class="empty-notifications">
        <i class="el-icon-bell-off"></i>
        <span>暂无消息通知</span>
      </div>
      <div v-for="notification in notifications"
           :key="notification.id"
           class="notification-item"
           :class="{ 'unread': !notification.read }"
      >
        <div class="notification-icon">
          <i :class="getNotificationIcon(notification.type)"></i>
        </div>
        <div class="notification-content">
          <div class="notification-title">{{ notification.title }}</div>
          <div class="notification-desc">{{ notification.content }}</div>
          <div class="notification-time">{{ formatTime(notification.time) }}</div>
        </div>
        <div v-if="!notification.read" class="notification-badge"></div>
      </div>
    </div>
    <div slot="footer" class="notification-footer">
      <el-button size="small" @click="markAllAsRead">全部已读</el-button>
      <el-button size="small" type="primary" @click="viewAllNotifications">查看全部</el-button>
    </div>
  </el-dialog>
  </div>
</template>

<script>
import {mapGetters} from 'vuex'
import Breadcrumb from '@/components/Breadcrumb'
import TopNav from '@/components/TopNav'
import Screenfull from '@/components/Screenfull'
import SizeSelect from '@/components/SizeSelect'

export default {
  emits: ['setLayout'],
  components: {
    Breadcrumb,
    TopNav,
    Screenfull,
    SizeSelect
  },
  data() {
    return {
      searchQuery: '',
      showSearch: true,
      showShadow: false,
      notificationVisible: false,
      notificationCount: 3,
      isDark: false,
      notifications: [
        {
          id: 1,
          type: 'success',
          title: '系统更新',
          content: '系统已成功更新到最新版本',
          time: new Date(),
          read: false
        },
        {
          id: 2,
          type: 'warning',
          title: '内存使用警告',
          content: '服务器内存使用率超过80%',
          time: new Date(Date.now() - 3600000),
          read: false
        },
        {
          id: 3,
          type: 'info',
          title: '新用户注册',
          content: '有新用户注册了系统',
          time: new Date(Date.now() - 7200000),
          read: true
        }
      ],
      userRole: '管理员'
    }
  },
  computed: {
    ...mapGetters([
      'sidebar',
      'avatar',
      'device',
      'nickName'
    ]),
    setting() {
      return this.$store.state.settings.showSettings
    },
    topNav() {
      return this.$store.state.settings.topNav
    }
  },
  mounted() {
    // 监听滚动事件，控制阴影显示
    window.addEventListener('scroll', this.handleScroll)
  },
  beforeDestroy() {
    window.removeEventListener('scroll', this.handleScroll)
  },
  methods: {
    toggleSideBar() {
      this.$store.dispatch('app/toggleSideBar')
    },
    setLayout(event) {
      this.$emit('setLayout')
    },
    logout() {
      this.$confirm('确定注销并退出系统吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        this.$store.dispatch('LogOut').then(() => {
          location.href = '/index'
        })
      }).catch(() => {
      })
    },

    // 搜索相关方法
    handleSearch() {
      // 实现全局搜索逻辑
      console.log('搜索:', this.searchQuery)
    },
    clearSearch() {
      this.searchQuery = ''
    },

    // 通知相关方法
    showNotifications() {
      this.notificationVisible = true
    },
    markAllAsRead() {
      this.notifications.forEach(notification => {
        notification.read = true
      })
      this.notificationCount = 0
      this.$message.success('所有消息已标记为已读')
    },
    viewAllNotifications() {
      this.notificationVisible = false
      this.$message.info('正在跳转到通知中心...')
    },
    getNotificationIcon(type) {
      const icons = {
        success: 'el-icon-success',
        warning: 'el-icon-warning',
        info: 'el-icon-info',
        error: 'el-icon-error'
      }
      return icons[type] || 'el-icon-bell'
    },
    formatTime(time) {
      const now = new Date()
      const diff = now - time
      const hours = Math.floor(diff / 3600000)

      if (hours < 1) {
        return '刚刚'
      } else if (hours < 24) {
        return `${hours}小时前`
      } else {
        return time.toLocaleDateString()
      }
    },

    // 主题切换
    toggleTheme() {
      this.isDark = !this.isDark
      this.$message.success(`已切换到${this.isDark ? '深色' : '浅色'}主题`)
    },

    // 全屏切换
    toggleFullscreen() {
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen()
      } else {
        if (document.exitFullscreen) {
          document.exitFullscreen()
        }
      }
    },

    // 显示设置
    showSettings() {
      this.$emit('setLayout')
    },

    // 处理滚动
    handleScroll() {
      this.showShadow = window.scrollY > 10
    },

    // 处理下拉菜单命令
    handleCommand(command) {
      switch (command) {
        case 'profile':
          this.$router.push('/user/profile')
          break
        case 'settings':
          this.$emit('setLayout')
          break
        case 'theme':
          this.toggleTheme()
          break
        case 'logout':
          this.logout()
          break
      }
    }
  }
}
</script>

<style lang="scss" scoped>
// 导航栏容器
.navbar-container {
  position: relative;
  z-index: 1000;
}

// 现代化导航栏样式
.modern-navbar {
  height: 60px;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  transition: all 0.3s ease;
  position: relative;
  z-index: 1000;

  &.navbar-shadow {
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  }

  .navbar-left {
    display: flex;
    align-items: center;
    gap: 20px;
    flex: 1;
  }

  .navbar-right {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  // 导航栏项目
  .navbar-item {
    position: relative;
    width: 40px;
    height: 40px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s ease;
    color: #64748b;

    &:hover {
      background: #f1f5f9;
      color: #4f46e5;
      transform: translateY(-2px);
    }

    .tooltip-text {
      position: absolute;
      left: 100%;
      margin-left: 8px;
      background: #1f2937;
      color: #ffffff;
      padding: 4px 8px;
      border-radius: 6px;
      font-size: 12px;
      white-space: nowrap;
      opacity: 0;
      pointer-events: none;
      transition: opacity 0.3s ease;

      &::before {
        content: '';
        position: absolute;
        right: 100%;
        top: 50%;
        transform: translateY(-50%);
        border: 4px solid transparent;
        border-right-color: #1f2937;
      }
    }

    &:hover .tooltip-text {
      opacity: 1;
    }
  }

  // 汉堡菜单图标
  .hamburger-icon {
    display: flex;
    flex-direction: column;
    justify-content: space-around;
    width: 20px;
    height: 16px;
    cursor: pointer;

    span {
      display: block;
      width: 100%;
      height: 2px;
      background-color: #4b5563;
      border-radius: 1px;
      transition: all 0.3s ease;
    }

    &.is-active span:nth-child(1) {
      transform: rotate(45deg) translate(5px, 5px);
    }

    &.is-active span:nth-child(2) {
      opacity: 0;
    }

    &.is-active span:nth-child(3) {
      transform: rotate(-45deg) translate(7px, -6px);
    }
  }

  // 面包屑包装
  .breadcrumb-wrapper {
    margin-left: 16px;
  }

  // 顶部导航包装
  .topmenu-wrapper {
    margin-left: 16px;
  }

  // 搜索框包装
  .search-wrapper {
    flex: 1;
    max-width: 400px;
    margin-left: 20px;

    .global-search {
      .el-input__inner {
        height: 36px;
        border-radius: 8px;
        background: #f8fafc;
        border: 1px solid #e2e8f0;

        &:focus {
          background: #ffffff;
          border-color: #4f46e5;
        }
      }

      .el-input__prefix {
        .el-input__icon {
          color: #94a3b8;
        }
      }
    }
  }

  // 通知铃铛
  .notification-bell {
    position: relative;
    width: 24px;
    height: 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #64748b;

    .notification-dot {
      position: absolute;
      top: 0;
      right: 0;
      width: 8px;
      height: 8px;
      background: #ef4444;
      border-radius: 50%;
      animation: pulse 2s infinite;
    }
  }

  // 全屏图标
  .fullscreen-icon,
  .theme-icon,
  .settings-icon {
    font-size: 20px;
    color: #64748b;
    transition: color 0.3s ease;

    &:hover {
      color: #4f46e5;
    }
  }

  // 用户下拉菜单
  .user-dropdown {
    .user-info {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 6px;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.3s ease;

      &:hover {
        background: #f8fafc;
      }

      .user-avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        object-fit: cover;
        border: 2px solid #e2e8f0;
      }

      .user-details {
        display: flex;
        flex-direction: column;
        overflow: hidden;

        .user-name {
          font-size: 14px;
          font-weight: 500;
          color: #1f2937;
        }

        .user-role {
          font-size: 12px;
          color: #6b7280;
        }
      }

      .user-arrow {
        font-size: 12px;
        color: #9ca3af;
        transition: transform 0.3s ease;
      }

      &:hover .user-arrow {
        transform: rotate(180deg);
      }
    }

    ::v-deep .el-dropdown-menu {
      .dropdown-header {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 16px;
        border-bottom: 1px solid #e5e7eb;
        margin-bottom: 8px;

        .dropdown-avatar {
          width: 40px;
          height: 40px;
          border-radius: 50%;
          object-fit: cover;
        }

        .dropdown-info {
          .dropdown-name {
            font-size: 14px;
            font-weight: 500;
            color: #1f2937;
          }

          .dropdown-role {
            font-size: 12px;
            color: #6b7280;
          }
        }
      }

      .el-dropdown-item {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        padding: 10px 16px;

        i {
          font-size: 16px;
          color: #6b7280;
        }
      }
    }
  }
}

// 通知弹窗样式
::v-deep .notification-dialog {
  border-radius: 16px;
  overflow: hidden;

  .el-dialog__header {
    padding: 20px;
    background: #f8fafc;
    border-bottom: 1px solid #e5e7eb;

    .el-dialog__title {
      font-size: 18px;
      font-weight: 600;
      color: #1f2937;
    }
  }

  .el-dialog__body {
    padding: 0;

    .notification-list {
      .empty-notifications {
        text-align: center;
        padding: 40px 20px;
        color: #9ca3af;

        i {
          font-size: 32px;
          margin-bottom: 8px;
          display: block;
        }

        span {
          font-size: 14px;
        }
      }

      .notification-item {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        padding: 16px 20px;
        border-bottom: 1px solid #f1f5f9;
        cursor: pointer;
        transition: all 0.3s ease;

        &:hover {
          background: #f8fafc;
        }

        &.unread {
          background: #f0f9ff;
          border-left: 3px solid #3b82f6;
          padding-left: 17px;
        }

        .notification-icon {
          width: 36px;
          height: 36px;
          border-radius: 8px;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;

          i {
            font-size: 18px;
            color: #ffffff;
          }
        }

        .notification-content {
          flex: 1;

          .notification-title {
            font-size: 14px;
            font-weight: 500;
            color: #1f2937;
            margin-bottom: 4px;
          }

          .notification-desc {
            font-size: 13px;
            color: #6b7280;
            line-height: 1.4;
            margin-bottom: 4px;
          }

          .notification-time {
            font-size: 12px;
            color: #9ca3af;
          }
        }

        .notification-badge {
          width: 8px;
          height: 8px;
          background: #3b82f6;
          border-radius: 50%;
          flex-shrink: 0;
        }
      }
    }

    .notification-footer {
      display: flex;
      justify-content: flex-end;
      gap: 8px;
      padding: 16px 20px;
      border-top: 1px solid #e5e7eb;
    }
  }
}

// 动画
@keyframes pulse {
  0% {
    transform: scale(1);
    opacity: 1;
  }
  50% {
    transform: scale(1.2);
    opacity: 0.7;
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

// 响应式设计
@media (max-width: 768px) {
  .modern-navbar {
    .search-wrapper {
      display: none;
    }

    .navbar-item {
      &:not(.notification-bell) {
        display: none;
      }
    }
  }
}

@media (max-width: 480px) {
  .modern-navbar {
    .navbar-left {
      .breadcrumb-wrapper,
      .topmenu-wrapper {
        display: none;
      }
    }

    .user-dropdown .user-details {
      display: none;
    }
  }
}
</style>
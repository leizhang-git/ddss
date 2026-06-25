<template>
  <div :class="{'has-logo':showLogo, 'modern-sidebar': true, [settings.sideTheme]: true}"
       :style="{ backgroundColor: settings.sideTheme === 'theme-dark' ? variables.menuBackground : variables.menuLightBackground }">
    <!-- Logo 区域 -->
    <div class="sidebar-header" :class="{ 'collapsed': isCollapse }">
      <logo v-if="showLogo" :collapse="isCollapse"/>
      <!-- 折叠按钮 -->
      <div v-if="!isCollapse" class="collapse-trigger" @click="toggleSidebar">
        <i :class="['collapse-icon', sidebar.opened ? 'el-icon-close' : 'el-icon-menu']"></i>
      </div>
    </div>

    <!-- 搜索框（展开时显示） -->
    <div v-if="!isCollapse && showSearch" class="sidebar-search">
      <el-input
        v-model="searchQuery"
        placeholder="搜索菜单..."
        prefix-icon="el-icon-search"
        clearable
        @input="handleSearch"
        @clear="clearSearch"
      />
    </div>

    <!-- 菜单区域 -->
    <el-scrollbar :class="settings.sideTheme" wrap-class="scrollbar-wrapper">
      <el-menu
        :active-text-color="settings.theme"
        :background-color="settings.sideTheme === 'theme-dark' ? variables.menuBackground : variables.menuLightBackground"
        :collapse="isCollapse"
        :collapse-transition="false"
        :default-active="activeMenu"
        :text-color="settings.sideTheme === 'theme-dark' ? variables.menuColor : variables.menuLightColor"
        :unique-opened="true"
        mode="vertical"
        class="modern-menu"
      >
        <!-- 菜单项 -->
        <sidebar-item
          v-for="(route, index) in filteredRoutes"
          :key="route.path + index"
          :base-path="route.path"
          :item="route"
        />

        <!-- 未搜索到结果的提示 -->
        <div v-if="searchQuery && filteredRoutes.length === 0" class="no-results">
          <i class="el-icon-search"></i>
          <span>未找到相关菜单</span>
        </div>
      </el-menu>
    </el-scrollbar>

    <!-- 底部信息 -->
    <div v-if="!isCollapse" class="sidebar-footer">
      <div class="user-info" @click="showUserMenu">
        <img :src="userAvatar" class="user-avatar">
        <div class="user-details">
          <div class="user-name">{{ userName }}</div>
          <div class="user-role">{{ userRole }}</div>
        </div>
        <i class="el-icon-arrow-right"></i>
      </div>
    </div>
  </div>
</template>

<script>
import {mapGetters, mapState} from "vuex"
import Logo from "./Logo"
import SidebarItem from "./SidebarItem"
import variables from "@/assets/styles/variables.scss"

export default {
  components: {SidebarItem, Logo},
  data() {
    return {
      searchQuery: '',
      showSearch: true,
      filteredRoutes: [],
      menuAnimation: true
    }
  },
  computed: {
    ...mapState(["settings"]),
    ...mapGetters(["sidebarRouters", "sidebar"]),
    activeMenu() {
      const route = this.$route
      const {meta, path} = route
      // if set path, the sidebar will highlight the path you set
      if (meta.activeMenu) {
        return meta.activeMenu
      }
      return path
    },
    showLogo() {
      return this.$store.state.settings.sidebarLogo
    },
    variables() {
      return variables
    },
    isCollapse() {
      return !this.sidebar.opened
    },
    // 用户信息
    userAvatar() {
      return this.$store.state.user.avatar || '/assets/images/avatar.png'
    },
    userName() {
      return this.$store.state.user.name || '用户'
    },
    userRole() {
      return this.$store.state.user.role || '管理员'
    }
  },
  watch: {
    // 监听路由变化
    '$route': {
      handler() {
        this.updateActiveMenu()
      },
      immediate: true
    },
    // 监听菜单搜索
    searchQuery(val) {
      if (val) {
        this.filterMenu(val)
      } else {
        this.filteredRoutes = this.sidebarRouters
      }
    },
    // 监听菜单动画
    sidebar: {
      handler() {
        this.menuAnimation = false
        setTimeout(() => {
          this.menuAnimation = true
        }, 300)
      },
      deep: true
    }
  },
  mounted() {
    this.filteredRoutes = this.sidebarRouters
    // 初始化时添加动画类
    this.$nextTick(() => {
      this.menuAnimation = true
    })
  },
  methods: {
    // 切换侧边栏
    toggleSidebar() {
      this.$store.dispatch('app/toggleSideBar')
    },

    // 更新活动菜单
    updateActiveMenu() {
      this.filteredRoutes = this.sidebarRouters
    },

    // 搜索菜单
    handleSearch() {
      if (this.searchQuery.trim()) {
        this.filterMenu(this.searchQuery.trim())
      }
    },

    // 过滤菜单
    filterMenu(query) {
      const result = []
      const search = (items) => {
        items.forEach(item => {
          if (item.hidden) return

          // 检查标题是否匹配
          if (item.meta && item.meta.title &&
              item.meta.title.toLowerCase().includes(query.toLowerCase())) {
            result.push(item)
          }

          // 递归搜索子菜单
          if (item.children) {
            const children = []
            search(item.children)
            if (children.length > 0) {
              result.push({
                ...item,
                children: children
              })
            }
          }
        })
      }

      search(this.sidebarRouters)
      this.filteredRoutes = result
    },

    // 清除搜索
    clearSearch() {
      this.searchQuery = ''
      this.filteredRoutes = this.sidebarRouters
    },

    // 显示用户菜单
    showUserMenu() {
      this.$message.info('用户菜单功能开发中...')
    }
  }
}
</script>

<style lang="scss" scoped>
// 现代化侧边栏样式
.modern-sidebar {
  height: 100%;
  display: flex;
  flex-direction: column;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  backdrop-filter: blur(10px);

  // 侧边栏头部
  .sidebar-header {
    height: 60px;
    padding: 0 16px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: rgba(255, 255, 255, 0.05);
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    transition: all 0.3s ease;

    &.collapsed {
      justify-content: center;
      padding: 0;
    }

    .collapse-trigger {
      width: 32px;
      height: 32px;
      border-radius: 8px;
      background: rgba(255, 255, 255, 0.1);
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      transition: all 0.3s ease;

      &:hover {
        background: rgba(255, 255, 255, 0.2);
        transform: scale(1.05);
      }

      .collapse-icon {
        color: #6b7280;
        font-size: 18px;
        transition: color 0.3s ease;
      }
    }
  }

  // 搜索框
  .sidebar-search {
    padding: 16px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);

    .el-input {
      .el-input__inner {
        background: rgba(255, 255, 255, 0.1);
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-radius: 8px;
        color: #ffffff;

        &:focus {
          background: rgba(255, 255, 255, 0.15);
          border-color: #4f46e5;
        }

        &::placeholder {
          color: rgba(255, 255, 255, 0.5);
        }
      }

      .el-input__prefix {
        .el-input__icon {
          color: rgba(255, 255, 255, 0.6);
        }
      }
    }
  }

  // 滚动条样式
  ::v-deep .el-scrollbar {
    height: calc(100% - 60px);

    &.theme-dark {
      .el-scrollbar__view {
        background: transparent;
      }
    }

    &.light {
      .el-scrollbar__view {
        background: #ffffff;
      }
    }

    .scrollbar-wrapper {
      overflow-x: hidden !important;

      .el-scrollbar__bar {
        &.is-vertical {
          right: 0;
          width: 4px;
        }
      }
    }
  }

  // 现代化菜单
  .modern-menu {
    border: none;
    padding: 8px 0;

    // 菜单项基础样式
    ::v-deep .el-menu-item, ::v-deep .el-submenu__title {
      height: 48px;
      line-height: 48px;
      margin: 4px 8px;
      border-radius: 12px;
      transition: all 0.3s ease;
      position: relative;
      overflow: hidden;

      // 图标样式
      .svg-icon {
        margin-right: 12px;
        font-size: 18px;
        transition: all 0.3s ease;
      }

      // 文字样式
      span {
        font-size: 14px;
        font-weight: 500;
        transition: all 0.3s ease;
      }

      // hover效果
      &:hover {
        background: rgba(255, 255, 255, 0.08);
        transform: translateX(4px);
      }

      &.is-active {
        background: rgba(79, 70, 229, 0.2);
        border-left: 3px solid #4f46e5;
        color: #4f46e5;

        .svg-icon {
          color: #4f46e5;
        }
      }
    }

    // 子菜单
    ::v-deep .el-submenu {
      .el-submenu__title {
        &:hover {
          background: rgba(255, 255, 255, 0.08);
        }
      }

      .el-menu {
        background: transparent;

        .el-menu-item {
          margin-left: 24px;
          margin-right: 8px;
        }
      }
    }

    // 折叠状态
    &.el-menu--collapse {
      .el-menu-item, .el-submenu__title {
        margin: 0;
        border-radius: 0;
        height: 56px;
        line-height: 56px;

        &:hover {
          transform: translateX(0);
        }

        &.is-active {
          border-left: none;
          background: rgba(79, 70, 229, 0.1);
        }
      }
    }
  }

  // 无搜索结果
  .no-results {
    padding: 40px 16px;
    text-align: center;
    color: rgba(255, 255, 255, 0.5);

    i {
      font-size: 24px;
      margin-bottom: 8px;
      display: block;
    }

    span {
      font-size: 14px;
    }
  }

  // 侧边栏底部
  .sidebar-footer {
    padding: 16px;
    border-top: 1px solid rgba(255, 255, 255, 0.1);

    .user-info {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px;
      border-radius: 12px;
      cursor: pointer;
      transition: all 0.3s ease;

      &:hover {
        background: rgba(255, 255, 255, 0.08);
        transform: translateY(-2px);
      }

      .user-avatar {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        border: 2px solid rgba(255, 255, 255, 0.3);
      }

      .user-details {
        flex: 1;
        overflow: hidden;

        .user-name {
          font-size: 14px;
          font-weight: 500;
          color: #ffffff;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .user-role {
          font-size: 12px;
          color: rgba(255, 255, 255, 0.6);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }
      }

      .el-icon-arrow-right {
        color: rgba(255, 255, 255, 0.6);
        transition: transform 0.3s ease;
      }

      &:hover .el-icon-arrow-right {
        transform: translateX(4px);
      }
    }
  }

  // 深色主题特定样式
  &.theme-dark {
    background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);

    .sidebar-header {
      background: rgba(30, 41, 59, 0.8);
    }
  }

  // 浅色主题特定样式
  &.light {
    background: #ffffff;
    box-shadow: 2px 0 10px rgba(0, 0, 0, 0.05);

    .sidebar-header {
      background: #f8fafc;
      border-bottom-color: #e2e8f0;
    }

    .sidebar-search .el-input .el-input__inner {
      background: #f8fafc;
      border-color: #e2e8f0;

      &:focus {
        background: #ffffff;
        border-color: #4f46e5;
      }
    }

    .sidebar-footer {
      border-top-color: #e2e8f0;
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .modern-sidebar {
    .sidebar-header {
      .collapse-trigger {
        display: flex;
      }
    }

    .sidebar-search {
      display: none;
    }

    .sidebar-footer {
      display: none;
    }
  }
}

// 动画效果
@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.menu-enter-active {
  animation: slideIn 0.3s ease;
}
</style>

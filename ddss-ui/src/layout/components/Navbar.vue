<template>
  <div class="navbar">
    <div class="navbar-left">
      <div class="hamburger" @click="toggleSideBar">
        <i :class="['hamburger-icon', sidebar.opened ? 'is-active' : '']">
          <span></span><span></span><span></span>
        </i>
      </div>
      <breadcrumb v-if="!topNav" class="breadcrumb" />
      <top-nav v-if="topNav" class="top-nav" />
    </div>

    <div class="navbar-right">
      <el-tooltip content="全屏" placement="bottom" :open-delay="300">
        <div class="nav-icon-btn" @click="toggleFullscreen">
          <i class="el-icon-full-screen"></i>
        </div>
      </el-tooltip>

      <el-tooltip content="布局设置" placement="bottom" :open-delay="300">
        <div class="nav-icon-btn" @click="setLayout">
          <i class="el-icon-setting"></i>
        </div>
      </el-tooltip>

      <el-dropdown trigger="click" @command="handleCommand" class="user-dropdown">
        <div class="user-trigger">
          <img :src="avatar" class="user-avatar" />
          <span class="user-name">{{ nickName }}</span>
          <i class="el-icon-arrow-down user-arrow"></i>
        </div>
        <el-dropdown-menu slot="dropdown">
          <div class="dropdown-header">
            <img :src="avatar" class="dropdown-avatar" />
            <div>
              <div class="dropdown-name">{{ nickName }}</div>
            </div>
          </div>
          <el-dropdown-item command="profile">
            <i class="el-icon-user"></i> 个人中心
          </el-dropdown-item>
          <el-dropdown-item divided command="logout">
            <i class="el-icon-switch-button"></i> 退出登录
          </el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import Breadcrumb from '@/components/Breadcrumb'
import TopNav from '@/components/TopNav'

export default {
  emits: ['setLayout'],
  components: { Breadcrumb, TopNav },
  computed: {
    ...mapGetters(['sidebar', 'avatar', 'nickName', 'device']),
    setting() {
      return this.$store.state.settings.showSettings
    },
    topNav() {
      return this.$store.state.settings.topNav
    }
  },
  methods: {
    toggleSideBar() {
      this.$store.dispatch('app/toggleSideBar')
    },
    setLayout() {
      this.$emit('setLayout')
    },
    toggleFullscreen() {
      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen()
      } else {
        document.exitFullscreen()
      }
    },
    handleCommand(command) {
      if (command === 'profile') {
        this.$router.push('/user/profile')
      } else if (command === 'logout') {
        this.$confirm('确定注销并退出系统吗？', '提示', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }).then(() => {
          this.$store.dispatch('LogOut').then(() => {
            location.href = '/index'
          })
        }).catch(() => {})
      }
    }
  }
}
</script>

<style lang="scss" scoped>
@import '~@/assets/styles/variables.scss';

.navbar {
  height: $header-height;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 $space-6;
  background: rgba(255, 255, 255, 0.72);
  backdrop-filter: saturate(180%) blur(20px);
  -webkit-backdrop-filter: saturate(180%) blur(20px);
  border-bottom: 1px solid $border-lighter;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
  z-index: 100;

  .navbar-left {
    display: flex;
    align-items: center;
    gap: $space-4;
    flex: 1;
    min-width: 0;
  }

  .navbar-right {
    display: flex;
    align-items: center;
    gap: $space-3;
  }

  .hamburger {
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    border-radius: $radius-sm;
    transition: background $duration-fast $ease;

    &:hover {
      background: $bg-subtle;
    }

    .hamburger-icon {
      display: flex;
      flex-direction: column;
      justify-content: center;
      gap: 4px;
      width: 18px;
      height: 14px;

      span {
        display: block;
        width: 100%;
        height: 2px;
        background: $gray-600;
        border-radius: 1px;
        transition: all $duration-base $ease;
        transform-origin: center;
      }

      &.is-active span:nth-child(1) {
        transform: rotate(45deg) translate(4px, 4px);
        width: 18px;
      }
      &.is-active span:nth-child(2) {
        opacity: 0;
      }
      &.is-active span:nth-child(3) {
        transform: rotate(-45deg) translate(4px, -4px);
        width: 18px;
      }
    }
  }

  .breadcrumb {
    margin-left: $space-2;
  }

  .nav-icon-btn {
    width: 36px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    border-radius: $radius-full;
    color: $gray-500;
    transition: all $duration-fast $ease;

    i {
      font-size: 18px;
    }

    &:hover {
      background: $bg-subtle;
      color: $text-primary;
    }
  }

  .user-dropdown {
    .user-trigger {
      display: flex;
      align-items: center;
      gap: $space-2;
      padding: $space-1 $space-3 $space-1 $space-1;
      border-radius: $radius-full;
      cursor: pointer;
      transition: background $duration-fast $ease;

      &:hover {
        background: $bg-subtle;
      }

      .user-avatar {
        width: 30px;
        height: 30px;
        border-radius: $radius-full;
        object-fit: cover;
      }

      .user-name {
        font-size: $fs-base;
        font-weight: $fw-medium;
        color: $text-primary;
        max-width: 120px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .user-arrow {
        font-size: 11px;
        color: $gray-400;
        transition: transform $duration-fast $ease;
      }

      &:hover .user-arrow {
        transform: rotate(180deg);
      }
    }
  }
}

::v-deep .el-dropdown-menu {
  border-radius: $radius-base !important;
  border: 1px solid $border-light;
  box-shadow: $shadow-lg !important;
  padding: $space-1;
  min-width: 180px;

  .dropdown-header {
    display: flex;
    align-items: center;
    gap: $space-3;
    padding: $space-3 $space-3 $space-2;
    margin-bottom: $space-1;
    border-bottom: 1px solid $border-lighter;

    .dropdown-avatar {
      width: 36px;
      height: 36px;
      border-radius: $radius-full;
      object-fit: cover;
    }

    .dropdown-name {
      font-size: $fs-base;
      font-weight: $fw-semibold;
      color: $text-primary;
    }
  }

  .el-dropdown-menu__item {
    border-radius: $radius-xs;
    margin: 2px 0;
    padding: $space-2 $space-3;
    font-size: $fs-base;
    color: $text-regular;
    transition: all $duration-fast $ease;

    &:not(.is-disabled):hover {
      background: $bg-subtle;
      color: $text-primary;
    }

    i {
      margin-right: $space-2;
      color: $gray-400;
    }
  }
}

@media (max-width: 768px) {
  .navbar {
    padding: 0 $space-4;

    .user-name {
      display: none;
    }
  }
}
</style>

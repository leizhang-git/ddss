<template>
  <div class="sidebar-wrapper" :class="settings.sideTheme">
    <logo v-if="showLogo" :collapse="isCollapse" />
    <el-scrollbar wrap-class="scrollbar-wrapper">
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :collapse-transition="false"
        :unique-opened="true"
        :background-color="bgColor"
        :text-color="textColor"
        :active-text-color="activeColor"
        mode="vertical"
      >
        <sidebar-item
          v-for="(route, index) in sidebarRouters"
          :key="route.path + index"
          :base-path="route.path"
          :item="route"
        />
      </el-menu>
    </el-scrollbar>
  </div>
</template>

<script>
import { mapGetters, mapState } from 'vuex'
import Logo from './Logo'
import SidebarItem from './SidebarItem'
import variables from '@/assets/styles/variables.scss'

export default {
  components: { SidebarItem, Logo },
  computed: {
    ...mapState(['settings']),
    ...mapGetters(['sidebarRouters', 'sidebar']),
    activeMenu() {
      const route = this.$route
      const { meta, path } = route
      if (meta.activeMenu) return meta.activeMenu
      return path
    },
    showLogo() {
      return this.$store.state.settings.sidebarLogo
    },
    isCollapse() {
      return !this.sidebar.opened
    },
    variables() {
      return variables
    },
    isDark() {
      return this.settings.sideTheme !== 'theme-light' && this.settings.sideTheme !== 'light'
    },
    bgColor() {
      return this.isDark ? variables.menuBackground : variables.menuLightBackground
    },
    textColor() {
      return this.isDark ? variables.menuColor : variables.menuLightColor
    },
    activeColor() {
      return this.isDark ? variables.menuColorActive : variables.menuLightColorActive
    }
  }
}
</script>

<style lang="scss" scoped>
@import '~@/assets/styles/variables.scss';

.sidebar-wrapper {
  height: 100%;
  display: flex;
  flex-direction: column;

  ::v-deep .el-scrollbar {
    flex: 1;
  }
}
</style>

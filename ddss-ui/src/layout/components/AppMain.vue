<template>
  <section class="app-main">
    <transition mode="out-in" name="fade-transform">
      <keep-alive :include="cachedViews">
        <router-view v-if="!$route.meta.link" :key="key"/>
      </keep-alive>
    </transition>
    <iframe-toggle/>
    <copyright/>
  </section>
</template>

<script>
import copyright from "./Copyright/index"
import iframeToggle from "./IframeToggle/index"

export default {
  name: 'AppMain',
  components: {iframeToggle, copyright},
  computed: {
    cachedViews() {
      return this.$store.state.tagsView.cachedViews
    },
    key() {
      return this.$route.path
    }
  },
  watch: {
    $route() {
      this.addIframe()
    }
  },
  mounted() {
    this.addIframe()
  },
  methods: {
    addIframe() {
      const {name} = this.$route
      if (name && this.$route.meta.link) {
        this.$store.dispatch('tagsView/addIframeView', this.$route)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
@import '~@/assets/styles/variables.scss';

.app-main {
  min-height: calc(100vh - #{$header-height});
  width: 100%;
  position: relative;
  background: $bg-base;
}

.fixed-header + .app-main {
  margin-top: $header-height;
  height: calc(100vh - #{$header-height});
  overflow-y: auto;
  min-height: 0;
}

.app-main:has(.copyright) {
  padding-bottom: 36px;
}

.hasTagsView {
  .app-main {
    min-height: calc(100vh - #{$header-height} - #{$tags-height});
  }

  .fixed-header + .app-main {
    margin-top: calc(#{$header-height} + #{$tags-height});
    height: calc(100vh - #{$header-height} - #{$tags-height});
    min-height: 0;
  }
}
</style>

<style lang="scss">
::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

::-webkit-scrollbar-track {
  background-color: transparent;
}

::-webkit-scrollbar-thumb {
  background-color: #c0c0c0;
  border-radius: 3px;
}
</style>

<template>
  <div id="tags-view-container" class="tags-view-container">
    <div class="tags-wrapper">
      <div v-show="showLeftArrow" class="scroll-arrow left-arrow" @click="scrollLeft">
        <i class="el-icon-arrow-left"></i>
      </div>

      <scroll-pane ref="scrollPane" class="tags-scroll-container" @scroll="handleScroll">
        <router-link
          v-for="tag in visitedViews"
          ref="tag"
          :key="tag.path"
          :to="{ path: tag.path, query: tag.query, fullPath: tag.fullPath }"
          tag="span"
          class="tags-view-item"
          :class="{ active: isActive(tag), affix: isAffix(tag) }"
          @click.middle.native="!isAffix(tag) ? closeSelectedTag(tag) : ''"
          @contextmenu.prevent.native="openMenu(tag, $event)"
        >
          {{ tag.title }}
          <i v-if="!isAffix(tag)" class="el-icon-close" @click.prevent.stop="closeSelectedTag(tag)"></i>
        </router-link>
      </scroll-pane>

      <div v-show="showRightArrow" class="scroll-arrow right-arrow" @click="scrollRight">
        <i class="el-icon-arrow-right"></i>
      </div>
    </div>

    <ul v-show="visible" :style="{left: left+'px', top: top+'px'}" class="contextmenu">
      <li @click="refreshSelectedTag(selectedTag)"><i class="el-icon-refresh"></i> 刷新页面</li>
      <li v-if="!isAffix(selectedTag)" @click="closeSelectedTag(selectedTag)"><i class="el-icon-close"></i> 关闭当前</li>
      <li @click="closeOthersTags"><i class="el-icon-circle-close"></i> 关闭其他</li>
      <li v-if="!isFirstView()" @click="closeLeftTags"><i class="el-icon-back"></i> 关闭左侧</li>
      <li v-if="!isLastView()" @click="closeRightTags"><i class="el-icon-right"></i> 关闭右侧</li>
      <li @click="closeAllTags(selectedTag)"><i class="el-icon-delete"></i> 全部关闭</li>
    </ul>
  </div>
</template>

<script>
import ScrollPane from './ScrollPane'
import path from 'path'

export default {
  components: { ScrollPane },
  data() {
    return {
      visible: false,
      top: 0,
      left: 0,
      selectedTag: {},
      affixTags: [],
      showLeftArrow: false,
      showRightArrow: false
    }
  },
  computed: {
    visitedViews() {
      return this.$store.state.tagsView.visitedViews
    },
    routes() {
      return this.$store.state.permission.routes
    },
    theme() {
      return this.$store.state.settings.theme
    }
  },
  watch: {
    $route() {
      this.addTags()
      this.moveToCurrentTag()
      this.checkScrollButtons()
    },
    visible(value) {
      if (value) {
        document.body.addEventListener('click', this.closeMenu)
      } else {
        document.body.removeEventListener('click', this.closeMenu)
      }
    },
    'visitedViews.length'() {
      this.checkScrollButtons()
    }
  },
  mounted() {
    this.initTags()
    this.addTags()
    this.checkScrollButtons()
  },
  methods: {
    isActive(route) {
      return route.path === this.$route.path
    },
    isAffix(tag) {
      return tag.meta && tag.meta.affix
    },
    isFirstView() {
      try {
        return this.selectedTag.fullPath === '/index' || this.selectedTag.fullPath === this.visitedViews[1].fullPath
      } catch (err) {
        return false
      }
    },
    isLastView() {
      try {
        return this.selectedTag.fullPath === this.visitedViews[this.visitedViews.length - 1].fullPath
      } catch (err) {
        return false
      }
    },
    filterAffixTags(routes, basePath = '/') {
      let tags = []
      routes.forEach(route => {
        if (route.meta && route.meta.affix) {
          const tagPath = path.resolve(basePath, route.path)
          tags.push({
            fullPath: tagPath,
            path: tagPath,
            name: route.name,
            meta: { ...route.meta }
          })
        }
        if (route.children) {
          const tempTags = this.filterAffixTags(route.children, route.path)
          if (tempTags.length >= 1) {
            tags = [...tags, ...tempTags]
          }
        }
      })
      return tags
    },
    initTags() {
      const affixTags = this.affixTags = this.filterAffixTags(this.routes)
      for (const tag of affixTags) {
        if (tag.name) {
          this.$store.dispatch('tagsView/addVisitedView', tag)
        }
      }
    },
    addTags() {
      const { name } = this.$route
      if (name) {
        this.$store.dispatch('tagsView/addView', this.$route)
      }
    },
    moveToCurrentTag() {
      const tags = this.$refs.tag
      this.$nextTick(() => {
        for (const tag of tags) {
          if (tag.to.path === this.$route.path) {
            this.$refs.scrollPane.moveToTarget(tag)
            if (tag.to.fullPath !== this.$route.fullPath) {
              this.$store.dispatch('tagsView/updateVisitedView', this.$route)
            }
            break
          }
        }
      })
    },
    refreshSelectedTag(view) {
      this.$tab.refreshPage(view)
      if (this.$route.meta.link) {
        this.$store.dispatch('tagsView/delIframeView', this.$route)
      }
    },
    closeSelectedTag(view) {
      this.$tab.closePage(view).then(({ visitedViews }) => {
        if (this.isActive(view)) {
          this.toLastView(visitedViews, view)
        }
      })
    },
    closeRightTags() {
      this.$tab.closeRightPage(this.selectedTag).then(visitedViews => {
        if (!visitedViews.find(i => i.fullPath === this.$route.fullPath)) {
          this.toLastView(visitedViews)
        }
      })
    },
    closeLeftTags() {
      this.$tab.closeLeftPage(this.selectedTag).then(visitedViews => {
        if (!visitedViews.find(i => i.fullPath === this.$route.fullPath)) {
          this.toLastView(visitedViews)
        }
      })
    },
    closeOthersTags() {
      this.$router.push(this.selectedTag.fullPath).catch(() => {})
      this.$tab.closeOtherPage(this.selectedTag).then(() => {
        this.moveToCurrentTag()
      })
    },
    closeAllTags(view) {
      this.$tab.closeAllPage().then(({ visitedViews }) => {
        if (this.affixTags.some(tag => tag.path === this.$route.path)) {
          return
        }
        this.toLastView(visitedViews, view)
      })
    },
    toLastView(visitedViews, view) {
      const latestView = visitedViews.slice(-1)[0]
      if (latestView) {
        this.$router.push(latestView.fullPath)
      } else {
        if (view.name === 'Dashboard') {
          this.$router.replace({ path: '/redirect' + view.fullPath })
        } else {
          this.$router.push('/')
        }
      }
    },
    openMenu(tag, e) {
      const menuMinWidth = 105
      const offsetLeft = this.$el.getBoundingClientRect().left
      const offsetWidth = this.$el.offsetWidth
      const maxLeft = offsetWidth - menuMinWidth
      const left = e.clientX - offsetLeft + 15
      if (left > maxLeft) {
        this.left = maxLeft
      } else {
        this.left = left
      }
      this.top = e.clientY
      this.visible = true
      this.selectedTag = tag
    },
    closeMenu() {
      this.visible = false
    },
    handleScroll() {
      this.closeMenu()
      this.checkScrollButtons()
    },
    checkScrollButtons() {
      const scrollContainer = this.$refs.scrollPane.$el
      if (scrollContainer) {
        this.showLeftArrow = scrollContainer.scrollLeft > 0
        this.showRightArrow = scrollContainer.scrollLeft < scrollContainer.scrollWidth - scrollContainer.clientWidth
      }
    },
    scrollLeft() {
      const scrollContainer = this.$refs.scrollPane.$el
      if (scrollContainer) {
        scrollContainer.scrollBy({ left: -200, behavior: 'smooth' })
      }
    },
    scrollRight() {
      const scrollContainer = this.$refs.scrollPane.$el
      if (scrollContainer) {
        scrollContainer.scrollBy({ left: 200, behavior: 'smooth' })
      }
    }
  }
}
</script>

<style lang="scss" scoped>
@import '~@/assets/styles/variables.scss';

.tags-view-container {
  height: $tags-height;
  width: 100%;
  display: flex;
  align-items: center;
  padding: 0 $space-4;
  background: $bg-surface;
  border-bottom: 1px solid $border-lighter;

  .tags-wrapper {
    position: relative;
    display: flex;
    align-items: center;
    height: 100%;
    width: 100%;

    .scroll-arrow {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      width: 24px;
      height: 24px;
      background: transparent;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      z-index: 10;
      color: $gray-400;
      transition: color $duration-fast $ease;

      &:hover {
        color: $text-primary;
      }

      &.left-arrow { left: 0; }
      &.right-arrow { right: 0; }

      i { font-size: 14px; }
    }

    .tags-scroll-container {
      flex: 1;
      height: 100%;
      overflow: hidden;
      white-space: nowrap;
      padding: 0 28px;
      min-width: 0;
    }
  }

  .tags-view-item {
    display: inline-flex;
    align-items: center;
    height: 28px;
    line-height: 28px;
    padding: 0 12px;
    margin: 0 4px 0 0;
    font-size: $fs-sm;
    color: $text-secondary;
    background: $bg-subtle;
    border: 1px solid $border-light;
    border-radius: $radius-full;
    cursor: pointer;
    transition: all $duration-fast $ease;
    white-space: nowrap;
    vertical-align: middle;

    &:hover {
      color: $brand;
      border-color: rgba(0, 113, 227, 0.25);
      background: $brand-bg;
    }

    // 固定首页：淡蓝底
    &.affix {
      background: $brand-bg;
      color: $brand;
      border-color: transparent;
      font-weight: $fw-medium;

      &:hover {
        background: darken($brand-bg, 3%);
      }
    }

    // 当前激活：实心蓝，优先级高于 affix
    &.active {
      background: $brand;
      color: #fff;
      border-color: $brand;
      font-weight: $fw-medium;
      box-shadow: 0 2px 8px rgba(0, 113, 227, 0.25);

      &:hover {
        background: $brand-hover;
        border-color: $brand-hover;
        color: #fff;
      }
    }

    .el-icon-close {
      width: 14px;
      height: 14px;
      line-height: 14px;
      border-radius: $radius-full;
      text-align: center;
      margin-left: 6px;
      font-size: 12px;
      color: inherit;
      opacity: 0.7;
      transition: all $duration-fast $ease;

      &:hover {
        opacity: 1;
        background: rgba(0, 0, 0, 0.08);
        color: inherit;
      }
    }

    &.active .el-icon-close {
      opacity: 0.85;

      &:hover {
        background: rgba(255, 255, 255, 0.25);
        color: #fff;
      }
    }
  }

  .contextmenu {
    margin: 0;
    background: $bg-surface;
    z-index: 3000;
    position: absolute;
    list-style: none;
    padding: $space-1;
    border-radius: $radius-sm;
    border: 1px solid $border-light;
    box-shadow: $shadow-lg;
    font-size: $fs-sm;

    li {
      margin: 0;
      padding: $space-2 $space-3;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: $space-2;
      border-radius: $radius-xs;
      color: $text-regular;
      transition: all $duration-fast $ease;

      &:hover {
        background: $bg-subtle;
        color: $text-primary;
      }

      i {
        font-size: 14px;
        color: $gray-400;
      }
    }
  }
}
</style>

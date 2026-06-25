<template>
  <div id="tags-view-container" class="modern-tags-view">
    <!-- 标签搜索栏 -->
    <div v-if="showSearch" class="tags-search">
      <el-input
        v-model="searchQuery"
        placeholder="搜索标签..."
        prefix-icon="el-icon-search"
        clearable
        @input="handleSearch"
        @clear="clearSearch"
        class="tag-search-input"
      />
      <div class="search-results" v-if="searchQuery && filteredTags.length > 0">
        <div
          v-for="tag in filteredTags"
          :key="tag.path"
          class="search-result-item"
          @click="navigateToTag(tag)"
        >
          <i v-if="tag.meta && tag.meta.icon" class="tag-icon">
            <svg-icon :icon-class="tag.meta.icon"/>
          </i>
          <span class="tag-title">{{ tag.title }}</span>
        </div>
      </div>
    </div>

    <!-- 标签滚动区域 -->
    <div class="tags-wrapper">
      <!-- 左箭头 -->
      <div v-show="showLeftArrow" class="scroll-arrow left-arrow" @click="scrollLeft">
        <i class="el-icon-arrow-left"></i>
      </div>

      <!-- 标签容器 -->
      <scroll-pane
        ref="scrollPane"
        class="tags-scroll-container"
        @scroll="handleScroll"
      >
        <!-- 标签分组 -->
        <div v-for="(group, groupIndex) in groupedTags" :key="groupIndex" class="tag-group">
          <div v-if="group.length > 1" class="group-title">{{ group[0] && group[0].meta && group[0].meta.module || '常用' }}</div>
          <div class="tag-list">
            <div
              v-for="tag in group"
              :key="tag.path"
              ref="tag"
              :class="[
                'tag-item',
                { 'active': isActive(tag), 'affix': isAffix(tag), 'has-icon': tagsIcon, 'modified': tag.modified }
              ]"
              :style="activeStyle(tag)"
              @click="navigateToTag(tag)"
              @contextmenu.prevent="openMenu(tag, $event)"
              @mouseenter="showTagActions(tag)"
              @mouseleave="hideTagActions(tag)"
            >
              <!-- 图标 -->
              <i v-if="tagsIcon && tag.meta && tag.meta.icon && tag.meta.icon !== '#'" class="tag-icon">
                <svg-icon :icon-class="tag.meta.icon"/>
              </i>

              <!-- 标题 -->
              <span class="tag-title">{{ tag.title }}</span>

              <!-- 操作按钮 -->
              <div v-if="!isAffix(tag) && showActionsOnHover === tag" class="tag-actions">
                <i class="el-icon-refresh" @click.stop="refreshSelectedTag(tag)" title="刷新"></i>
                <i class="el-icon-close" @click.stop="closeSelectedTag(tag)" title="关闭"></i>
              </div>

              <!-- 修改指示器 -->
              <div v-if="tag.modified" class="modified-indicator">
                <i class="el-icon-edit"></i>
              </div>
            </div>
          </div>
        </div>

        <!-- 空状态 -->
        <div v-if="visitedViews.length === 0" class="empty-tags">
          <i class="el-icon-document-remove"></i>
          <span>暂无打开的标签页</span>
        </div>
      </scroll-pane>

      <!-- 右箭头 -->
      <div v-show="showRightArrow" class="scroll-arrow right-arrow" @click="scrollRight">
        <i class="el-icon-arrow-right"></i>
      </div>
    </div>

    <!-- 快捷操作栏 -->
    <div class="tags-actions">
      <div class="action-item" @click="refreshAllTags">
        <i class="el-icon-refresh"></i>
        <span>全部刷新</span>
      </div>
      <div class="action-item" @click="closeOthersTags">
        <i class="el-icon-circle-close"></i>
        <span>关闭其他</span>
      </div>
      <div class="action-item" @click="closeAllTags">
        <i class="el-icon-delete"></i>
        <span>关闭全部</span>
      </div>
    </div>

    <!-- 右键菜单 -->
    <div
      v-show="visible"
      class="context-menu"
      :style="{ left: left + 'px', top: top + 'px' }"
    >
      <div class="menu-item" @click="refreshSelectedTag(selectedTag)">
        <i class="el-icon-refresh"></i>
        <span>刷新页面</span>
      </div>
      <div v-if="!isAffix(selectedTag)" class="menu-item" @click="closeSelectedTag(selectedTag)">
        <i class="el-icon-close"></i>
        <span>关闭当前</span>
      </div>
      <div class="menu-item" @click="closeOthersTags">
        <i class="el-icon-circle-close"></i>
        <span>关闭其他</span>
      </div>
      <div v-if="!isFirstView()" class="menu-item" @click="closeLeftTags">
        <i class="el-icon-back"></i>
        <span>关闭左侧</span>
      </div>
      <div v-if="!isLastView()" class="menu-item" @click="closeRightTags">
        <i class="el-icon-right"></i>
        <span>关闭右侧</span>
      </div>
      <div class="menu-item danger" @click="closeAllTags(selectedTag)">
        <i class="el-icon-delete"></i>
        <span>全部关闭</span>
      </div>
    </div>

    <!-- 标签拖拽提示 -->
    <div v-if="isDragging" class="drag-hint">
      拖拽标签以重新排序
    </div>
  </div>
</template>

<script>
import ScrollPane from './ScrollPane'
import path from 'path'

export default {
  components: {ScrollPane},
  data() {
    return {
      visible: false,
      top: 0,
      left: 0,
      selectedTag: {},
      affixTags: [],
      searchQuery: '',
      showSearch: true,
      showActionsOnHover: null,
      isDragging: false,
      dragStartIndex: -1,
      dragEndIndex: -1,
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
    },
    tagsIcon() {
      return this.$store.state.settings.tagsIcon
    },
    // 过滤后的标签
    filteredTags() {
      if (!this.searchQuery) return []
      const query = this.searchQuery.toLowerCase()
      return this.visitedViews.filter(tag =>
        tag.title.toLowerCase().includes(query)
      )
    },
    // 分组标签
    groupedTags() {
      const groups = {}
      this.visitedViews.forEach(tag => {
        const module = tag.meta && tag.meta.module || 'default'
        if (!groups[module]) {
          groups[module] = []
        }
        groups[module].push(tag)
      })

      // 将默认组放在前面
      const sortedGroups = []
      if (groups.default) {
        sortedGroups.push(groups.default)
        delete groups.default
      }

      // 添加其他组
      Object.keys(groups).sort().forEach(key => {
        sortedGroups.push(groups[key])
      })

      return sortedGroups
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

    // 监听滚动事件
    this.$refs.scrollPane.$el.addEventListener('scroll', this.handleScroll)

    // 添加拖拽事件
    this.initDragAndDrop()
  },
  beforeDestroy() {
    this.$refs.scrollPane.$el.removeEventListener('scroll', this.handleScroll)
  },
  methods: {
    isActive(route) {
      return route.path === this.$route.path
    },
    activeStyle(tag) {
      if (!this.isActive(tag)) return {}
      return {
        "background-color": this.theme,
        "border-color": this.theme,
        "color": "#ffffff"
      }
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
            meta: {...route.meta}
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
        // Must have tag name
        if (tag.name) {
          this.$store.dispatch('tagsView/addVisitedView', tag)
        }
      }
    },
    addTags() {
      const {name} = this.$route
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
            // when query is different then update
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
      this.$tab.closePage(view).then(({visitedViews}) => {
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
      this.$router.push(this.selectedTag.fullPath).catch(() => {
      })
      this.$tab.closeOtherPage(this.selectedTag).then(() => {
        this.moveToCurrentTag()
      })
    },
    closeAllTags(view) {
      this.$tab.closeAllPage().then(({visitedViews}) => {
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
        // now the default is to redirect to the home page if there is no tags-view,
        // you can adjust it according to your needs.
        if (view.name === 'Dashboard') {
          // to reload home page
          this.$router.replace({path: '/redirect' + view.fullPath})
        } else {
          this.$router.push('/')
        }
      }
    },
    openMenu(tag, e) {
      const menuMinWidth = 105
      const offsetLeft = this.$el.getBoundingClientRect().left // container margin left
      const offsetWidth = this.$el.offsetWidth // container width
      const maxLeft = offsetWidth - menuMinWidth // left boundary
      const left = e.clientX - offsetLeft + 15 // 15: margin right

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

    // 搜索相关方法
    handleSearch() {
      // 搜索逻辑
    },
    clearSearch() {
      this.searchQuery = ''
    },
    navigateToTag(tag) {
      this.$router.push(tag.fullPath)
      this.searchQuery = ''
    },

    // 显示标签操作
    showTagActions(tag) {
      this.showActionsOnHover = tag
    },
    hideTagActions(tag) {
      if (this.showActionsOnHover === tag) {
        this.showActionsOnHover = null
      }
    },

    // 快捷操作
    refreshAllTags() {
      this.visitedViews.forEach(tag => {
        if (!this.isAffix(tag)) {
          this.refreshSelectedTag(tag)
        }
      })
    },

    // 滚动按钮
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
    },

    // 拖拽功能
    initDragAndDrop() {
      // 这里可以添加拖拽功能
      // 由于时间限制，暂时留空
    }
  }
}
</script>

<style lang="scss" scoped>
// 现代化标签页样式
.modern-tags-view {
  background: #ffffff;
  border-bottom: 1px solid #e5e7eb;
  transition: all 0.3s ease;

  // 标签搜索
  .tags-search {
    position: relative;
    padding: 12px 20px;
    background: #f8fafc;
    border-bottom: 1px solid #e5e7eb;

    .tag-search-input {
      .el-input__inner {
        height: 32px;
        border-radius: 8px;
        background: #ffffff;
        border: 1px solid #e2e8f0;

        &:focus {
          border-color: #4f46e5;
        }
      }

      .el-input__prefix {
        .el-input__icon {
          color: #94a3b8;
        }
      }
    }

    .search-results {
      position: absolute;
      top: 100%;
      left: 20px;
      right: 20px;
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      z-index: 1000;
      max-height: 200px;
      overflow-y: auto;

      .search-result-item {
        display: flex;
        align-items: center;
        padding: 10px 16px;
        cursor: pointer;
        transition: all 0.2s ease;

        &:hover {
          background: #f1f5f9;
        }

        .tag-icon {
          margin-right: 12px;
          color: #64748b;
        }

        .tag-title {
          font-size: 14px;
          color: #1f2937;
        }
      }
    }
  }

  // 标签包装器
  .tags-wrapper {
    position: relative;
    display: flex;
    align-items: center;
    height: 40px;

    // 滚动箭头
    .scroll-arrow {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      width: 32px;
      height: 32px;
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      z-index: 10;
      transition: all 0.3s ease;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);

      &:hover {
        background: #f8fafc;
        border-color: #4f46e5;
        color: #4f46e5;
        transform: translateY(-50%) scale(1.1);
      }

      &.left-arrow {
        left: 4px;
      }

      &.right-arrow {
        right: 4px;
      }

      i {
        font-size: 16px;
      }
    }

    // 标签滚动容器
    .tags-scroll-container {
      flex: 1;
      overflow-x: auto;
      overflow-y: hidden;
      white-space: nowrap;
      scrollbar-width: thin;
      scrollbar-color: #cbd5e1 #f1f5f9;

      &::-webkit-scrollbar {
        height: 4px;
      }

      &::-webkit-scrollbar-track {
        background: #f1f5f9;
        border-radius: 2px;
      }

      &::-webkit-scrollbar-thumb {
        background: #cbd5e1;
        border-radius: 2px;

        &:hover {
          background: #94a3b8;
        }
      }

      // 标签分组
      .tag-group {
        display: inline-block;
        margin: 0 8px;

        .group-title {
          font-size: 12px;
          color: #6b7280;
          margin-bottom: 4px;
          padding: 0 8px;
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        // 标签列表
        .tag-list {
          display: flex;
          align-items: center;
          gap: 4px;

          // 标签项
          .tag-item {
            position: relative;
            display: inline-flex;
            align-items: center;
            padding: 6px 12px;
            margin: 0 2px;
            background: #f1f5f9;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 14px;
            color: #475569;
            min-width: 80px;
            justify-content: center;
            height: 32px;

            &:hover {
              background: #e2e8f0;
              border-color: #cbd5e1;
              transform: translateY(-2px);
              box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            }

            &.active {
              background: #4f46e5;
              border-color: #4f46e5;
              color: #ffffff;
              box-shadow: 0 2px 8px rgba(79, 70, 229, 0.3);

              &:hover {
                background: #4338ca;
              }
            }

            &.affix {
              background: #fef3c7;
              border-color: #fde68a;
              color: #92400e;

              &:hover {
                background: #fde68a;
              }
            }

            &.modified {
              background: #dbeafe;
              border-color: #93c5fd;
              color: #1e40af;

              &:hover {
                background: #93c5fd;
              }
            }

            // 标签图标
            .tag-icon {
              margin-right: 6px;
              font-size: 16px;

              &.active {
                color: inherit;
              }
            }

            // 标签标题
            .tag-title {
              font-weight: 500;
              white-space: nowrap;
              max-width: 120px;
              overflow: hidden;
              text-overflow: ellipsis;
            }

            // 标签操作
            .tag-actions {
              position: absolute;
              top: 50%;
              right: 4px;
              transform: translateY(-50%);
              display: flex;
              gap: 4px;
              opacity: 0;
              transition: opacity 0.3s ease;

              i {
                width: 20px;
                height: 20px;
                border-radius: 50%;
                background: rgba(0, 0, 0, 0.6);
                color: #ffffff;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 12px;
                cursor: pointer;
                transition: all 0.2s ease;

                &:hover {
                  background: #4f46e5;
                  transform: scale(1.1);
                }
              }
            }

            &:hover .tag-actions {
              opacity: 1;
            }

            // 修改指示器
            .modified-indicator {
              position: absolute;
              top: 0;
              right: 0;
              width: 16px;
              height: 16px;
              background: #3b82f6;
              border-radius: 0 8px 0 8px;
              display: flex;
              align-items: center;
              justify-content: center;
              color: #ffffff;
              font-size: 10px;
            }
          }
        }
      }

      // 空状态
      .empty-tags {
        text-align: center;
        padding: 40px;
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
    }
  }

  // 快捷操作栏
  .tags-actions {
    position: absolute;
    right: 20px;
    top: 50%;
    transform: translateY(-50%);
    display: flex;
    gap: 12px;
    padding: 8px;
    background: #f8fafc;
    border: 1px solid #e5e7eb;
    border-radius: 8px;

    .action-item {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 6px 12px;
      cursor: pointer;
      border-radius: 6px;
      transition: all 0.3s ease;
      font-size: 13px;
      color: #64748b;

      &:hover {
        background: #ffffff;
        color: #4f46e5;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
      }

      i {
        font-size: 14px;
      }
    }
  }

  // 右键菜单
  .context-menu {
    margin: 0;
    background: #ffffff;
    z-index: 3000;
    position: absolute;
    list-style-type: none;
    padding: 8px 0;
    border-radius: 12px;
    font-size: 14px;
    font-weight: 500;
    color: #374151;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
    border: 1px solid #e5e7eb;
    min-width: 180px;

    .menu-item {
      margin: 0;
      padding: 10px 16px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 12px;
      transition: all 0.2s ease;

      &:hover {
        background: #f3f4f6;
        color: #4f46e5;
      }

      &.danger {
        color: #ef4444;

        &:hover {
          background: #fef2f2;
        }
      }

      i {
        font-size: 16px;
        width: 20px;
        text-align: center;
      }
    }
  }

  // 拖拽提示
  .drag-hint {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: rgba(0, 0, 0, 0.8);
    color: #ffffff;
    padding: 12px 24px;
    border-radius: 8px;
    font-size: 14px;
    z-index: 9999;
    pointer-events: none;
  }
}
</style>

<style lang="scss">
// 重置 Element UI 样式
.tags-scroll-container {
  .el-icon-close {
    width: 16px;
    height: 16px;
    vertical-align: 2px;
    border-radius: 50%;
    text-align: center;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    transform-origin: 100% 50%;
    background: rgba(0, 0, 0, 0.1);
    color: #64748b;
    cursor: pointer;
    margin-left: 4px;

    &:hover {
      background: #ef4444;
      color: #ffffff;
      transform: scale(1.1);
    }
  }
}
</style>

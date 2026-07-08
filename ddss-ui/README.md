# DDSS 管理系统前端

基于 Vue 2 + Element UI + ECharts 的管理后台前端，对应后端 `ddss-bootstrap`。

## 环境要求

- Node.js >= 14
- npm >= 6

## 开发

```bash
# 安装依赖（使用国内镜像加速）
npm install --registry=https://registry.npmmirror.com

# 启动开发服务
npm run dev
```

浏览器访问 http://localhost:80

## 环境变量

| 文件 | 用途 | API 前缀 |
|------|------|---------|
| `.env.development` | 开发环境 | `VUE_APP_BASE_API = '/ddss'` |
| `.env.staging` | 预发布环境 | 见文件 |
| `.env.production` | 生产环境 | 见文件 |

开发时代理规则（`vue.config.js`）：以 `VUE_APP_BASE_API`（`/ddss`）开头的请求代理至 `http://localhost:8088`，并重写去掉 `/ddss` 前缀。

## 构建

```bash
# 构建生产环境
npm run build:prod

# 构建预发布环境
npm run build:stage
```

产物输出到 `dist/`。

## 目录结构

```
src/
├── api/          接口请求封装（按模块组织，如 finance.js）
├── assets/       静态资源与全局样式（variables.scss 设计令牌、element-variables.scss 主题）
├── components/   公共组件
├── layout/       整体布局
├── router/       路由（常量路由 + 后端动态路由）
├── store/        Vuex 状态管理
├── utils/        工具函数（request.js 等）
└── views/        页面
    ├── finance/  财务管理（index.vue 记录、statistics.vue 统计）
    ├── system/   系统管理
    ├── monitor/  系统监控
    └── tool/     系统工具
```

## 财务模块

- `views/finance/index.vue`：借款记录列表，支持动态月份列、单元格双击编辑月还款、合计行、列显隐、排序、Excel 导出。
- `views/finance/statistics.vue`：汇总卡片 + ECharts 饼图（状态分布）、柱图（欠款方）、折线图（月趋势）+ 明细进度表。

详细计算规则见根目录 [设计文档.md](../设计文档.md) 第五节。

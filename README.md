# DDSS 管理系统

基于 RuoYi v3.9.0 改造的企业级管理系统，后端 Spring Boot 2.5.15 + MyBatis，前端 Vue2 + Element UI + ECharts。

## 模块清单

| 模块 | 说明 |
|------|------|
| `ddss-bootstrap` | Spring Boot 启动入口 + REST Controller + Swagger + 中间件开关 |
| `ddss-common` | 工具类、注解、常量、过滤器、设计模式基类、Redis 缓存封装 |
| `ddss-ry-framework` | Security/JWT/AOP、Event 系统、Strategy 实现、线程池 |
| `ddss-system` | 系统业务：用户/角色/菜单/部门/字典/配置 |
| `ddss-server` | 业务模块：财务管理、视频资源、Kafka、MinIO |
| `ddss-quartz` | 定时任务管理 |
| `ddss-generator` | 代码生成器 |
| `ddss-ui` | 前端 Vue2 + Element UI + ECharts |

## 技术栈

- 后端：Java 8、Spring Boot 2.5.15、Spring Security 5.7、MyBatis、MyBatis-Plus、Druid、PageHelper、Redis、Kafka、MinIO、Quartz、XXL-Job、Nacos、H2（开发兜底）
- 前端：Vue 2、Element UI、ECharts、Axios、Vue CLI

## 快速启动

### 方式一：Dev 模式（无需任何中间件，H2 内存库）

适合本地开发与演示。修改 `ddss-bootstrap/src/main/resources/bootstrap.yml`：

```yaml
ddss:
  middleware:
    nacos:
      enabled: false
    redis:
      enabled: false
    kafka:
      enabled: false
    minio:
      enabled: false
    mysql:
      enabled: false      # 关闭后自动切换 H2 内存库
    xxl-job:
      enabled: false
  dev:
    login-enabled: true    # 开启开发认证后门，免密以 admin 身份登录
```

启动 `DdssApplication`，H2DataInitializer 会自动执行 `h2/schema.sql` + `h2/data.sql` 初始化表与数据。

### 方式二：生产模式（全开中间件 + Nacos）

`bootstrap.yml` 保持默认（全部 `enabled: true`），通过 Nacos 下发 `ddss-server.yaml` 与 `ddss-server-druid.yaml`。

依赖中间件：MySQL 8.x、Redis、Kafka、MinIO、Nacos、XXL-Job（地址见 `application-local.yml`）。

### 前端启动

```bash
cd ddss-ui
npm install --registry=https://registry.npmmirror.com
npm run dev
```

浏览器访问 http://localhost:80（API 前缀 `/ddss` 代理至后端 8088）。

## 部署

```powershell
# Windows 部署脚本（需 SSH 免密配置）
.\deploy.ps1
```

构建产物：`ddss-bootstrap/target/ddss-bootstrap.jar`。

## 数据库

- 全量脚本：`db/ddss.sql`（MySQL 8.0，utf8mb4）
- Nacos 初始化：`db/nacos.sql`
- XXL-Job 初始化：`db/xxl-job.sql`
- H2 开发兜底：`ddss-bootstrap/src/main/resources/h2/schema.sql` + `data.sql`

## 安全提示

- `ddss.dev.login-enabled` 默认 `false`，仅本地开发置 `true`，**生产必须保持 false**，否则任何请求将以 admin 身份放行。
- JWT 密钥 `token.secret` 本地兜底配置已满足 HS512 长度要求；生产请通过 Nacos 加密配置或环境变量 `TOKEN_SECRET` 覆盖并定期轮换。
- MinIO 资源接口需登录鉴权，请按需补充 `@PreAuthorize` 权限注解。

## 文档

详见 [设计文档.md](设计文档.md)，包含中间件开关体系、设计模式、Redis 缓存策略、财务管理模块、核心数据流、配置文件清单等。

# DDSS 管理系统

基于 RuoYi v3.9.0 改造，后端模块架构参照 [iuap-data-common](../iuap-data-common)（用友数据中台主框架）的 **consumer / provider / bootstrap** 三层——全项目**只有一套契约与一套实现**（2026-10 定稿）。保留 consumer/provider 模块化分层的目的：**ddss-consumer 可独立发布为 RPC 契约 jar，为将来升级 RPC 框架（Dubbo/Feign/gRPC）预留切换点**。技术栈：Spring Boot 2.5.15 + MyBatis-Plus，前端 Vue2 + Element UI + ECharts。

## 模块清单（5 个）

| 模块 | 说明 |
|------|------|
| `ddss-parent` | 根 POM：依赖版本管理 + 模块聚合 |
| `ddss-common` | 通用工具、注解、常量、Redis 缓存封装 |
| `ddss-consumer` | **对外契约总集**：system/finance/video 全部业务域的实体、Service 接口、Mapper 接口，零实现 |
| `ddss-framework` | 框架核心（原 ddss-ry-framework）：Security/JWT/AOP、事件系统、线程池、Kafka 通道、上下文、MinIO/xxl-job 适配、接口日志切面 |
| `ddss-provider` | **实现总集**：全部 ServiceImpl、Mapper XML、`*Resource` REST（统一 iuap 命名）、workflow(Flowable)、quartz、代码生成、MinIO 资源同步任务 |
| `ddss-bootstrap` | 启动入口 + 组装层：认证与基础设施 REST（Login/Register/Index/Captcha/Common/monitor infra），对标 iuap desktop-bootstrap |
| `ddss-ui` | 前端 Vue2 + Element UI + ECharts |

> 实际构建模块 5 个：common / framework / consumer / provider / bootstrap。

### 分层规则（来自 iuap-data-common）

- **consumer（契约层）**：只有实体、Service 接口、Mapper 接口，零实现——RPC 升级时此模块即独立的契约 jar；包名按域保留（`com.ddss.system.*`、`com.ddss.finance.*`、`com.ddss.video.*`），域归域、契约归契约；
- **provider（实现层）**：Service 实现、Mapper XML、`*Resource` REST（iuap 命名风格，URL 不变）、workflow/quartz/generator 实现；RPC 升级时只需给这里的实现换注入方式（REST ↔ RPC），consumer 不动；
- **依赖方向**：`common ← consumer ← framework ← provider ← bootstrap`，禁止逆向依赖；
- **bootstrap（组装层）**：只保留认证/通用/监控基础设施 REST，业务 REST 全部在 provider 的 `com.ddss.{域}.web.rest` 包。

### 从 iuap-data-common 移植的优质代码

- `ddss-framework/aop/logging/LoggingAspect` + `LoggingAspectConfiguration`：Service/Mapper/REST 方法进出与异常切面，local/dev 生效（iuap 作者 lzx）；
- `ddss-framework/web/exception/GlobalExceptionHandler` 增强：错误响应携带链路 ID（前端报错凭 ID 检索后端日志）、cause 链 5 层摘要、报文/约束校验专项 catch（iuap 769 行异常处理器的设计精髓）。

### 内核 v2（2026-10 重塑）

- **全链路追踪**：`TraceIdFilter` 为每次请求生成/续链 traceId，贯穿 HTTP → 日志（logback `%X{traceId}`）→ 响应体（`R.traceId` / `vtrace`）→ `@Async` 异步线程（`MdcTaskDecorator`），前端报错凭响应头 `X-Trace-Id` 一键检索全链路日志；
- **统一响应契约**：强类型 `R<T>`（code/msg/data/traceId，与旧结构字段对齐，前端零改动）+ `ErrorCode`/`GlobalErrorCode` 错误码体系 + `ServiceException(ErrorCode)`；未知异常不再向前端泄漏内部细节；
- **分页一行式**：`pageQuery(() -> service.selectXxList(x))` 收敛分页上下文管理，try/finally 保证 ThreadLocal 清理；
- **领域规则归位**：财务月度计算提炼为 `FinanceCalculator`（纯函数、可单测），Controller 只编排、Excel 只渲染。

详见 [设计文档.md](设计文档.md) 第十章。

## 技术栈

- 后端：Java 8、Spring Boot 2.5.15、Spring Security 5.7、MyBatis、MyBatis-Plus、Druid、PageHelper、Redis、Kafka、MinIO、Quartz、XXL-Job、Nacos、H2（开发兜底）
- 前端：Vue 2、Element UI、ECharts、Axios、Vue CLI

## 本机构建（无 IDE 命令行）

```bash
export JAVA_HOME="C:\\Program Files\\Java\\jdk-17"
/d/apache-maven-3.9.9/bin/mvn.cmd -pl ddss-bootstrap -am clean verify
# 产物：ddss-bootstrap/target/ddss-bootstrap.jar
# 前端门禁：cd ddss-ui && npm ci && npm run lint && npm run build:prod
```

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
    login-enabled: true    # 仅本地开发按需开启；生产环境必须保持 false
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

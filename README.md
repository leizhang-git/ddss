# DDSS 管理系统

基于 RuoYi v3.9.0 改造。当前根 POM 聚合七个后端 Maven 子模块。既有 consumer/provider/bootstrap 应用仍承载现有系统功能；新加入的 `ddss-domain` 与 `ddss-application` 是 framework-free 的领域/用例切片，目前覆盖工作流请假发起、审批、本人批量撤回、流程定义批量删除命令、待办/已办查询及 Finance Excel 导出计算，尚未替换 provider 中其余既有业务和 Flowable 工作流实现。`ddss-consumer` 可作为契约模块单独构建；当前没有 Dubbo、Feign 或 gRPC 调用实现。技术栈：Spring Boot 2.5.15 + MyBatis-Plus，前端 Vue2 + Element UI + ECharts。

## 模块清单（后端 7 个构建模块）

以下模块职责按当前代码整理，不代表新领域/用例已整体替代现有服务。`ddss-parent` 是根聚合 POM，不计入子模块数；`ddss-ui` 是独立前端项目。下表区分现有系统边界与新模块当前覆盖范围。

| 模块 | 当前职责与边界 |
|------|------|
| `ddss-domain` | 新增 framework-free 领域切片，目前含不可变请假申请/天数/状态、FinanceLoan、FinanceSchedule 与月度计算规则；并非所有业务实体的统一归属。 |
| `ddss-application` | 新增 framework-free 用例切片，依赖 `ddss-domain`；目前含 `SubmitLeave`、`DecideWorkflowTask`、`WithdrawLeaveApplications`、`DeleteWorkflowDeployments`、`GetWorkflowTodo`、`GetWorkflowDone`、`PrepareFinanceExport`、出站端口、显式结果/计划类型及用例测试。 |
| `ddss-common` | 通用工具、注解、常量、过滤器、缓存封装；POM 含 Spring Web/Security、Redis、PageHelper 等依赖，并非无基础设施依赖的纯工具模块 |
| `ddss-consumer` | system/finance/video 域的实体、Service 接口与 Mapper 接口；依赖 common、MyBatis-Plus 和 dynamic-datasource |
| `ddss-framework` | Security/JWT/AOP、事件、线程池、Kafka、上下文、MinIO、XXL-Job 等框架支持；依赖 consumer |
| `ddss-provider` | 业务实现、Mapper XML、REST Resource、现有 workflow（Flowable）、工作流/Finance 导出适配器、quartz、代码生成和视频资源同步任务；依赖 consumer、framework、application、domain |
| `ddss-bootstrap` | 启动入口与组装层，含登录/注册/首页、验证码、通用和监控 REST；引入 Nacos 配置/发现并依赖 framework、provider |
| `ddss-ui` | 独立前端 Vue2 + Element UI + ECharts 项目，不是 Maven 子模块 |

### 当前分层与迁移边界

- **既有系统边界**：consumer 存放 system/finance/video 的契约和对应域实体；provider 存放这些域的实现、REST 资源和 Mapper XML。既有 Flowable workflow 的 domain、mapper、service 接口与实现仍在 provider，不能说全部实体和接口仅在 consumer。
- **新模块当前边界**：`ddss-domain` 放置 framework-free 的请假申请领域类型；`ddss-application` 依赖 domain，包含请假提交、审批决策、本人批量撤回、流程定义批量删除、待办/已办查询与 Finance 导出用例及出站端口。provider 依赖 application/domain，以 MyBatis 与 Flowable 适配器装配 `SubmitLeave`、`DecideWorkflowTask`、`WithdrawLeaveApplications`、`DeleteWorkflowDeployments`、`GetWorkflowTodo`、`GetWorkflowDone`，并由既有请假/任务/定义服务调用。当前只接管请假发起、审批、撤回、部署删除命令和待办/已办查询，不代表模型部署或其他业务领域已迁入。
- **当前 REST 边界**：业务 REST Resource 位于 provider；认证、验证码、通用和监控入口位于 bootstrap。新增 domain/application 尚无框架 REST 入口。
- **Maven 依赖关系**：`ddss-application → ddss-domain`；provider 增加 `ddss-provider → ddss-application + ddss-domain`，既有系统依赖为 `ddss-consumer → ddss-common`、`ddss-framework → ddss-consumer`、`ddss-provider → ddss-consumer + ddss-framework`、`ddss-bootstrap → ddss-framework + ddss-provider`（consumer/common 经传递依赖进入）。provider 仅在 workflow 请假发起/审批/撤回/部署删除/待办已办查询和 Finance 导出准备中调用新用例；其他 workflow 能力和其他领域仍未迁移。这是 POM 依赖关系，不等于 RPC 调用链。
- **RPC 边界**：consumer 作为契约模块可单独构建，但 RPC 发布/调用替代 REST 仍是后续选项；当前没有 Dubbo、Feign 或 gRPC 调用实现。

### 当前可见的内核实现

- `ddss-framework/src/main/java/com/ddss/framework/aop/logging/LoggingAspect` + `LoggingAspectConfiguration`：Service/Mapper/REST 方法日志切面，仅 dev/local profile 装配；
- `ddss-framework/src/main/java/com/ddss/framework/web/exception/GlobalExceptionHandler`：错误响应携带链路 ID、cause 链摘要和专项异常处理。

### 内核 v2（2026-10 重塑）

以下列出现有内核组件与已使用的计算/分页样例；不代表所有 endpoint 已统一迁移到新响应和分页 API。

- **全链路追踪**：`TraceIdFilter` 为每次请求生成/续链 traceId，贯穿 HTTP → 日志（logback `%X{traceId}`）→ 响应体（`R.traceId` / `vtrace`）→ `@Async` 异步线程（`MdcTaskDecorator`），前端报错凭响应头 `X-Trace-Id` 一键检索全链路日志；
- **统一响应契约**：强类型 `R<T>`（code/msg/data/traceId，与旧结构字段对齐，前端零改动）+ `ErrorCode`/`GlobalErrorCode` 错误码体系 + `ServiceException(ErrorCode)`；未知异常不再向前端泄漏内部细节；
- **分页一行式**：`pageQuery(() -> service.selectXxList(x))` 收敛分页上下文管理，try/finally 保证 ThreadLocal 清理；
- **财务导出切片**：`ddss-domain/src/main/java/com/ddss/domain/finance/FinanceScheduleCalculator` 提供纯 Java 月度计划计算；`ddss-application` 的 `PrepareFinanceExport` 编排读取与计算，provider 适配器负责旧 SysFinance/JSON 映射，FinanceResource 只负责 POI/HTTP 输出。该切片仅覆盖 Excel 导出准备，Finance CRUD 与统计仍在旧服务中。

详见 [设计文档.md](设计文档.md) 第十章。

## 技术栈

- 后端：Java 17（根 POM 的 `java.version`；domain 使用 record/sealed interface）、Spring Boot 2.5.15、Spring Security 5.7、MyBatis、MyBatis-Plus、Druid、PageHelper、Redis、Kafka、MinIO、Quartz、XXL-Job、Nacos、H2（开发兜底）
- 前端：Vue 2、Element UI、ECharts、Axios、Vue CLI

## 构建与测试验证

需要本机 Java 与 Maven 已安装并可从命令行调用。根 POM 当前配置 `java.version` 为 17，编译插件的 source/target 跟随该属性。

从仓库根目录构建所有七个 Maven 子模块，并运行各模块测试与 verify 生命周期：

```bash
mvn clean verify
```

只验证 `ddss-application` 及其 `ddss-domain` 依赖模块：

```bash
mvn -pl ddss-application -am test
```

运行 provider 的计算器测试及其 reactor 依赖模块：

```bash
mvn -pl ddss-provider -am -Dtest=FinanceScheduleCalculatorTest,PrepareFinanceExportTest,SubmitLeaveTest,DecideWorkflowTaskTest,WithdrawLeaveApplicationsTest,DeleteWorkflowDeploymentsTest,WorkflowTaskQueriesTest,LegacyFinanceExportAdapterTest,FinanceExportMigrationTest,LegacyLeaveAdaptersTest,LegacyLeaveWithdrawalAdapterTest,LegacyWorkflowDeploymentDeletionAdapterTest,LegacyWorkflowApprovalAdapterTest,LegacyWorkflowTaskQueryAdapterTest,WorkflowServiceContractTest -Dsurefire.failIfNoSpecifiedTests=false test
```

前端 lint 与生产构建：

```bash
cd ddss-ui
npm ci
npm run lint
npm run build:prod
```

后端启动包：`ddss-bootstrap/target/ddss-bootstrap.jar`。

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

`ddss-bootstrap/src/main/resources/bootstrap.yml` 默认引用 Nacos dataId `ddss-server.yaml` 与 `ddss-server-druid.yaml`（此处为配置标识，不是 `ddss-server` 源码模块路径）。

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
- 既有 MySQL 库请先备份，再手工执行 `db/migration/V20261012_01__leave_days_decimal.sql`，将 `ddss_leave.leave_days` 升级为支持半天的 `DECIMAL(4,1)`；仓库当前没有自动 migration runner。

## 安全提示

- `ddss.dev.login-enabled` 默认 `false`，仅本地开发置 `true`，**生产必须保持 false**，否则任何请求将以 admin 身份放行。
- JWT 密钥 `token.secret` 本地兜底配置已满足 HS512 长度要求；生产请通过 Nacos 加密配置或环境变量 `TOKEN_SECRET` 覆盖并定期轮换。
- MinIO 资源接口需登录鉴权，请按需补充 `@PreAuthorize` 权限注解。

## 文档

详见 [设计文档.md](设计文档.md)，其中模块边界按当前源码记录，并区分现行实现与后续演进选择；另见 [开发参考文档](docs/开发参考文档.md) 获取构建/测试命令及工作流代码位置。

# OpenSpec 规范驱动开发系统

## 概述

OpenSpec 是一个基于 AI 的规范驱动开发系统，用于管理软件项目的规范变更和实现。它提供了从提案、设计、规范制定到实现、同步和归档的完整工作流程。

## 系统架构

### 核心组件

1. **OpenSpec CLI** - 命令行工具，管理规范变更
2. **.opencode 目录** - 包含自定义命令和技能
3. **规范存储** - 支持本地和远程规范仓库
4. **AI 集成** - 利用 Claude 进行文档生成和实现

### 工作流程

```
提案 → 设计 → 规范 → 实现 → 同步 → 归档
```

## 快速开始

### 1. 创建新变更

```bash
/opsx-propose <变更描述>
```

例如：
```bash
/opsx-propose 添加用户认证功能
```

这将自动生成：
- `proposal.md` - 变更提案
- `design.md` - 设计文档  
- `tasks.md` - 实施任务列表
- `specs/` - 规范文件

### 2. 实现任务

```bash
/opsx-apply [变更名称]
```

### 3. 同步规范

```bash
/opsx-sync [变更名称]
```

### 4. 探索想法

```bash
/opsx-explore [主题]
```

### 5. 归档变更

```bash
/opsx-archive [变更名称]
```

## 目录结构

```
openspec/
├── README.md              # 本文档
├── config.yaml           # 配置文件
├── docs/                 # 详细文档
│   ├── workflow.md      # 工作流程详解
│   ├── artifacts.md     # 工件格式说明
│   ├── delta-specs.md   # 增量规范格式
│   └── api.md           # API 参考
└── examples/            # 示例文件
    ├── proposal-example.md
    ├── design-example.md
    └── spec-example.md
```

## 配置文件

### openspec/config.yaml

```yaml
schema: spec-driven

# 项目上下文（可选）
# 这是在创建工件时显示给 AI 的。
context: |
  Tech stack: Java 8, Spring Boot 2.5.15, MyBatis, Vue 2
  Domain: 企业级管理系统
  Conventions: RESTful API, JWT 认证, RBAC 权限控制

# 每工件规则（可选）
rules:
  proposal:
    - 保持提案简洁，不超过 500 字
    - 必须包含 "非目标" 部分
  tasks:
    - 任务分解不超过 2 小时
    - 使用可测试的描述
```

## 核心命令详解

### /opsx-propose - 提出新变更

**功能**: 创建完整的变更提案，包括所有必需的工件

**工作流程**:
1. 创建变更目录
2. 获取工件构建顺序
3. 按依赖顺序创建工件
4. 确保所有 `applyRequires` 工件完成

### /opsx-apply - 实现任务

**功能**: 从 OpenSpec 变更中实现任务

**特点**:
- 支持部分实现和继续
- 自动更新任务状态
- 提供实现指导和上下文

### /opsx-sync - 同步规范

**功能**: 将变更中的增量规范同步到主规范

**支持的变更类型**:
- ADDED - 新增需求
- MODIFIED - 修改现有需求
- REMOVED - 删除需求
- RENAMED - 重命名需求

### /opsx-explore - 探索模式

**功能**: 深入思考、探索想法、调查问题

**特点**:
- 仅思考，不实现
- 使用 ASCII 图表辅助
- 适应性强，自然对话

### /opsx-archive - 归档变更

**功能**: 归档已完成的变更

**特点**:
- 检查工件和任务完成状态
- 提供规范同步选项
- 生成带时间戳的归档

## 工件类型

### 1. proposal.md - 变更提案

```markdown
# <变更名称> 提案

## 问题描述
<描述要解决的问题>

## 解决方案
<提出的解决方案>

## 范围
- 目标 1
- 目标 2

## 非目标
- 不在范围内的内容

## 风险和依赖
<潜在风险和依赖关系>
```

### 2. design.md - 设计文档

```markdown
# <变更名称> 设计

## 架构决策
<关键的架构决策>

## 技术实现
<具体的技术实现方案>

## 组件设计
<主要组件及其交互>

## 数据流
<数据流动和处理逻辑>
```

### 3. specs/ - 规范目录

```
specs/
├── authentication/
│   └── spec.md
├── authorization/
│   └── spec.md
└── ...
```

**规范文件格式**:
```markdown
# <功能名称> 规范

## Purpose
<功能目的描述>

## Requirements
### Requirement: <需求名称>
需求详细描述...

#### Scenario: <场景名称>
- **WHEN** <前提条件>
- **THEN** <预期结果>
- **AND** <附加条件>
```

### 4. tasks.md - 任务列表

```markdown
# <变更名称> 实施任务

- [ ] 初始化项目结构
- [ ] 实现用户认证接口
- [ ] 实现权限管理
- [ ] 编写单元测试
- [ ] 集成测试
```

## 增量规范格式

当需要修改现有规范时，使用增量格式：

```markdown
## ADDED Requirements
### Requirement: 新功能
系统 SHALL 提供新功能。

#### Scenario: 基本情况
- **WHEN** 用户执行操作
- **THEN** 系统响应

## MODIFIED Requirements
### Requirement: 现有功能
#### Scenario: 新增场景
- **WHEN** 用户执行新操作
- **THEN** 系统执行新响应

## REMOVED Requirements
### Requirement: 已弃用功能

## RENAMED Requirements
- FROM: `### Requirement: 旧名称`
- TO: `### Requirement: 新名称`
```

## 使用示例

### 完整的变更周期

1. **探索阶段**
   ```bash
   /opsx-explore 用户认证系统设计
   ```

2. **提案阶段**
   ```bash
   /opsx-propose 实现基于 JWT 的用户认证
   ```

3. **实现阶段**
   ```bash
   /opsx-apply jwt-auth
   ```

4. **同步阶段**
   ```bash
   /opsx-sync jwt-auth
   ```

5. **归档阶段**
   ```bash
   /opsx-archive jwt-auth
   ```

### 增量开发

1. 创建新变更
2. 生成工件
3. 实现功能
4. 更新增量规范
5. 同步到主规范

## 故障排除

### 常见问题

1. **变更已存在**
   - 使用不同的名称
   - 或继续现有变更

2. **工件不完整**
   ```bash
   openspec status --change <名称> --json
   ```

3. **同步冲突**
   - 检查增量规范格式
   - 确保主规范存在

### 调试命令

```bash
# 检查安装
openspec --version

# 验证配置
openspec doctor

# 列出变更
openspec list --json
```

## 扩展开发

### 自定义技能

在 `.opicode/skills/` 下添加自定义技能：

```yaml
---
name: custom-skill
description: 自定义技能描述
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: your-name
  version: "1.0"
---
# 技能实现
```

### 自定义命令

在 `.opicode/commands/` 下添加自定义命令：

```yaml
---
description: 自定义命令描述
---
# 命令实现
```

## 版本历史

- v1.0.0 - 初始版本，支持基本工作流程
- v1.1.0 - 添加增量规范支持
- v1.2.0 - 增强探索模式功能

## 许可证

MIT License

## 支持

如有问题，请参考详细文档或联系开发团队。
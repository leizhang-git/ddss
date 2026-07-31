# OpenSpec 系统完整文档

## 概述

OpenSpec 是一个基于 AI 的规范驱动开发系统，用于管理软件项目的规范变更和实现。它提供了从提案、设计、规范制定到实现、同步和归档的完整工作流程。

## 系统架构

### 核心组件

1. **OpenSpec CLI** - 命令行工具，管理规范变更
2. **.opicode 目录** - 包含自定义命令和技能
3. **规范存储** - 支持本地和远程规范仓库
4. **AI 集成** - 利用 Claude 进行文档生成和实现

### 工作流程

```
提案 → 设计 → 规范 → 实现 → 同步 → 归档
```

## 目录结构

```
.opencode/
├── commands/          # 自定义命令
│   ├── opsx-propose.md      # 提出新变更
│   ├── opsx-apply.md       # 实现任务
│   ├── opsx-sync.md         # 同步规范
│   ├── opsx-explore.md      # 探索模式
│   └── opsx-archive.md     # 归档变更
└── skills/            # 技能模块
    ├── openspec-propose/           # 提案技能
    ├── openspec-apply-change/      # 实现技能
    ├── openspec-sync-specs/        # 同步技能
    ├── openspec-explore/           # 探索技能
    └── openspec-archive-change/   # 归档技能
```

## 核心命令

### 1. opsx-propose - 提出新变更

**功能**: 创建完整的变更提案，包括所有必需的工件

**触发方式**: `/opsx-propose <变更名称>`

**生成的工件**:
- `proposal.md` - 变更提案（什么和为什么）
- `design.md` - 设计文档（如何实现）
- `tasks.md` - 实施任务列表
- `specs/` - 规范文件（如果适用）

**工作流程**:
1. 创建变更目录
2. 获取工件构建顺序
3. 按依赖顺序创建工件
4. 确保所有 `applyRequires` 工件完成

### 2. opsx-apply - 实现任务

**功能**: 从 OpenSpec 变更中实现任务

**触发方式**: `/opsx-apply [变更名称]`

**工作流程**:
1. 选择变更（自动推断或用户选择）
2. 检查状态和模式
3. 获取实现指令
4. 阅读上下文文件
5. 循环实现剩余任务

**支持的模式**:
- `spec-driven` - 规范驱动模式（默认）
- 其他自定义模式

### 3. opsx-sync - 同步规范

**功能**: 将变更中的增量规范同步到主规范

**触发方式**: `/opsx-sync [变更名称]`

**增量规范格式**:
```markdown
## ADDED Requirements
### Requirement: 新功能
系统 SHALL 执行新功能。

#### Scenario: 基本情况
- **WHEN** 用户执行 X
- **THEN** 系统执行 Y

## MODIFIED Requirements
### Requirement: 现有功能
#### Scenario: 新增场景
- **WHEN** 用户执行 A
- **THEN** 系统执行 B

## REMOVED Requirements
### Requirement: 已弃用功能

## RENAMED Requirements
- FROM: `### Requirement: 旧名称`
- TO: `### Requirement: 新名称`
```

### 4. opsx-explore - 探索模式

**功能**: 深入思考、探索想法、调查问题、明确需求

**触发方式**: `/opsx-explore [主题]`

**特点**:
- 仅思考，不实现
- 使用 ASCII 图表辅助思考
- 适应性强，跟随对话自然发展
- 可以探索代码库
- 提供多种思考方式

**可以做的事情**:
- 探索问题空间
- 调查代码库
- 比较选项
- 可视化
- 识别风险和未知数

### 5. opsx-archive - 归档变更

**功能**: 归档已完成的变更

**触发方式**: `/opsx-archive [变更名称]`

**工作流程**:
1. 选择变更
2. 检查工件完成状态
3. 检查任务完成状态
4. 评估增量规范同步状态
5. 执行归档操作

**归档位置**: `<planningHome.changesDir>/archive/YYYY-MM-DD-<变更名称>/`

## 技能模块

### openspec-propose 技能

**描述**: 提出新变更，一次性生成所有工件

**使用场景**: 用户想要快速描述要构建的内容并获得完整的提案

**步骤**:
1. 理解用户需求
2. 创建变更目录
3. 获取工件构建顺序
4. 按依赖顺序创建工件
5. 显示最终状态

### openspec-apply-change 技能

**描述**: 从 OpenSpec 变更中实现任务

**使用场景**: 用户想要开始实现、继续实现或完成任务

**特点**:
- 支持流体工作流
- 可以随时调用
- 允许工件更新
- 保持上下文文件更新

### openspec-sync-specs 技能

**描述**: 将变更中的增量规范同步到主规范

**使用场景**: 用户想要在不归档变更的情况下更新主规范

**智能合并原则**:
- 应用部分更新
- 增量表示意图，而不是整体替换
- 合理合并变更

### openspec-explore 技能

**描述**: 探索模式，作为思考伙伴

**使用场景**: 用户想要在变更前后或期间思考某些内容

**立场**:
- 好奇，而非指令性
- 开放线程，而非盘问
- 视觉化
- 适应性
- 耐心
- 基于现实

### openspec-archive-change 技能

**描述**: 归档已完成的工作流变更

**使用场景**: 用户想要在实现完成后完成并归档变更

**特点**:
- 检查工件和任务完成状态
- 提供同步选项
- 生成带时间戳的归档目录

## 配置文件

### openspec/config.yaml

```yaml
schema: spec-driven

# 项目上下文（可选）
# 这是在创建工件时显示给 AI 的。
# 添加你的技术栈、约定、风格指南、领域知识等。
# 示例：
#   context: |
#     Tech stack: TypeScript, React, Node.js
#     We use conventional commits
#     Domain: e-commerce platform

# 每工件规则（可选）
# 为特定工件添加自定义规则。
# 示例：
#   rules:
#     proposal:
#       - Keep proposals under 500 words
#       - Always include a "Non-goals" section
#     tasks:
#       - Break tasks into chunks of max 2 hours
```

### 规范存储

OpenSpec 支持本地和远程规范仓库：

**本地规范仓库**: 在最近的 `openspec/` 根目录下操作

**远程规范仓库**: 如果用户命名了一个存储（在此机器上注册的独立 OpenSpec 仓库），运行：
```bash
openspec store list --json
```
然后在使用读取或写入规范和变更的命令上传递 `--store <id>`。

## 工件类型

### 1. proposal.md - 变更提案

**内容**:
- 变更描述
- 为什么需要这个变更
- 范围和目标
- 非目标
- 风险和依赖

### 2. design.md - 设计文档

**内容**:
- 架决策
- 技术实现方案
- 组件设计
- 接口定义
- 数据流

### 3. specs/ - 规范目录

**结构**:
```
specs/
├── <capability-1>/
│   └── spec.md
├── <capability-2>/
│   └── spec.md
└── ...
```

**规范文件格式**:
```markdown
# <功能名称> 规范

## Purpose
<目的描述>

## Requirements
### Requirement: <需求名称>
需求描述...

#### Scenario: <场景名称>
- **WHEN** <前提条件>
- **THEN** <预期结果>
```

### 4. tasks.md - 任务列表

**格式**:
```markdown
# 实施任务

- [ ] 任务 1
- [ ] 任务 2
- [x] 已完成任务
```

## 使用最佳实践

### 1. 开始新变更
```bash
/opsx-propose <变更描述>
```

### 2. 检查状态
```bash
openspec status --change <名称> --json
```

### 3. 获取指令
```bash
openspec instructions <工件ID> --change <名称> --json
```

### 4. 列出所有变更
```bash
openspec list --json
```

### 5. 验证变更
```bash
openspec validate --change <名称>
```

### 6. 诊断问题
```bash
openspec doctor --change <名称>
```

### 7. 获取上下文信息
```bash
openspec context --change <名称>
```

## 工作流程示例

### 完整的变更周期

1. **探索阶段**
   ```bash
   /opsx-explore 新功能的想法
   ```

2. **提案阶段**
   ```bash
   /opsx-propose 添加用户认证功能
   # 自动创建：proposal.md, design.md, tasks.md
   ```

3. **实现阶段**
   ```bash
   /opsx-apply add-user-auth
   # 逐步实现 tasks.md 中的任务
   ```

4. **同步阶段**
   ```bash
   /opsx-sync add-user-auth
   # 将增量规范同步到主规范
   ```

5. **归档阶段**
   ```bash
   /opsx-archive add-user-auth
   # 归档已完成的变更
   ```

### 增量开发示例

1. **创建变更**
   ```bash
   openspec new change "feature-enhancement"
   ```

2. **生成工件**
   - `/opsx-propose feature-enhancement`
   - AI 生成完整的提案、设计和任务

3. **实现功能**
   ```bash
   /opsx-apply feature-enhancement
   # 按任务列表实现
   ```

4. **更新规范**
   - 在 `specs/` 目录中修改增量规范
   - 使用 `/opsx-sync` 同步到主规范

## 故障排除

### 常见问题

1. **变更已存在**
   - 使用不同的名称
   - 或继续现有变更

2. **工件不完整**
   - 检查 `openspec status --json`
   - 确保 `applyRequires` 工件完成

3. **同步冲突**
   - 检查增量规范格式
   - 确保主规范存在
   - 手动合并复杂变更

4. **存储选择问题**
   - 运行 `openspec store list --json`
   - 使用 `--store <id>` 指定存储

### 调试命令

```bash
# 检查 OpenSpec 安装
openspec --version

# 验证配置
openspec doctor

# 检查存储
openspec store list --json

# 获取帮助
openspec --help
```

## 高级特性

### 1. 多模式支持

除了默认的 `spec-driven` 模式，OpenSpec 支持自定义模式，每个模式可以有不同的工件类型和依赖关系。

### 2. 智能合并

增量规范支持智能合并，可以：
- 添加新需求而不复制整个需求
- 修改现有需求的场景
- 删除需求
- 重命名需求

### 3. AI 辅助

- 自动生成工件
- 智能依赖解析
- 上下文感知的指令生成
- 自然语言交互

### 4. 版本控制

- 每个变更都有完整的上下文
- 归档保留完整的历史
- 支持回滚和比较

## 扩展 OpenSpec

### 自定义技能

可以在 `.opicode/skills/` 目录下添加自定义技能：

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

可以在 `.opicode/commands/` 目录下添加自定义命令：

```yaml
---
description: 自定义命令描述
---
# 命令实现
```

## 总结

OpenSpec 提供了一个完整的、AI 驱动的规范驱动开发工作流程，从创意到实现，再到维护。它通过智能的工件生成、依赖管理和同步机制，使开发过程更加结构化和高效。

主要优势：
- 结构化的开发流程
- AI 辅助的工件生成
- 智能的规范管理
- 灵活的探索和实现模式
- 完整的变更生命周期管理
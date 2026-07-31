# OpenSpec 工作流程详解

## 工作流程概述

OpenSpec 提供了一个完整的、结构化的开发工作流程，确保从想法到实现的每个步骤都有清晰的指导和规范。

## 标准工作流程

### 阶段 1: 探索 (Explore)

**目的**: 深入理解问题，探索解决方案，明确需求

**命令**: `/opsx-explore [主题]`

**活动**:
- 调研问题空间
- 挑战假设
- 重新定义问题
- 可视化解决方案
- 识别风险和未知数

**输出**:
- 明确的问题理解
- 多个解决方案选项
- 风险评估
- （可选）OpenSpec 工件

### 阶段 2: 提案 (Propose)

**目的**: 创建正式的变更提案，包含所有必需的工件

**命令**: `/opsx-propose <变更描述>`

**活动**:
- 创建变更目录
- 生成提案文档
- 生成设计文档
- 生成任务列表
- 生成规范文件（如适用）

**生成的工件**:
1. `proposal.md` - 变更提案（什么和为什么）
2. `design.md` - 设计文档（如何实现）
3. `tasks.md` - 实施任务列表
4. `specs/` - 功能规范（如果适用）

### 阶段 3: 实现 (Apply)

**目的**: 按照任务列表逐步实现变更

**命令**: `/opsx-apply [变更名称]`

**活动**:
- 读取上下文文件
- 逐个实现任务
- 更新任务状态
- 处理实现中的问题

**特点**:
- 支持部分实现和继续
- 自动跟踪进度
- 提供实现指导

### 阶段 4: 同步 (Sync)

**目的**: 将变更中的增量规范同步到主规范

**命令**: `/opsx-sync [变更名称]`

**活动**:
- 读取增量规范
- 应用变更到主规范
- 处理冲突
- 更新规范版本

**支持的变更类型**:
- 新增需求
- 修改现有需求
- 删除需求
- 重命名需求

### 阶段 5: 归档 (Archive)

**目的**: 归档已完成的变更，维护历史记录

**命令**: `/opsx-archive [变更名称]`

**活动**:
- 验证工件完成
- 验证任务完成
- 同步最终规范
- 移动到归档目录

## 工作流程变体

### 增量开发工作流程

适用于小型、频繁的变更：

1. **创建变更**
   ```bash
   openspec new change "small-feature"
   ```

2. **快速提案**
   ```bash
   /opsx-propose small-feature
   ```

3. **实现功能**
   ```bash
   /opsx-apply small-feature
   ```

4. **同步规范**
   ```bash
   /opsx-sync small-feature
   ```

5. **立即归档**
   ```bash
   /opsx-archive small-feature
   ```

### 大型项目工作流程

适用于复杂、多阶段的项目：

1. **探索阶段**
   ```bash
   /opsx-explore 整体架构设计
   ```

2. **创建主变更**
   ```bash
   /opsx-propose 整体系统重构
   ```

3. **分阶段实现**
   ```bash
   /opsx-apply main-refactor
   # 实现部分任务
   /opsx-apply main-refactor
   # 继续实现
   ```

4. **增量规范更新**
   ```bash
   # 在实现过程中发现新需求
   # 更新 specs/ 中的增量规范
   /opsx-sync main-refactor
   ```

5. **最终归档**
   ```bash
   /opsx-archive main-refactor
   ```

## 并行工作流程

OpenSpec 支持同时维护多个变更：

```bash
# 查看所有活跃变更
openspec list --json

# 在不同变更间切换
/opsx-apply change-1
/opsx-apply change-2
```

## 工作流程状态管理

### 变更状态

- **active**: 活跃状态，正在开发中
- **archived**: 已归档，完成开发
- **blocked**: 被阻塞，等待依赖解决

### 工件状态

```json
{
  "artifacts": [
    {
      "id": "proposal",
      "status": "done",
      "dependencies": []
    },
    {
      "id": "design", 
      "status": "done",
      "dependencies": ["proposal"]
    },
    {
      "id": "specs",
      "status": "ready",
      "dependencies": ["design"]
    },
    {
      "id": "tasks",
      "status": "ready", 
      "dependencies": ["design"]
    }
  ]
}
```

### 任务状态

```markdown
# tasks.md

- [ ] 任务 1（待完成）
- [x] 任务 2（已完成）
```

## 最佳实践

### 1. 保持工件简洁

- proposal.md 控制在 500 字以内
- design.md 聚焦关键技术决策
- tasks.md 分解为 2 小时以内的小任务

### 2. 规范管理

- 使用增量格式修改规范
- 保持主规范的完整性
- 定期同步变更

### 3. 任务管理

- 使用可测试的任务描述
- 及时更新任务状态
- 遇到阻塞时立即标记

### 4. 版本控制

- 每个变更保持完整历史
- 归档时保留所有工件
- 定期清理未使用的变更

## 故障处理

### 工件依赖问题

如果某个工件无法创建：

1. 检查依赖是否完成
2. 使用 `/opsx-explore` 探索问题
3. 更新依赖工件
4. 重新尝试创建

### 实现阻塞

实现过程中遇到问题：

1. 暂停实现
2. 更新相关工件
3. 使用 `/opsx-explore` 探索解决方案
4. 继续实现

### 规范冲突

同步时出现冲突：

1. 检查增量格式
2. 手动解决冲突
3. 重新同步
4. 更新变更规范

## 工作流程监控

### 状态检查

```bash
# 查看变更状态
openspec status --change <名称> --json

# 查看所有变更
openspec list --json

# 验证变更
openspec validate --change <名称>
```

### 进度跟踪

- 使用 `openspec status` 跟踪工件完成情况
- 使用 tasks.md 跟踪任务完成情况
- 定期检查依赖关系

## 自动化建议

### CI/CD 集成

1. 在预提交钩子中验证规范
2. 自动同步已完成的变更
3. 定期归档稳定的变更

### 工具集成

1. 与 IDE 集成，提供 OpenSpec 支持
2. 自动生成变更模板
3. 智能任务分解

## 总结

OpenSpec 工作流程提供了一个结构化的方法来管理软件变更。通过清晰的阶段划分、状态管理和最佳实践，确保开发过程的可控性和可追溯性。
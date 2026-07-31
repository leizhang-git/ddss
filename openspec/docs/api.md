# OpenSpec API 参考

## 概述

OpenSpec 提供了一套完整的 CLI API，用于管理规范变更和实现。本文档详细介绍了所有可用的命令和选项。

## 基本命令

### `openspec` - 主命令

```bash
openspec [command] [options]
```

## 变更管理命令

### `openspec new change` - 创建新变更

```bash
openspec new change "<change-name>"
```

**选项**:
- `--store <id>`: 指定存储 ID
- `--schema <name>`: 指定模式名称（默认：spec-driven）

**示例**:
```bash
# 创建新变更
openspec new change "user-authentication"

# 在指定存储中创建变更
openspec new change "user-authentication" --store "local-repo"
```

### `openspec list` - 列出变更

```bash
openspec list [options]
```

**选项**:
- `--json`: 以 JSON 格式输出
- `--store <id>`: 指定存储 ID

**示例**:
```bash
# 列出所有变更
openspec list

# 以 JSON 格式输出
openspec list --json

# 列出指定存储中的变更
openspec list --store "local-repo"
```

### `openspec show` - 显示变更详情

```bash
openspec show <change-name> [options]
```

**选项**:
- `--store <id>`: 指定存储 ID
- `--json`: 以 JSON 格式输出

**示例**:
```bash
# 显示变更详情
openspec show "user-authentication"

# 以 JSON 格式显示
openspec show "user-authentication" --json
```

## 状态和查询命令

### `openspec status` - 查看变更状态

```bash
openspec status --change <change-name> [options]
```

**选项**:
- `--json`: 以 JSON 格式输出
- `--store <id>`: 指定存储 ID
- `--verbose`: 显示详细信息

**输出格式**:
```json
{
  "changeName": "user-authentication",
  "schemaName": "spec-driven",
  "planningHome": "/path/to/openspec",
  "changeRoot": "/path/to/openspec/changes/user-authentication",
  "artifactPaths": {
    "proposal": {
      "existingOutputPaths": ["proposal.md"]
    },
    "design": {
      "existingOutputPaths": ["design.md"]
    },
    "specs": {
      "existingOutputPaths": ["specs/authentication/spec.md"]
    },
    "tasks": {
      "existingOutputPaths": ["tasks.md"]
    }
  },
  "actionContext": {
    "canEdit": true,
    "readConstraints": [],
    "writeConstraints": []
  },
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
  ],
  "applyRequires": ["tasks"]
}
```

### `openspec instructions` - 获取创建指令

```bash
openspec instructions <artifact-id> --change <change-name> [options]
```

**选项**:
- `--json`: 以 JSON 格式输出
- `--store <id>`: 指定存储 ID

**输出格式**:
```json
{
  "context": {
    "project": {
      "name": "DDSS 管理系统",
      "techStack": ["Java 8", "Spring Boot 2.5.15", "Vue 2"],
      "domain": "企业级管理系统"
    }
  },
  "rules": {
    "proposal": [
      "保持提案简洁，不超过 500 字",
      "必须包含非目标部分"
    ]
  },
  "template": "# {{changeName}} 提案\n\n## 问题描述\n\n## 解决方案概述\n\n## 范围\n\n### 包含\n\n### 不包含\n\n## 非目标\n\n## 风险和依赖\n",
  "instruction": "创建一个简洁的变更提案，包含问题描述、解决方案、范围和非目标部分。",
  "resolvedOutputPath": "changes/user-authentication/proposal.md",
  "dependencies": []
}
```

### `openspec apply instructions` - 获取实现指令

```bash
openspec apply instructions --change <change-name> [options]
```

**选项**:
- `--json`: 以 JSON 格式输出
- `--store <id>`: 指定存储 ID

**输出格式**:
```json
{
  "state": "ready",
  "progress": {
    "total": 5,
    "complete": 2,
    "remaining": 3
  },
  "contextFiles": {
    "proposal": ["changes/user-authentication/proposal.md"],
    "design": ["changes/user-authentication/design.md"],
    "specs": ["changes/user-authentication/specs/authentication/spec.md"],
    "tasks": ["changes/user-authentication/tasks.md"]
  },
  "tasks": [
    {
      "id": 1,
      "description": "创建用户认证模块",
      "status": "done"
    },
    {
      "id": 2,
      "description": "实现 JWT 令牌生成",
      "status": "done"
    },
    {
      "id": 3,
      "description": "添加登录接口",
      "status": "pending"
    },
    {
      "id": 4,
      "description": "实现权限验证",
      "status": "pending"
    },
    {
      "id": 5,
      "description": "编写测试用例",
      "status": "pending"
    }
  ],
  "instruction": "继续实现剩余任务，从任务 3 开始。"
}
```

## 验证和诊断命令

### `openspec validate` - 验证变更

```bash
openspec validate --change <change-name> [options]
```

**选项**:
- `--store <id>`: 指定存储 ID
- `--strict`: 严格模式，包含警告

**示例**:
```bash
# 验证变更
openspec validate --change "user-authentication"

# 严格验证
openspec validate --change "user-authentication" --strict
```

### `openspec doctor` - 诊断问题

```bash
openspec doctor --change <change-name> [options]
```

**选项**:
- `--store <id>`: 指定存储 ID
- `--json`: 以 JSON 格式输出

**示例**:
```bash
# 诊断变更问题
openspec doctor --change "user-authentication"

# 以 JSON 格式输出诊断结果
openspec doctor --change "user-authentication" --json
```

### `openspec context` - 获取上下文信息

```bash
openspec context --change <change-name> [options]
```

**选项**:
- `--store <id>`: 指定存储 ID
- `--json`: 以 JSON 格式输出

## 存储管理命令

### `openspec store` - 存储管理

```bash
# 列出所有存储
openspec store list [options]

# 添加新存储
openspec store add <store-id> <store-path> [options]

# 移除存储
openspec store remove <store-id> [options]

# 切换默认存储
openspec store use <store-id> [options]
```

**选项**:
- `--json`: 以 JSON 格式输出

**示例**:
```bash
# 列出所有存储
openspec store list

# 添加本地存储
openspec store add local-repo /path/to/openspec/repo

# 使用指定存储
openspec store use local-repo
```

## 同步命令

### `openspec sync` - 同步规范

```bash
openspec sync --change <change-name> [options]
```

**选项**:
- `--store <id>`: 指定存储 ID
- `--dry-run`: 预览模式，不实际执行
- `--force`: 强制同步，跳过确认

**示例**:
```bash
# 同步规范
openspec sync --change "user-authentication"

# 预览同步结果
openspec sync --change "user-authentication" --dry-run

# 强制同步
openspec sync --change "user-authentication" --force
```

## 归档命令

### `openspec archive` - 归档变更

```bash
openspec archive --change <change-name> [options]
```

**选项**:
- `--store <id>`: 指定存储 ID
- `--include-delta`: 包含增量规范
- `--destination <path>`: 自定义归档路径

**示例**:
```bash
# 归档变更
openspec archive --change "user-authentication"

# 包含增量规范归档
openspec archive --change "user-authentication" --include-delta

# 自定义归档路径
openspec archive --change "user-authentication" --destination "/custom/path"
```

## 配置命令

### `openspec config` - 配置管理

```bash
# 查看当前配置
openspec config show [options]

# 设置配置值
openspec config set <key> <value> [options]

# 删除配置
openspec config unset <key> [options]

# 重置配置
openspec config reset [options]
```

**选项**:
- `--global`: 全局配置
- `--local`: 本地配置

**示例**:
```bash
# 查看配置
openspec config show

# 设置默认模式
openspec config set schema "spec-driven"

# 设置项目上下文
openspec config set.context "Tech stack: Java, Spring Boot"
```

## 输出格式

### JSON 输出

所有支持 `--json` 选项的命令都会返回标准化的 JSON 格式：

```json
{
  "success": true,
  "data": {
    // 具体数据内容
  },
  "metadata": {
    "command": "status",
    "change": "user-authentication",
    "timestamp": "2024-01-01T00:00:00Z",
    "version": "1.0.0"
  }
}
```

### 错误格式

```json
{
  "success": false,
  "error": {
    "code": "CHANGE_NOT_FOUND",
    "message": "Change 'user-authentication' not found",
    "details": {
      "availableChanges": ["feature-1", "feature-2"]
    }
  },
  "metadata": {
    "command": "show",
    "change": "user-authentication",
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

## 状态码

| 状态码 | 描述 |
|--------|------|
| 0 | 成功 |
| 1 | 一般错误 |
| 2 | 变更未找到 |
| 3 | 工件创建失败 |
| 4 | 同步冲突 |
| 5 | 验证失败 |

## 使用示例

### 完整工作流程示例

```bash
# 1. 创建新变更
openspec new change "user-authentication"

# 2. 查看状态
openspec status --change "user-authentication" --json

# 3. 获取提案创建指令
openspec instructions proposal --change "user-authentication" --json

# 4. 生成设计文档
openspec instructions design --change "user-authentication" --json

# 5. 获取任务列表
openspec apply instructions --change "user-authentication" --json

# 6. 验证变更
openspec validate --change "user-authentication"

# 7. 同步规范
openspec sync --change "user-authentication"

# 8. 归档变更
openspec archive --change "user-authentication"
```

### 批量操作示例

```bash
# 列出所有变更并处理
for change in $(openspec list --json | jq -r '.[].name'); do
  echo "Processing $change..."
  openspec validate --change "$change"
done

# 批量同步
openspec list --json | jq -r '.[].name' | while read -r change; do
  if [ "$change" != "archived" ]; then
    openspec sync --change "$change"
  fi
done
```

## 高级用法

### 自定义脚本

```bash
#!/bin/bash
# deploy-change.sh

change_name="$1"

# 验证变更
openspec validate --change "$change_name" || exit 1

# 同步规范
openspec sync --change "$change_name" || exit 1

# 归档变更
openspec archive --change "$change_name" || exit 1

echo "Change $change_name deployed successfully!"
```

### 集成到 CI/CD

```yaml
# .github/workflows/openspec.yml
name: OpenSpec Workflow

on:
  pull_request:
    paths:
      - 'openspec/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Validate changes
        run: |
          openspec list --json | jq -r '.[].name' | while read -r change; do
            openspec validate --change "$change"
          done
```

## 故障排除

### 常见错误

1. **CHANGE_NOT_FOUND**
   - 检查变更名称是否正确
   - 使用 `openspec list` 查看所有变更

2. **ARTIFACT_DEPENDENCY_ERROR**
   - 检查工件依赖关系
   - 按正确顺序创建工件

3. **SYNC_CONFLICT**
   - 使用 `--dry-run` 预览冲突
   - 手动解决冲突后重新同步

### 调试技巧

1. **详细输出**
   ```bash
   openspec --verbose status --change "example"
   ```

2. **JSON 调试**
   ```bash
   openspec status --change "example" --json | jq '.'
   ```

3. **日志级别**
   ```bash
   export OPENSPEC_LOG_LEVEL=debug
   openspec status --change "example"
   ```

## 更新和维护

### 更新 OpenSpec

```bash
# 检查版本
openspec --version

# 更新到最新版本
npm update -g @openspec/cli
```

### 清理旧变更

```bash
# 归档所有完成超过 30 天的变更
openspec list --json | jq -r '.[].name' | while read -r change; do
  openspec show "$change" --json | jq -r '.metadata.age > 30' | grep true && \
  openspec archive --change "$change"
done
```

## 总结

OpenSpec 提供了一套完整且强大的 API，用于管理软件开发的规范和实现。通过 CLI 工具，可以轻松地创建、管理、验证和同步规范变更。本文档涵盖了所有主要的 API 命令，帮助开发者充分利用 OpenSpec 的功能。
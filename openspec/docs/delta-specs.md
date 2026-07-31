# OpenSpec 增量规范格式详解

## 概述

增量规范是 OpenSpec 中用于表示对现有规范进行修改的一种轻量级格式。它允许在不复制整个规范的情况下，精确地表达对规范的添加、修改、删除和重命名操作。

## 增量规范的用途

1. **版本控制**: 跟踪规范的变更历史
2. **代码审查**: 清晰展示具体的修改内容
3. **冲突解决**: 帮助理解和解决规范冲突
4. **同步更新**: 将变更同步到主规范
5. **协作开发**: 支持团队成员之间的规范变更

## 增量规范结构

### 基本格式

增量规范是 Markdown 文件，包含以下四个主要部分：

```markdown
## ADDED Requirements
## MODIFIED Requirements  
## REMOVED Requirements
## RENAMED Requirements
```

### 1. ADDED Requirements - 新增需求

用于添加新的功能需求到现有规范。

#### 格式规范

```markdown
## ADDED Requirements

### Requirement: <需求名称>
需求描述，使用 SHALL 语句...

#### Scenario: <场景名称>
- **GIVEN** <前置条件>
- **WHEN** <用户操作>
- **THEN** <预期结果>

#### Scenario: <边界场景>
- **GIVEN** <特殊情况>
- **WHEN** <执行操作>
- **THEN** <预期处理>
```

#### 示例

```markdown
## ADDED Requirements

### Requirement: 用户密码重置
系统 SHALL 支持用户通过邮箱重置密码。

#### Scenario: 发送重置邮件
- **GIVEN** 用户已存在且邮箱已验证
- **WHEN** 用户点击"忘记密码"链接
- **THEN** 系统发送重置密码邮件到用户邮箱
- **AND** 邮件包含有效期为 1 小时的重置链接

#### Scenario: 使用重置链接
- **GIVEN** 用户点击重置链接
- **WHEN** 用户输入新密码并确认
- **THEN** 系统更新用户密码
- **AND** 用户使用新密码成功登录
```

### 2. MODIFIED Requirements - 修改需求

用于修改现有需求的描述或添加新的场景。

#### 格式规范

```markdown
## MODIFIED Requirements

### Requirement: <现有需求名称>
#### Scenario: <新场景名称>
- **GIVEN** <前置条件>
- **WHEN** <用户操作>
- **THEN** <预期结果>

#### Scenario: <修改的场景名称>
- **GIVEN** <修改的前置条件>
- **WHEN** <修改的用户操作>
- **THEN** <修改的预期结果>
```

#### 示例

```markdown
## MODIFIED Requirements

### Requirement: 用户登录
#### Scenario: 记住登录状态
- **GIVEN** 用户勾选"记住我"选项
- **WHEN** 用户成功登录
- **THEN** 系统在 30 天内保持登录状态

### Requirement: 商品搜索
#### Scenario: 按价格排序
- **GIVEN** 用户已进入商品列表页面
- **WHEN** 用户点击"价格从低到高"排序
- **THEN** 商品按价格升序排列
```

### 3. REMOVED Requirements - 删除需求

用于标记不再需要的需求。

#### 格式规范

```markdown
## REMOVED Requirements

### Requirement: <需求名称>
（可选）删除原因说明...
```

#### 示例

```markdown
## REMOVED Requirements

### Requirement: 传统表单提交
已改为使用 AJAX 异步提交，不再需要传统表单提交方式。

### Requirement: PDF 导出功能
由于第三方服务不稳定，暂时移除此功能。
```

### 4. RENAMED Requirements - 重命名需求

用于重命名现有的需求。

#### 格式规范

```markdown
## RENAMED Requirements

- FROM: `### Requirement: 旧名称`
- TO: `### Requirement: 新名称`
```

#### 示例

```markdown
## RENAMED Requirements

- FROM: `### Requirement: 用户资料管理`
- TO: `### Requirement: 个人信息管理`

- FROM: `### Requirement: 商品展示`
- TO: `### Requirement: 商品列表`
```

## 完整示例

### 变更前主规范

```markdown
# 用户管理规范

## Purpose
管理系统用户相关的功能。

## Requirements
### Requirement: 用户注册
系统 SHALL 支持用户注册功能。

#### Scenario: 用户注册
- **GIVEN** 用户访问注册页面
- **WHEN** 用户填写注册信息并提交
- **THEN** 系统创建用户账号

### Requirement: 用户登录
系统 SHALL 支持用户登录功能。

#### Scenario: 用户登录
- **GIVEN** 用户拥有有效账号
- **WHEN** 用户输入用户名和密码
- **THEN** 系统验证用户身份
```

### 增量规范

```markdown
## ADDED Requirements

### Requirement: 用户密码重置
系统 SHALL 支持用户密码重置功能。

#### Scenario: 发送重置邮件
- **GIVEN** 用户已存在且邮箱已验证
- **WHEN** 用户点击忘记密码链接
- **THEN** 系统发送重置邮件

## MODIFIED Requirements

### Requirement: 用户登录
#### Scenario: 记住登录状态
- **GIVEN** 用户勾选记住我选项
- **WHEN** 用户成功登录
- **THEN** 系统保持 30 天登录状态

### Requirement: 用户注册
#### Scenario: 邮箱验证
- **GIVEN** 用户注册成功
- **WHEN** 系统发送验证邮件
- **THEN** 用户必须验证邮箱后才能登录

## RENAMED Requirements

- FROM: `### Requirement: 用户注册`
- TO: `### Requirement: 用户账号创建`
```

### 同步后的主规范

```markdown
# 用户管理规范

## Purpose
管理系统用户相关的功能。

## Requirements
### Requirement: 用户账号创建
系统 SHALL 支持用户账号创建功能。

#### Scenario: 用户注册
- **GIVEN** 用户访问注册页面
- **WHEN** 用户填写注册信息并提交
- **THEN** 系统创建用户账号

#### Scenario: 邮箱验证
- **GIVEN** 用户注册成功
- **WHEN** 系统发送验证邮件
- **THEN** 用户必须验证邮箱后才能登录

### Requirement: 用户登录
系统 SHALL 支持用户登录功能。

#### Scenario: 用户登录
- **GIVEN** 用户拥有有效账号
- **WHEN** 用户输入用户名和密码
- **THEN** 系统验证用户身份

#### Scenario: 记住登录状态
- **GIVEN** 用户勾选记住我选项
- **WHEN** 用户成功登录
- **THEN** 系统保持 30 天登录状态

### Requirement: 用户密码重置
系统 SHALL 支持用户密码重置功能。

#### Scenario: 发送重置邮件
- **GIVEN** 用户已存在且邮箱已验证
- **WHEN** 用户点击忘记密码链接
- **THEN** 系统发送重置邮件
```

## 增量规范最佳实践

### 1. 保持原子性

每个增量规范应该聚焦于一个特定的变更，避免混合多个不相关的变更。

### 2. 清晰描述

使用明确的语言描述变更，避免歧义。

### 3. 版本控制

为每个增量规范添加版本信息或日期标记。

### 4. 审计追踪

保留增量规范的历史记录，以便追踪变更的演变过程。

### 5. 一致性

保持与现有规范相同的格式和术语。

## 智能合并规则

### 合并策略

1. **新增操作**: 直接添加到主规范末尾
2. **修改操作**: 找到对应需求，更新或添加场景
3. **删除操作**: 移除整个需求块
4. **重命名操作**: 更新需求标题，保持内容不变

### 冲突处理

1. **并发修改**: 最新版本优先
2. **冲突场景**: 需要人工干预
3. **循环引用**: 自动检测并提示

## 增量规范验证

### 验证规则

1. **格式验证**: 确保符合基本格式要求
2. **引用验证**: 确保引用的需求存在
3. **逻辑验证**: 确保场景的 GIVEN-WHEN-THEN 逻辑正确
4. **完整性验证**: 确保没有遗漏重要的变更

### 验证工具

```bash
# 验证增量规范格式
openspec validate-delta --file <delta-file>

# 预览合并结果
openspec preview-sync --change <change-name>

# 执行同步
openspec sync --change <change-name>
```

## 实际应用场景

### 1. 功能增强

```markdown
## ADDED Requirements
### Requirement: 导出功能
系统 SHALL 支持数据导出为 CSV 格式。

## MODIFIED Requirements  
### Requirement: 数据查询
#### Scenario: 分页查询
- **GIVEN** 数据量超过一页
- **WHEN** 用户指定页码
- **THEN** 返回对应页的数据
```

### 2. Bug 修复

```markdown
## MODIFIED Requirements
### Requirement: 表单验证
#### Scenario: 邮箱格式验证
- **GIVEN** 用户输入无效邮箱
- **WHEN** 提交表单
- **THEN** 显示邮箱格式错误提示
```

### 3. 架构重构

```markdown
## REMOVED Requirements
### Requirement: 旧模块集成
已迁移到新架构，移除旧模块依赖。

## ADDED Requirements
### Requirement: 新模块集成
系统 SHALL 使用新的微服务架构。
```

## 总结

增量规范提供了一种轻量级的方式来管理规范的变更，具有以下优势：

1. **精确性**: 精确指定变更内容
2. **效率**: 无需复制整个规范
3. **可追溯**: 清晰的变更历史
4. **协作友好**: 便于团队协作和代码审查

通过正确使用增量规范，可以有效地管理规范的演进，确保规范与实现保持同步。
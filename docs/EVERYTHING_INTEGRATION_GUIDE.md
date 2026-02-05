# Everything-Claude-Code 集成指南

## 集成概述

**集成日期**: 2026-02-05
**集成版本**: v0.4.0
**项目**: n8n-workwolf

本指南说明如何在 n8n-workwolf 项目中使用 Everything-Claude-Code 开发环境。

---

## 快速开始

### 激活开发环境

在 Claude Code 会话中输入：

```
使用 vibe-coding-cn 方法论开始开发
```

这将激活：
- Vibe Coding 结对编程模式
- 所有启用的 Agents 和 Commands
- 9 个专业 Skills
- 13 个 MCP 服务器
- Hooks 自动化系统

---

## 核心组件

### 1. Agents (3 个)

#### planner - 实现规划
**使用场景**:
- 复杂功能实施
- 架构重构
- 多步骤任务

**触发方式**:
```
"使用 planner agent 分析这个需求"
```

#### architect - 系统设计
**使用场景**:
- 技术决策
- 架构设计
- 性能优化

**触发方式**:
```
"使用 architect agent 设计这个功能"
```

#### code-reviewer - 代码审查
**使用场景**:
- 代码变更后（必须执行）
- 提交前审查
- 安全检查

**触发方式**:
```
"使用 code-reviewer agent 审查这段代码"
```

---

### 2. Commands (3 个)

#### /plan - 实施计划
创建详细的实施计划和风险评估。

**用法**:
```
/plan
创建一个 n8n 工作流来调用聚鑫 API 生成视频
```

**输出**:
1. 需求分析
2. 风险评估
3. 实施步骤
4. 验证标准

#### /tdd - 测试驱动开发
使用 TDD 工作流开发新功能。

**用法**:
```
/tdd
实现工作流的错误处理逻辑
```

**流程**:
1. RED - 编写失败的测试
2. GREEN - 实现最小代码
3. IMPROVE - 重构优化
4. 验证 80%+ 覆盖率

#### /code-review - 代码审查
全面审查代码质量和安全。

**用法**:
```
/code-review
审查 skills/n8n-workflow-patterns/
```

**检查项**:
- 代码规范
- 安全问题
- 性能问题
- 最佳实践

---

### 3. Skills (9 个)

#### Everything Skills (4 个)

**vibe-coding-cn**
- Vibe Coding 方法论
- AI 结对编程最佳实践

**coding-standards**
- 通用编码规范
- TypeScript/JavaScript 最佳实践

**tdd-workflow**
- 测试驱动开发流程
- 80%+ 测试覆盖率要求

**security-review**
- 安全审查清单
- OWASP Top 10 防护

#### n8n Skills (5 个)

**n8n-expression-syntax**
- n8n 表达式语法参考

**n8n-mcp-tools-expert**
- n8n MCP 工具专家

**n8n-node-configuration**
- n8n 节点配置指南

**n8n-validation-expert**
- n8n 验证专家

**n8n-workflow-patterns**
- n8n 工作流模式

---

### 4. MCP 服务器 (13 个)

#### 核心服务器 (4 个)
1. **memory** - 知识图谱存储
2. **github** - GitHub 操作
3. **context7** - 官方文档查询
4. **fetch** - HTTP 请求

#### GLM 服务器 (3 个)
5. **web-search-prime** - 网络搜索
6. **web-reader** - 网页提取
7. **zai-mcp-server** - 视觉理解

#### n8n 特定 (2 个)
8. **n8n-mcp** - n8n 工作流
9. **skills-mcp** - Skills 服务

#### 浏览器 (2 个)
10. **chrome-devtools** - 浏览器自动化
11. **browsermcp** - 浏览器操作

#### 其他 (2 个)
12. **sequential-thinking** - 复杂推理
13. **notion** - Notion 文档

---

## 工作流示例

### 场景 1: 创建新的 n8n 工作流

```
# 1. 创建实施计划
/plan
创建一个工作流：接收 Webhook → 调用聚鑫 API → 返回视频结果

# 2. 使用 TDD 开发
/tdd
实现这个工作流

# 3. 代码审查
/code-review
审查工作流配置

# 4. 更新知识库
将工作流信息记录到 Memory MCP
```

### 场景 2: 调试工作流问题

```
# 1. 分析问题
使用 sequential-thinking MCP 分析问题原因

# 2. 搜索解决方案
使用 web-search-prime 搜索类似问题

# 3. 验证配置
使用 n8n-validation-expert skill

# 4. 记录问题
更新 memory-bank/progress.md
```

### 场景 3: 优化现有工作流

```
# 1. 性能分析
使用 architect agent 分析性能

# 2. 应用最佳实践
使用 n8n-workflow-patterns skill

# 3. 代码审查
使用 code-reviewer agent

# 4. 更新文档
更新 memory-bank/architecture.md
```

---

## Memory 知识库

### 查询知识库

```
# 搜索实体
搜索: "n8n-mcp"
搜索: "聚鑫API"

# 读取整个图谱
读取整个知识图谱
```

### 创建实体

```
创建实体:
- 名称: Sora2视频生成工作流
- 类型: workflow
- 描述: 调用聚鑫 API 生成视频
```

### 更新文档

```
# 更新进度
编辑 memory-bank/progress.md

# 更新架构
编辑 memory-bank/architecture.md
```

---

## Hooks 自动化

### PreToolUse (执行前)
- 提醒使用 tmux 执行长时间命令
- Git 推送前打开审查
- 阻止创建不必要的文档

### PostToolUse (执行后)
- 自动格式化 JS/TS 文件
- TypeScript 类型检查
- 警告 console.log 使用

### Stop (会话结束)
- 检查所有修改的文件中的 console.log

---

## 环境配置

### 必需的环境变量

```bash
# GitHub
GITHUB_TOKEN=your_github_token

# GLM
GLM_API_KEY=your_glm_api_key
ZAI_API_KEY=your_zai_api_key

# n8n
N8N_API_URL=http://localhost:5678
N8N_API_KEY=your_n8n_api_key

# 项目路径
PROJECT_PATH=E:/User/GitHub/n8n-workwolf
```

### 配置文件

- **MCP 配置**: `.claude/mcp_config.json`
- **环境变量模板**: `.env.example`
- **Skills 清单**: `.claude/SKILLS_MANIFEST.md`

---

## 最佳实践

### 1. 开发流程
```
需求分析 → /plan → TDD 开发 → 代码审查 → 更新文档
```

### 2. 代码质量
- 始终使用 TDD 工作流
- 代码变更后必须代码审查
- 80%+ 测试覆盖率
- 遵循编码规范

### 3. 知识管理
- 更新 Memory 知识库
- 记录问题和解决方案
- 维护架构文档
- 定期更新进度

### 4. 安全
- 使用 security-review skill
- 不硬编码敏感信息
- 定期审查 API Keys
- 遵循最小权限原则

---

## 故障排除

### MCP 服务器连接失败

**症状**: 无法连接到 MCP 服务器

**解决**:
1. 检查环境变量是否设置
2. 验证 MCP 配置文件
3. 查看 Claude Code 日志
4. 重启 Claude Code

### Skills 不工作

**症状**: Skills 无法加载

**解决**:
1. 检查 skills-mcp 路径
2. 验证 SKILL.md 文件
3. 查看 MCP 服务器日志
4. 重新启动 MCP 服务器

### Hooks 失败

**症状**: Hooks 脚本执行失败

**解决**:
1. 检查 Node.js 版本
2. 验证脚本权限
3. 查看 hooks.json 配置
4. 检查脚本语法

---

## 相关文档

- **项目文档**: `CLAUDE.md`
- **Memory 知识库**: `memory-bank/`
- **Skills 清单**: `.claude/SKILLS_MANIFEST.md`
- **MCP 配置**: `.claude/mcp_config.json`
- **规则文件**: `.claude/rules/`

---

## 获取帮助

### 使用 help command
```
/help
```

### 查看可用 agents
```
列出所有可用的 agents
```

### 查看可用 commands
```
列出所有可用的 commands
```

---

## 版本历史

### v1.0.0 (2026-02-05)
- 初始集成 Everything-Claude-Code v0.4.0
- 添加 13 个 MCP 服务器
- 添加 9 个 Skills
- 初始化 Memory 知识库

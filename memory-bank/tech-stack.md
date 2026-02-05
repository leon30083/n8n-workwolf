# n8n-workwolf 技术栈文档

## 开发环境

### 核心工具
- **IDE**: Cursor / VS Code
- **AI 助手**: Claude Code (Everything-Claude-Code v0.4.0)
- **版本控制**: Git
- **工作流引擎**: n8n

### 开发方法论
- **Vibe Coding**: AI 结对编程
- **TDD**: 测试驱动开发 (80%+ 覆盖率)
- **Git Flow**: 特性分支工作流

---

## MCP 服务器架构

### 核心服务器 (13 个)

| # | 服务器 | 用途 | 优先级 |
|---|--------|------|--------|
| 1 | memory | 知识图谱存储 | P0 |
| 2 | github | GitHub 操作 | P0 |
| 3 | n8n-mcp | n8n 工作流 | P0 |
| 4 | skills-mcp | Skills 服务 | P0 |
| 5 | context7 | 文档查询 | P1 |
| 6 | chrome-devtools | 浏览器自动化 | P1 |
| 7 | sequential-thinking | 复杂推理 | P1 |
| 8 | fetch | HTTP 请求 | P1 |
| 9 | web-search-prime | 网络搜索 | P2 |
| 10 | web-reader | 网页提取 | P2 |
| 11 | zai-mcp-server | 视觉理解 | P2 |
| 12 | browsermcp | 浏览器操作 | P2 |
| 13 | notion | Notion 文档 | P3 |

---

## Skills 架构

### Everything Skills (4 个)
1. **vibe-coding-cn**: Vibe Coding 方法论
2. **coding-standards**: 编码规范
3. **tdd-workflow**: TDD 工作流
4. **security-review**: 安全审查

### n8n Skills (5 个)
1. **n8n-expression-syntax**: 表达式语法
2. **n8n-mcp-tools-expert**: MCP 工具专家
3. **n8n-node-configuration**: 节点配置
4. **n8n-validation-expert**: 验证专家
5. **n8n-workflow-patterns**: 工作流模式

---

## Agents 系统 (3 个)

### 启用的 Agents
1. **planner**: 实现规划
2. **architect**: 系统设计
3. **code-reviewer**: 代码审查

### 使用场景
- **复杂功能**: 先 planner 后 architect
- **代码变更**: code-reviewer 必须执行
- **架构决策**: architect agent

---

## Commands 系统 (3 个)

### 启用的 Commands
1. **/plan**: 需求分析和实施计划
2. **/tdd**: TDD 工作流
3. **/code-review**: 代码审查

### Hooks 自动化
- **PreToolUse**: 验证和参数修改
- **PostToolUse**: 自动格式化和检查
- **Stop**: 会话结束验证

---

## Contexts 系统 (3 个)

### 上下文模板
1. **dev.md**: 开发上下文
2. **review.md**: 审查上下文
3. **research.md**: 研究上下文

---

## Rules 系统 (8 个)

### 编码规范
1. **agents.md**: Agent 编排
2. **coding-style.md**: 代码风格
3. **git-workflow.md**: Git 工作流
4. **hooks.md**: Hooks 系统
5. **patterns.md**: 常见模式
6. **performance.md**: 性能优化
7. **security.md**: 安全指南
8. **testing.md**: 测试要求

---

## Memory 知识库

### 目录结构
```
memory-bank/
├── prompts/          # 提示词模板
├── prd.md            # 产品需求文档
├── tech-stack.md     # 技术栈文档 (本文件)
├── implementation-plan.md  # 实施计划
├── progress.md       # 进度记录
└── architecture.md   # 架构文档
```

### 初始实体
- n8n-workwolf (project)
- n8n-mcp (mcp-server)
- skills-mcp (mcp-server)
- 聚鑫API (external-api)
- Sora2 (external-api)

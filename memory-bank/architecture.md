# n8n-workwolf 架构文档

## 系统架构

### 高层架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                     n8n-workwolf 平台                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                 Claude Code 开发环境                       │  │
│  │  (Everything-Claude-Code v0.4.0 集成)                     │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │  Agents (3)    │  Commands (3)  │  Rules (8)  │ Hooks    │  │
│  │  - planner     │  - /plan       │  - agents   │ - PreTool │  │
│  │  - architect   │  - /tdd        │  - coding  │ - PostTool│  │
│  │  - reviewer    │  - /code-review│  - git     │ - Stop    │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    Skills (9)                              │  │
│  ├──────────────────────┬────────────────────────────────────┤  │
│  │  Everything (4)      │  n8n Specific (5)                   │  │
│  │  - vibe-coding-cn    │  - expression-syntax                │  │
│  │  - coding-standards  │  - mcp-tools-expert                 │  │
│  │  - tdd-workflow      │  - node-configuration               │  │
│  │  - security-review   │  - validation-expert                │  │
│  │                      │  - workflow-patterns                │  │
│  └──────────────────────┴────────────────────────────────────┘  │
│                              │                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              MCP 服务器层 (13 个)                          │  │
│  ├───────────────────────────────────────────────────────────┤  │
│  │  Core (4)          │  GLM (3)        │  n8n (2)           │  │
│  │  - memory          │  - web-search   │  - n8n-mcp         │  │
│  │  - github          │  - web-reader   │  - skills-mcp      │  │
│  │  - context7        │  - zai-server                        │  │
│  │  - fetch           │                                         │  │
│  │                     │  Browser (2)   │  Other (2)         │  │
│  │                     │  - chrome-dev  │  - sequential      │  │
│  │                     │  - browsermcp  │  - notion          │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  Memory 知识库                              │  │
│  │  - prd.md                                                  │  │
│  │  - tech-stack.md                                           │  │
│  │  - implementation-plan.md                                  │  │
│  │  - progress.md                                             │  │
│  │  - architecture.md (本文件)                                │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                    │
└──────────────────────────────┼────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                      外部服务层                                   │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐      │
│  │   n8n       │  │  聚鑫API    │  │     Sora2           │      │
│  │  localhost  │  │  sora-2-all │  │  sora-2/sora-2-pro  │      │
│  │  :5678      │  │             │  │                     │      │
│  └─────────────┘  └─────────────┘  └─────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 数据流

### 开发工作流

```
用户输入
   │
   ▼
Claude Code (命令解析)
   │
   ├─→ /plan → planner agent → 实施计划
   │
   ├─→ /tdd → tdd-workflow skill → 测试先开发
   │
   └─→ /code-review → code-reviewer agent → 代码审查
         │
         ▼
    执行操作
         │
         ├─→ MCP 服务器 (n8n-mcp, skills-mcp, etc.)
         │
         └─→ Memory 知识库 (存储实体和关系)
```

### n8n 工作流执行

```
Claude Code
   │
   ▼
n8n-mcp (MCP 服务器)
   │
   ▼
n8n API (localhost:5678)
   │
   ▼
工作流执行
   │
   ├─→ 聚鑫 API (Sora2 视频生成)
   │
   └─→ 其他外部服务
```

---

## 组件说明

### 1. Claude Code 开发环境

**Agents (3)**
- **planner**: 实现规划和风险评估
- **architect**: 系统架构设计
- **code-reviewer**: 代码质量和安全审查

**Commands (3)**
- **/plan**: 需求分析、风险评估、实施计划
- **/tdd**: TDD 工作流，测试先行
- **/code-review**: 全面代码审查

**Rules (8)**
- agents.md, coding-style.md, git-workflow.md, hooks.md
- patterns.md, performance.md, security.md, testing.md

**Hooks 自动化**
- **PreToolUse**: 验证、参数修改
- **PostToolUse**: 自动格式化、类型检查
- **Stop**: 会话结束验证

---

### 2. Skills 系统 (9 个)

**Everything Skills (4)**
- 提供通用开发方法论和最佳实践
- Vibe Coding, TDD, 安全审查

**n8n Skills (5)**
- 提供 n8n 特定的专业知识
- 工作流模式、节点配置、验证

---

### 3. MCP 服务器层 (13 个)

**Core MCP (4)**
- memory: 知识图谱存储
- github: GitHub 操作
- context7: 文档查询
- fetch: HTTP 请求

**GLM MCP (3)**
- web-search-prime: 网络搜索
- web-reader: 网页提取
- zai-mcp-server: 视觉理解

**n8n MCP (2)**
- n8n-mcp: n8n 工作流
- skills-mcp: Skills 服务

**Browser MCP (2)**
- chrome-devtools: 浏览器自动化
- browsermcp: 浏览器操作

**Other (2)**
- sequential-thinking: 复杂推理
- notion: Notion 文档

---

### 4. Memory 知识库

**目录结构**
```
memory-bank/
├── prompts/          # 提示词模板
├── prd.md            # 产品需求
├── tech-stack.md     # 技术栈
├── implementation-plan.md  # 实施计划
├── progress.md       # 进度记录
└── architecture.md   # 架构 (本文件)
```

**初始实体**
- n8n-workwolf (project)
- n8n-mcp (mcp-server)
- skills-mcp (mcp-server)
- 聚鑫API (external-api)
- Sora2 (external-api)

---

## 扩展性

### 添加新的 MCP 服务器
1. 在 `.claude/mcp_config.json` 中添加配置
2. 在 `.env.example` 中添加环境变量
3. 更新 tech-stack.md

### 添加新的 Skill
1. 创建 Skill 目录和 SKILL.md
2. 更新 SKILLS_MANIFEST.md
3. 在 Memory 中创建实体

### 添加新的 Agent
1. 在 `.claude/agents/` 中创建 agent.md
2. 更新 agents.md 规则

---

## 安全考虑

1. **API Keys**: 所有敏感信息通过环境变量管理
2. **MCP 安全**: n8n-mcp 使用 stdio 模式，日志级别 error
3. **Git 安全**: .gitignore 排除 .env 文件
4. **Hooks 自动化**: PostToolUse 检查安全问题

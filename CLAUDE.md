# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**n8n-workwolf** is a specialized n8n workflow development workspace integrated with AI-assisted automation via Claude Code and Model Context Protocol (MCP). The primary goal is to build and manage n8n workflows for AI video generation, particularly leveraging the Juxin API for text-to-video and image-to-video capabilities.

### Technology Stack

- **n8n** - Workflow automation platform (running on `localhost:5678`)
- **Claude Code** - AI programming assistant for workflow creation and management
- **MCP (Model Context Protocol)** - Two implementations providing intelligent tools and skills:
  - `n8n-mcp` - Bridges Claude Code to n8n REST API
  - `skills-mcp` - Provides expert guidance on node selection and workflow patterns
- **Installed Skills**:
  - `n8n-mcp-tools-expert` - Expert guidance on n8n tools
  - `automation-helper-marketplace` - Automation helper utilities
  - `n8n-mcp-skills` - Extended n8n skills
- **External APIs** - Juxin API (AI video generation), Sora 2 API (OpenAI video generation)

## Project Structure

```
n8n-workwolf/
├── config/                              # MCP server configurations
│   ├── trae-mcp-n8n.json               # n8n MCP server config (N8N_API_URL, N8N_API_KEY)
│   └── trae-skills-mcp.json            # Skills MCP server config (absolute path required)
├── scripts/                             # Startup scripts
│   ├── run-n8n-mcp.ps1                 # PowerShell script to start n8n MCP
│   └── run-skills-mcp.ps1              # PowerShell script to start skills MCP
├── skills/                              # Custom skills for AI assistance
│   └── n8n-mcp-tools-expert/           # Expert skill for n8n tool guidance
│       └── SKILL.md                     # Skill instructions and tool references
├── 工作流/ (Workflows)                  # n8n workflow definition files (JSON)
├── API供应商信息/ (API Vendor Info)     # Third-party API documentation and specs
├── 测试/ (Tests)                       # Test resources and reference images
├── .trae/rules/                        # Trae project rules and guidelines
└── 原始需求.md                         # Original project requirements (Chinese)
```

## High-Level Architecture

```
Claude Code (AI Programming Assistant)
    ├─→ skills-mcp (npx skills-mcp)
    │   ├─ n8n-mcp-tools-expert
    │   ├─ automation-helper-marketplace
    │   └─ n8n-mcp-skills
    │       ├─ Expert guidance on node selection
    │       ├─ Configuration validation suggestions
    │       ├─ Workflow templates and best practices
    │       └─ API documentation integration
    │
    ├─→ n8n-mcp (npx n8n-mcp)
    │   └─→ n8n REST API (http://localhost:5678)
    │       ├─ Workflow CRUD operations
    │       ├─ Node discovery and documentation
    │       ├─ Configuration validation
    │       ├─ Workflow execution management
    │       └─ Execution history and debugging
    │
    └─→ Workflow Storage
        ├─ Workflow JSON files (in 工作流/ directory)
        ├─ API configurations and credentials
        └─ External API integrations
```

**Key Data Flow:**
1. User requests workflow development task in Claude Code
2. Claude Code communicates via MCP with both servers
3. Skills-MCP provides n8n expertise and validates approaches
4. n8n-MCP translates requests to n8n REST API calls
5. Workflows are created/updated/executed through n8n
6. Results returned to Claude Code for feedback and iteration

## Getting Started

### Prerequisites
- n8n installed globally: `E:\home\leon3000\.npm-global`
- Node.js with npm (for MCP tools)
- n8n accessible at `http://localhost:5678` with API key configured
- Claude Code CLI or IDE installed

### Starting the Environment

**1. Start n8n (if not running):**
```powershell
# From PowerShell or command prompt
npm start -g  # or navigate to n8n install directory and start
# Verify: http://localhost:5678
```

**2. Start MCP Servers (run these scripts in separate terminal windows):**

Using PowerShell scripts in `scripts/` directory:
```powershell
# Terminal 1 - Skills MCP
E:\User\Documents\GitHub\n8n-workwolf\scripts\run-skills-mcp.ps1

# Terminal 2 - n8n MCP
E:\User\Documents\GitHub\n8n-workwolf\scripts\run-n8n-mcp.ps1
```

Or manually:
```bash
# Skills MCP
npx skills-mcp

# n8n MCP
npx n8n-mcp
```

**3. Configure Claude Code:**
- Add the two MCP server configurations from `config/` directory to Claude Code's MCP settings
- Verify both servers connect successfully

## Common Development Tasks

### Workflow Development with Claude Code

**Typical Workflow:**
1. Describe desired functionality to Claude Code (e.g., "Create a workflow that calls Juxin API")
2. Claude Code discovers relevant nodes via n8n-MCP
3. Claude Code gets best practice suggestions via skills-mcp
4. Claude Code creates workflow and saves to n8n
5. Claude Code validates configuration and runs tests
6. Claude Code exports workflow and saves to `工作流/` directory

### Working with Workflows

**Creating a New Workflow:**
1. Tell Claude Code the workflow purpose (e.g., "Create a Juxin video generation workflow")
2. Claude Code will discover nodes using n8n-MCP: `list_nodes({category: "trigger"})`
3. Claude Code gets node essentials: `get_node_essentials("nodes-base.httpRequest")`
4. Claude Code creates workflow: `n8n_create_workflow({name, nodes, connections, settings})`
5. Claude Code saves to `工作流/` directory as JSON file

**Validating Workflow Configuration:**
- Quick check: `validate_node_minimal(nodeType, config)` - checks required fields
- Runtime validation: `validate_node_operation(nodeType, config, {profile:"runtime"})` - catches execution errors
- Full workflow: `n8n_validate_workflow({id})` - validates entire workflow structure

**Updating Workflows:**
- Incremental updates: `n8n_update_partial_workflow({id, operations})` - safer than full replace
- Auto-fix errors: `n8n_autofix_workflow({id, applyFixes:true})` - applies suggested fixes

### Node Discovery and Configuration

**Finding Nodes:**
1. By category: `list_nodes({category: "trigger"})` - browse trigger nodes
2. Full text search: `search_nodes({query: "keyword"})` - global search
3. Get essentials: `get_node_essentials("nodeType")` - required + common fields only
4. Full schema: `get_node_info("nodeType")` - complete node documentation

**Common Node Workflows:**
- **Trigger nodes**: Start, Webhook, Schedule (cronjob)
- **HTTP nodes**: HTTP Request (for API calls), HTTP Server (for webhooks)
- **Transform nodes**: Function, Code, Set
- **Conditional nodes**: IF, Switch (for branching)
- **Error handling**: Error handler nodes, conditional branching

### Working with the Juxin API

**API Configuration:**
- API Key: Store in n8n credentials (never commit to repo)
- Base URL: `https://api.juxinai.com` (or endpoint from API供应商信息/)
- Documentation: See `API供应商信息/聚鑫api文档.txt` and `补充信息.md`

**Common Workflow Pattern:**
1. **Trigger** (Webhook or Schedule) receives request
2. **HTTP Request** node calls Juxin API endpoint
3. **Parse response** with Set/Function node
4. **Handle errors** with error handlers and retry logic
5. **Return results** with HTTP Response or other output

**Best Practices:**
- Use HTTP Request node v4.3+ with `typeVersion: 4.3`
- Enable retry logic: `retryOnFail: true`, `maxTries: 3`
- Configure response handling: enable status code and headers
- Add error branch handling for failed API calls
- Include timeout configuration for long-running operations

### Debugging and Execution

**Claude Code can monitor workflow execution:**
```
n8n_list_executions({workflowId})     # List execution history
n8n_get_execution({id, mode:"full"})  # Get detailed execution info
```

**Common Issues & Solutions:**
- **API Key Invalid**: Verify credentials in n8n settings
- **CORS/SSRF Errors**: Use proxy configuration if needed (Windows proxy: localhost:7890 for Clash)
- **Node Configuration**: Validate with `validate_node_minimal` first, then `validate_node_operation`
- **Connection Issues**: Ensure n8n server is running and accessible, check API URL in MCP config

## MCP Configuration Files

### `config/trae-mcp-n8n.json`
Configuration for n8n MCP server. Requires:
- `N8N_API_URL`: Point to local n8n instance (default: `http://localhost:5678`)
- `N8N_API_KEY`: API key from n8n settings
- Path must be properly escaped on Windows

### `config/trae-skills-mcp.json`
Configuration for skills MCP server. Requires:
- `SKILLS_PATH`: **Absolute path** to skills directory (e.g., `E:/User/Documents/GitHub/n8n-workwolf/skills`)
- Must use forward slashes or escaped backslashes

### `scripts/run-*.ps1`
PowerShell startup scripts. May need to:
- Set execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Modify environment variables if using proxy (Clash on port 7890)

## MCP Tools and Skills

### n8n-MCP Tools Available

**Node Discovery:**
- `list_nodes({category, limit, offset})` - Browse nodes by category
- `search_nodes({query, mode, limit})` - Full-text search across nodes
- `list_ai_tools()` - List AI-related nodes
- `get_node_essentials(nodeType)` - Required and common parameters
- `get_node_info(nodeType)` - Complete node schema and documentation
- `search_node_properties(nodeType, searchTerm)` - Find specific properties

**Configuration Validation:**
- `validate_node_minimal(nodeType, config)` - Check required fields
- `validate_node_operation(nodeType, config, {profile})` - Deeper validation

**Workflow Management:**
- `n8n_create_workflow({name, nodes, connections, settings})`
- `n8n_update_partial_workflow({id, operations})` - Incremental updates
- `n8n_validate_workflow({id, options})` - Validate entire workflow
- `n8n_autofix_workflow({id, applyFixes})` - Automatic error fixing
- `n8n_list_executions({workflowId, limit, offset})`
- `n8n_get_execution({id, mode})` - Get execution details

### Skills System

Three primary skills are available via the skills-mcp that Claude Code can directly access:

**1. n8n-mcp-tools-expert** (Built-in)
- Choosing appropriate nodes for tasks
- Configuring node parameters correctly
- Designing error handling patterns
- Best practices for API integrations
- Workflow optimization and debugging

**2. AutomationHelper_plugins** (`automation-helper-marketplace`)
- Helper utilities for common automation patterns
- Workflow templates and snippets
- Integration assistance for popular services
- Pre-built automation components

**3. n8n-skills** (`n8n-mcp-skills`)
- Extended n8n node capabilities and documentation
- Advanced configuration patterns
- Performance optimization tips
- Community-contributed best practices

Claude Code has direct access to all these skill capabilities.

## Important Notes

### Security & Configuration
- Never commit API keys or credentials to the repository
- Store sensitive data in MCP config files or n8n credentials system
- Use environment variables or local config for API keys
- Windows proxy (Clash): Can set `HTTP_PROXY=localhost:7890` in PowerShell if needed

### Development Workflow
- Always validate node configuration with `validate_node_minimal` before running
- Test workflows in development before deploying to production
- Use `n8n_update_partial_workflow` for safe incremental changes
- Add error handlers to critical nodes for robustness
- Include retry logic for external API calls
- Save workflow JSON files to `工作流/` directory for version control
- Prefer latest node `typeVersion` (e.g., HTTP Request v4.3)
- Keep node configurations up-to-date
- Test before updating node versions in production workflows

### Workspace Rules (from `.trae/rules/project_rules.md`)
- Use absolute paths in MCP configs (e.g., `E:/...` format)
- Skills and tools are invoked via natural language in Trae
- Prefer `get_node_essentials` before `get_node_info` (lighter weight)
- Always use `validate_node_minimal` as first validation step
- Create new workflows in development environment before production use

## Related Files
- Project rules: `.trae/rules/project_rules.md` (in Chinese)
- Skills documentation: `skills/n8n-mcp-tools-expert/SKILL.md` (in Chinese)
- API documentation: `API供应商信息/` directory
- Original requirements: `原始需求.md` (in Chinese)
- Workflow examples: `工作流/` directory

---

# Everything-Claude-Code Integration

**集成日期**: 2026-02-05
**集成版本**: v0.4.0
**开发方法论**: Vibe Coding (AI 结对编程)

## 集成概述

n8n-workwolf 已集成 Everything-Claude-Code 开发环境，提供：
- **3 个 Agents**: planner, architect, code-reviewer
- **3 个 Commands**: /plan, /tdd, /code-review
- **8 个 Rules**: 编码规范、工作流程、安全指南
- **9 个 Skills**: 4 个 Everything + 5 个 n8n
- **13 个 MCP 服务器**: 核心开发工具 + n8n 特定
- **Hooks 自动化**: PreToolUse, PostToolUse, Stop
- **3 个 Contexts**: dev, review, research

## Agents (3 个)

### planner
实现规划专家。使用场景：
- 复杂功能实施
- 架构重构
- 多步骤任务

### architect
系统设计专家。使用场景：
- 技术决策
- 架构设计
- 性能优化

### code-reviewer
代码审查专家。使用场景：
- 代码变更后（必须执行）
- 提交前审查
- 安全检查

## Commands (3 个)

### /plan
需求分析和实施计划。用法：
```
/plan
描述你的需求...
```

### /tdd
测试驱动开发工作流。用法：
```
/tdd
描述要实现的功能...
```

### /code-review
代码审查。用法：
```
/code-review
指定文件或变更...
```

## Rules (8 个)

| Rule | 说明 |
|------|------|
| agents.md | Agent 编排规则 |
| coding-style.md | 代码风格规范 |
| git-workflow.md | Git 工作流 |
| hooks.md | Hooks 自动化系统 |
| patterns.md | 常见模式 |
| performance.md | 性能优化 |
| security.md | 安全指南 |
| testing.md | 测试要求 (80%+ 覆盖率) |

## Hooks 自动化系统

### PreToolUse (执行前)
- tmux reminder (长时间命令)
- git push review (推送前审查)
- doc blocker (阻止创建不必要的文档)

### PostToolUse (执行后)
- Prettier (自动格式化 JS/TS)
- TypeScript check (类型检查)
- console.log warning (警告 console.log)

### Stop (会话结束)
- console.log audit (检查所有文件)

## Skills (9 个)

### Everything Skills (4 个)

| Skill | 说明 | 触发短语 |
|-------|------|----------|
| vibe-coding-cn | Vibe Coding 方法论 | "使用 vibe-coding" |
| coding-standards | 编码规范 | "检查编码规范" |
| tdd-workflow | TDD 工作流 | "使用 tdd" |
| security-review | 安全审查 | "安全审查" |

### n8n Skills (5 个)

| Skill | 说明 | 位置 |
|-------|------|------|
| n8n-expression-syntax | 表达式语法 | `skills/` |
| n8n-mcp-tools-expert | MCP 工具专家 | `skills/` |
| n8n-node-configuration | 节点配置 | `skills/` |
| n8n-validation-expert | 验证专家 | `skills/` |
| n8n-workflow-patterns | 工作流模式 | `skills/` |

**完整清单**: 见 `.claude/SKILLS_MANIFEST.md`

## MCP 服务器 (13 个)

### 核心 (4 个)
1. **memory** - 知识图谱存储
2. **github** - GitHub 操作
3. **context7** - 官方文档查询
4. **fetch** - HTTP 请求

### GLM (3 个)
5. **web-search-prime** - 网络搜索
6. **web-reader** - 网页提取
7. **zai-mcp-server** - 视觉理解

### 浏览器 (2 个)
8. **chrome-devtools** - 浏览器自动化
9. **browsermcp** - 浏览器操作

### n8n 特定 (2 个)
10. **n8n-mcp** - n8n 工作流
11. **skills-mcp** - Skills 服务

### 其他 (2 个)
12. **sequential-thinking** - 复杂推理
13. **notion** - Notion 文档

**配置文件**: `.claude/mcp_config.json`

## Contexts (3 个)

| Context | 用途 |
|---------|------|
| dev.md | 开发上下文 |
| review.md | 审查上下文 |
| research.md | 研究上下文 |

## Memory 知识库

### 目录结构
```
memory-bank/
├── prompts/
│   ├── initial.md        # 初始提示词
│   ├── implementation.md # 实施提示词
│   └── debug.md          # 调试提示词
├── prd.md                # 产品需求文档
├── tech-stack.md         # 技术栈文档
├── implementation-plan.md # 实施计划
├── progress.md           # 进度记录
└── architecture.md       # 架构文档
```

### 初始实体
- n8n-workwolf (project)
- n8n-mcp (mcp-server)
- skills-mcp (mcp-server)
- 聚鑫API (external-api)
- Sora2 (external-api)

## 环境变量

### 必需变量
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

**模板文件**: `.env.example`

## Vibe Coding 工作流

### 新功能开发
1. 使用 `/plan` 创建实施计划
2. 使用 `tdd-workflow` skill 开始开发
3. 使用 `n8n-workflow-patterns` 设计工作流
4. 使用 `/code-review` 审查代码
5. 更新 Memory 知识库

### 问题排查
1. 使用 `sequential-thinking` MCP 分析
2. 使用 `web-search-prime` 搜索解决方案
3. 使用 `n8n-validation-expert` skill 验证
4. 记录到 `memory-bank/progress.md`

### 代码审查
1. 使用 `/code-review` command
2. 使用 `security-review` skill 检查安全
3. 使用 `coding-standards` 检查规范
4. 提供改进建议

## 快速开始

### 1. 激活 Vibe Coding
```
"使用 vibe-coding-cn 方法论开始开发"
```

### 2. 创建实施计划
```
/plan
我需要创建一个 n8n 工作流来调用聚鑫 API
```

### 3. TDD 开发
```
/tdd
实现视频生成工作流
```

### 4. 代码审查
```
/code-review
审查工作流配置
```

## 集成文档

**完整指南**: `docs/EVERYTHING_INTEGRATION_GUIDE.md` (待创建)

## 回滚策略

如需回滚到集成前状态：
```bash
BACKUP_DIR="E:/User/GitHub/backups/n8n-workwolf-20260205_215945"
rm -rf .claude
cp -r "$BACKUP_DIR/.claude" ./
git reset --hard HEAD
git clean -fd
```

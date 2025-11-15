# CLAUDE.zh-CN.md

本文件为 Claude Code（claude.ai/code）在此仓库中工作时提供指导。

## 项目概述

**n8n-workwolf** 是一个专门用于n8n工作流开发的工作区，通过Claude Code和模型上下文协议（MCP）集成了AI辅助自动化。该项目的主要目标是使用Claude Code构建和管理n8n工作流，实现AI视频生成，特别是利用聚鑫API实现文本转视频和图片转视频功能。

### 技术栈

- **n8n** - 工作流自动化平台（运行在 `localhost:5678`）
- **Claude Code** - 用于工作流创建和管理的AI编程助手
- **MCP (Model Context Protocol)** - 两个实现，提供工作流工具和技能：
  - `n8n-mcp` - 连接Claude Code到n8n REST API
  - `skills-mcp` - 提供n8n节点选择和工作流模式的专家指导
- **已安装技能**：
  - `n8n-mcp-tools-expert` - n8n工具使用专家
  - `automation-helper-marketplace` - 自动化助手
  - `n8n-mcp-skills` - n8n技能扩展
- **外部API** - 聚鑫API（AI视频生成）、Sora 2 API（OpenAI视频生成）

## 项目结构

```
n8n-workwolf/
├── config/                              # MCP服务器配置
│   ├── trae-mcp-n8n.json               # n8n MCP服务器配置（N8N_API_URL, N8N_API_KEY）
│   └── trae-skills-mcp.json            # Skills MCP服务器配置（需绝对路径）
├── scripts/                             # 启动脚本
│   ├── run-n8n-mcp.ps1                 # PowerShell脚本启动n8n MCP
│   └── run-skills-mcp.ps1              # PowerShell脚本启动skills MCP
├── skills/                              # 自定义技能
│   └── n8n-mcp-tools-expert/           # n8n工具使用专家技能
│       └── SKILL.md                     # 技能说明和工具参考
├── 工作流/ (Workflows)                  # n8n工作流定义文件（JSON）
├── API供应商信息/ (API Vendor Info)     # 第三方API文档和规范
├── 测试/ (Tests)                       # 测试资源和参考图像
├── .trae/rules/                        # 项目规则和指南
└── 原始需求.md                         # 原始项目需求（中文）
```

## 高级架构

```
Claude Code（AI编程助手）
    ├─→ skills-mcp (npx skills-mcp)
    │   ├─ n8n-mcp-tools-expert
    │   ├─ automation-helper-marketplace
    │   └─ n8n-mcp-skills
    │       ├─ 节点选择专家指导
    │       ├─ 配置验证建议
    │       ├─ 工作流模板和最佳实践
    │       └─ API文档集成
    │
    ├─→ n8n-mcp (npx n8n-mcp)
    │   └─→ n8n REST API (http://localhost:5678)
    │       ├─ 工作流CRUD操作
    │       ├─ 节点发现和文档
    │       ├─ 配置验证
    │       ├─ 工作流执行管理
    │       └─ 执行历史和调试
    │
    └─→ 工作流存储
        ├─ 工作流JSON文件（在 工作流/ 目录中）
        ├─ API配置和凭证
        └─ 外部API集成
```

**关键数据流：**
1. 用户在Claude Code中提出工作流开发任务
2. Claude Code通过MCP与两个服务器通信
3. Skills-MCP提供n8n专业知识和验证建议
4. n8n-MCP将请求转换为n8n REST API调用
5. 通过n8n创建/更新/执行工作流
6. 结果返回给Claude Code供反馈和迭代

## 快速开始

### 前置条件
- n8n全局安装：`E:\home\leon3000\.npm-global`
- Node.js和npm（用于MCP工具）
- n8n在 `http://localhost:5678` 上可访问且配置了API密钥
- Claude Code CLI或IDE已安装

### 启动环境

**1. 启动n8n（如果未运行）：**
```powershell
# 从PowerShell或命令提示符
npm start -g  # 或导航到n8n安装目录并启动
# 验证：http://localhost:5678
```

**2. 启动MCP服务器（在单独的终端窗口中运行这些脚本）：**

使用 `scripts/` 目录中的PowerShell脚本：
```powershell
# 终端1 - Skills MCP
E:\User\Documents\GitHub\n8n-workwolf\scripts\run-skills-mcp.ps1

# 终端2 - n8n MCP
E:\User\Documents\GitHub\n8n-workwolf\scripts\run-n8n-mcp.ps1
```

或手动启动：
```bash
# Skills MCP
npx skills-mcp

# n8n MCP
npx n8n-mcp
```

**3. 配置Claude Code：**
- 将两个MCP服务器配置从 `config/` 目录添加到Claude Code的MCP设置
- 验证两个服务器连接成功

## 常见开发任务

### 使用Claude Code进行工作流开发

**典型工作流：**
1. 向Claude Code描述所需功能（如"创建一个调用聚鑫API的工作流")
2. Claude Code通过n8n-MCP发现相关节点
3. Claude Code通过skills-mcp获取最佳实践建议
4. Claude Code创建工作流并保存到n8n
5. Claude Code验证配置并执行测试
6. Claude Code将工作流导出并保存到 `工作流/` 目录

### 工作流操作

**创建新工作流：**
1. 告诉Claude Code工作流目的（如"创建聚鑫视频生成工作流")
2. Claude Code将使用n8n-MCP工具发现节点：`list_nodes({category: "trigger"})`
3. Claude Code获取节点要点：`get_node_essentials("nodes-base.httpRequest")`
4. Claude Code创建工作流：`n8n_create_workflow({name, nodes, connections, settings})`
5. Claude Code保存到 `工作流/` 目录为JSON文件

**验证工作流配置：**
- 快速检查：`validate_node_minimal(nodeType, config)` - 检查必填字段
- 运行期验证：`validate_node_operation(nodeType, config, {profile:"runtime"})` - 捕获执行错误
- 完整工作流：`n8n_validate_workflow({id})` - 验证整个工作流结构

**更新工作流：**
- 增量更新：`n8n_update_partial_workflow({id, operations})` - 比完全替换更安全
- 自动修复：`n8n_autofix_workflow({id, applyFixes:true})` - 应用建议的修复

### 节点发现和配置

**查找节点：**
1. 按类别：`list_nodes({category: "trigger"})` - 浏览触发节点
2. 全文搜索：`search_nodes({query: "keyword"})` - 全局搜索
3. 获取要点：`get_node_essentials("nodeType")` - 仅必需和常用字段
4. 完整模式：`get_node_info("nodeType")` - 完整节点文档

**常见节点工作流：**
- **触发节点**：Start、Webhook、Schedule（定时任务）
- **HTTP节点**：HTTP Request（用于API调用）、HTTP Server（用于webhooks）
- **转换节点**：Function、Code、Set
- **条件节点**：IF、Switch（用于分支）
- **错误处理**：错误处理节点、条件分支

### 使用聚鑫API

**API配置：**
- API密钥：存储在n8n凭证中（不要提交到仓库）
- 基础URL：`https://api.juxinai.com`（或从 API供应商信息/ 获取端点）
- 文档：见 `API供应商信息/聚鑫api文档.txt` 和 `补充信息.md`

**常见工作流模式：**
1. **触发**（Webhook或Schedule）接收请求
2. **HTTP Request**节点调用聚鑫API端点
3. 使用Set/Function节点**解析响应**
4. 使用错误处理器和重试逻辑**处理错误**
5. 使用HTTP Response或其他输出**返回结果**

**最佳实践：**
- 使用HTTP Request节点v4.3+，`typeVersion: 4.3`
- 启用重试逻辑：`retryOnFail: true`、`maxTries: 3`
- 配置响应处理：启用状态码和响应头
- 为失败的API调用添加错误分支处理
- 为长运行操作包含超时配置

### 调试和执行

**Claude Code可监控工作流执行：**
```
n8n_list_executions({workflowId})     # 列出执行历史
n8n_get_execution({id, mode:"full"})  # 获取详细执行信息
```

**常见问题和解决方案：**
- **API密钥无效**：验证n8n设置中的凭证
- **CORS/SSRF错误**：如需要可使用代理配置（Windows代理：Clash在localhost:7890）
- **节点配置**：先用 `validate_node_minimal` 验证，再用 `validate_node_operation`
- **连接问题**：确保n8n服务器运行且可访问，检查MCP配置中的API URL

## MCP配置文件

### `config/trae-mcp-n8n.json`
n8n MCP服务器配置。需要：
- `N8N_API_URL`：指向本地n8n实例（默认：`http://localhost:5678`）
- `N8N_API_KEY`：来自n8n设置的API密钥
- 路径在Windows上必须正确转义

### `config/trae-skills-mcp.json`
Skills MCP服务器配置。需要：
- `SKILLS_PATH`：**绝对路径**指向skills目录（如 `E:/User/Documents/GitHub/n8n-workwolf/skills`）
- 必须使用正斜杠或转义反斜杠

### `scripts/run-*.ps1`
PowerShell启动脚本。可能需要：
- 设置执行策略：`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- 如使用代理（Clash在7890端口）则修改环境变量

## MCP工具和技能

### n8n-MCP工具可用

**节点发现：**
- `list_nodes({category, limit, offset})` - 按类别浏览节点
- `search_nodes({query, mode, limit})` - 跨节点全文搜索
- `list_ai_tools()` - 列出AI相关节点
- `get_node_essentials(nodeType)` - 必需和常用参数
- `get_node_info(nodeType)` - 完整节点模式和文档
- `search_node_properties(nodeType, searchTerm)` - 查找特定属性

**配置验证：**
- `validate_node_minimal(nodeType, config)` - 检查必填字段
- `validate_node_operation(nodeType, config, {profile})` - 深度验证

**工作流管理：**
- `n8n_create_workflow({name, nodes, connections, settings})`
- `n8n_update_partial_workflow({id, operations})` - 增量更新
- `n8n_validate_workflow({id, options})` - 验证整个工作流
- `n8n_autofix_workflow({id, applyFixes})` - 自动修复错误
- `n8n_list_executions({workflowId, limit, offset})`
- `n8n_get_execution({id, mode})` - 获取执行详情

### 技能系统

三个主要技能通过skills-mcp可用，Claude Code可直接使用：

**1. n8n-mcp-tools-expert**（内置）
- 为任务选择适当的节点
- 正确配置节点参数
- 设计错误处理模式
- API集成最佳实践
- 工作流优化和调试

**2. AutomationHelper_plugins**（`automation-helper-marketplace`）
- 常见自动化模式的辅助工具
- 工作流模板和代码片段
- 热门服务集成协助
- 预构建的自动化组件

**3. n8n-skills**（`n8n-mcp-skills`）
- 扩展的n8n节点功能和文档
- 高级配置模式
- 性能优化提示
- 社区贡献的最佳实践

Claude Code可直接访问这些技能的功能。

## 重要说明

### 安全性和配置
- 不要将API密钥或凭证提交到仓库
- 将敏感数据存储在MCP配置文件或n8n凭证系统中
- 使用环境变量或本地配置作为API密钥
- Windows代理（Clash）：如需可在PowerShell中设置 `HTTP_PROXY=localhost:7890`

### Claude Code开发工作流
- 运行前始终验证节点配置
- 在生产部署前在开发环境中测试工作流
- 使用 `n8n_update_partial_workflow` 进行安全的增量更改
- 为关键节点添加错误处理器以提高健壮性
- 为外部API调用包含重试逻辑
- 将工作流JSON文件保存到 `工作流/` 目录便于版本控制

### 版本管理
- 优先使用最新节点 `typeVersion`（如HTTP Request v4.3）
- 保持节点配置最新
- 在生产工作流中更新节点版本前测试

### 项目规则
- 在MCP配置中使用绝对路径（如 `E:/...` 格式）
- 优先使用 `get_node_essentials` 而非 `get_node_info`（更轻量）
- 始终使用 `validate_node_minimal` 作为第一验证步骤
- 在生产使用前在开发环境中创建新工作流

## 相关文件
- 项目规则：`.trae/rules/project_rules.md`（中文）
- 技能文档：`skills/n8n-mcp-tools-expert/SKILL.md`（中文）
- API文档：`API供应商信息/` 目录
- 原始需求：`原始需求.md`（中文）
- 工作流示例：`工作流/` 目录

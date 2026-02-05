# n8n-workwolf 产品需求文档 (PRD)

## 项目概述

**项目名称**: n8n-workwolf
**项目类型**: n8n 工作流自动化平台
**开发方法论**: Vibe Coding (AI 结对编程)
**初始化日期**: 2026-02-05

---

## 核心目标

### 主要目标
1. 构建基于 n8n 的工作流自动化平台
2. 集成聚鑫 API (Sora2 视频生成)
3. 提供可视化的工作流编辑体验
4. 支持 MCP (Model Context Protocol) 扩展

### 次要目标
1. 创建可复用的 n8n 工作流模板库
2. 开发 n8n 特定的 Skills (5 个)
3. 集成 Everything-Claude-Code 开发环境

---

## 功能范围

### 核心 MCP 服务器 (2 个)
1. **n8n-mcp**: n8n 工作流自动化
   - 工作流执行
   - 节点管理
   - API 集成

2. **skills-mcp**: 本地 Skills 服务器
   - 5 个 n8n 特定 Skills
   - 4 个 Everything Skills

### 外部 API 集成
1. **聚鑫API** (sora-2-all)
   - Sora2 视频生成
   - 任务管理
   - Webhook 回调

2. **Sora2** (sora-2/sora-2-pro)
   - 视频提示词生成
   - 角色管理

---

## 技术栈

### 基础设施
- **工作流引擎**: n8n
- **开发环境**: Claude Code + Everything-Claude-Code
- **版本控制**: Git

### MCP 服务器 (13 个)
1. memory - 知识图谱存储
2. github - GitHub 操作
3. context7 - 官方文档查询
4. chrome-devtools - 浏览器自动化
5. sequential-thinking - 复杂推理
6. fetch - HTTP 请求
7. notion - Notion 文档管理
8. web-search-prime - 网络搜索 (智谱)
9. web-reader - 网页提取 (智谱)
10. zai-mcp-server - 视觉理解
11. browsermcp - 浏览器自动化
12. n8n-mcp - n8n 工作流
13. skills-mcp - Skills 服务器

---

## 用户故事

### US1: 工作流执行
**作为** 开发者
**我想要** 通过 MCP 执行 n8n 工作流
**以便** 自动化日常任务

### US2: 视频生成
**作为** 内容创作者
**我想要** 通过 n8n 调用聚鑫 API 生成视频
**以便** 快速产出视频内容

### US3: 技能扩展
**作为** 开发者
**我想要** 使用 n8n 特定的 Skills
**以便** 提高开发效率

---

## 非功能性需求

### 性能
- 工作流执行时间 < 30 秒
- API 响应时间 < 5 秒

### 安全
- 所有 API Keys 通过环境变量管理
- n8n API Key 定期轮换
- 不在代码中硬编码敏感信息

### 可维护性
- 完整的 Memory MCP 知识库
- 详细的文档和注释
- Git 提交遵循规范

---

## 成功指标

- [ ] 13 个 MCP 服务器成功连接
- [ ] 5 个 n8n Skills 正常工作
- [ ] 3 个 Agents 响应正常
- [ ] 3 个 Commands 无错误执行
- [ ] Memory MCP 知识库初始化完成

# 用户规则附加说明（n8n 工具分配与调用约束）

- 工具配额限制：每个智能体最多 40 个工具；solo coder 当前不包含 n8n-mcp。
- n8n 专用智能体：仅以下两个智能体具备 n8n-mcp 工具权限：
  - n8n 聚鑫流控（用于创建/修改/验证工作流、最小增量变更、端到端测试）
  - 聚鑫对齐校验（只读审计与最小化修复建议，不直接写入）
- 路由规则（强制）：凡涉及 n8n 的任何任务，必须由以上两个智能体之一（或两者配合）执行；其它智能体与 solo coder 不得直接调用 n8n API 或修改工作流。
- 任务拆分：当一个任务同时包含 n8n 与非 n8n 内容时，需将 n8n 部分路由到上述智能体，非 n8n 部分由对应能力的智能体或 solo coder 处理，禁止混批。
- 校验与交付：沿用项目规则与智能体 v2 默认执行策略；交付需包含流程 mermaid 图与至少 10 条用例（微改不少于 5 条）。

## 聚鑫 API 鉴权方式对照

| API | 鉴权类型 | genericAuthType | 凭据类型 |
|-----|----------|-----------------|----------|
| Sora-2 (/v1/video/create) | Header Auth | httpHeaderAuth | httpHeaderAuth |
| VEO (/v1/videos) | **Bearer Auth** | **httpBearerAuth** | **httpBearerAuth** |
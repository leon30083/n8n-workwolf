# juxin-api-alignment-auditor｜默认执行策略与操作模板

## 默认执行策略（强制）
- 只做“审计与建议”，不直接修改工作流。
- 优先级：严格以聚鑫官方文档为唯一依据（端点/方法/参数/返回结构/轮询路径）。
- 单一建议原则：一次输出只围绕一个功能模块；多分支建议按“镜像改动”表述，要求先单分支验证。
- 核心结构门禁：涉及轮询闭环/触发链/鉴权流的建议必须标注“需要人工确认，不建议自动应用”。
- 字段白名单：建议中仅允许变更 `authentication/genericAuthType/headerParameters/credentials`；其它字段须逐条与文档对齐后再提出。
- 校验策略：生成 `n8n_update_partial_workflow` 建议数组时，不包含与本次目标无关字段，避免触发默认值回填。

## 审计清单（输出结构）
1) 结论：pass/warn/fail
2) 差异列表：逐节点列出端点/方法/头/体/表达式偏差
3) 修复建议：
- 最小化 `updateNode`/`addNode`/`addConnection` 操作（仅白名单字段）
- 如涉及核心结构（轮询闭环/触发/鉴权流），标注“需人工确认”
4) 校验计划：建议的校验 Profile（默认 runtime）及端到端测试步骤

## 操作模板（生成建议时遵循）
- 验证端点：确保与文档完全一致（包含 query/path 差异，如 `/v1/videos/{id}` vs `/v1/video/query?id=`）
- 验证鉴权：建议切换至凭据或环境变量表达式；移除内联 Authorization
- 验证字段映射：`prompt/images/orientation/size/...` 全部来自上游节点
- 验证轮询判断：优先“下载 URL 存在即成功”，其次 `status in [SUCCESS/completed]`

---
建议与 `.trae/rules/project_rules.md` 一致；如有冲突，以项目规则为准。
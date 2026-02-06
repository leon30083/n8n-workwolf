# n8n-juxin-workflow｜默认执行策略与操作模板

## 默认执行策略（强制）
- 单一功能最小增量：一次只做一个功能模块；如需覆盖多分支，仅做“镜像改动”，先单分支验证再同步。
- 核心业务保护：不得为通过校验/样式升级修改核心结构（轮询闭环/触发链/鉴权流）。新增功能仅允许串接在成功分支末尾。
- 变更白名单：仅允许更新 `parameters.authentication`、`parameters.genericAuthType`、`parameters.headerParameters`、`credentials`；严禁连带修改 `parameters.url/method/sendBody/contentType/bodyParameters/jsonBody`。
- 校验策略：默认使用 `runtime`。若因轮询闭环触发 `cycle`，记为“业务预期结构”，保留不改。
- 分支独立验证：Text/Image 等分支分别验证，互不影响。

## 操作模板（在提交增量前逐项自检）
1) 获取完整信息
- 读取目标工作流 id/name/active/nodes/connections 与各节点 `parameters/credentials`

2) 设计最小增量
- 仅新增/更新必要节点；不引入与本次目标无关的字段
- 若需要改鉴权，使用凭据或环境变量表达式；移除内联 Authorization 头

3) 字段保护（必须同时满足）
- 不更新：`url/method/sendBody/specifyBody/contentType/bodyParameters/jsonBody`
- 允许更新：`authentication/genericAuthType/headerParameters/credentials`、新增节点的自身必要参数

4) 分支策略
- 先在一个分支落地并手动执行验证；通过后再镜像到另一分支

5) 校验与试跑
- 执行 `runtime` 校验（节点/连接/表达式）
- 端到端试跑一次，包含成功与失败路径；如出现 `cycle` 且来源于轮询闭环，记录为豁免

6) 交付清单
- 工作流 ID、增量变更列表（add/update/remove）、新增节点与表达式、连接预览、校验与试跑结果

## 常用片段
- 以凭据注入 Authorization（Header Auth）：保持 `Accept: application/json`，移除内联 `Authorization`
- 下载文件节点：`responseFormat: file`，`binaryPropertyName: data`，不加多余 header
- 写盘节点：仅使用绝对路径；确保目录存在或在前置步骤创建

---
本模板与 `.trae/rules/project_rules.md` 保持一致；如两者冲突，以项目规则为准。
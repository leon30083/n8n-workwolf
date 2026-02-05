# n8n-workwolf 实施提示词

## 用途

在实现新功能或修改现有功能时使用此提示词。

## 实施前检查

### 1. 需求确认
- [ ] 功能目标明确
- [ ] 验收标准清晰
- [ ] 边界条件考虑

### 2. 风险评估
- [ ] 性能影响
- [ ] 安全风险
- [ ] 兼容性问题
- [ ] 回滚计划

### 3. 技术方案
- [ ] 使用 `/plan` 创建详细计划
- [ ] 使用 `architect` agent 设计架构
- [ ] 确定 MCP 服务器使用
- [ ] 选择合适的 Skills

## 实施流程

### Step 1: TDD 工作流
```
使用 tdd-workflow skill:
1. 编写测试 (RED)
2. 运行测试 (必须失败)
3. 实现最小代码 (GREEN)
4. 重构优化 (IMPROVE)
5. 验证覆盖率 (80%+)
```

### Step 2: n8n 工作流开发
```
使用 n8n-workflow-patterns skill:
1. 分析需求
2. 设计节点流程
3. 配置参数
4. 添加错误处理
5. 测试验证
```

### Step 3: 代码审查
```
使用 /code-review command:
1. 静态分析
2. 安全审查 (security-review skill)
3. 性能评估
4. 编码规范检查 (coding-standards skill)
```

### Step 4: 文档更新
```
更新 Memory 知识库:
1. memory-bank/progress.md - 记录进度
2. memory-bank/architecture.md - 更新架构
3. .claude/SKILLS_MANIFEST.md - 如有新 Skills
```

## n8n 工作流模板

### 基础工作流结构
```json
{
  "name": "工作流名称",
  "nodes": [
    {
      "parameters": {},
      "name": "Start",
      "type": "n8n-nodes-base.start",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "url": "={{ $json.endpoint }}",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth"
      },
      "name": "HTTP Request",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4.1,
      "position": [450, 300],
      "credentials": {
        "httpHeaderAuth": {
          "id": "1",
          "name": "聚鑫 API"
        }
      }
    }
  ],
  "connections": {
    "Start": {
      "main": [[{"node": "HTTP Request", "type": "main", "index": 0}]]
    }
  },
  "pinData": {},
  "settings": {},
  "staticData": null,
  "tags": [],
  "triggerCount": 0
}
```

## 常用模式

### 1. API 调用工作流
- HTTP Request 节点
- 错误处理 (Error Trigger)
- 数据转换 (Set/Function)
- 结果存储

### 2. Webhook 接收
- Webhook 节点
- 数据验证
- 处理逻辑
- 响应返回

### 3. 定时任务
- Schedule Trigger
- 数据获取
- 处理逻辑
- 通知发送

## 错误处理

### 常见错误
1. **API 调用失败**: 重试机制、降级方案
2. **数据格式错误**: 验证输入、错误消息
3. **超时问题**: 调整超时时间、异步处理
4. **权限问题**: 检查 API Key、权限配置

### 错误处理模式
```json
{
  "errorWorkflow": true,
  "nodes": [
    {
      "name": "Error Trigger",
      "type": "n8n-nodes-base.errorTrigger"
    },
    {
      "name": "Log Error",
      "type": "n8n-nodes-base.set"
    },
    {
      "name": "Send Notification",
      "type": "n8n-nodes-base.emailSend"
    }
  ]
}
```

## 性能优化

### 优化建议
1. **减少节点数量**: 合并相似操作
2. **使用 Function 节点**: 复杂逻辑用代码实现
3. **批量处理**: 避免循环调用
4. **缓存数据**: 使用 Memory MCP 缓存

## 安全检查

### 使用 security-review skill
- [ ] API Keys 不在代码中
- [ ] 输入验证完整
- [ ] 错误消息不泄露信息
- [ ] 权限最小化
- [ ] 日志不记录敏感数据

## 完成标准

### 功能要求
- [ ] 所有测试通过
- [ ] 代码覆盖率 ≥ 80%
- [ ] 代码审查通过
- [ ] 文档已更新

### 质量要求
- [ ] 无 console.log
- [ ] 无硬编码值
- [ ] 错误处理完整
- [ ] 性能符合预期

### n8n 特定
- [ ] 工作流可导出
- [ ] 节点配置正确
- [ ] 连接测试通过
- [ ] 生产环境就绪

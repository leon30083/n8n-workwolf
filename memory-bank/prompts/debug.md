# n8n-workwolf 调试提示词

## 用途

在排查问题或调试 n8n 工作流时使用此提示词。

## 调试流程

### Step 1: 问题定义
```
回答以下问题:
1. 预期行为是什么？
2. 实际行为是什么？
3. 错误消息是什么？
4. 何时开始出现？
5. 最近有什么变更？
```

### Step 2: 信息收集
```
使用以下 MCP 服务器:
1. sequential-thinking - 分析问题
2. n8n-mcp - 获取工作流状态
3. memory - 查询历史记录
4. web-search-prime - 搜索类似问题
```

### Step 3: 根因分析
```
使用以下 Skills:
1. n8n-validation-expert - 验证配置
2. n8n-expression-syntax - 检查表达式
3. coding-standards - 检查代码规范
```

### Step 4: 解决方案
```
1. 创建修复计划
2. 实施 TDD 工作流
3. 验证修复效果
4. 更新文档
```

## 常见问题排查

### 1. n8n-mcp 连接失败

**症状**: 无法连接到 n8n API

**检查步骤**:
```bash
# 1. 检查 n8n 服务状态
curl http://localhost:5678/healthz

# 2. 验证环境变量
echo $N8N_API_URL
echo $N8N_API_KEY

# 3. 测试 MCP 连接
npx n8n-mcp --version
```

**解决方案**:
- 确认 n8n 服务运行中
- 检查 API URL 和 Key
- 查看 n8n 日志

### 2. 工作流执行失败

**症状**: 工作流节点报错

**检查步骤**:
1. 查看执行历史
2. 检查节点配置
3. 验证输入数据
4. 测试单个节点

**解决方案**:
- 使用 n8n-validation-expert skill
- 检查表达式语法
- 添加错误处理节点

### 3. API 调用超时

**症状**: HTTP Request 节点超时

**检查步骤**:
1. 检查网络连接
2. 验证 API 端点
3. 查看请求参数

**解决方案**:
- 增加超时时间
- 添加重试逻辑
- 使用异步处理

### 4. 表达式错误

**症状**: 表达式返回错误值

**检查步骤**:
1. 验证表达式语法
2. 检查数据结构
3. 测试表达式

**解决方案**:
- 使用 n8n-expression-syntax skill
- 添加调试输出
- 简化复杂表达式

## 调试工具

### n8n 内置工具
```javascript
// Function 节点中调试
console.log('Input:', $input.all());
console.log('Item:', $input.item());
return $input.all();
```

### Memory MCP 查询
```
# 查询历史问题
搜索: "n8n-mcp 连接问题"
搜索: "工作流执行失败"
```

### Sequential Thinking
```
# 分析复杂问题
1. 列出所有可能原因
2. 评估每个原因的可能性
3. 确定最可能的原因
4. 制定验证计划
```

## 日志分析

### n8n 日志位置
```bash
# Docker
docker logs n8n

# 本地安装
~/.n8n/logs/
```

### 关键日志内容
- 工作流执行开始/结束
- 节点执行状态
- 错误堆栈信息
- API 调用响应

## 性能调试

### 慢工作流排查
1. 识别慢节点（执行时间）
2. 检查数据量大小
3. 优化数据处理逻辑
4. 考虑批量处理

### 内存问题
1. 监控内存使用
2. 检查大数据处理
3. 优化数据流
4. 清理不必要的数据

## 数据验证

### 输入验证
```javascript
// 验证必需字段
if (!$json.requiredField) {
  throw new Error('Missing required field');
}
```

### 输出验证
```javascript
// 验证输出格式
const output = {
  id: $json.id,
  status: 'success'
};

if (!output.id) {
  throw new Error('Invalid output');
}

return output;
```

## 错误处理模式

### Try-Catch 模式
```javascript
try {
  // 执行操作
  const result = executeOperation($input.item());
  return [{ json: result }];
} catch (error) {
  // 记录错误
  console.error('Operation failed:', error);
  // 返回错误状态
  return [{ json: { status: 'error', message: error.message } }];
}
```

### 重试模式
```javascript
// 在节点配置中设置重试
{
  "retryOnFail": true,
  "maxTries": 3,
  "waitBetweenTries": 1000
}
```

## 预防措施

### 1. 开发阶段
- 使用 TDD 工作流
- 编写单元测试
- 代码审查
- 文档完善

### 2. 测试阶段
- 测试边界条件
- 模拟错误场景
- 性能测试
- 集成测试

### 3. 监控阶段
- 设置告警
- 记录日志
- 性能监控
- 错误追踪

## 记录和分享

### 调试日志
```
在 memory-bank/progress.md 中记录:
1. 问题描述
2. 排查过程
3. 解决方案
4. 预防措施
```

### 知识共享
```
使用 Memory MCP 创建实体:
- 问题类型
- 解决方案
- 相关资源
```

## 调试检查清单

### 初步检查
- [ ] 错误消息已记录
- [ ] 最近变更已确认
- [ ] 环境配置已验证
- [ ] 日志已查看

### 深入调试
- [ ] 根因已分析
- [ ] 解决方案已测试
- [ ] 修复已验证
- [ ] 文档已更新

### 防止复发
- [ ] 测试已添加
- [ ] 代码已审查
- [ ] 知识已记录
- [ ] 团队已通知

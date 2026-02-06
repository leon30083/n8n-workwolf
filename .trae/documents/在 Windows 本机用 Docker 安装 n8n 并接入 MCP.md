## 前置检查
- 确认已安装并运行 `Docker Desktop`（后端为 WSL2 或 Hyper-V 均可）。
- 预留端口 `5678`（如需外网访问，再开放 `80/443` 由反向代理承接）。
- 在本机工作目录创建 `n8n` 运行文件夹并持久化数据卷（避免容器销毁后数据丢失）。
- 时区与主机名按本机环境设置：`Asia/Shanghai`、`localhost`。

## 最小可用部署（SQLite）
- 在目标目录创建 `docker-compose.yml`（单容器 + 本地卷持久化）：
```
services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      - TZ=Asia/Shanghai
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - GENERIC_TIMEZONE=Asia/Shanghai
      # 强烈建议设置：用于加密凭据（请自备随机字符串）
      - N8N_ENCRYPTION_KEY=<your-secure-random-key>
    volumes:
      - ./data/.n8n:/home/node/.n8n
    restart: unless-stopped
```
- 启动：在该目录执行 `docker compose up -d`。
- 验证：浏览器打开 `http://localhost:5678`，首次注册管理员账户。

## 可选增强
- 反向代理（Caddy/Nginx）：将 `n8n` 端口映射到 `80/443`，并设置 `N8N_HOST=<your-domain>`、`N8N_PROTOCOL=https`、必要时 `WEBHOOK_URL=https://<your-domain>/`。
- 数据库改为 Postgres：新增 `postgres` 服务与网络，设置 `DB_TYPE=postgres`、`DB_POSTGRESDB` 等变量与凭据，再在 `n8n` 里指向该数据库（生产推荐）。

## 安全与维护
- 生成并妥善保存 `N8N_ENCRYPTION_KEY`，不可提交至仓库。
- 升级：`docker compose pull && docker compose up -d`。
- 备份：定期备份 `./data/.n8n`（或数据库数据卷）。
- 卸载：`docker compose down`（如需清理数据，额外删除 `./data/.n8n`）。

## 接入 MCP（n8n-mcp）
- 在 n8n UI → Settings → API 生成 `API Key`。
- 本机运行工具前置环境变量：
```
Set-Item env:MCP_MODE "stdio"
Set-Item env:LOG_LEVEL "error"
Set-Item env:DISABLE_CONSOLE_OUTPUT "true"
Set-Item env:N8N_API_URL "http://localhost:5678"
Set-Item env:N8N_API_KEY "<复制的 API Key>"
```
- 启动工具：`npx n8n-mcp`（或全局安装后使用 `n8n-mcp`）。
- 在 Trae 中即可调用搜索/校验/创建/增量更新等工具；仅搜索/校验类无需 API，工作流操作类需 API。

## 验证清单
- 打开 `http://localhost:5678` 并完成管理员初始化。
- 生成并测试 `API Key`：使用 `curl` 访问 `/rest/workflows` 或在 MCP 健康检查中显示可用。
- 创建一个最小工作流（Webhook → Respond），在 MCP 中读取、校验一次以确认 API 工具链通畅。

## 可能问题与处理
- 端口被占用：更换宿主端口或释放占用后重启。
- 外网访问失败：检查防火墙策略并为 `5678/80/443` 添加允许入站规则；或仅本机使用。
- 证书问题：反代启用 HTTPS 时使用正规证书并正确设置 `N8N_PROTOCOL=https` 与 `N8N_HOST`。

请您审阅以上计划。如果内容准确无误，请回复“确认”，我将为您生成并应用 `docker-compose.yml` 与目录结构、启动容器、完成 UI 初始化与 MCP 接入的自动化步骤。
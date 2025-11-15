Set-Item env:MCP_MODE "stdio"
Set-Item env:LOG_LEVEL "error"
Set-Item env:DISABLE_CONSOLE_OUTPUT "true"
Set-Item env:N8N_API_URL "http://localhost:5678"
Set-Item env:N8N_API_KEY "<REPLACE_WITH_YOUR_API_KEY>"
npx n8n-mcp
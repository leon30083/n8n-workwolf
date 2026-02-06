{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true",
        "N8N_API_URL": "http://localhost:5678",
        "N8N_API_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0ZTk5ZTU2OS00OTg3LTQwODYtOTJiNy1hMDBlN2FlMDgwODUiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY1MDI5NDI0LCJleHAiOjE3NzI3MjY0MDB9.b89jQXW0oTu5PkAUoiR8qxcaXMiJsAaPxZXHevRLN1M"
      }
    }
  }
}
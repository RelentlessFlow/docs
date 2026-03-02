# 基于 ws 实现 MCP 反向隧道调研报告

## 1. 背景与目标

在云端 Agent（如 LangGraph 编排器）需要操作本地开发机（Localhost）上的资源（文件、数据库、终端）时，由于本地环境通常位于 NAT 或防火墙之后，云端无法直接发起连接。

本方案旨在实现一个 **反向 MCP 架构**：
*   **连接方向反转**：由 **本地（Local）** 主动通过 WebSocket 连接 **云端（Cloud）**。
*   **控制方向不变**：连接建立后，云端依然作为 MCP Client（下发指令），本地依然作为 MCP Server（执行指令）。
*   **纯原生实现**：不依赖 `ngrok`、`localtunnel` 等第三方内网穿透服务，仅使用 `@modelcontextprotocol/sdk` 和 `ws` 库。

## 2. 架构设计

系统由以下五个核心模块组成：

1.  **Transport 层 (`ws_transport.ts`)**：通用适配器，负责将标准的 WebSocket 对象包装为 MCP SDK 可识别的 `Transport` 接口。
2.  **业务服务端 (`mcp_server.ts`)**：定义具体的 MCP 工具（如 `read_file`, `execute_command`），不包含网络逻辑。
3.  **本地客户端 (`local_client.ts`)**：负责建立 WebSocket 连接，并将 `mcp_server` 挂载到该连接上。
4.  **云端网关 (`cloud_server.ts`)**：监听 WebSocket 端口，等待本地连接。
5.  **云端 Agent (`mcp_client.ts`)**：处理已建立的连接，自动发现工具并进行调用。

## 3. 核心代码实现

### 3.1 通用传输适配器 (`ws_transport.ts`)

负责底层协议转换，使 MCP SDK 能运行在纯 WebSocket 上。

```typescript
import type { Transport } from "@modelcontextprotocol/sdk/shared/transport.js";
import type { JSONRPCMessage } from "@modelcontextprotocol/sdk/types.js";
import WebSocket from "ws";

/**
 * 适配器：将 WebSocket 包装为 MCP Transport
 * 既可以用于 Client 也可以用于 Server，只要传入一个已建立的 WebSocket 实例
 */
export class WebSocketTransport implements Transport {
  private _ws: WebSocket;

  onclose?: () => void;
  onerror?: (error: Error) => void;
  onmessage?: (message: JSONRPCMessage) => void;

  constructor(ws: WebSocket) {
    this._ws = ws;
    
    this._ws.on("message", (data) => {
      try {
        const json = JSON.parse(data.toString());
        if (this.onmessage) {
          this.onmessage(json);
        }
      } catch (e) {
        console.error("Failed to parse JSONRPC message:", e);
        if (this.onerror) {
          this.onerror(new Error("Invalid JSON"));
        }
      }
    });

    this._ws.on("close", () => {
      if (this.onclose) {
        this.onclose();
      }
    });

    this._ws.on("error", (err) => {
      if (this.onerror) {
        this.onerror(err);
      }
    });
  }

  async start(): Promise<void> {
    if (this._ws.readyState === WebSocket.OPEN) {
      return;
    }
    if (this._ws.readyState === WebSocket.CONNECTING) {
      return new Promise((resolve) => {
        this._ws.once("open", () => resolve());
      });
    }
  }

  async send(message: JSONRPCMessage): Promise<void> {
    this._ws.send(JSON.stringify(message));
  }

  async close(): Promise<void> {
    this._ws.close();
  }
}
```

### 3.2 本地 MCP 服务定义 (`mcp_server.ts`)

定义真实的文件系统和命令执行能力。

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import * as fs from "fs/promises";
import * as path from "path";
import { exec } from "child_process";
import util from "util";
import { Dirent } from "fs";

const execAsync = util.promisify(exec);

export const createMcpServer = () => {
  const server = new McpServer({
    name: "LocalTools",
    version: "1.0.0",
  });

  // 辅助函数：解析路径
  function resolvePath(requestedPath: string) {
    if (path.isAbsolute(requestedPath)) {
        return requestedPath;
    }
    return path.resolve(process.cwd(), requestedPath);
  }

  // 注册工具：列出目录
  server.registerTool(
    "list_directory",
    {
      description: "List files and directories in the given path",
      inputSchema: z.object({
        path: z.string().default("."),
      }),
    },
    async ({ path: relativePath }) => {
      try {
        const fullPath = resolvePath(relativePath);
        const items = await fs.readdir(fullPath, { withFileTypes: true });
        const result = items.map((item: Dirent) => ({
          name: item.name,
          isDirectory: item.isDirectory(),
          path: path.join(fullPath, item.name),
        }));
        return {
          content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
        };
      } catch (error: any) {
        return {
          content: [{ type: "text", text: `Error: ${error.message}` }],
          isError: true,
        };
      }
    }
  );

  // 注册工具：读取文件
  server.registerTool(
    "read_file",
    {
      description: "Read file content",
      inputSchema: z.object({
        path: z.string(),
      }),
    },
    async ({ path: relativePath }) => {
      try {
        const fullPath = resolvePath(relativePath);
        const content = await fs.readFile(fullPath, "utf-8");
        return {
          content: [{ type: "text", text: content }],
        };
      } catch (error: any) {
        return {
          content: [{ type: "text", text: `Error: ${error.message}` }],
          isError: true,
        };
      }
    }
  );

  // 注册工具：执行 Shell 命令
  server.registerTool(
    "execute_command",
    {
      description: "Execute a shell command",
      inputSchema: z.object({
        command: z.string(),
      }),
    },
    async ({ command }) => {
      const dangerousPatterns = ["rm -rf /", "rm -fr /"]; 
      if (dangerousPatterns.some(pattern => command.includes(pattern))) {
        return {
          content: [{ type: "text", text: "Error: Command contains forbidden patterns." }],
          isError: true,
        };
      }

      try {
        const { stdout, stderr } = await execAsync(command, { cwd: process.cwd() });
        return {
          content: [{ 
            type: "text", 
            text: JSON.stringify({ stdout, stderr }, null, 2) 
          }],
        };
      } catch (error: any) {
         return {
            content: [{ 
                type: "text", 
                text: JSON.stringify({ error: error.message }, null, 2) 
            }],
            isError: true,
        };
      }
    }
  );

  return server;
};
```

### 3.3 本地连接器 (`local_client.ts`)

启动 MCP 服务并连接到云端。

```typescript
import WebSocket from "ws";
import { WebSocketTransport } from "./ws_transport.js";
import { createMcpServer } from "./mcp_server.js";

// 配置：云端网关地址
const SERVER_URL = "ws://localhost:8080";

async function connectToCloud() {
  console.log(`[Network] Connecting to Cloud Gateway at ${SERVER_URL}...`);
  
  const socket = new WebSocket(SERVER_URL);
  
  socket.on("open", async () => {
    console.log("[Network] WebSocket connected!");
    
    // 获取纯业务的 MCP Server 实例
    const server = createMcpServer();
    
    // 创建传输层适配器
    const transport = new WebSocketTransport(socket);
    
    // 将 MCP Server 挂载到网络传输层
    await server.connect(transport);
    console.log("[Network] MCP Server is now online and serving the Cloud!");
  });

  socket.on("error", (err) => {
    console.error("[Network] Connection error:", err.message);
    setTimeout(connectToCloud, 5000);
  });

  socket.on("close", () => {
    console.log("[Network] Disconnected. Retrying in 5s...");
    setTimeout(connectToCloud, 5000);
  });
}

connectToCloud();
```

### 3.4 云端网关 (`cloud_server.ts`)

监听端口并处理连接。

```typescript
import { WebSocketServer } from "ws";
import { WebSocketTransport } from "./ws_transport.js";
import { handleNewMcpSession } from "./mcp_client.js";

const PORT = 8080;

function startServer() {
  const wss = new WebSocketServer({ port: PORT });
  console.log(`[Network] Cloud Gateway listening on port ${PORT}...`);

  wss.on("connection", (socket) => {
    console.log("[Network] New inbound connection received.");

    // 1. 包装 WebSocket 为 MCP Transport
    const transport = new WebSocketTransport(socket);

    // 2. 将传输层交给业务逻辑层处理
    handleNewMcpSession(transport);
    
    socket.on("close", () => {
        console.log("[Network] Client disconnected.");
    });
  });
}

startServer();
```

### 3.5 云端 Agent 逻辑 (`mcp_client.ts`)

模拟 Agent 行为，自动发现和调用工具。

```typescript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import type { Transport } from "@modelcontextprotocol/sdk/shared/transport.js";

export async function handleNewMcpSession(transport: Transport) {
  const client = new Client(
    { name: "CloudAgent", version: "1.0.0" },
    { capabilities: { sampling: {} } }
  );

  try {
    await client.connect(transport);
    console.log("\n[MCP Core] ✅ Session established with remote tool provider.");

    // 列出工具
    const resources = await client.listTools();
    const toolNames = resources.tools.map(t => t.name).join(", ");
    console.log(`[MCP Core] 🛠️  Discovered tools: [ ${toolNames} ]`);

    // 自动调用示例
    if (resources.tools.some(t => t.name === "list_directory")) {
        console.log("\n[MCP Core] 📂 Invoking 'list_directory'...");
        const result = await client.callTool({
            name: "list_directory",
            arguments: { path: "." }
        });
        // @ts-ignore
        console.log(`[MCP Core] Result length: ${result.content[0].text.length} chars`);
    }

  } catch (error) {
    console.error("[MCP Core] ❌ Session Error:", error);
  }
}
```

## 4. 运行与验证

1.  **启动云端网关**：
    ```bash
    pnpm start:server
    ```
    *输出：`[Network] Cloud Gateway listening on port 8080...`*

2.  **启动本地连接器**：
    ```bash
    pnpm start:client
    ```
    *输出：`[Network] MCP Server is now online and serving the Cloud!`*

3.  **验证**：
    观察云端控制台，应能看到自动发现并调用了本地工具，输出了当前目录的文件列表。
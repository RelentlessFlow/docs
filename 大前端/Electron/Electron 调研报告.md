# Electron技术调研报告

[toc]

## 一、Electron 技术架构

![image-20251021094831073](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251021094831073.png)

### 1-1、简介

Electron是一个使用 JavaScript、HTML 和 CSS 构建桌面应用程序的框架。 嵌入 [Chromium](https://www.chromium.org/) 和 [Node.js](https://nodejs.org/) 到 二进制的 Electron 允许您保持一个 JavaScript 代码代码库并创建 在Windows上运行的跨平台应用 macOS和Linux——不需要本地开发 经验。

### 1-2、为什么选择 Electron

**编程语言**

TypeScript、JavaScript、前端框架、Node.js

**兼容性**

内嵌 Chromium 内核，不需要关注 操作系统内嵌 Webview 版本太低，导致展示异常

**社区生态**

丰富的 Electron 包，无需编写 C++ 代码，如果需要的话，也可以自己写 [node-addon-api](https://github.com/nodejs/node-addon-api)

- better-clipboard 剪切板增强插件 https://www.npmjs.com/package/better-clipboard

```typescript
import { betterClipboard } from 'better-clipboard';

betterClipboard.readFilePathList(); // get the path of file which in clipboard
betterClipboard.readBufferList();
betterClipboard.readFileList();


betterClipboard.writeFileList([]); // write file into clipboard via file path
```

client-active-win https://www.npmjs.com/package/@todesktop/client-active-win

```typescript
import { getActiveWin } from "@todesktop/client-active-win";

(async () => {
  console.log(await getActiveWin(options));
  /*
	{
		bounds: {
			x: 720,
			y: 330,
			height: 600,
			width: 800
		},
		id: 7184,
		memoryUsage: 1248,
		owner: {
			name: 'Simple App',
			processId: 56614,
			bundleId: 'com.google.Chrome',
			path: '/Applications/Google Chrome.app'
		},
		platform: "macos",
		title: 'Google',
	}
	*/
})();
```

**WASM**

Node 内核，跨平台

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/8NdXryEFjMXYhItCYvNx7vdTinXJfouFFrhngaj7rfIOCBB0LvassnR7eEGt5RXsxQEecZlqDQLZrsh0MIY1mA.svg" alt="FFmpeg | Lsong's Notes" style="zoom:25%;" />

![GitHub - electric-sql/pglite: Embeddable Postgres with real-time, reactive  bindings.](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/logo-light.svg)

## 二、Electron 流程模型

多进程模型，进程隔离

![chrome-processes-0506d3984ec81aa39985a95e7a29fbb8](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/chrome-processes-0506d3984ec81aa39985a95e7a29fbb8.png)

包括三套进程

- 主进程
- 渲染进程
- 预加载（preload）脚本

### 2-1、主进程

窗口管理、托盘管理、菜单管理、系统对话框管理、持久化仓库管理、IPC通信

**具备完整的Node.js 环境**

### 2-2、渲染进程

每个 窗体都会生成一个渲染器进程，每个渲染器进行都可以加载一个html文件

一般前端都是SPA单页面应用（Single Page Application），只有一个index.html文件，

这里最好是创建一个主窗体，用来展示SPA应用，其他窗体放一些 “加载页”、“关于应用” 等简单页面

**浏览器环境（默认禁用 Node）**

### 2-3、上下文隔离

- 主进程使用的是 Node.js 环境
- 渲染进程、预加载脚本，Chromium 环境（Node.js 环境）
- 为了安全，electron 提供了一套沙墙和上下文隔离机制
- 主进程、渲染进程通信依靠IPC
- 预加载脚本，暴露IPC通道i和一部分Node,js代码给渲染进程

### 2-4、主进程、渲染进程通信

#### 流程图

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/f22665e0ebbe49498c89a18c83dbf143~tplv-k3u1fbpfcp-jj-mark:3024:0:0:0:q75.awebp" alt="electron进程通信实战，实现截图功能主进程与渲染进程的通信，页面之间的交互通信，js截图的两种方式，调用webrt - 掘金" style="zoom:50%;" />

####  样例代码

**主进程**

```typescript
 // 打开网址
  ipcMain.handle(IpcChannel.OS_OPEN_URL, (_, { url }: { url: string }) => {
    if (!url)
      throw new Error('网址为空')
    try {
      shell.openExternal(url)
      return '已打开网址'
    }
    catch (_) {
      const channel = IpcChannel.OS_OPEN_URL
      const msg = '打开系统浏览器失败'
      logger.ipc(channel, msg, 'error')
      throw new Error(msg)
    }
  })
```

**渲染进程**

```react
<a
  target="_blank"
  rel="noreferrer"
  onClick={() => ipcRenderer.invoke(
    IpcChannel.OS_OPEN_URL,
    {
      url: 'https://www.baidu.com',
    },
  )}
>
  打开网址
</a>
```

### 2-5、preload 脚本

- 包含在渲染进程里
- 先于网页内容开始加载的代码 
- 使用webContents属性被挂在到BrowserWindow实例上
- 通过 contextBridge 暴露安全 API -> IPC 通信

通过`@electron-toolkit/preload` 暴露 IPC

```typescript
import { electronAPI } from '@electron-toolkit/preload'
import { contextBridge } from 'electron'

try {
  contextBridge.exposeInMainWorld('electron', electronAPI)
}
catch (error) {
  console.error(error)
}

import type { ElectronAPI } from '@electron-toolkit/preload'

declare global {
  interface Window {
    electron: ElectronAPI
  }
}
```

通过` IPC 通道`暴露 IPC

```typescript
import { contextBridge } from "electron";

const IPC = {
  // 剪切板相关
  READ_CLIPBOARD: () => ipcRenderer.invoke(IPC_CHANNEL.READ_CLIPBOARD),
  LOAD_CLIPBOARD: () => ipcRenderer.invoke(IPC_CHANNEL.LOAD_CLIPBOARD),
  WRITE_CLIPBOARD: () => ipcRenderer.invoke(IPC_CHANNEL.WRITE_CLIPBOARD),
  // 权限相关
  // 录屏、辅助功能权限检测
  PERMISSION_ACTIVE: () => ipcRenderer.invoke(IPC_CHANNEL.PERMISSION_ACTIVE),
  // 前往权限授予界面
  OPEN_SETTINGS_SECURITY: (target: '' | 'ScreenCapture' | 'Accessibility' = '') => ipcRenderer.send(IPC_CHANNEL.OPEN_SETTINGS_SECURITY, target),
  APP_ICON_PATH: (appPath: string) => ipcRenderer.invoke(IPC_CHANNEL.APP_ICON_PATH, appPath),
  FILE_SERVER_HOST: () => ipcRenderer.invoke(IPC_CHANNEL.FILE_SERVER_HOST),
};

contextBridge.exposeInMainWorld("ipc", IPC);
```

### 2-6、Electron 多进程对比

| 对比项       | 主进程 (Main Process)                | 渲染进程 (Renderer Process) | 预加载脚本 (Preload Script)                |
| ------------ | ------------------------------------ | --------------------------- | ------------------------------------------ |
| **作用**     | 管理应用生命周期、创建窗口、系统交互 | 渲染网页内容、执行前端逻辑  | 在网页加载前运行，用于安全地访问主进程功能 |
| **运行环境** | 完整 Node.js 环境                    | 浏览器环境（默认禁用 Node） | 运行在渲染进程中，具备受限的 Node 能力     |
| **数量**     | 只有一个                             | 每个窗口对应一个            | 每个渲染进程可有一个                       |
| **通信方式** | 通过 `ipcMain` 接收消息              | 通过 `ipcRenderer` 发送消息 | 使用 `contextBridge` 暴露安全 API          |

## 三、Electron 持久化

### 3-1、electron-store

`electron-store` 是一个 **轻量级、基于 JSON 文件的持久化存储库**，非常常用于 Electron 应用中存储用户信息、App 通用通用设置等。API用法基本同 **localstorage**，但是不用自己做序列化、反序列化。 **仅 Node.js 访问**

| 方法 / 属性                    | 说明                                                      | 示例                                          |
| ------------------------------ | --------------------------------------------------------- | --------------------------------------------- |
| **`new Store(options?)`**      | 创建一个存储实例。可配置文件名、默认值、加密、schema 等。 | `const store = new Store({ name: 'config' })` |
| **`.get(key, defaultValue?)`** | 获取某个键的值，不存在时可返回默认值。支持嵌套路径。      | `store.get('theme', 'light')`                 |
| **`.set(key, value)`**         | 设置某个键的值。支持嵌套路径。                            | `store.set('user.name', 'Alice')`             |
| **`.delete(key)`**             | 删除指定键。                                              | `store.delete('theme')`                       |
| **`.clear()`**                 | 清空所有存储内容。                                        | `store.clear()`                               |
| **`.has(key)`**                | 检查键是否存在。                                          | `store.has('user.name')`                      |

### 3-2、sync-store

类似用户信息、用户认证Token这类数据主进程、渲染进程最好保持一致，这里封装了一个 `sync-store` 做双向数据同步

**示例流程**

```
┌───────────────────────┐       ┌──────────────────────────┐
│    渲染进程 (Renderer) │       │       主进程 (Main)       │
└─────────┬─────────────┘       └───────────┬──────────────┘
          │                                   │
          │ 1. initSync()                     │
          │ → 遍历 STORE_SYNC_KEYS             │
          │ → 读取 localStorage                │
          │ → IPC: STORE_SET_ITEM(key, value) │ ←─── 2. 接收并存入主进程存储（如文件/内存）
          │                                   │
          │                                   │
          │ 3. 监听 IPC: STORE_SYNC            │
          │ ←─────────────────────────────────┘
          │ (主进程广播：任意进程修改后触发)
          │
          │ 4. 收到 STORE_SYNC 事件
          │ → 更新 localStorage
          │ → 触发所有监听器 (emit)
          │
          │ 5. setItem(key, value)
          │ → 更新 localStorage
          │ → 若是同步键 → IPC: STORE_SET_ITEM(key, value)
          │ → 触发监听器
          │
          │ 6. removeItem(key)
          │ → 删除 localStorage
          │ → 若是同步键 → IPC: STORE_REMOVE_ITEM(key)
          │ → 触发监听器 (value=null)
          │
          │ 7. getItem(key) → 从 localStorage 读取并解析
          │
          └───────────────────────────────────────────────────┐
                                                              │
                                          ┌───────────────────┴───────────────────┐
                                          │           所有监听器（组件/模块）           │
                                          │   (如：主题切换、用户偏好、窗口状态等)    │
                                          │   ←─── 接收 key/value 变化，自动更新 UI ──┘
                                          └─────────────────────────────────────────┘
```

其他持久化方案：SQLite + TypeORM、Prisma

## 四、Electron 项目构建

**electron-vite** 是一个新型构建工具，旨在为 [Electron](https://www.electronjs.org/) 提供更快、更精简的开发体验。

https://cn.electron-vite.org/

几个特性：

1. electron-builder、autoupdater、tsconfig、vite.config.ts 零配置

2. 模板比较丰富，支持目前所有的主流框架

目前支持的模板预设如下：

|                          JavaScript                          |                          TypeScript                          |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
| [vanilla](https://github.com/alex8088/quick-start/tree/master/packages/create-electron/playground/vanilla) | [vanilla-ts](https://github.com/alex8088/quick-start/tree/master/packages/create-electron/playground/vanilla-ts) |
| [vue](https://github.com/alex8088/quick-start/tree/master/packages/create-electron/playground/vue) | [vue-ts](https://github.com/alex8088/quick-start/tree/master/packages/create-electron/playground/vue-ts) |
| [react](https://github.com/alex8088/quick-start/tree/master/packages/create-electron/playground/react) | [react-ts](https://github.com/alex8088/quick-start/tree/master/packages/create-electron/playground/react-ts) |
| [svelte](https://github.com/alex8088/quick-start/tree/master/packages/create-electron/playground/svelte) | [svelte-ts](https://github.com/alex8088/quick-start/tree/master/packages/create-electron/playground/svelte-ts) |
| [solid](https://github.com/alex8088/quick-start/tree/master/packages/create-electron/playground/solid) | [solid-ts](https://github.com/alex8088/quick-start/tree/master/packages/create-electron/playground/solid-ts) |

3. HMR、热重载的支持
4. 支持源代码保护 https://cn.electron-vite.org/guide/source-code-protection
5. 支持 Worker Threads （性能优化）
6. 自带的 @electron-toolkit 对 IPC 通信 进行了二次封装，为开发提效

## 五、Electron 发布、自动更新

依赖 electron-builder、autoupdater

### 5-5、electron-builder

**electron-builder** 支持打包win、mac、linux等多个平台，并且可以自动处理 C++一些包的依赖关系

```
├── builder-debug.yml
├── builder-effective-config.yaml
├── desktop-1.0.0-arm64-mac.zip
├── desktop-1.0.0-arm64-mac.zip.blockmap
├── desktop-1.0.0.dmg
├── desktop-1.0.0.dmg.blockmap
├── latest-mac.yml
└── mac-arm64
    └── desktop.app
```

### 5-6、autoupdater

1、配置 autoupdater 打包服务器，其实就是个URL，OSS上传打包后的文件

2、调用 autoupdater 检查命令

3、autoupdater 读取OSS里面的配置，是否高于当前应用程序的版本号，如果高于就下载里面的zip包（这个可以配置是zip还是dmg），返回下载进度，下载完成后，会自动替换相关的文件，重启应用就更新成功了

4、mac 想看自动更新，必须用开发者账号签名

```yaml
publish:                                          # 自动更新配置（Auto Update）
  provider: generic                               # 自动更新服务提供商
  url: https://auto-updated-1304276643.cos.ap-guangzhou.myqcloud.com  
  # 自动更新服务的 URL，用于检查和下载更新
```

## 六、其他使用到的技术栈

多仓库依赖管理、缓存：turborepo

![image-20251021094311425](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251021094311425.png)

前端框架：react19 https://react.dev/

路由库：tanstack router（约定式文件路由、Hash模式） https://tanstack.com.cn/router/latest

![image-20251021094402447](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20251021094402447.png)

Hooks库：ahooks https://ahooks.js.org/zh-CN/hooks/use-request/index

常用Hooks：

- useRequest：https://ahooks.js.org/zh-CN/hooks/use-request/index

- usePagination：https://ahooks.js.org/zh-CN/hooks/use-pagination
- useAntdTable：https://ahooks.js.org/zh-CN/hooks/use-antd-table
- [useMount](https://ahooks.js.org/zh-CN/hooks/use-mount)
- [useUnmount](https://ahooks.js.org/zh-CN/hooks/use-unmount)
- useSetState
- useGetState

状态管理：hox https://hox.js.org/zh/

复杂状态更新：Immer https://immerjs.github.io/immer/zh-CN/example-setstate

- useImmer
- useState + Immer

组件库：antd https://ant.design/index-cn/

CSS库：taildwind css v4 https://tailwindcss.com/

组件封装可以参考：

https://ui.shadcn.com/docs/installation

https://github.com/shadcn-ui/ui/blob/main/apps/www/registry/default/ui/button.tsx?utm_source=chatgpt.com

## 七、接下来调研内容

主题配置、暗色模式（antd、taildwind ）

国际化 https://umijs.org/docs/max/i18n

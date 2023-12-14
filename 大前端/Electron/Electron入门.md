# Electron入门

## 一、Electron 脚手架

**1、添加 package.json**

Electron + JS + 原生

nodemon 可以自动兼容文件变化，重启Electron客户端

```json
{
  "name": "electron-app",
  "version": "1.0.0",
  "description": "",
  "main": "main.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "dev": "nodemon --exec electron ."
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "electron": "^28.0.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
```

nodemon.json

```json
{
  "ignore": [
    "node_modules",
    "dist"
  ],
  "colours": true,
  "verbose": true,
  "watch": [
    "*.*"
  ],
  "ext": "html,js"
}
```

Electron + Vite + 任意框架

concurrently 执行同时执行多命令

```json
{
  "name": "electron-vue",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "main": "main.cjs",
  "scripts": {
    "dev": "concurrently \"vite\" \"electron .\"",
    "build": "vue-tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "concurrently": "^8.2.2",
    "electron": "^28.0.0",
    "vue": "^3.3.8"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.5.0",
    "typescript": "^5.2.2",
    "vite": "^5.0.0",
    "vue-tsc": "^1.8.22"
  }
}
```

**2、添加index.html**

配置跨域

```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self'" />
<meta http-equiv="X-Content-Security-Policy" content="default-src 'self'; script-src 'self'" />
```

**3、添加main.js**

```typescript
const createWindow = () => {
	const mainWindow = new BrowserWindow({
		width: 1000,
		height: 800,
		x: 20,
		y: 20,
		alwaysOnTop: false,
		frame: true,
		transparent: false,
	});

	mainWindow.loadURL(path.resolve(__dirname, 'index.html'));
	mainWindow.webContents.openDevTools();
    
	return mainWindow;
}

app.whenReady().then(() => {
	createWindow();
})
```

## 二、Electron 进程通信

### 1、Electron 进程

Electron 主进程与渲染进程同时支持Node环境，但一般的，为了渲染进程安全，建议通过进程通信的方式在渲染进程中使用Node.

Electron 进程分为 主进程 main.js，渲染进程 renderer.js，预加载进程 preload.js

预加载进行用于预加载事件通信。

**注册preload.js 预加载进程**

```json
const mainWindow = new BrowserWindow({
	webPreferences: {
		preload: path.resolve(__dirname, 'preload.js'),
		nodeIntegration: true,
	}
})
```

### 2、渲染进程向主进程发送消息

1. 预渲染进程注册 IPC通道

```json
contextBridge.exposeInMainWorld('api', {
	IPC_SET_TITLE: (preload) => ipcRenderer.send('CHANNEL_SET_TITLE', preload),
}）
```

2. 渲染进程向 IPC 通道发送消息

```javascript
function createFormElement () {
	const input = document.createElement('input');
	input.name = 'title'
	const button = document.createElement('button');
	button.innerText = 'Submit'

	button.type = 'submit';

	const form = document.createElement('form');
	form.onsubmit = (event) => {
		event.preventDefault();

		const inputTitle = event.target.querySelector('input[name="title"]').value
		window.api.IPC_SET_TITLE(inputTitle)
	}

	form.appendChild(input);
	form.appendChild(button);

	document.body.appendChild(form);
}
```

3. 在主进程监听 IPC 通道消息

```javascript
ipcMain.on('CHANNEL_SET_TITLE', (event, preload) => {
	//获取用于控制网页的webContents对象
	const webContents = event.sender
	//获取窗口
	const win = BrowserWindow.fromWebContents(webContents)
	//设置窗口标题
	win.setTitle(preload)
})
```

### 3、主进程向渲染进程发送消息

一个Electron菜单向页面发送消息的例子

1. 预渲染进程注册 IPC通道

```javascript
IPC_INCREMENT: (callback) => ipcRenderer.on('CHANNEL_INCREMENT', callback)
```

这里注册的是一个监听通道事件，它返回了一个回调函数，每当有通道消息，都会触发callback回调函数。

callback 它的类型大概是这样的

```javascript
(event, preload) => any
```

2. 菜单向IPC 通道发送消息

注册菜单：

```javascript
// const mainWindow = new BrowserWindow(...)
createMenu(mainWindow);
```

menu.js

```javascript
const { Menu } = require('electron')

function createMenu(win) {
	const menu = Menu.buildFromTemplate([
		{
			label: '菜单',
			submenu: [
				{	//主进程向渲染进程发送消息
					click: () => win.webContents.send('CHANNEL_INCREMENT', 1),
					label: '增加',
				},
			],
		},
	]);
	Menu.setApplicationMenu(menu);
}

module.exports = { createMenu }
```

3. 重写 IPC_INCREMENT 函数，使其能够被 IPC通道 调用。

renderer.js

```javascript
window.api.IPC_INCREMENT((event, value) => {
	const h1 = document.querySelector('h1');
	h1.innerHTML = Number(h1.innerText) + value;

	event.sender.send('CHANNEL_FINISH', h1.innerHTML); // 这个可以直接用
    // window.api.IPC_FINISH(h1.innerHTML); 这个需要在preload里先注册
})
```

4. main.js

```javascript
ipcMain.on('CHANNEL_FINISH', (event, preload) => {
	console.log(preload) // IDE 打印 1 2 3 4
})
```

### 4、Invoke 双向通信

1. preload.js 注册通道

```javascript
IPC_MAIN_SHOW: async (preload) =>  {
		console.log('IPC_MAIN_SHOW', preload);
		return ipcRenderer.invoke('CHANNEL_MAIN_SHOW', preload) // Promise<T>
}
```

2. main.js 向通道 返回数据

```javascript
app.whenReady().then(() => {
	createWindow();
	ipcMain.handle('CHANNEL_MAIN_SHOW', () => {
		return 'is main handle'
	})
})
```

3. renderer 拿到通道 返回的数据，并向通道传入新的请求参数

```javascript
function createInvokeButton () {
	const btn = document.createElement('button');
	btn.innerText = 'Invoke';
	btn.onclick = async () => {
		const res = await api.IPC_MAIN_SHOW('renderer');
		document.body.insertAdjacentText('afterend', res);
	}
	document.body.appendChild(btn)
}
```

## 三、进程隔离

参考文档：https://doc.houdunren.com/%E7%B3%BB%E7%BB%9F%E8%AF%BE%E7%A8%8B/electron/4%20%E9%9A%94%E7%A6%BB%E8%BF%9B%E7%A8%8B.html#%E4%B8%8A%E4%B8%8B%E6%96%87%E9%9A%94%E7%A6%BB

进程隔离有三个选项

contextIsolation 上下文隔离

nodeIntegration 集成Node

sandbox 沙盒环境

```javascript
const mainWindow = new BrowserWindow({
	webPreferences: {
		preload: path.resolve(__dirname, 'preload.js'),
		contextIsolation: false,
		nodeIntegration: true,
		sandbox: false,
	},
})
```

隔离的配置有几种情况：

- 默认  contextIsolation 为 true，nodeIntegration为 false，sandbox为true（安全，啥API用不了）

  - 此时main.js 为完全node环境，renderer 和 preload 为浏览器环境
- nodeIntegration 为 true（推荐）

  - nodeIntegration 为 true，sandbox 自动设置 true，可以在preload中使用各种Node 高级模块，比如fs 等
- nodeIntegration 为 true，sandbox为 false（不安全，啥API用不了）

  - 只能在preload 中用一些很低级的模块
- contextIsolation为 false（不安全）
  - 不支持 contextBridge.exposeInMainWorld 等 API，在开启Node集成，关闭沙盒后，可以直接在render.js 中 使用完整的 NodeJS API，不安全
  

## 四、窗口定义

窗口实例常用的方法

| 方法                           | 说明                 |
| ------------------------------ | -------------------- |
| win.loadFile()                 | 加载文件             |
| win.loadURL()                  | 加载链接             |
| win.webContents.openDevTools() | 打开开发者工具       |
| win.setContentBounds()         | 控制窗口尺寸与位置   |
| win.center()                   | 将窗口移动到屏幕中心 |

常用的窗口属性

| 属性            | 说明                                                         |
| --------------- | ------------------------------------------------------------ |
| title           | 标题，也可以修改html模板的title标签，模板的title标签优先级高 |
| icon            | window系统窗口图标                                           |
| frame           | 是否显示边框                                                 |
| transparent     | 窗口是否透明                                                 |
| x               | x坐标                                                        |
| y               | y坐标                                                        |
| width           | 宽度                                                         |
| height          | 高度                                                         |
| movable         | 是否可以移动窗口                                             |
| minHeight       | 最小高度，不能缩放小于此高度                                 |
| minWidth        | 最大高度，不能缩放小于此高度                                 |
| resizable       | 是否允许缩放窗口                                             |
| alwaysOnTop     | 窗口是否置顶                                                 |
| autoHideMenuBar | 是否自动隐藏窗口菜单栏。 一旦设置，菜单栏将只在用户单击 `Alt` 键时显示 |
| fullscreen      | 是否全屏幕                                                   |

## 五、菜单管理

在electron中可以方便的对应用菜单进行定义。

### 清除菜单

下面先来学习不显示默认菜单，在主进程main.js中定义以下代码。

```text
const { BrowserWindow, app, Menu } = require('electron')
Menu.setApplicationMenu(null)
```

我们需要用到 [Menu (opens new window)](https://www.electronjs.org/zh/docs/latest/api/menu-item)模块、[MenuItem (opens new window)](https://www.electronjs.org/zh/docs/latest/api/menu-item#new-menuitemoptions)菜单项与 [`accelerator` (opens new window)](https://www.electronjs.org/zh/docs/latest/api/accelerator)快捷键知识。

```typescript
const { Menu, BrowserWindow } = require('electron')

const isMac = process.platform === 'darwin'

function createMenu(window) {
	const menu = Menu.buildFromTemplate([
		{
			label: '菜单',
			submenu: [
				{
					label: '打开新窗口',
					click: () => new BrowserWindow({ width: 800, height: 600 }).loadURL('https://baidu.com'),
					accelerator: 'CommandOrControl+n',
				},
				{ //主进程向渲染进程发送消息
					label: '增加',
					click: () => window.webContents.send('CHANNEL_INCREMENT', 1),
				},
			],
		},
		{
			type: 'separator',
		},
		isMac
			? { label: '关闭', role: 'close' }
			: { role: 'quit' },
	]);
	Menu.setApplicationMenu(menu);
}

module.exports = {
	createMenu,
}
```

### 右键菜单

electron 可以定义快捷右键菜单，需要预加载脚本与主进程结合使用

main.js 主进程定义ipc事件，当preload.js 触发事件时显示右键菜单

```typescript
ipcMain.on('show-context-menu', (event) => {
  const popupMenuTemplate = [
    { label: '退出', click: () => app.quit() },
  ]

  const menu = Menu.buildFromTemplate(
    popupMenuTemplate,
  )
  menu.popup(
    BrowserWindow.fromWebContents(event.sender),
  )
})
```

preload.js 预加载脚本定义，用于触发右键事件，然后通过IPC调用主进程显示右键菜单

```typescript
window.addEventListener('contextmenu', (e) => {
  e.preventDefault()
  ipcRenderer.send('show-context-menu')
})
```

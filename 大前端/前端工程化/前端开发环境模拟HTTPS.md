# 前端开发环境模拟HTTPS

## 一、创建HTTPS证书

进入要建立 HTTPS 服务的目录

```shell
openssl genrsa -out key.pem 1024
openssl req -new -key key.pem -out csr.pem
openssl x509 -req -in csr.pem -signkey key.pem -out cert.pem
```

### openssl报错？

**Windows11 安装openssl**

```shell
winget search openssl
winget install OpenSSL
```

配置环境变量

```shell
# 变量名
OPENSSL_HOME
# 变量值
C:\Program Files\OpenSSL-Win64\bin

# PATH
%OPENSSL_HOME%
```

## 二、创建HTTPS服务器

```shell
http-server -S ./
```

## 三、脚手架配置HTTPS

### @umi配置

```typescript
import {defineConfig} from "umi";

export default defineConfig({
	https: {
		cert: './key/cert.pem',
		key: './key/key.pem',
		http2: true
	},
	define: {
		IS_DEV: true
	}
})
```

### @vite配置

```typescript
import * as fs from "fs";
import * as path from "path";
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    https: {
        cert: fs.readFileSync(path.join(__dirname, 'key/cert.pem')),
        key: fs.readFileSync(path.join(__dirname, 'key/key.pem')),
    }
   },
  plugins: [react()],
})
```

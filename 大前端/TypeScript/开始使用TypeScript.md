# 开始使用TypeScript

## 一、安装typescript

[toc]

### 1. 配置镜像站

#### npm

- 查询当前配置 npm get registry
- 配置镜像站 npm config set registry http://registry.npm.taobao.org/
- 换成原来的 npm config set registry https://registry.npmjs.org/

#### yarn

- 查询当前配置 yarn config get registry
- 配置镜像站 yarn config set registry http://registry.npm.taobao.org/
- 换成原来的 yarn config set registry http://registry.npmjs.org/

##### 1. 全局安装

```shell
green@greendeMacBook-Pro ~ % sudo npm install typescript -g
green@greendeMacBook-Pro ~ % tsc -V
Version 4.6.4
```

##### 2. 项目独立安装

```shell
green@greendeMacBook-Pro develop % mkdir tp
green@greendeMacBook-Pro develop % cd tp 
green@greendeMacBook-Pro tp % yarn init -y
yarn init v1.22.18
warning The yes flag has been set. This will automatically answer yes to all questions, which may have security implications.
success Saved package.json
✨  Done in 0.01s.
green@greendeMacBook-Pro tp % ls
package.json
green@greendeMacBook-Pro tp % yarn add typescript -D   
yarn add v1.22.18
info No lockfile found.
[1/4] 🔍  Resolving packages...
[2/4] 🚚  Fetching packages...
[3/4] 🔗  Linking dependencies...
[4/4] 🔨  Building fresh packages...
success Saved lockfile.
success Saved 1 new dependency.
info Direct dependencies
└─ typescript@4.6.4
info All dependencies
└─ typescript@4.6.4
✨  Done in 13.49s.
green@greendeMacBook-Pro tp % yarn tsc -v
yarn run v1.22.18
$ /Users/green/Documents/develop/tp/node_modules/.bin/tsc -v
Version 4.6.4
✨  Done in 0.55s.
green@greendeMacBook-Pro tp % 
```

## 二、编译TypeScript

### 1. 手动编译命令

```shell
tsc 1.ts
```

### 2. 自动编译命令

```shell
tsc 1.ts -w
```

### 3. 为Visual Studio Code添加自动编译任务

- 在项目根目录创建tsconfig.json

```shell
tsc --init
```

- Control + Option + R > Typescript > tsc --watch


# MacOSX安装教程

### Brew安装

```shell
$ brew tap mongodb/brew
$ brew install mongodb-community@4.4
```

**@** 符号后面的 **4.4** 是最新版本号。

安装信息：

- 配置文件：**/usr/local/etc/mongod.conf**
- 日志文件路径：**/usr/local/var/log/mongodb**
- 数据存放路径：**/usr/local/var/mongodb**

### 运行 MongoDB

我们可以使用 brew 命令或 mongod 命令来启动服务。

brew 启动：

```shell
$ brew services start mongodb-community@4.4
```

brew 停止：

```shell
$ brew services stop mongodb-community@4.4
```

mongod 命令后台进程方式：

```shell
$ mongod --config /usr/local/etc/mongod.conf --fork
```

这种方式启动要关闭可以进入 mongo shell 控制台来实现：

```shell
> db.adminCommand({ "shutdown" : 1 })
```

配置MongoDB环境变量

```shell
$ vim ~/.zshrc
```

```
PATH=$PATH:/usr/local/Cellar/mongodb-community/4.4.0
```

```shell
$ source ~/.zshrc
```

```shell
$ mongo
```


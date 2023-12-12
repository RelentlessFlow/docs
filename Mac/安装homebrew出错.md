## 问题描述

今天安装brew时遇到了如下错误：

```shell
curl: (7) Failed to connect to raw.githubusercontent.com port 443: Connection refused
```

## 解决办法

1. 使用Chrome或者Safari打开如下链接`https://raw.githubusercontent.com/Homebrew/install/master/install`

2. 按下快捷键Commond+S保存网页内容到任意你可以找得到的位置，文件名输入brew_install.rb，文件类型填写为全部文件类型（Safari即为页面源码）。

3. 打开终端进入刚才保存文件所在的文件夹下，输入`ruby brew_install.rb`命令即可安装brew工具。

   安装时部分代码：

   ```shell
   ==> This script will install:
   /usr/local/bin/brew
   /usr/local/share/doc/homebrew
   /usr/local/share/man/man1/brew.1
   /usr/local/share/zsh/site-functions/_brew
   /usr/local/etc/bash_completion.d/brew
   /usr/local/Homebrew
   ==> The following existing directories will be made group writable:
   /usr/local/bin
   ```

4. 验证brew命令是否管用：

   ```shell
   $ brew
   ```

   


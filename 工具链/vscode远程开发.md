# VSCode远程开发

### 1、 安装VSCode拓展

Remote - SSH

https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh

Remote - SSH: Editing Configuration Files

https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit

Remote Explorer

https://marketplace.visualstudio.com/items?itemName=ms-vscode.remote-explorer



这个插件也还不错：

Remote - SSH

https://marketplace.visualstudio.com/items?itemName=Kelvin.vscode-sshfs

### 2、配置ssh.config

在侧边栏Remote Explorer，点击齿轮 Open SSH Config File，选择 Users\username\.ssh\config

```
# Read more about SSH config files: https://linux.die.net/man/5/ssh_config
Host 10.1.1.11_jupyter_container
HostName 10.1.1.11
Port 22
User root
IdentityFile ~/.ssh/id_rsa
```

### 3、生成SSH秘钥

**生成 SSH 密钥对**： 打开终端（Windows: PowerShell 或 CMD，macOS/Linux: Terminal），然后运行以下命令生成 SSH 密钥对：

```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

windows提示ssh-keygen不存在，就用winget安装一下openssh

按照提示完成密钥生成过程。

### 4、将秘钥导入远程服务网

**显示公钥内容**： 在本地计算机上打开 PowerShell，运行以下命令以显示公钥内容：

```
Get-Content $env:USERPROFILE\.ssh\id_rsa.pub
```

Linux、Mac

```
cat ~/.ssh/id_rsa.pub
```

复制输出的整行内容。

1. **使用 SSH 连接到远程服务器**： 使用 SSH 连接到远程服务器，指定端口 `2200`：

   ```
   ssh -p 2200 root@10.1.1.11
   ```

2. **创建 `.ssh` 目录（如果不存在）**： 在远程服务器上，确保存在 `.ssh` 目录并设置正确权限：

   ```
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   ```

3. 编辑authorized_keys文件，将之前的公钥复制到这里

   ```
   vim ~/.ssh/authorized_keys
   ```

   如果之前已经添加过公钥了，另起一行，将公钥复制另一行

4. **设置 `authorized_keys` 文件权限**： 确保 `authorized_keys` 文件具有正确的权限：

   ```
   chmod 600 ~/.ssh/authorized_keys
   ```

5. **退出远程服务器**： 完成后，退出远程服务器会话：

    ```
    exit
    ```
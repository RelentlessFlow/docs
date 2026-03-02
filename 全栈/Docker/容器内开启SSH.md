# 容器内开启SSH

## 流程

**进入容器内**

```
docker exec -it del_jupyterhub /bin/bash
```

**为root用户设置新密码**：

```
passwd
```

**安装并启动SSH服务**（如果尚未安装）

```
apt-get update
apt-get install -y openssh-server
service ssh start
```

**确保SSH配置允许密码登录**：

编辑 `/etc/ssh/sshd_config` 文件，确保以下配置项正确：

```
PermitRootLogin yes  # 如果你要允许root登录
PasswordAuthentication yes
```

**重启SSH服务**：

```
service ssh restart
```

完成这些步骤后，你就可以使用设置的用户名和密码通过SSH连接到容器了。

***确保 sshd 在后台运行***

```
nohup /usr/sbin/sshd &
```

**确认ssh状态**

```
service ssh status
```

**设置开启自启**

```
systemctl enable ssh
```

**提交当前容器为新镜像**

```
docker commit del_jupyterhub qiyan-jupyterhub-api:1.0.1
```

**使用新镜像启动新容器**

```
docker run -d -p 2200:22 --name del_jupyterhub qiyan-jupyterhub-api:1.0.1
```

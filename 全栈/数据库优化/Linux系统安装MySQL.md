# Linux系统安装MySQL

## 1.对虚拟机的设置

CentOS7下载地址：http://mirrors.zju.edu.cn/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1908.iso

设置虚拟机CPU虚拟化以及网络桥接模式：

![image-20200309124323095](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20200309124323095.png)

![image-20200309124335301](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20200309124335301.png)

## 2.设置SSH连接：

使用SSH工具连接Linux虚拟机

1. 查看本地IP地址：`ip ddr`

![image-20200309124539199](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20200309124539199.png)

2. 使用SSH工具连接到CentOS

   `ssh -p 22 root@192.168.1.105`

3. 输入账号密码即可

## 3.禁用SELinux

1. 输入命令`vi /etc/selinux/config`
2. 设置SELINUX=disabled
3. 重启系统

## 4.替换yum源

1. `curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo`

2. `yum clean all`
3. `yum makecache `

## 5.安装MySQL

### yum在线安装

1. 下载rpm文件

   `yum localinstall https://repo.mysql.com//mysql80-community-release-el7-1.noarch.rpm`

2. 安装MySQL数据库

   `yum install mysql-community-server -y`

###  本地安装

1. 下载MySQL安装包文件，并上传到/root/mysql

   mysql下载地址：https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.19-1.el7.x86_64.rpm-bundle.tar

   ```shell
   $ mkdir mysql
   $ cd mysql
   ```

2. 解压缩TAR文件

   ```shell
   $ tar xvf mysql-8.0.19-1.el7.x86_64.rpm-bundle.tar
   ```

3. 安装第三方依赖包

   ```shell
   $ yum install perl -y
   $ yum install net-tools -y
   ```

4. 安装MySQL安装包

   ```shell
   $ rpm -qa|grep mariadb
   $ rpm e mariadb-libs-5.5.60-l.el7_5.x86_64 --nodeps
   $ rpm -ivh mysql-community-common-8.0.19-1.el7.x86_64.rpm
   $ rpm -ivh mysql-community-libs-8.0.19-1.el7.x86_64.rpm
   $ rpm -ivh mysql-community-client-8.0.19-1.el7.x86_64.rpm
   $ rpm -ivh mysql-community-server-8.0.19-1.el7.x86_64.rpm
   ```

## 6.启动MySQL

1. 设置权限并完成初始化操作

```
$ chmod -R 777 /var/lib/mysql
$ mysqld --initialize
$ chmod -R 777 /var/lib/mysql/*
```

2. 启动数据库

   ```shell
   [root@localhost var]# service mysqld start
   Redirecting to /bin/systemctl start mysqld.service
   [root@localhost var]# grep 'temporary password' /var/log/mysqld.log
   2020-03-09T04:14:10.349992Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: bNbx.IA?j4=x
   [root@localhost var]# mysql -u -p
   ERROR 1045 (28000): Access denied for user '-p'@'localhost' (using password: NO)
   [root@localhost var]# mysql -u root -p
   Enter password:
   Welcome to the MySQL monitor.  Commands end with ; or \g.
   Your MySQL connection id is 9
   Server version: 8.0.19
   
   Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.
   
   Oracle is a registered trademark of Oracle Corporation and/or its
   affiliates. Other names may be trademarks of their respective
   owners.
   
   Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
   
   mysql>
   ```

## 7.修改默认密码

```shell
mysql> alter user user() identified by "abc123456";
Query OK, 0 rows affected (0.01 sec)

mysql> exit
Bye
[root@localhost var]#
```

## 8.允许root远程访问

1. 允许远程使用root账户

   ```shell
   mysql> use mysql;
   Reading table information for completion of table and column names
   You can turn off this feature to get a quicker startup with -A
   
   Database changed
   mysql> update user set host='%' where user='root';
   Query OK, 1 row affected (0.01 sec)
   Rows matched: 1  Changed: 1  Warnings: 0
   
   mysql> flush privileges
       -> ;
   Query OK, 0 rows affected (0.00 sec)
   ```

2. 设置配置文件etc/my.config

   ```shell
   $ vi /etc/my.cnf
   
   Oracle is a registered trademark of Oracle Corporation and/or its
   affiliates. Other names may be trademarks of their respective
   # For advice on how to change settings please see
   # http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html
   
   [mysqld]
   character_set_server = utf8
   bind-address=0.0.0.0
   ...
   
   [root@localhost var]# service mysqld restart
   Redirecting to /bin/systemctl restart mysqld.service
   ```

3. 系统开放3306端口

   ```shell
   [root@localhost var]# firewall-cmd --zone=public --add-port=3306/tcp --permanent
   success
   [root@localhost var]# firewall-cmd --reload
   success
   ```

## 9.使用DataGrip连接MySQL数据库

![image-20200309140748446](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20200309140748446.png)


# Mac OSX 终端走shadowsocks代理


## 参考资料：

>https://zhuanlan.zhihu.com/p/47849525

>https://github.com/Eccon/Gitalk/issues/3

最近发现MacOS的终端命令brew,git,npm等命令下载速度缓慢，排除掉代理的因素，发现是Mac终端本身不支持Socket5代理，经过一番摸索，送上解决方案。

## 前提条件：

- SSR版本：ShadowsocksX-NG-R8
- Shadowsocks:On
- PAC或全局模式
- 终端为shell或zsh

1. 确定你的代理设置，确认本地Socket5监听地址为127.0.0.1，监听端口为8006

   ​	操作步骤：任务栏SSR图标 > 高级设置 > 确认端口、地址

2. 以bash为例

   ```shell
   # touch ~/bash.profile	创建命令 
   $ vim ~/.bash.profile
   ```

3. 添加代理配置

   ```shell
   # proxy list
   alias proxy='export https_proxy=http://127.0.0.1:1087 export http_proxy=http://127.0.0.1:1087 export all_proxy=socks5://127.0.0.1:1086'
   alias unproxy='unset all_proxy unset https_proxy unset http_proxy'
   ```

4. 刷新代理配置

   ```shell
   $ source .bash_profile
   ```

5. 测试当前连接

   ```shell
   $ curl cip.cc
   IP	: 103.78.125.224
   地址	: 中国  中国
   
   数据二	: 亚太地区
   
   数据三	: 中国湖南长沙 | 湖南巨亚
   ```

6. 启动代理服务

   ```shell
   $ proxy
   ```

7. 再次测试连接

   ```shell
   $ curl cip.cc
   IP	: 118.140.62.233
   地址	: 中国  香港  hgc.com.hk
   
   数据二	: 香港
   
   数据三	: 中国香港
   ```

8. 测试git clone

   ```shell
   $ git clone https://github.com/litten/hexo-theme-yilia.git
   Cloning into 'hexo-theme-yilia'...
   remote: Enumerating objects: 1, done.
   remote: Counting objects: 100% (1/1), done.
   remote: Total 2037 (delta 0), reused 0 (delta 0), pack-reused 2036
   Receiving objects: 100% (2037/2037), 10.52 MiB | 1.06 MiB/s, done.
   Resolving deltas: 100% (1093/1093), done.
   ```

   可以看到，速度还是非常快的。

9. 如果想要禁用代理可以使用命令

   ```shell
   $ unproxy
   ```

**注意：**如果是zsh只需要在~/.zshrc中加入`source ~/.bash_profile`即可将bash配置引入到zsh内。

# Nginx 踩坑经历

最近在基于SSE（Server Sent Events）做服务端单向推送服务，本地开发时一切顺利，但是在部署到预发环境时就碰到1个很诡异的问题，这里需要简单介绍下我们的整体架构：

# 整体架构

![image.png](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/bea4225c6dc840a58f930073d08dc725~tplv-k3u1fbpfcp-jj-mark:3024:0:0:0:q75.awebp)

可以看到所有的请求都会先到统一的网关层（对应 example.com 这个一级域名），然后发到不同的应用对应的`docker`镜像上，这里不同的应用可以简单地用不同的域名来做表示，例如应用 A 的域名是`A.example.com`，应用 B 的域名是`B.example.com`，且这里的每1个应用都是1个SPA单页应用，这样的话前端和服务端就是完全分离的，前端这边完全掌控页面和路由的跳转，对于数据获取和更新只需要请求对应的接口和服务即可，这也算是现在比较流行的一种架构了。

因为历史原因，我们的服务有多个，且这些服务的域名是不一样的，例如对于应用A来说，所依赖的底层服务有 `serviceA`（域名是 serviceA.example.com）和`serviceB`（域名是 serviceB.example.com），所以在应用A的`docker`上会存在1个 Nginx ，用来对 A.example.com 下的不同接口的请求做反向代理，确保能转发到不同的服务上。

例如当用户请求 `A.example.com/doc/update/`这个接口时，本质上会发送请求到 doc.example.com/update 这个接口上，并得到数据。

好了，背景介绍得差不多了，现在开始上重点。

# 真实场景

现在我们做了1个 [SSE（Server Sent Events）](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.mozilla.org%2Fzh-CN%2Fdocs%2FWeb%2FAPI%2FServer-sent_events)服务在 doc.example.com/sse，那么我们需要Nginx将 `A.example.com/doc/sse/`给转发到 doc.example.com/sse 上即可

> SSE的全称是（Server Sent Events），简单来说服务器发送事件，是客户端与服务端建立单向的长连接通信的一种方式，客户端可以通过 EventSource 来订阅事件通知，等待服务端去推送消息

在咨询了ChatGPT 4之后，最精简的配置如下：

```ts
ts

 体验AI代码助手
 代码解读
复制代码server {
    listen  80;
    charset utf-8;
    ... # 省略配置信息

    location /doc/sse {        
        # 转发到对应的域名下
        proxy_pass https://doc.example.com/sse; 

        # Disable buffering for SSE
        proxy_buffering off;
        
       # Other necessary SSE headers
        proxy_set_header Cache-Control 'no-cache';
        proxy_set_header Connection 'keep-alive';

        # Standard proxy headers
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
 }
```

但是在连接后就发现1个很奇怪的问题，sse 无法连接，会被重定向到 A.example.com/sse 这个域名下，而不是我们想要的 doc.example.com/sse。

上面的配置看起来无比正确，但就是存在问题。那么话不多说，直接二分排查。

这里抽象一个解决的方法论，先保留一个最小的正确问题的现场，然后通过二分搜索的方式去找到具体的原因

## 问题本质

经过层层筛选，最后发现问题出在 `proxy_set_header Host $http_host;`这条语句上。

当在 Nginx 中同时使用 `proxy_set_header` 和 `proxy_pass` 指令时，`Host` 头部的处理步骤如下：

### 第一步：请求到达 Nginx

客户端发起请求，该请求到达运行 Nginx 的服务器。该请求会包含一个 `Host` 头部，通常是用来指定服务器的域名或IP地址。

### 第二步：匹配 Location 块

Nginx 根据请求的 URI 匹配相应的 `location` 块。例如，如果请求的是 `/doc/sse`，Nginx 将匹配包含 `proxy_pass` 和 `proxy_set_header` 指令的 `location /doc/sse` 块。

### 第三步：处理 proxy_set_header 指令

如果在 `location` 块中使用了 `proxy_set_header Host $http_host;` 指令，Nginx 将修改或添加 `Host` 请求头部，将其值设置为 `$http_host` 变量的值。这个变量通常包含客户端在请求中发送的 `Host` 头部的值。

### 第四步：处理 proxy_pass 指令

`proxy_pass` 指令告诉 Nginx 将请求转发到指定的后端服务。如果配置为 ` proxy_pass  ``https://doc.example.com/sse;`，Nginx 将请求转发到 `https://doc.example.com/sse`。

### 第五步：设置请求头部

重点来了，在将请求转发给后端服务之前，Nginx 将根据 `proxy_set_header` 指令设置的值来修改请求头部。**在这个过程中，Nginx 会将** **`Host`** **头部设置为客户端请求中的** **`Host`** **头部的值，而不是** **`proxy_pass`** **中指定的后端服务的域名。**

也就是说，我们请求的地址经历了以下的变化：

1. `A.example.com/doc/sse`
2. `doc``.example.com/sse`
3. `A.example.com/sse`（由`proxy_set_header`执行）

那么相当于发生了1次不受 Nginx 管控的重定向。

## 正确答案：

最精简的完整配置如下：

```ts
ts

 体验AI代码助手
 代码解读
复制代码location /doc/sse {        
        proxy_pass https://doc.example.com/sse; 

        # Disable buffering for SSE
        proxy_buffering off;
    }
```

这里可能有的同学会好奇，为什么一定要关闭代理缓存呢？如果不关闭会怎么样呢？下面我们来简单讲讲：

## 为什么要关闭代理缓存？

对于(SSE)来说，关闭代理缓冲非常重要，原因主要在于SSE的工作机制和数据流的特性。

1. **SSE工作机制**： SSE允许服务器通过一个持久的HTTP连接向客户端实时推送数据。服务器发送的数据流是一个持续的过程，不是一次性完成的。
2. **代理缓冲的影响**： 如果代理服务器对传入的响应进行缓冲，**它可能会等待缓冲区填满或达到某个特定的数据量后，才将数据一次性发送给客户端**。这样做的结果是客户端不能实时接收到服务器推送的数据，从而破坏了SSE的实时性。
3. **实时性要求**： SSE的主要用途是为了实现实时通信。如果代理服务器对数据进行缓冲，则实时通信的效果会被大大降低，因为客户端接收数据的速度会受到影响。
4. **连接保持**： 除了实时性之外，SSE连接需要保持打开状态，以便服务器可以持续发送数据。如果代理服务器对连接进行了不当的处理（例如，由于长时间不活动而关闭连接），这也可能干扰SSE的正常工作。

因此，对于SSE来说，关闭代理服务器的响应缓冲是确保数据能够及时、连续地发送给客户端的关键。这样可以保持数据流的连续性，确保客户端能够实时接收到服务器端发送的每一条消息。

作者：王和阳
链接：https://juejin.cn/post/7319163510448766995
来源：稀土掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
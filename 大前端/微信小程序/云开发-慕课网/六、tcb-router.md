# 六、tcb-router

> 基于 koa 风格的小程序·云开发云函数轻量级类路由库，主要用于优化服务端函数处理逻辑
>
> 主页：https://github.com/TencentCloudBase/tcb-router

## 一、使用

```
npm install --save tcb-router
```

## 二、Koa洋葱模型

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20220413173229821.png" alt="image-20220413173229821" style="zoom:50%;" />

## 三、中间件基本流程

cloudfunctions/tcbRouter/index.js

```javascript
// 云函数的 index.js
const TcbRouter = require('./router');

exports.main = (event, context) => {
    const app = new TcbRouter({ event });
  
    // app.use 表示该中间件会适用于所有的路由
    app.use(async (ctx, next) => {
        ctx.data = {};
        await next(); // 执行下一中间件
    });

    // 路由为数组表示，该中间件适用于 user 和 timer 两个路由
    app.router(['user', 'timer'], async (ctx, next) => {
        ctx.data.company = 'Tencent';
        await next(); // 执行下一中间件
    });

    // 路由为字符串，该中间件只适用于 user 路由
    app.router('user', async (ctx, next) => {
        ctx.data.name = 'heyli';
        await next(); // 执行下一中间件
    }, async (ctx, next) => {
        ctx.data.sex = 'male';
        await next(); // 执行下一中间件
    }, async (ctx) => {
        ctx.data.city = 'Foshan';
        // ctx.body 返回数据到小程序端
        ctx.body = { code: 0, data: ctx.data};
    });

    // 路由为字符串，该中间件只适用于 timer 路由
    app.router('timer', async (ctx, next) => {
        ctx.data.name = 'flytam';
        await next(); // 执行下一中间件
    }, async (ctx, next) => {
        ctx.data.sex = await new Promise(resolve => {
        // 等待500ms，再执行下一中间件
        setTimeout(() => {
            resolve('male');
        }, 500);
        });
        await next(); // 执行下一中间件
    }, async (ctx)=>  {
        ctx.data.city = 'Taishan';

        // ctx.body 返回数据到小程序端
        ctx.body = { code: 0, data: ctx.data };
    });

    return app.serve();

}
```

## 四、小程序端

```javascript
// 调用名为 router 的云函数，路由名为 user
wx.cloud.callFunction({
    // 要调用的云函数名称
    name: "router",
    // 传递给云函数的参数
    data: {
        $url: "user", // 要调用的路由的路径，传入准确路径或者通配符*
        other: "xxx"
    }
});
```
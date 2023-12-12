# @umi Qiankun实践

### 一、使用umi创建App

### 二、配置umi

这里有一些WASM的配置，不想要可以去掉

```typescript
import { defineConfig } from 'umi';

export default defineConfig({
  title: 'xxxxxx',
  routes: [
    {
      path: '/',
      component: 'index',
    },
    { path: '/scene-obj', component: 'OBJScene' },
    { path: '/*', redirect: '/' },
  ],
  npmClient: 'pnpm',
  proxy: {
    '/api': {
      target: 'http://jsonplaceholder.typicode.com/',
      changeOrigin: true,
      pathRewrite: { '^/api': '' },
    },
  },
  plugins: [
    '@umijs/plugins/dist/model',
    '@umijs/plugins/dist/qiankun',
    '@umijs/plugins/dist/request',
  ],
  model: {},
  qiankun: {
    slave: {},
  },
  request: {
    dataField: 'data',
  },
  mfsu: {
    mfName: 'umiR3f', // 默认的会冲突，所以需要随便取个名字避免冲突
  },
  chainWebpack(config) {
    config.set('experiments', {
      ...config.get('experiments'),
      asyncWebAssembly: true,
    });

    const REG = /\.wasm$/;

    config.module.rule('asset').exclude.add(REG).end();

    config.module
      .rule('wasm')
      .test(REG)
      .exclude.add(/node_modules/)
      .end()
      .type('webassembly/async')
      .end();
  },
});
```

### 三、跨域配置

```typescript
import type { IApi } from 'umi';

export default (api: IApi) => {
  // 中间件支持 cors
  api.addMiddlewares(() => {
    return function cors(req, res, next) {
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Headers', '*');
      next();
    };
  });
  api.onBeforeMiddleware(({ app }) => {
    app.request.headers['access-control-allow-origin'] = '*';
    app.request.headers['access-control-allow-headers'] = '*';
    app.request.headers['access-control-allow-credentials'] = '*';
    app.request.originalUrl = '*';
  });
};
```

修改app.ts，子应用配置生命周期钩子.

```typescript
export const qiankun = {
  // 应用加载之前
  async bootstrap(props: any) {
    console.log('app1 bootstrap', props);
  },
  // 应用 render 之前触发
  async mount(props: any) {
    console.log('app1 mount', props);
  },
  // 应用卸载之后触发
  async unmount(props: any) {
    console.log('app1 unmount', props);
  },
};
```


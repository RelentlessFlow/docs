# 六、react-router

> 参考：https://blog.csdn.net/qdmoment/article/details/85451642

基于react-router 4.0

react-router React Router 核心

react-router-dom 用于 DOM 绑定的 React Router（一般引用这一个即可）

react-router-native 用于 React Native 的 React Router

react-router-redux React Router 和 Redux 的集成

react-router-config 静态路由配置帮助助手

## 一、react-router路由模式表

| **`BrowserRouter`**                                   | **`HashRouter`**                                             | **`MemoryRouter`**                                  | NativeRouter                   | StaticRouter   |
| ----------------------------------------------------- | ------------------------------------------------------------ | --------------------------------------------------- | ------------------------------ | -------------- |
| 使用 HTML5 提供的 history API 来保持 UI 和 URL 的同步 | 使用 URL 的 hash (例如：window.location.hash) 来保持 UI 和 URL 的同步 | 能在内存保存你 “URL” 的历史纪录(并没有对地址栏读写) | 为使用React Native提供路由支持 | 从不会改变地址 |

1、BrowserRouter: 浏览器的路由方式，也就是在开发中最常使用的路由方式/
2、HashRouter:在路径前加入#号成为一个哈希值，Hash模式的好处是，再也不会因为我们刷新而找不到我们的对应路径
3、MemoryRouter: 不存储history,所有路由过程保存在内存里，不能进行前进后退，因为地址栏没有发生任何变化
4、NativeRouter:经常配合ReactNative使用，多用于移动端
5、StaticRouter: 设置静态路由，需要和后台服务器配合设置，比如设置服务端渲染时使用


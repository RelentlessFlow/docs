# 二、setState

[toc]

## 1. React中的setState是同步还是异步的

- 执行
  - 同步
    - 原生事件
    - setTimeout
  - 异步
    - react合成事件
    - 生命周期钩子函数
- 本质
  - 本身执行的过程和代码都是同步的，
  - 只是合成事件和钩子函数的调用顺序在更新之前，
  - 导致在合成事件和钩子函数中没法立马拿到更新后的值，形式了所谓的“异步”。

## 2. React setState两次实际会执行几次

```javascript
setState(updater, [callback])
```

1)官方文档部分：

`setState()` 将对组件 state 的更改排入队列，并通知 React 需要使用更新后的 state 重新渲染此组件及其子组件。这是用于更新用户界面以响应事件处理器和处理服务器数据的主要方式

将 `setState()` 视为*请求*而不是立即更新组件的命令。为了更好的感知性能，React 会延迟调用它，然后通过一次传递更新多个组件。React 并不会保证 state 的变更会立即生效。

1)博文https://segmentfault.com/a/1190000015463599

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/bVbcTeX.png" alt="clipboard.png" style="zoom:100%;" />

在React的setState函数实现中，会根据一个变量 `isBatchingUpdates` 判断是`直接更新` this.state 还是`放到队列` 中。

而`isBatchingUpdates` 默认是`false`，也就表示setState会`同步更新`this.state，但是有一个函数`batchedUpdates`。

这个函数会把`isBatchingUpdates`修改为`true`，而当React在调用事件处理函数之前就会调用这个`batchedUpdates`，造成的后果，就是由React控制的事件处理过程setState`不会同步更新`this.state。

## setState 源码

```javascript
// setState方法入口如下:
ReactComponent.prototype.setState = function (partialState, callback) {
  // 将setState事务放入队列中
  this.updater.enqueueSetState(this, partialState);
  if (callback) {
    this.updater.enqueueCallback(this, callback, 'setState');
  }};
```


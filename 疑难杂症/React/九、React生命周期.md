# 九、React生命周期

[React](https://so.csdn.net/so/search?q=React&spm=1001.2101.3001.7020) 16之后有三个生命周期被废弃：

- componentWillMount
- componentWillReceiveProps
- componentWillUpdate

因为这些[生命周期](https://so.csdn.net/so/search?q=生命周期&spm=1001.2101.3001.7020)方法容易被误解和滥用。

**React 16.8+的生命周期分为三个阶段，分别是挂载阶段、更新阶段、卸载阶段。**

### 挂载阶段

- constructor: 构造函数，最先被执行,我们通常在构造函数里初始化`state`对象或者给自定义方法绑定`this`
- getDerivedStateFromProps: `static getDerivedStateFromProps(nextProps, prevState)`，这是个静态方法,当我们接收到新的属性想去修改`state`，可以使用`getDerivedStateFromProps`
- render: `render`函数是纯函数，只返回需要渲染的东西，不应该包含其它的业务逻辑,可以返回原生的DOM、React组件、Fragment、Portals、字符串和数字、Boolean和null等内容
- componentDidMount: 组件装载之后调用，此时可以获取到DOM节点并操作，比如对canvas，svg的操作，服务器请求，订阅都可以写在这个里面，但是记得在`componentWillUnmount`中取消订阅。

### 更新阶段

- getDerivedStateFromProps: 此方法在更新个挂载阶段都可能会调用
- shouldComponentUpdate: `shouldComponentUpdate(nextProps, nextState)`，有两个参数`nextProps`和`nextState`，表示新的属性和变化之后的`state`，返回一个布尔值，`true`表示会触发重新渲染，`false`表示不会触发重新渲染，默认返回`true`,我们通常利用此生命周期来优化React程序性能
- render: 更新阶段也会触发此生命周期
- getSnapshotBeforeUpdate: `getSnapshotBeforeUpdate(prevProps, prevState)`，这个方法在`render`之后，`componentDidUpdate`之前调用，有两个参数`prevProps`和`prevState`，表示之前的属性和之前的`state`，这个函数有一个返回值，会作为第三个参数传给`componentDidUpdate`，如果你不想要返回值，可以返回null，此生命周期必须与`componentDidUpdate`搭配使用
- componentDidUpdate: `componentDidUpdate(prevProps, prevState, snapshot)`，该方法在`getSnapshotBeforeUpdate`方法之后被调用，有三个参数`prevProps`，`prevState`，`snapshot`，表示之前的props，之前的state，和snapshot。第三个参数是`getSnapshotBeforeUpdate`返回的,如果触发某些回调函数时需要用到 DOM 元素的状态，则将对比或计算的过程迁移至`getSnapshotBeforeUpdate`，然后在 `componentDidUpdate`中统一触发回调或更新状态。

### 卸载阶段

- componentWillUnmount: 当组件被卸载或者销毁了就会调用，我们可以在这个函数里去清除一些定时器，取消网络请求，清理无效的DOM元素等垃圾清理工作。
  ![在这里插入图片描述](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzE2NTI1Mjc5,size_16,color_FFFFFF,t_70.png)
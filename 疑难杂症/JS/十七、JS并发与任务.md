# 十七、JS并发模型与事件循环

[toc]

参考资料：

> 1. https://zhuanlan.zhihu.com/p/78113300
> 2. https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/EventLoop
> 3. https://www.cnblogs.com/xingguozhiming/p/13276725.html

## 一、事件循环消息队列和微任务宏任务

### 1. 事件循环与消息队列

JS是单线程编程语言，它的代码是一行一行执行的，前面没有执行完成是不会执行后面的代码的。

- 同步和异步的区别其实就在于需不需要排队的问题

  - 同步：所有任务一视同仁，都得排队，先来后到；
  - 异步：可以按照一定规则（不至于乱套）插队执行；

- 事件循环和消息队列怎么理解

  - 事件循环：单线程脚本语言javascript处理任务的一种执行机制，通过循环来执行任务队列里的任务。这个执行过程形象的称之为事件循环
  - 消息队列：js为单线程脚本语言，执行任务时需要排队，每当有新的任务来临时就加到这个队列后面。这个队列就叫消息队列或者任务队列

### 2. 浏览器事件循环过程

当某个宏任务执行完后,会查看是否有微任务队列。  

如果有，先执行微任务队列中的所有任务， 

如果没有，会读取宏任务队列中排在最前的任务，执行宏任务的过程中，遇到微任务，

依次加入微任务队列。  栈空后，再次读取微任务队列里的任务，依次类推。

### 3. 微任务与宏任务

在js中，任务可以分为同步任务和异步任务，也可以分为微任务和宏任务。同步任务属于宏任务，有了这些划分，就可以保证所有任务都有条不紊的执行下去，总的来说就是给要执行的任务定了执行规则、划分了优先级。

- 可能存在异步执行的情况
  1. 回调函数 callback
  2. Promise/async await
  3. Generator 函数
  4. 事件监听
  5. 发布/订阅
  6. 计时器
  7. requestAnimationFrame
  8. MutationObserver
  9. process.nextTick
  10. I/O
- 宏任务：
  - 所有的同步任务
  - I/O, 比如文件读写、数据库数据读写等等
  - [window.setTimeout](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/setTimeout)
  - [window.setInterval](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/setInterval)
  - [window.setImmediate](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/setImmediate)
  - [window.requestAnimationFrame](https://developer.mozilla.org/zh-CN/docs/Web/API/window/requestAnimationFrame)
- 微任务：
  - [Promise.then catch finally](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Promise)
  - [Generator 函数](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Generator)
  - [async await](https://es6.ruanyifeng.com/#docs/async) 和promise是一样的，属于微任务
  - [MutationObserver](https://developer.mozilla.org/zh-CN/docs/Web/API/MutationObserver)
- 注：
  - [process.nextTick](http://nodejs.cn/api/process.html#process_process_nexttick_callback_args)(它指定的任务总是发生在所有异步任务之前)，网上几乎无一例外说这是微任务，可是只要存在这个，process.nextTick就会在所有异步任务执行之前执行
  - 事件监听, 比如addeventlistener。宏任务待验证
  - 发布/订阅 宏任务待验证
  - 有人说同步任务属于宏任务，关于这中说法我觉得不太准确，应该说同步任务的执行优先级是高于异步任务
- **任务执行过程**
  1. 所有任务都在主进程上执行，异步任务会经历2个阶段 Event Table和Event Queue
  2. 同步任务在主进程排队执行，异步任务（包括宏任务和微任务）在事件队列排队等待进入主进程执行
  3. 遇到宏任务推进宏任务队列，遇到微任务推进微任务队列（宏任务队列的项一般对应一个微任务队列，有点像一个大哥带着一群小马仔，这就组成一组异步任务。如果有嵌套那就会有多个大哥小马仔）
  4. 执行宏任务，执行完宏任务，检查有没有当前层的微任务（大哥带着小马仔逐步亮相。。。）
  5. 继续执行下一个宏任务，然后执行对应层次的微任务，直到全部执行完毕（下一个大哥带着他的小马仔亮相。。。）

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/23744478-43a2aeb9fe47b636.png" alt="23744478-43a2aeb9fe47b636" style="zoom:50%;" />

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/23744478-4d8b4c2aaa09dcdf.png" alt="23744478-4d8b4c2aaa09dcdf" style="zoom:50%;" />

```javascript
console.log('1') //主进程 执行 
setTimeout(function () {
  console.log('2')   //因为setTimeout是宏任务，所以加入宏任务队列1，['2']
  process.nextTick(function () {
    console.log('3') //因为 process.nextTick是微任务，所以加入微任务队列2，['4','3']
  })
  new Promise(function (resolve) {
    console.log('4') //因为此处代码执行不属于异步，所以直接推入主程序执行，['4']
    resolve()
  }).then(function () {
    console.log('5') // 因为promise then 是微任务，所以推入微任务队列2,['4','3','5']
  })
}, 0)
// process.nextTick总是发生在所有异步任务之前
process.nextTick(function () {
  console.log('6')  //因为process.nextTick是微任务，所以推入微任务队列1,['6']
  new Promise(function (resolve) {
    console.log('7')//因为此处代码执行不属于异步，所以直接推入主程序执行，['6','7']
    resolve()
  }).then(function () {
    console.log('8')//因为 promise then 是微任务，所以推入微任务队列1,['6','7','8']
  })
  setTimeout(function () {
    console.log('9')//因为setTimeout是宏任务，所以推入宏任务队列2 ，['9']
    process.nextTick(function () {
      console.log('10')//因为process.nextTick是微任务，所以推入微任务队列3，['9','11','12','10']
    })
    new Promise(function (resolve) {
      console.log('11')//因为此处代码执行不属于异步，所以直接推入主程序执行,['9','11']
      resolve()
      console.log('12')////因为此处代码执行不属于异步，所以直接推入主程序执行,['9','11','12']
    }).then(function () {
      console.log('13')//因为 promise then 是微任务，所以推入微任务队列3,['9','11','12','10','12']
    })
  }, 0)
})
```

结果：

```javascript
//打印输出
// 1
// 6
// 7
// 8
// 2
// 4
// 3
// 5
// 9
// 11
// 12
// 10
// 13
```

### 4. 练习题

字节笔试题

```javascript
async function async1() {        
  console.log('async1 start');
  await async2();
  console.log('async1 end');
}
async function async2() {
  console.log('async2'); 
}

console.log('script start'); 
setTimeout(function() {
    console.log('setTimeout');
}, 0);  
async1();
new Promise(function(resolve) {
    console.log('promise1');
    resolve();
  }).then(function() {
    console.log('promise2');
});
console.log('script end');
```

结果：

```
script start
async1 start
async2
promise1
script end
async1 end
promise2
setTimeout
```

## 做题技巧

主任务 > 微任务 > 宏任务 

function > async function > awit > promise > promise then > setTimeout

1. 首先考虑最外层的console.log（主进程）
2. 遇到setTimeout放到最后。（宏任务）
3. 然后考虑async修饰的函数（微任务）
   1. async函数内部先执行await之前的。(微任务内的主进程)
   2. 进入await内部代码，将await跑完。
   3. 跑完看看有没有Promise。
   4. Promise之后考虑Promise then
   5. Promise then 之后看setTimeout

## 面试题

事件循环：js是单线程的，但是又需要一种机制来处理多个块的执行，
且执行每个块时调用js引1擎，这种机制称为事件循环，与事件绑定概念毫无关系

事件循环分了部分：主线程、宏队列、微队列，异步代码都会被丢进宏/微队列

宏任务：script, setTimeout, setInterval, set Immeditate, I/0, UI rendering

微任务：process.nextTick, promise. then(), objgct.observe, Mutationobserver

主线程只有一个，且执行顺序为：

1. 先执行主线程
2. 遇到宏任务放到宏队列
3. 遇到微任务放到微队列
4. 主线程执行完毕
5. 执行微队列，微队列执行完毕
6. 执行一次宏队列的任务，执行完毕
7. 执行微队列，执行完毕
8. 依次循环

# 十四、Promise基础

[toc]

## 一、Promise最小实例

下面是模拟肯德基吃饭的事情，使用 `promise` 操作异步的方式每个阶段会很清楚

```javascript
let kfc = new Promise((resolve, reject) => {
  console.log("肯德基厨房开始做饭");
  resolve("我是肯德基，你的餐已经做好了");
});
let dad = kfc.then(msg => {
  console.log(`收到肯德基消息: ${msg}`);
  return {
    then(resolve) {
      setTimeout(() => {
        resolve("孩子，我吃了两秒了，不辣，你可以吃了");
      }, 2000);
    }
  };
});
let son = dad.then(msg => {
  return new Promise((resolve, reject) => {
    console.log(`收到爸爸消息: ${msg}`);
    setTimeout(() => {
      resolve("妈妈，我和向军爸爸吃完饭了");
    }, 2000);
  });
});
let ma = son.then(msg => {
  console.log(`收到孩子消息: ${msg},事情结束`);
});
```

## 二、异步状态

- 一个 `promise` 必须有一个 `then` 方法用于处理状态改变

### 状态说明

Promise包含`pending`、`fulfilled`、`rejected`三种状态

- `pending` 指初始等待状态，初始化 `promise` 时的状态
- `resolve` 指已经解决，将 `promise` 状态设置为`fulfilled`
- `reject` 指拒绝处理，将 `promise` 状态设置为`rejected`
- `promise` 是生产者，通过 `resolve` 与 `reject` 函数告之结果
- `promise` 非常适合需要一定执行时间的异步任务
- 状态一旦改变将不可更改

promise 是队列状态，就像体育中的接力赛，或多米诺骨牌游戏，状态一直向后传递，当然其中的任何一个promise也可以改变状态。

```javascript
new Promise((resolve, reject) => {}) // Promise { <pending> }
new Promise((resolve, reject) => {
  reject("rejected");
}) //Promise {<rejected>: "rejected"}
```

`promise` 创建时即立即执行即同步任务，`then` 会放在异步微任务中执行，需要等同步任务执行后才执行。

```javascript
let promise = new Promise((resolve, reject) => {
  resolve('3');
  console.log('1');
});
promise.then(msg => {console.log(msg);})
console.log('2'); // 1 2 3
```

下例在三秒后将 `Promise` 状态设置为 `fulfilled` ，然后执行 `then` 方法

```javascript
let p = new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve('fullfilled');
  }, 3000);
}).then(
  msg => {
    console.log(msg);
  },
  error => {
    console.log(error);
  }
)
```

状态被改变后就不能再修改了，下面先通过`resolve` 改变为成功状态，表示`promise` 状态已经完成，就不能使用 `reject` 更改状态了

```javascript
let p = new Promise((resolve, reject) => {
  setTimeout(() => {
    // resolve('fullfilled');
    reject(new Error('请求失败'));
  }, 3000);
}).then(
  msg => {
    console.log(msg);
  },
  error => {
    console.log('myerror: ' + error);
  }
)
```

当promise做为参数传递时，需要等待promise执行完才可以继承，下面的p2需要等待p1执行完成。

- 因为`p2` 的`resolve` 返回了 `p1` 的promise，所以此时`p2` 的`then` 方法已经是`p1` 的了
- 正因为以上原因 `then` 的第一个函数输出了 `p1` 的 `resolve` 的参数

```javascript
const p1 = new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve('操作成功');
  }, 2000);
});

const p2 = new Promise((resolve, reject) => {
  resolve(p1);
}).then(
  msg => {
    console.log(msg);
  },
  error => {
    console.log(error);
  }
);
```

### 总结：Promise then的三种方式

第一种

```javascript
const p = new Promise((resolve, reject) => {
  resolve('操作完成');
})
const t = p.then(msg => {
  console.log(msg);
})
```

第二种

```javascript
const p = new Promise((resolve, reject) => {
  resolve('操作完成');
}).then(msg => {
  console.log(msg);
})
```

第三种

```javascript
const p1 = new Promise((resolve, reject) => {
  resolve('操作完成');
});
const p2 = new Promise((resove, reject) => {
  resove(p1)
}).then(
  msg => { console.log(msg); }
)
```

## async await

### 1. 最简例子

````javascript
function myPromise() {
  return new Promise((resolve, reject) => {
    let sino = parseInt(Math.random() * 6 + 1)
    setTimeout(() => {
      resolve(sino)
    }, 3000)
  })
}
async function myTest() {
  let rs = await myPromise();
  console.log(rs);
}
myTest();
````

# 面试题

## 1、es7里面async/await有使用过吗？

https://www.jianshu.com/p/876aae475b0b

1. async/await可以说是生成器函数的语法糖。用更加清晰的语义解决js异步代码。
2. Promise.then 嵌套问题
3. 解决方案：生成器函数 function* yield
4. async await
5. async返回值
6. async/Promise 异常处理

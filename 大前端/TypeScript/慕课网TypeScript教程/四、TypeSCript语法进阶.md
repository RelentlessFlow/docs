# 四、TypeScript语法进阶

[toc]

## 一、联合类型和类型保护

### 1、interface/联合类型保护

通过判断对象内部某个属性来判断

例子：

```typescript
interface Bird {
  fly: boolean;
  sing: () => {};
}

interface Dog {
  fly: boolean;
  bark: () => {}
}

function trainAnimal(animal: Bird | Dog) { // 一
  if(animal.fly) {
    (animal as Bird).sing()
  } else {
    (animal as Dog).bark()
  }
}

function trainAnimalSecond(animal: Bird | Dog) { // 二
  if('sing' in animal) {
    animal.sing();
  } else {
    animal.bark();
  }
}

class NumberObj {
  count!: number;
}

function addThird(first: object | NumberObj2, second: object | NumberObj2) {
  if('count' in first && 'count' in second) { // 三
    return first.count + second.count
  }else {
    return 0
  }
}
```

### 2、class类型保护（instanceof）

例子：

```typescript
class NumberObj {
  count!: number;
}

function addSecond(first: object | NumberObj, second: object | NumberObj) {
  if(first instanceof NumberObj && second instanceof NumberObj) {
    return first.count + second.count;
  }
  return 0;
}
```

## 二、enum

enum相当于一个常量KEY MAP数组，默认KEY的VALUE为number形的数组下标

```
enum Status {
  OFFLINE
  ONLINE
  DELETED
}
console.log(Status.OFFLINE === 0) // true
```

也可以手动设置value的值

```
enum Status {
  OFFLINE = 'offline',
  ONLINE = 'online',
  DELETED = 'deleted'
}
console.log(Status.OFFLINE === 'offline') // true
```

## 三、泛型

简单例子

```typescript
class DataManager<T extends number | string> {
  constructor(private data: T[]) {}
  getItem(i: number): T {
    return this.data[i];
  }
}
const data1 = new DataManager([1]);
const data2 = new DataManager<string>(["1"])
```

## 四、命名空间

例子：

```typescript
namespace Components {
  export namespace SubComponents { // 子命名空间
    export class Test {}
  }

  export interface User {
    name: string
  }

  export class Headers {
    constructor() {
      const ele = document.createElement('div');
      ele.innerHTML = 'This is Header'
      document.body.appendChild(ele)
    }
  }
  
  export class Content {
    constructor() {
      const ele = document.createElement('div');
      ele.innerHTML = 'This is Content'
      document.body.appendChild(ele)
    }
  }
  
  export class Footer {
    constructor() {
      const ele = document.createElement('div');
      ele.innerHTML = 'This is Footer'
      document.body.appendChild(ele)
    }
  }
}
```

```typescript
///<reference path="./components.ts" />

namespace Home {
  const user: Components.User = {
    name: '张三'
  }
  export class Page {
    constructor() {
      new Components.Headers()
      new Components.Content()
      new Components.Footer()
    }
  }
}

```

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
  <script src="./build/page.js"></script>
</head>
<body>
  <script>
    new Home.Page()
  </script>
</body>
</html>
```

配置文件：

```
"outFile": "./build/page.js",
"outDir": "./dist",
"module": "amd",    
"rootDir": "./src",           
```

## 五、import模块化

1. 定义模块

```typescript
export class Headers {
  constructor() {
    const ele = document.createElement("div");
    ele.innerHTML = "This is Header";
    document.body.appendChild(ele);
  }
}

export class Content {
  constructor() {
    const ele = document.createElement("div");
    ele.innerHTML = "This is Content";
    document.body.appendChild(ele);
  }
}

export class Footer {
  constructor() {
    const ele = document.createElement("div");
    ele.innerHTML = "This is Footer";
    document.body.appendChild(ele);
  }
}
```

```typescript
import { Headers, Content, Footer } from "./components";

export default class Page {
  constructor() {
    new Headers();
    new Content();
    new Footer();
  }
}
```

使用 tsc编译后的打包文件如下：

```javascript
// ...
define("page", ["require", "exports", "components"], function (require, exports, components_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    class Page {
        constructor() {
            new components_1.Headers();
            new components_1.Content();
            new components_1.Footer();
        }
    }
    exports.default = Page;
});
```

该代码为require.js模块语法，需要使用require.js解析

2. 解析编译后的代码

```html
<head>
  <script src="https://cdn.bootcdn.net/ajax/libs/require.js/2.3.6/require.js"></script>
  <script src="./build/page.js"></script>
</head>
<body>
  <script>
    require(['page'], function(page) {
      new page.default()
    })
  </script>
</body>
```

## 六、使用Parcel简化打包流程

parcel相当于一个小型的自动化的Webpack

安装：`sudo npm install parcel -g `

命令：`"start": parcel index.html`

使用Parcel可以直接引入TS文件

```html
<head><script src="./src/page.ts"></script></head>
```


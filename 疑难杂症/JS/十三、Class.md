# 十三、Class

[toc]

## 一、Class与prototype

#### 1. 方法定义

```javascript
class User {
	constructor(name) {
		this.name = name;
	}
	/* 等于
	User.prototype.show = function() {
		console.log(this.name);
	}
	*/
	show() {
		console.log(this.name);
	}
}
const u = new User();
```

#### 2. 属性定义

```javascript
class User {
  site = 'site';
  constructor(name) {
    this.name = name;
  }
  show() {
    console.log(`name: ${this.name}, site: ${this.site}`)
  }
}
const u = new User('user');
console.log(u.show());  // user
```

#### 3. `class` 中定义的方法不能枚举

```javascript
class User {
  constructor(name) {
    this.name = name;
  }
  show() {console.log(this.name);}
}

// [ 'constructor', 'show' ]
console.log(Object.getOwnPropertyNames(User.prototype));

const u = new User('User');
u.show(); // User
```

4. `class` 默认使用`strict` 严格模式执行

## 二、 静态访问

#### 1. 静态属性

静态属性即为类设置属性，而不是为生成的对象设置。

```javascript
function User() {}
User.site = '后盾人';
// [Function: User] { site: '后盾人' }
console.dir(User);
console.log(User.site); // 后盾人

const u = new User();
console.log(u.site); // undefined
```

在 `class` 中为属性添加 `static` 关键字即声明为静态属性

```javascript
class Request {
  static HOST = 'https://www.houdunren.com';
  query(api) {
    return Request.HOST + '/' + api;
  }
}

let requst = new Request();
```

#### 2. 静态方法

```javascript
class Request {
  static #host = 'https://www.houdunren.com';
  static query(api) {
    return this.#host + '/' + api;
  }
}

console.log(Request.query());
```

#### 3. 访问器

有点Object.definePropert语法糖那味

```javascript
class User {
  constructor(name) {
    this.data = { name };
  }
  get name() {
    return this.data.name;
  }
  set name(value) {
    if (value.trim() == "") throw new Error("invalid params");
    this.data.name = value;
  }
}
let hd = new User("向军大叔");
hd.name = "后盾人";
console.log(hd.name);
```

### 3. 访问控制

#### 1）public

`public` 指不受保护的属性，在类的内部与外部都可以访问到

```javascript
class User {
  url = "houdunren.com";
  constructor(name) {
    this.name = name;
  }
}
let hd = new User("后盾人");
console.log(hd.name, hd.url);
```

`protected`是受保护的属性修释，不允许外部直接操作，但可以继承后在类内部访问。有以下几种方式定义

##### （1）命名保护

将属性定义为以 `_` 开始，来告诉使用者这是一个私有属性，请不要在外部使用。

```javascript
class Article {
  _host = "https://houdunren.com";

  set host(url) {
    if (!/^https:\/\//i.test(url)) {
      throw new Error("网址错误");
    }
    this._host = url;
  }
  
  lists() {
    return `${this._host}/article`;
  }
}
let article = new Article();
console.log(article.lists()); //https://houdunren.com/article
article.host = "https://hdcms.com";
console.log(article.lists()); //https://hdcms.com/article
```

继承时是可以使用的

##### （2）Symbol

下面使用 `Symbol`定义私有访问属性，即在外部通过查看对象结构无法获取的属性

```javascript
const protecteds = Symbol();
class Common {
  constructor() {
    this[protecteds] = {};
    this[protecteds].host = "https://houdunren.com";
  }
  set host(url) {
    if (!/^https?:/i.test(url)) {
      throw new Error("非常网址");
    }
    this[protecteds].host = url;
  }
  get host() {
    return this[protecteds].host;
  }
}
class User extends Common {
  constructor(name) {
    super();
    this[protecteds].name = name;
  }
  get name() {
    return this[protecteds].name;
  }
}
let hd = new User("后盾人");
hd.host = "https://www.hdcms.com";
// console.log(hd[Symbol()]);
console.log(hd.name);
```

##### （3）WeakMap

https://doc.houdunren.com/js/12%20%E7%B1%BB.html#protected

#### 2）private

`private` 指私有属性，只在当前类可以访问到，并且不允许继承使用

- 为属性或方法名前加 `#` 为声明为私有属性
- 私有属性只能在声明的类中使用

下面声明私有属性 `#host` 与私有方法 `check` 用于检测用户名

```javascript
class User {
  //private
  #host = "https://houdunren.com";
  constructor(name) {
    this.name = name ;
    this.#check(name);
  }
  set host(url) {
    if (!/^https?:/i.test(url)) {
      throw new Error("非常网址");
    }
    this.#host = url;
  }
  get host() {
    return this.#host;
  }
  #check = () => {
    if (this.name.length <= 5) {
      throw new Error("用户名长度不能小于五位");
    }
    return true;
  };
}
let hd = new User("后盾人在线教程");
hd.host = "https://www.hdcms.com";
console.log(hd.host);
```

## 三、继承

### 继承内置类

使用原型扩展内置类

```javascript
function Arr(...args) {
  args.forEach(item => this.push(item));
  this.first = function() {
    return this[0];
  };
  this.max = function() {
    return this.data.sort((a, b) => b - a)[0];
  };
}
let a = [1, 23];
Arr.prototype = Object.create(Array.prototype);
let arr = new Arr("后盾人", 2, 3);
console.log(arr.first());
```

使用`class`扩展内酯类

```javascript
class NewArr extends Array {
  constructor(...args) {
    super(...args);
  }
  first() {
    return this[0];
  }
  add(value) {
    this.push(value);
  }
  remove(value) {
    let pos = this.findIndex(curValue => {
      return curValue == value;
    });
    this.splice(pos, 1);
  }
}
let hd = new NewArr(5, 3, 2, 1);
console.log(hd.length); //4
console.log(hd.first()); //5

hd.add("houdunren");
console.log(hd.join(",")); //5,3,2,1,houdunren

hd.remove("3");
console.log(hd.join(",")); //5,2,1,houdunren
```

### mixin

关于`mixin` 的使用在原型章节已经讨论过，在`class` 使用也是相同的原理

`JS`不能实现多继承，如果要使用多个类的方法时可以使用`mixin`混合模式来完成。

- `mixin` 类是一个包含许多供其它类使用的方法的类
- `mixin` 类不用来继承做为其它类的父类

```javascript
const Tool = {
  max(key) {
    return this.data.sort((a, b) => b[key] - a[key])[0];
  }
};

class Lesson {
  constructor(lessons) {
    this.lessons = lessons;
  }
  get data() {
    return this.lessons;
  }
}

Object.assign(Lesson.prototype, Tool);
const data = [
  { name: "js", price: 100 },
  { name: "mysql", price: 212 },
  { name: "vue.js", price: 98 }
];
let hd = new Lesson(data);
console.log(hd.max("price"));
```


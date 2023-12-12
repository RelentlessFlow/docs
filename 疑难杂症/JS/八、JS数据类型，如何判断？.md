# 八、JS数据类型，如何判断？

[toc]

## 一、JS有哪些数据类型？

基本数据类型：

String、Number、Boolean、Symbol、undefined、Null

引用数据类型：

Object，Array，Function，Date，FormData，Set，Map

## 二、JS如何判断数据类型？

```
// typeof
typeof array; // object 
// toString.call()
const type = Object.prototype.toString.call(array);
console.log(type); // [object Array]
```

其他toString.call()案例可以参考`五`中call应用场景的部分。

## 三、面试相关

#### 1. JS判断数据类型的场景？

根据接口返回类型参数做区别处理。

#### 2. JS中的数据类型？

基本数据类型: String 、Number、Boolean、Symbol、undefined、Null
引用数据类型: Object、 Array、Function

#### 3. JS中判断类型的方式？

**一、typeof**

- 优点：使用简单
- 缺点：功能残缺，只能用来判断6种数据类型：string，number，boolean，undefined，symbol，function，对Object派生类型都判断为object。

**二、Object.prototype.toString.call**

- 优点：适用于判断所有数据类型
- 缺点：使用烦碎，但这不是JS的问题

**三、instanceof（排除）**

instanceof 运算符用于检测构造函数的prototype属性是否出现在某个实例对象的原型链上

## 补充！！！

帖子：**JS的instanceof到底是有多坑？**

> 出处：https://www.imooc.com/article/69870

### typeof

> typeof操作符返回一个字符串，表示未经计算的操作数的类型。

就这么几种类型: number、 boolean、 string、 object、 undefined、 function、symbol。（七种）

```javascript
typeof 1 // "number"
typeof '1' // "string"
typeof true // "boolean"
typeof Symbol(1) // "symbol"
typeof {} // "object"
typeof [] // "object"，小坑
typeof function(){} // "function"
typeof Symbol(1) // "symbol"
typeof undefined // "undefined"
typeof null // "object"，出名的坑
```

对于null->"object"的问题，仅仅typeof无解，记住有这么个坑即可。

而关于array->"object"的问题，建议使用：`Array.isArray([]) // true`来判断即可。

### instanceof

> instanceof 运算符用来测试一个对象在其原型链中是否存在一个构造函数的 prototype 属性。

涉及的构造函数有这些：

基础类型：String、Number、Boolean、Undefined、Null、Symbol；

复杂类型：Array，Object；

其他类型：Function、RegExp、Date。

语法：[对象] instanceof [构造函数]，如：

```javascript
let obj = new Object()
obj instanceof Object // true
```

注意左侧必须是对象（object），如果不是，直接返回false，具体见基础类型。

### 基本类型

```javascript
let num = 1
num instanceof Number // false

num = new Number(1)
num instanceof Number // true
```

明明都是num，而且都是1，只是因为第一个不是对象，是基本类型，所以直接返回false，而第二个是封装成对象，所以true。

这里要严格注意这个问题，有些说法是检测目标的`__proto__`与构造函数的`prototype`相同即返回true，这是不严谨的，检测的一定要是对象才行，如：

```javascript
et num = 1
num.__proto__ === Number.prototype // true
num instanceof Number // false

num = new Number(1)
num.__proto__ === Number.prototype // true
num instanceof Number // true

num.__proto__ === (new Number(1)).__proto__ // true
```

上面例子可以看出，1与new Number(1)几乎是一样的，只是区别在于是否封装成对象，所以instanceof的结果是不同的。

string、boolean等，这些基础类型一样的。

> new String(1)与String(1)是不同的，new是封装成对象，而没有new的只是基础类型转换，还是基础类型，如下：

```
new String(1) // String {"1"}
String(1) // "1"
```

其他基础类型一样的。

复杂类型，比如数组与对象，甚至函数等，与基础类型不同。

------

### 复杂类型

```javascript
let arr = []
arr instanceof Array // true
arr instanceof Object // true
Array.isArray(arr) // true
```

首先，字面量是直接生成构造函数的，所以不会像基本类型一样两种情况，这个可以放心用。

但是上面那个问题，当然，基础类型也会有这个问题，就是与Object对比。没办法，Object在原型链的上层，所以都会返回true，如下：

```
(new Number(1)) instanceof Object // true
```

由于从下往上，比如你判断是Number，那就没必要判断是不是Object了，因为已经是Number了……

Array一个道理，不过还是建议使用isArray来专门处理数组判断。

`new Object()`与`{}`就不介绍了，一样的情况。

------

### 其他类型

```javascript
let reg = new RegExp(//)
reg instanceof RegExp // true
reg instanceof Object // true

let date = new Date()
date instanceof Date // true
date instanceof Object // true
```

除了Function，都一样，具体Function如下：

```javascript
function A() {}
let a = new A()
a instanceof Function // false
a instanceof Object // true
A instanceof Function // true
```

这里要注意，`function A() {}`相当于`let A; A = function() {}`，然后分析：

1. a是new出来，所以是经过构造，因此已经是对象，不再是函数，所以false。
2. a是经过构造的对象，返回ture没问题。
3. 如上所述，A是个函数，因此没什么概念上的问题。但是要知道`A.__proto__`即`Function.prototype`是`ƒ () { [native code] }`，这是与object以后处于原型链上层的存在，而且与object平级，检测如下：

```javascript
let obj = {}
obj.__proto__ // {constructor: ƒ, __defineGetter__: ƒ, __defineSetter__: ƒ, hasOwnProperty: ƒ, __lookupGetter__: ƒ, …}
obj.__proto__.prototype // undefined

let A = function() {}
A.__proto__ // ƒ () { [native code] }
A.__proto__.prototype // undefined
```

## 总结

### 1. typeof

支持number，boolean，string，undefined，function，symbol

基本数据类型都OK。引用类型全不行。

坑：**null > object**	array > object可以用Array.isArray([])

```javascript
typeof null // "object"，出名的坑
typeof {} // "object"
typeof [] // "object"，小坑
```

### 2. instanceof

这玩意是用来测试帝乡在原型链中是否存在一个构造函数的prototype属性。

翻译成人话就是 看看这个对象有没有**构造函数**。

坑：

1.由于基本数据类型没有构造函数，所以基本数据类型全不能用。

2.复杂类型中字面量可以生成构造函数，但是Array中还是建议用`Array.isArray`

3.不能判断普通的函数，只能判断构造函数。

```javascript
let num = 1
num instanceof Number // false
num = new Number(1)
num instanceof Number // true
```

```javascript
function A() {}
let a = new A()
a instanceof Function // false
a instanceof Object // true
A instanceof Function // true
```


# 三、JS作用域与作用域链

[toc]

## 一、JS作用域

作用域的概念：

> 作用域是在运行时代码中的某些特定部分中变量，函数和对象的可访问性，作用域决定了代码区块中变量和其他资源的可见性。

作用域分为

- 全局作用域
- 局部作用域
- 块级作用域

### 1. 全局作用域

JS一般有以下三种情形拥有全局作用域

- 所有windows对象的属性都拥有全局作用域
- 在最外层定义的变量、函数及对象。
- 所有未定义直接赋值的变量自动声明未全局作用域

JS全局作用域使用windows对象来代理。

### 2. 局部作用域

局部作用域指的就是我们的函数作用域,代指函数内部的空间。函数内部空间声明的变量无法在外部访问，例如:

```javascript
function doSomething() {
  var currentName = 'xiaohong';
}
doSomething();
console.log(currentName); // currentName is not defined
```

### 3. 块级作用域

块级作用域是指被大括号("{}")包裹住的相关联的语句的集合。例如,你可以在if后声明一段函数块形式的代码，表明当条件判断为真时，解释程序应该运行上述函数块里的代码，或者当条件判断为假时跳过执行.上述函数块里的代码。如下:

```javascript
let isPay = false;
if(isPay) {
  console.log('payment success');
}
let a = 1;
{
  let a = 2;
}
console.log(a); // 1
```

## 二、作用域链

当我们在某个函数的内部作用域中查找某个变量时，如果没有找到就会到他的父级作用域中查找,如果父级也没找到就会接着- -层- -层的向 上寻找，直到找到全局作用域还是没找到的话，就宣布放弃。这种一层一层的作用域嵌套关系，就是作用城链,举个例子:

```javascript
var a = 100;
function globalFun() {
  var b = 200;
  function currentFunc() {
    var c = 300;
    console.log(a);
  }
  currentFunc();
}

globalFun();
```

## 三、面试考察

- 什么是作用域?

  作用域是在运行时代码中的某些特定部分中变量，函数和对象的可访问性，作用域决定了代码区块中变量和其他资源的可见性。

- 作用域存在的意义是什么? 
  作用域存在的最大意义就是变量隔离,即:不同作用域下同名变量不会有冲突。

- 什么是作用域链?

  当我们在某个函数的内部作用域中查找某个变量时,如果没有找到就会到他的父级作用域中查找，如果父级也没找到就会接着- - 层- 层的向上寻找，直到找到全局作用域还是没找到的话，就宣布放弃。这种-层一层的作用域嵌套关系，就是作用域链。

## 四、拓展

### 1. var与let的区别

1. 使用var声明的变量，其作用域为该语句所在的函数内，且存在变量提升现象；
2. 使用let声明的变量，其作用域为该语句所在的代码块内，不存在变量提升；
3. let不允许在相同作用域内，重复声明同一个变量。

var > 函数级别作用域	let > 块级别作用域

#### （1）let配合for循环的应用

```javascript
for (let i = 0; i < 5; i++) {
  console.log(i); //0 1 2 3 4 
}
      
console.log(i); //ReferenceError: i is not defined
```

````javascript
for(var i = 0; i < 10; i++) {
  setTimeout(function() {
    console.log(i);
  }, 0)
} // 10 个 10

for(let i = 0; i < 10; i++) {
  setTimeout(function() {
    console.log(i);
  }, 0)
} // 0 1 2 3 4 5 6 7 8 9
````

#### （2）不存在变量提升

var命令会发生”变量提升“现象，即变量可以在声明之前使用，值为undefined。

let命令则不同，它所声明的变量一定要在声明后使用，否则报错。

```javascript
// var 的情况
console.log(ar); // 输出undefined
var ar = 512;
    
// let 的情况
console.log(et); // 报错ReferenceError
let et = 512;
```

上面代码中，存在全局变量tmp，但是块级作用域内let又声明了一个局部变量tmp，导致后者绑定这个块级作用域，所以在let声明变量前，对tmp赋值会报错。

ES6 明确规定，如果区块中存在let和const命令，这个区块对这些命令声明的变量，从一开始就形成了封闭作用域。凡是在声明之前就使用这些变量，就会报错。(使用const声明的是常量，在后面出现的代码中不能再修改该常量的值。)

总之，在代码块内，使用let命令声明变量之前，该变量都是不可用的。这在语法上，称为“暂时性死区”（temporal dead zone，简称 TDZ）。

#### 不允许重复声明

let不允许在相同作用域内，重复声明同一个变量。

```jsx
// 报错
function func() {
  let a = 10;
  var a = 1;
}

// 报错
function func() {
  let a = 10;
  let a = 1;
}
```

因此，不能在函数内部重新声明参数。

```jsx
function func(arg) {
  let arg; // 报错
}

function func(arg) {
  {
    let arg; // 不报错
  }
}
```

### 2. 用来实现闭包

```javascript
const makeCounter = function () {
  let privateCounter = 0;
  function changeBy(val) {
    privateCounter += val;
  }
  return {
    increment() {
      changeBy(1);
    },
    decement() {
      changeBy(-1);
    },
    value() {
      return privateCounter;
    },
  };
};
```

闭包的内容看`四、闭包`的内容。

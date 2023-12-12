# 十一、ES6（一）

[toc]

## 一. let const var

区别：

- 不存在变量提升
- 块级作用域
- 暂时性死区
- 不可重复声明
- 不会挂在window对象下面
- const 声明之后必须马上赋值，否则会报错
- const声明的简单类型不可修改，复杂类型内部可修稿

具体看`三.4 拓展`

## 二. 尖头函数和普通函数的区别

1. **外形不同**
2. **箭头函数都是匿名函数**
3. **箭头函数不能用于构造函数，不能使用new**

普通函数可以用于构造函数，以此创建对象实例。

4. 箭头函数的this指向父级作用域的this，this一旦被捕获，就不再变化。

```javascript
var webName="捕获成功";
let func=()=>{
  console.log(this.webName);
}
func();
```

代码分析：箭头函数在全局作用域声明，所以它捕获全局作用域中的this，this指向window对象。

5. **call()/apply()/bind()无法改变箭头函数中this的指向。**

6. **箭头函数结合call(),apply()方法调用一个函数时，只传入一个参数对this没有影响。**

   ```javascript
   let obj2 = {
       a: 10,
       b: function(n) {
           let f = (n) => n + this.a;
           return f(n);
       },
       c: function(n) {
           let f = (n) => n + this.a;
           let m = {
               a: 20
           };
           return f.call(m,n);
       }
   };
   console.log(obj2.b(1));  // 结果：11
   console.log(obj2.c(1)); // 结果：11
   ```

7. **箭头函数不绑定arguments，取而代之用rest参数…解决**

```javascript
function A(a){
  console.log(arguments);
}
A(1,2,3,4,5,8);  //  [1, 2, 3, 4, 5, 8, callee: ƒ, Symbol(Symbol.iterator): ƒ]


let B = (b)=>{
  console.log(arguments);
}
B(2,92,32,32);   // Uncaught ReferenceError: arguments is not defined


let C = (...c) => {
  console.log(c);
}
C(3,82,32,11323);  // [3, 82, 32, 11323]
```

8. 其他区别
   1. 箭头函数不能Generator函数，不能使用yeild关键字。
   2. 箭头函数不具有prototype原型对象。
   3. 箭头函数不具有super。
   4. 箭头函数不具有new.target。

## 三、forEach / for in / for of

### 总结

1. forEach是数组实例的方法，使用简单，不用关心下标，没有返回值，但是不能break中断循环，不能retrun返回到外层函数。
2. for in 用于循环遍历数组或对象属性，可以遍历数组的键名，遍历对象方便。
3. for of对数据结构进行遍历时，需要该数据结构实现`SymbolIteraotr`属性，被视为拥有iterator接口。
4. 可用for of遍历的对象包括**数组**，**Set**，**Map**，**类数组对象**

### JavaScript里的循环方法：forEach，for-in，for-of

> https://www.webhek.com/post/javascript-loop-foreach-for-in-for-of.html

JavaScript诞生已经有20多年了，我们一直使用的用来循环一个数组的方法是这样的：

```js
for (var index = 0; index < myArray.length; index++) {
  console.log(myArray[index]);
}
```

自从JavaScript5起，我们开始可以使用内置的[`forEach`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach)方法：

```js
myArray.forEach(function (value) {
  console.log(value);
});
```

写法简单了许多，但也有短处：你不能中断循环(使用`break`语句或使用`return`语句。

JavaScript里还有一种循环方法：`for`–`in`。

for-in循环实际是为循环”enumerable“对象而设计的：

```js
var obj = {a:1, b:2, c:3};
    
for (var prop in obj) {
  console.log("obj." + prop + " = " + obj[prop]);
}

// 输出:
// "obj.a = 1"
// "obj.b = 2"
// "obj.c = 3"
```

你也可以用它来循环一个数组：

```js
for (var index in myArray) {    // 不推荐这样
  console.log(myArray[index]);
}
```

不推荐用for-in来循环一个数组，因为，不像对象，数组的`index`跟普通的对象属性不一样，是重要的数值序列指标。

总之，`for`–`in`是用来循环带有字符串key的对象的方法。

### for-of循环

JavaScript6里引入了一种新的循环方法，它就是for-of循环，它既比传统的for循环简洁，同时弥补了forEach和for-in循环的短板。

我们看一下它的for-of的语法：

```js
for (var value of myArray) {
  console.log(value);
}
```

for-of的语法看起来跟for-in很相似，但它的功能却丰富的多，它能循环很多东西。

### for-of循环使用例子：

#### 循环一个数组(`Array`):

```js
let iterable = [10, 20, 30];

for (let value of iterable) {
  console.log(value);
}
// 10
// 20
// 30
```

我们可以使用`const`来替代`let`，这样它就变成了在循环里的不可修改的静态变量。

```js
let iterable = [10, 20, 30];

for (const value of iterable) {
  console.log(value);
}
// 10
// 20
// 30
```

#### 循环一个字符串：

```js
let iterable = "boo";

for (let value of iterable) {
  console.log(value);
}
// "b"
// "o"
// "o"
```

#### 循环一个类型化的数组(`TypedArray`)：

```js
let iterable = new Uint8Array([0x00, 0xff]);

for (let value of iterable) {
  console.log(value);
}
// 0
// 255
```

#### 循环一个`Map`:

```js
let iterable = new Map([["a", 1], ["b", 2], ["c", 3]]);

for (let [key, value] of iterable) {
  console.log(value);
}
// 1
// 2
// 3

for (let entry of iterable) {
  console.log(entry);
}
// [a, 1]
// [b, 2]
// [c, 3]
```

#### 循环一个 `Set`:

```js
let iterable = new Set([1, 1, 2, 2, 3, 3]);

for (let value of iterable) {
  console.log(value);
}
// 1
// 2
// 3
```

#### 循环一个 DOM collection

循环一个DOM collections，比如`NodeList`，之前我们讨论过[如何循环一个NodeList](http://www.webhek.com/foreach-queryselectorall-nodelist)，现在方便了，可以直接使用for-of循环：

```js
// Note: This will only work in platforms that have
// implemented NodeList.prototype[Symbol.iterator]
let articleParagraphs = document.querySelectorAll("article > p");

for (let paragraph of articleParagraphs) {
  paragraph.classList.add("read");
}
```

#### 循环一个拥有enumerable属性的对象

for–of循环并不能直接使用在普通的对象上，但如果我们按对象所拥有的属性进行循环，可使用内置的Object.keys()方法：

```js
for (var key of Object.keys(someObject)) {
  console.log(key + ": " + someObject[key]);
}
```

#### 循环一个生成器(generators)

我们可循环一个生成器([generators](https://www.webhek.com/en-US/docs/Web/JavaScript/Reference/Statements/function*)):

```js
function* fibonacci() { // a generator function
  let [prev, curr] = [0, 1];
  while (true) {
    [prev, curr] = [curr, prev + curr];
    yield curr;
  }
}

for (let n of fibonacci()) {
  console.log(n);
  // truncate the sequence at 1000
  if (n >= 1000) {
    break;
  }
}
```


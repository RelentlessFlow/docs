# 五、bind/call/apply

[toc]

## 一、bind，call，apply区别

call和bind都会立刻执行函数，apply第二个参数为数组，apply多参数的情况通过向apply函数传递多参数的方法解决。

bind会返回一个新的函数，不会立刻执行。

## 二、应用场景

### 1. Call用来判断数据类型

```javascript
typeof null // object
typeof [8]; // object
typeof {}; // object
typeof function(){}; // function
typeof 2; // number
typeof ""; // string
typeof true; // boolean
typeof undefined; // undefined
typeof Symbol(2); // symbol

[] instanceof Array;  // true
[] instanceof Object; // true
null instanceof Object // false

// toString(function(){}); = Object.prototype.toString
toString(function(){}); 
// [object Undefined]
toString.call(function(){});
// [object Function]
toString.call(null)
//"[object Null]"
toString.call([2])
"[object Array]"
toString.call(undefined)
//"[object Undefined]"
toString.call('string')
//"[object String]"
toString.call(1)
//"[object Number]"
toString.call(true)
//"[object Boolean]"
toString.call(Symbol(3))
// "[object Symbol]"
toString.call({q:8})
//"[object Object]"
```

### 2. Call类数组转数组

```javascript
const arrayLike = {
  0: 'name',
  1: 'age',
  2: 'gender',
  length: 3
}
// [ 'name', 'age', 'gender' ]
Array.prototype.slice.call(arrayLike);
```

### 3. apply求数组最大值/最小值

apply 第二个参数要求就是一个数组，特别适合函数参数本身就是一个可变参数或者数组的使用。

```javascript
const array = [1,2,3,4,5];
// Math.max(...array);
// apply第二个参数要求就是一个数组
Math.max.apply(null, array); // 5
```

### 4. bind 在 React 生命周期函数用于this绑定

实际上用尖头函数可以解决这个问题。某些事件函数在调用的时候绑定this也可以。

### 5. 在继承中call用来调用父类构造方法

请参考`二、JS原型链（二）`

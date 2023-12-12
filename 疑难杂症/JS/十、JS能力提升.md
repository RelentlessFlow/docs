# 十、JS能力提升

[toc]

## 一、多种方式实现数组拍平（三种都要记）

本质上都是判断数组内部子元素是否为数组，如果是数组，则进行数组拍平（递归），否则不是数组就对返回值的数组进行cocat。

场景：Echarts数据处理

### 1. reduce + 递归 实现

```javascript
const array = [1, 2, 3, 4, [5, 6, [7, 8, 9]]];
function flatten (array) {
  return array.reduce(function(prev, current) {
    return prev.concat(Array.isArray(current) ? flatten(current) : current)
  }, [])
}
// [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]
flatten(array);
```

### 2. 利用JS自带的flat函数实现

```javascript
const array = [1, 2, 3, 4, [5, 6, [7, 8, 9]]];
function flatten (array) {
  return array.flat(Infinity); // 层级
}
flatten(array);
```

### 3. while  + some函数

```javascript
const array = [1, 2, 3, 4, [5, 6, [7, 8, 9]]];
function flatten (array) {
  while(array.some(Array.isArray)) {
    array = [].concat(...array)
  }
  return array;
}
flatten(array);
```

## 二、如果使如下判断成立？

```html
<script>
  if(a === 1 && b === 2 && a === 3) {
    console.log('object');
  }
</script>
```

解题方法

1. a 为 window全局对象，定义全局变量
2. a每次获取值的时候都+1，通过Object.defineProperty设定的值(变量)可以设置自定义get方法。
3. 每次get 都让 a + 1

```html
<script>
  let value = 0;
  Object.defineProperty(window, 'a', {
    get() {
      return value += 1;
    }
  })
  if(a === 1 && a === 2 && a === 3) {
    console.log('object');
  }
</script>
```

## 三、new操作符

```javascript
const TMap = function(options) {
  this.name = options.name;
  this.address = options.address;
  return this;
}
const map = new TMap({
  name: 'temp',
  address: 'AD'
})
console.log(map);
```

### 自己实现一个new操作符

```javascript
function TMap (options){
  this.name = options.name;
  this.location = options.location;
  return this;
}
const ObjectFactory = (...args) => {
  // 1 构建临时对象obj
  // 2 通过参数+call返回构造函数
  // 3 通过apply函数，为obj设置原型为Constructor的原型
  // 4 通过构造函数创建实例对象，并返回给临时变量ret
  // 5 判断ret是否为对象，如果是对象，则返回ret，如果是其他类型，比如array，返回obj
  const obj = {};
  const Constructor = [].shift.call(args);
  obj.__proto__ = Constructor.proptype;
  var ret = Constructor.apply(obj, args);
  return typeof ret === 'object' ? ret : obj;
}
ObjectFactory(TMap, {name: 'Map', location: 'mylocation'});
```

### 四、实现bind/call/apply函数（不好理解）

js自带bind函数

```javascript
function origin(a, b) {
  console.log(this.name);
  console.log([a,b]);
}

const obj = { name: 'freemen' }
const func = origin.bind(obj);
func(1, 2);
```

实现bind函数（看不懂）

1. bind函数改变this指向
2. bind函数是Function.prototype 上的方法
3. bind函数的返回值也是函数
4. bind函数调用之后返回的函数的参数同样也接受处理。

```javascript
Function.prototype.bindFn = function() {
  const fn = this;
  const obj = arguments[0];
  const args = [].slice.call(arguments, 1);
  return function() {
    const returnArgs = [].slice.call(arguments);
    fn.apply(obj, args.concat(returnArgs));
  }
}
```

实现call/apply函数。。。。

### 五、实现instanceof

> 基本思路：判断实例对象`__proto__`==构造函数`prototype`，找到就继续看实例对象的原型的上一层原型。

1. 获取实例对象的隐式原型

2. 获取构造函数的prototype属性
3. while循环->在原型链上不断向上查找
4. 在原型链上不断查找构造函数的显式原型
5. 直到implicitPrototype = null 都没找到，返回false
6. 构造函数的prototype 属性出现在实例对象的原型链上返回true

```javascript
function Person() {this.name = 'freemen'}
const obj = new Person();
obj.instanceOf(Person);
function instance_of(Obj, Constrctor) {
  let implicitPrototype = Obj.__proto__;
  let displayPrototype = Constrctor.prototype;
  // while循环，在原型链上进行查找
  while(true) {
    // 直到 implicitPrototype 为空， 返回null
    if(implicitPrototype == null) {return false;}
    // 构造函数的prototype属性出现在实例对象的原型链上，返回true
    else if(implicitPrototype === displayPrototype){
      return true;
    }
    // 在原型链上不断查找 构造函数的显式原型。
    implicitPrototype = implicitPrototype.__proto__;
  }
}
```


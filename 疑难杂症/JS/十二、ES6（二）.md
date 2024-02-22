# 十二、ES6（二）

[toc]

## 一、ES6实现数组去重

1. new Set() 构造函数去重

```javascript
const array = [1,2,3,4,5,6,1,2,3];
const result = new Set(array);
console.log(result); // 返回为Set类型数组
```

2. Array.from(new Set(array)); 将set转为array

```javascript
const array = [1,2,3,4,5,6,1,2,3];
const result = Array.from(new Set(array));
console.log(result);
```

3. ... + Set 展开运算符实现

```javascript
const array = [1,2,3,4,5,6,1,2,3];
const result = [...new Set(array)];
console.log(result);
```

4. 其他ES5实现参考`第六章节`

## 二、ES6对象新增的方法

- Object.is() 判断两个值是否为[同一个值](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Equality_comparisons_and_sameness)。(比较值与数据类型)
  - 与[`==` (en-US)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators) 运算*不同。* `==` 运算符在判断相等前对两边的变量(如果它们不是同一类型) 进行强制转换 (这种行为的结果会将 `"" == false` 判断为 `true`), 而 `Object.is`不会强制转换两边的值。
  - 与[`===` (en-US)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators) 运算也不相同。 `===` 运算符 (也包括 `==` 运算符) 将数字 `-0` 和 `+0` 视为相等 ，而将[`Number.NaN`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Number/NaN) 与[`NaN`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/NaN)视为不相等.
- Object.assign() 将所有可枚举属性的值从一个或多个源对象分配到目标对象 
- Object.keys() 返回一个由一个给定对象的自身可枚举属性组成的数组
- Object.values()  返回一个给定对象自身的所有可枚举属性值的数组
- Object.entries() 返回一个给定对象自身可枚举属性的键值对数组

```javascript
const object = { name: 'freeemen', age: 18 }
// [ 'name', 'age' ]
Object.keys(object);
// [ 'freeemen', 18 ]
Object.values(object);
// [ [ 'name', 'freeemen' ], [ 'age', 18 ] ]
Object.entries(object);
```

## 三、[Object.assign () 和深拷贝 ](https://www.cnblogs.com/lijuntao/p/13066834.html)

Object.assign() 方法用于将所有可枚举属性的值从一个或多个源对象复制到目标对象。它将返回目标对象。

Object.assign(target, ...sources)    【target：目标对象】，【souce：源对象（可多个）】

### 应用场景一：合并具有相同属性的对象

```javascript
const o1 = { a: 1, b: 2, c: 1 };
const o2 = { b: 2, c: 2 }
const o3 = { c: 3 };
const obj = Object.assign({}, o1, o2, o3);
console.log(obj); // { a: 1, b: 2, c: 3 }
```

### 应用场景二：深拷贝

当对象中只有一级属性，没有二级属性的时候，此方法为深拷贝，但是对象中有对象的时候，此方法，在二级属性以后就是浅拷贝。

```javascript
function deepClone(obj) {
    if(!obj || typeof obj !== 'object') {
        return obj;
    }

    const target = Array.isArray(obj) ? [] : {};

    for(const key in obj) {
        if(obj.hasOwnProperty(key)) {
            target[key] = typeof obj[key] === 'object'
                ? deepClone(obj[key])
                : obj[key]
        }
    }

    return target;
}

export { deepClone }
```

### JS实现的深拷贝

```javascript
function deepClone(data) {
    let _data = JSON.stringify(data),
        dataClone = JSON.parse(_data);
    return dataClone;
};
```

## 其他

1. 扩展运算符...`[].concat`

ES6

```javascript
let arr = [1,2,3]; let c = [...arr];
```

ES5

```
let arr = [1,2,3]; let c = [].concat(arr);
```

2. prototype 寄生组合式继承

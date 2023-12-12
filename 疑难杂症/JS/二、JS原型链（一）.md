# 二、JS原型链（一）

[toc]

## 一、对象构造函数，原型对象，实例对象之间的关系

1. 构造函数通过 prototype属性 指向 原型对象

2. 原型对象通过 constructor属性 指向 构造函数

3. 构造函数通过 new 的形式 实例化 并 创建 实例对象

4. 实例对象通过 __proto__ 属性 指向 原型对象

```javascript
function Person(nick, age) {
  this.nick = nick;
  this.age = age;
}
Person.prototype.sayName = function() {
  console.log(this.nick);
}
const zhangsan = new Person('张三', 20);
const lisi = new Person('李四', 21);
zhangsan.sayName(); // 张三
lisi.sayName(); // 李四
console.log(zhangsan.__proto__.sayName); // 张三
console.log(zhangsan.__proto__ === Person.prototype); // true
console.log(zhangsan.__proto__ === lisi.__proto__); // true
console.log(zhangsan.__proto__.constructor === Person); // true
```

## 二、原型链继承

1. 对象属性继承

```javascript
function Person(name, age) {
    this.name = name;
    this.age = age;
  }
Person.prototype.getName = function () {console.log(this.name)}
function Teacher(name, age, subject) {
	Person.call(this, name, age); // call会执行Person构造方法
  this.subject = subject;
}
var teacher = new Teacher('jack', 15, 'Math');
console.log(teacher.age);
console.log(teacher.name);
```

2. 方法继承

`Object.create();` 会创建一个无原型对象

```javascript
Teacher.prototype = Object.create(Person.prototype);
console.log(Teacher.prototype.constructor); // [Function: Person]
```

## 三、常用API

1. `obj.__proto__` 等于`Object.getPrototypeOf(obj)`
2. `obj.__proto__.constructor`用于获取构造函数
3. `__proto__`是ES6标准，Object.getPrototypeOf(obj)是老标准，用于获取对象实例的原型。

```javascript
function User(name, age) {
  this.name = name;
  this.age = age;
}
function createByObject(obj, ...args) {
  // const constructor = Object.getPrototypeOf(obj).constructor;
  const constructor = obj.__proto__.constructor;
  return new constructor(...args);
}
let hd = new User("后盾人");
let xj = createByObject(hd, "向军", 12);
console.log(xj);
```

## 四、面试问题

### 一、什么是原型与原型链

- 原型

在javascript中，函数可以有属性。每个函数都有-一个特殊的属性叫作原型(prototype)。

- 原型链

原型链就是当我们访问对象的某个属性或方法时，如果在当前对象中找不到定义，会继续在当前对象的原型对象中查找，如果原型对象中依然没有找到，会继续在原型对象的原型中查找(原型也是对象，也有它自己的原型)如此继续，直到找到为止，或者查找到最顶层的原型对象中也没有找到，就结束查找，返回undefined。可以看出，这个查找过程是一个链式的查找，每个对象都有一个到它自身原型对象的链接，这些链接组件的整个链条就是原型链。

### 二、原型和原型链存在的意义是什么?

使得实例对象可以共享构造函数原型属性和方法,节省内存。构造函数原型上的属性和方法越多，节省内存越大.

## 补充

### 一、in与hasOwnProperty属性检测差异

- in会攀升原型链检测，hasOwnProperty只会检测实例对象本身

```javascript
let a = { url: 'houdunre' };
let b = { name: '后盾人' };
Object.prototype.web = '后盾人';
'web' in a; // true
'name' in a; // false
Object.setPrototypeOf(a, b);
console.log(a.__proto__); // { name: '后盾人' }
'name' in a; // true
a.hasOwnProperty('name'); // false


for(const key in a ){
  // 只遍历实例对象的属性
  if(a.hasOwnProperty(key)) {
    const element = object[key];
  }
}
```

### 二、isPrototypeOf 原型链检测

```javascript
let a = {}; let b = {};
Object.setPrototypeOf(a,b); // b是a的爹
console.log(b.isPrototypeOf(a)); // true
```

### 三、DOM节点借用Array原型方法

```html
<script>
    let arr = [1, 3, 43];
    let res = arr.filter(item => {
      return item > 39;
    });
    console.log(res);
    let btns = document.querySelectorAll('button');
    btns = Array.prototype.filter.call(btns, item => {
      return item.hasAttribute('class');
    });
    console.log(btns[0].innerHTML);
</script>
```

### 四、合理的构造函数声明

#### 问题：不合理的构造函数

```javascript
function User(name) {
  this.name = name;
  this.show = function() {
    console.log(this.name);
  }
}
```

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20221009182636571.png" alt="image-20221009182636571" style="zoom:80%;" />

可以看到，这样创建的函数会被绑定到每个实例对象上，会浪费内存空间。

#### 合理的做法：将共享方法绑定到prototype上

```javascript
function User(name) {
  this.name = name;
}

User.prototype.show = function() {
  console.log(this.name);
}
```

#### 如果构造函数需要定义的方法较多，可以将原型声明为一个对象

```javascript
function User(name) {
  this.name = name;
}

User.prototype = {
  constructor: User, // 记得绑定构造函数
  show() {
    console.log(this.name);
  },
  get() {
    console.log(this.name);
  }
}
```

### 五、`__proto__`

#### 1. Object.setPrototypeOf与__proto__

由于```__proto__```是ES6标准，ES5可以使用Object提供的Object.setPrototypeOf代替`__proto__= xxx`

```javascript
let hd = { name: '后盾人' }
let user = { show: function() {return this.name} }
Object.setPrototypeOf(hd, user); // 代替__proto__ = xxx
// hd.__proto__ = user;
console.log(Object.getPrototypeOf(hd)); // 代替__proto__
// console.log(hd.__proto__);
```

#### 2. `__proto__`不是一个属性

```javascript
let hd = { name: '后盾热' };
hd.__proto__ = {
  show() {
    console.log(this.name);
  }
};
hd.__proto__ = 10;
// { show: [Function: show] }
console.log(hd.__proto__);
```

可以看到直接对`__proto__`赋值是无效的，`__proto__`是一个具备getter和setter的访问器。

自定义实现proto

```javascript
let obj = {proto: {},}
Object.defineProperty(obj, 'proto', {
  get() {
    return proto;
  },
  set(obj) {
    console.log('set proto');
    if(obj instanceof Object) {
      proto = obj;
    }
  }
})
let a = {name: '张三'};
let b = {
  show: function() {
    console.log(this.name);
  }
};
Object.setPrototypeOf(a, obj);
a.proto = b;
a.proto.show.call(a, null);
```

### 六、！！！原型链可以实现JS继承与多态

#### 1. JS继承的本质是原型链的继承

```javascript
function Entity() {};
Entity.prototype = {
  constructor: Entity,
  name: 'Entity',
  id: Math.floor(Math.random()*10)
}
function Person() {}
Person.prototype.nickName = '昵称';
Person.prototype.__proto__ = Entity.prototype;

const p1 = new Person();
console.log(p1.nickName);
```

#### 2. Object.create实现继承

```javascript
function User() {}
User.prototype.show = function() {
  console.log('user.show()');
}
function Admin() {}
Admin.prototype = Object.create(User.prototype);
// Admin.prototype.constructor = Admin;

let a = new Admin();
console.log(a.constructor); // User
```

```javascript
function User() {}
User.prototype.name = function() {
  console.log('user.name()');
}
function Admin() {}
Admin.prototype = Object.create(User.prototype);
// 这样可以避免for in循环去遍历原型链的问题
Object.defineProperty(Admin.prototype, 'constructor', {
  value: Admin,
  enumerable: false
})
Admin.prototype.role = function() {
  console.log('admin.role');
}
console.log(
  Object.getOwnPropertyDescriptors(Admin.prototype)
);
let a = new Admin();
```

#### 3. 原型链实现方法重写

```javascript
function User() {}
User.prototype.show = function() {
  console.log('user.show()');
}
function Admin() {}
Admin.prototype = Object.create(User.prototype);
Admin.prototype.constructor = Admin;
Admin.prototype.show = function () {
  console.log('admin.show()');
}

let hd = new Admin();
hd.show();
```

#### 4. 对象的多态

```javascript
function User() {}
User.prototype.description = 'User';
User.prototype.show = function() {
  console.log(this.description());
}

function Admin() {}
Admin.prototype = Object.create(User.prototype);
Admin.prototype.construction = Admin;
Admin.prototype.description = function() {return '管理员'}

function Member() {}
Member.prototype = Object.create(User.prototype);
Member.prototype.construction = Member;
Member.prototype.description = function() {return '成员'}

function Enterprise() {}
Enterprise.prototype = Object.create(User.prototype);
Enterprise.prototype.construction = Enterprise;
Enterprise.prototype.description = function() {return '企业用户'}

for (const obj of [new Admin(), new Member(), new Enterprise()]) {
  obj.show();
}
```

#### 5. 在子类中使用父类构造方法

```javascript
function User(name, age) {
  this.name = name;
  this.age = age;
}

User.prototype.show = function() {
  console.log(this.name, this.age);
};

function Admin(name, age) {
  User.call(this, name, age);
}

Admin.prototype = Object.create(User.prototype);
let admin = new Admin('管理员', 18);
admin.show();
```

利用apply方法可以简化子类构造方法的调用

```javascript
function User(name, age) {
  this.name = name;
  this.age = age;
}

User.prototype.show = function() {
  console.log(this.name, this.age);
};

function Admin(...args) {
  User.apply(this, args);
}

Admin.prototype = Object.create(User.prototype);
let admin = new Admin('管理员', 18);
admin.show();
```

#### 6. 使用原型工厂封装继承

```javascript
function User() {}
function Admin() {}
function extend(sub, sup) {
  sub.prototype = Object.create(sup.prototype);
  Object.defineProperty(sub.prototype, 'constructor', {
    value: sub,
    enumerable: false
  });
}
extend(Admin, User);
User.prototype.name = function() {
  console.log('user.name');
}
Admin.prototype.role = function() {
  console.log('admin.role');
}
let a = new Admin();
a.role();
a.name();
```

#### 7. 静态方法与实例方法

##### 1)静态方法

```javascript
Person.say=function(){
    console.log('I am a Person,I can say.')
};

Person.say(); //正常运行

var carl=new Person;
carl.say(); //报错
```

我们给Person这个类添加了一个say方法，它在类上面的，所以，它实际上是一个静态方法.

静态方法：不能在类的实例上调用静态方法，而应该通过类本身调用。

类（class）通过 **static** 关键字定义静态方法。以上对Person.say方法的定义等同于：

```javascript
class Person {
  static say() {
    return console.log('I am a Person, I can say.');
  }
}
```

##### 2)实例方法

```javascript
Person.prototype.getName=function(name){
    console.log('My name is '+name);
}

Person.getName('Carl'); //报错

var carl=new Person;
carl.getName('Carl'); //正常运行
```

getName这个方法实际上是在prototype上面的，只有创建一个实例的情况下，才可以通过实例进行访问。 


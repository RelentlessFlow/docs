# 十三、JS继承（JS原型链二）

[toc]

> 参考文献：https://blog.csdn.net/lixiaosenlin/category_10312467_2.html

## 一、JS实现继承的七种方式

### 1. 原型链实现继承

直接操作原型链指向的对象，使其指向父类构造函数。

核心代码：`Son.prototype = new Father();`

```javascript
function Father(){
    this.surname = 'li'
}
 
Father.prototype.getSurname = function(){
    return this.surname;
}
 
function Son(){
    this.name = 'alvin'
}
 
//这里Son的原型对象指向了Father的实例，也就是继承了Father
Son.prototype = new Father();
 
Son.prototype.getName = function(){
    return this.name;
}
 
var son = new Son();
console.log(son.getSurname()); //输出 li
```

##### 原型链实现继承的问题：

```javascript
function Father(){
    this.colors = ['red','pink','green']
}
function Son(){}
 
//这里Son的原型对象指向了Father的实例，也就是继承了Father
Son.prototype = new Father();
 
var son1 = new Son();
son1.colors.push('yellow');
console.log(son1.colors);//输出：red,pink,green,yellow
 
var son2 = new Son();
console.log(son2.colors);//输出：red,pink,green,yellow
```

问题一：包含引用类型的原型属性被所有人共享，可以被随意修改。

问题二：在创建子类的实例时，不能向父类的构造函数中传递参数。

### 2. 借用构造函数实现继承

通过在构造函数内使用call()调用父类构造函数实现继承

核心代码`function Son() {Father.call(this);}`

```javascript
function Father() {
  this.colors = ['red', 'pink', 'green']
}

function Son() {
  Father.call(this);
}

var son1 = new Son();
son1.colors.push('yellow');

var son2 = new Son();
// [ 'red', 'pink', 'green' ]
console.log(son2.colors);
```

这种方法可以解决原型链对象属性共享被修改问题。

##### 传递参数

相对于原型链而言，借用构造函数有一个很大的优势，就是可以在子类型的构造函数中向父类型的构造函数传递参数，看下面的示例

```javascript
function Father(name) {
  this.name = name;
}

function Son() {
  Father.call(this, 'Alvin');
  this.age = 18;
}

var son = new Son();
console.log(son.name); // Alvin
console.log(son.age); // 18
```

##### 借用构造函数的问题

如果仅仅是借用构造函数，那么也将无法避免构造函数模式存在的问题：方法都在构造函数中定义，因此函数的复用就无从谈起了。而且在父类型的原型中定义的方法，对子类型而言是不可见的。因此所有类型都只能使用构造函数模式。一般情况下不建议单独使用借用构造函数技术。

⬆️ 简单的说就是 这种继承模式是基于构造函数的继承，a 通过 b的构造函数实现继承，所有被继承的属性和方法都必须定义在构造函数中，对于原型中的方法，这种继承模式是无效的。

### 3. 组合继承（构造继承+原型继承）最常用！！！

组合继承有时候也叫做伪经典继承，指的是将原型链和借用构造函数的技术组合到一起，从而发挥二者之长的一种继承模式。其思路就是使用原型链实现对原型属性和方法的继承。而通过借用构造函数来实现对实例属性的继承。这样既通过在原型上定义方法实现函数复用，又能保证每个实例都有它自己的属性。

核心代码：

- 属性继承（构造函数实现继承）

```javascript
function Son(name, age){
    //属性继承
    Father.call(this, name);
    this.age = age;
}
```

- 方法继承（原型链实现继承）

```javascript
Son.prototype = new Father();
```

### 4. 原型式继承

```javascript
function object(o){
    function F(){}
    F.prototype = 0;
    return new F();
}
```

o是想要继承的对象，F是返回的被继承的对象。

```javascript
var person = {
    name: 'Alvin',
    friends: ['Yannis','Ylu']
}
 
var p1 = object(person);
p1.name = 'Bob';
p1.friends.push('Lucy');
 
var p2 = object(person);
p2.name = 'Lilei';
p2.friends.push('Hanmeimei');
 
console.log(person.friends);//Yannis, Ylu, Lucy, Hanmeimei
```

在ECMAScript5中新增了Object.create()方法，该方法规范了原型式继承。这个方法接收两个参数：一个用作新对象原型的对象，另一个是可选的，用于新对象定义额外的属性的对象。在只传入一个参数的情况下，Object.create()与上面的object()方法行为相同。看下面示例：

```javascript
var person = {
  name: 'Alvin',
  friends: ['Yannis','Ylu']
}

var p1 = Object.create(person);
p1.name = 'Bob';
p1.friends.push('Lucy');

var p2 = Object.create(person);
p2.name = 'Lilei';
p2.friends.push('Hanmeimei');

console.log(person.friends);
```

Object.create()方法的第二个参数与Object.defineProperties()方法的第二个参数格式相同：每个属性都是通过自己的描述符定义。以 这种方式指定**任何属性**都会覆盖原型对象上的同名属性。如：

```javascript
var person = {
    name: 'Alvin',
    friends: ['Yannis','Ylu']
}
 
var p1 = Object.create(person,{
    name:{
        value:'Lucy'
    }
})
 
console.log(p1.name);//Lucy
```

##### 优缺点

- 优点：简单，只想让一个对象与另一个对象保持类似的情况下，原型式继承是完全可以考虑的。

- 缺点：包含的所有引用类型的属性始终都会共享相应的值。

在没有必要兴师动众的创建构造函数，而只想让一个对象与另一个对象保持类似的情况下，原型式继承是完全可以考虑的。当然同样的问题就是：包含的所有引用类型的属性始终都会共享相应的值。

使用建议：感觉和Object.assign差不多。。。有点类似于浅拷贝的效果。

### 5. 寄生式继承

寄生式继承是与原型式继承紧密相关的一种思路。寄生式继承的思路与寄生[构造函数](https://so.csdn.net/so/search?q=构造函数&spm=1001.2101.3001.7020)和工程模式类似，即创建一个仅用于封装继承过程的函数，该函数的内部以某种方式来增强对象，最后再像真的是它做了所有工作一样返回对象。下面的代码示范了寄生式继承的模式

```javascript
function object(o) {
  function F(){}
  F.prototype = o;
  return new F();
}

function createAnother(original) {
  var clone = object(original);
  clone.sayName = function() {
    console.log(this.name);
  }
  return clone;
}

var person = { name: 'Alvin' }
var anotherPerson = createAnother(person);
anotherPerson.sayName();
```

在主要考虑对象而不是自定义类型和构造函数的情况下，寄生式继承也是一种有用的模式。前面示范继承模式时使用的object()函数不是必须。任何能够返回新对象的函数都可以。

使用寄生式继承来为对象添加函数，会由于不能做到函数复用而降低效率；这点与构造函数模式类似。

### 6. 寄生组合式继承

##### （一）回顾组合式继承

组合继承是JavaScript中最常用的继承模式。但是他也有自己的不足。组合继承最大的问题就是不管在什么情况下，都会**调用两次父类型的构造函数：一次是在创建子类型原型的时候，另一次是在子类型内部。子类型最终会包含父类型对象的全部实例属性，**但我们不得不在调用子类型构造函数时重写这些属性。下面再来看一下组合继承的例子：

⬇：组合式继承会调用两次构造函数

```javascript
function Father(name){
  this.name = name;
  this.friends = ['Yannis','Lucy']
}

Father.prototype.sayName = function(){
  console.log(this.name);
}

function Son(name, age){
  Father.call(this,name);//第二次调用Father()
  this.age = age;
}

Son.prototype = new Father();//第一次调用Father()
Son.prototype.constructor = Son;
Son.prototype.sayAge = function(){
  console.log(this.age)
}
```

#####  （二）使用Object.create 和工厂增强组合式继承

```javascript
function Parent() {
  this.name= 'parent';
}
Parent.prototype.getName= function() {
    return this.name;
}

function ChildFactory(Parent) {
  // 这个函数可以拆成两个部分
  function F() {}
  F.prototype = Parent;
  const parent = new Parent();
  let child = Object.create(parent);
  child.getPlay = function() {
    return 'play';
  }
  child.name = 'child'
  return child;
}

let child = ChildFactory(Parent);

console.log(child.getName());
console.log(child.getPlay());
```

##### （三）ES5继承最佳实践，寄生组合继承！！！

```javascript
function Parent() {
  this.name= 'parent';
}
Parent.prototype.getName= function() {
    return this.name;
}

function Child() {
  Parent.call(this);
  this.name = 'child';
}

Child.prototype = Object.create(Parent.prototype);
Child.prototype.constructor = Child;
Child.prototype.getPlay = function() {
  return 'play';
}

const child = new Child();
console.log(child.name);
console.log(child.getName());
console.log(child.getPlay());
```

##### （四）使用原型工厂封装寄生式组合继承

```javascript
function extend(sub, sup) {
  sub.prototype = Object.create(sup.prototype);
  Object.defineProperty(sub.prototype, 'constructor', {
    value: sub, enumerable: false
  });
}
function Parent() {
  this.name= 'parent';
}
Parent.prototype.getName= function() {
    return this.name;
}
function Child() {
  Parent.call(this);
  this.name = 'child';
}
extend(Child, Parent);
Child.prototype.getPlay = function() {
  return 'play';
}
const child = new Child();
console.log(child.name);
console.log(child.getName());
console.log(child.getPlay());
```

### 7. 寄生式构造函数的语法糖class

```javascript
class Parent {
  constructor(name) {
    this.name= 'parent';
  }
  getName(){
    return this.name;
  }
}

class Child extends Parent {
  constructor(name = 'child') {
    super(name);
  }
  getPlay() {
    return 'play';
  }
}

const child = new Child();
console.log(child.name);
console.log(child.getName());
console.log(child.getPlay());
```

## 二、JS多继承（Mixin模式）

### Mixin

`JS`不能实现多继承，如果要使用多个类的方法时可以使用`mixin`混合模式来完成。

- `mixin` 类是一个包含许多供其它类使用的方法的类
- `mixin` 类不用来继承做为其它类的父类

#### 核心代码：

原型链继承：

```javascript
Object.assign(Z.prototype, 
  A.prototype, B.prototype,  C.prototype
);
```

构造函数继承：

```javascript
function Z() {
  A.call(this); B.call(this); C.call(this);
  this.zName = 'Z'
}
```

### 代码实现

```javascript
function A() {this.aName = 'A'}
A.prototype.getAName = function() {
  return this.aName;
}
function B() {this.bName = 'B'}
B.prototype.getBName = function() {
  return this.bName;
}
function C() {this.cName = 'C'}
C.prototype.getCName = function() {
  return this.cName;
}

function Z() {
  A.call(this); B.call(this); C.call(this);
  this.zName = 'Z'
}
Object.assign(Z.prototype, 
  A.prototype, B.prototype,  C.prototype
);
Z.prototype.getZName = function() {
  return this.zName;
}
const z = new Z();
// 实例继承
console.log(z.aName); // A
// 原型链继承
console.log(z.getZName()); // Z
console.log(z.getBName()); // B
```

### Super

`super` 是在 `mixin` 类的原型中查找，而不是在 `User` 原型中

#### 核心代码：

```javascript
const Credit = {
  __proto__: Request,
  total() {
    console.log(super.ajax() + ",统计积分");
  }
};
```

##### 代码实现：

```javascript
function extend(sub, sup) {
  sub.prototype = Object.create(sup.prototype);
  sub.prototype.constructor = sub;
}
function User(name, age) {
  this.name = name;
  this.age = age;
}
User.prototype.show = function() {
  console.log(this.name, this.age);
};
const Request = {
  ajax() {
    return "请求后台";
  }
};
const Credit = {
  __proto__: Request,
  total() {
    console.log(super.ajax() + ",统计积分");
  }
};
```



## 三、总结

- 原型链继承

  - ```javascript
    Son.prototype = new Father();
    ```

  - 问题

    - 包含引用类型的原型属性被所有人共享，可以被随意修改。
    - 在创建子类的实例时，不能向父类的构造函数中传递参数。

- 构造函数继承

  - ```javascript
    function Son() {
      Father.call(this);
    }
    ```

  - 问题：所有被继承的属性和方法都必须定义在构造函数中，对于原型中的方法无法继承。

- 组合继承

  - 属性继承（构造函数实现继承）方法继承（原型链实现继承）

    ```javascript
    function Son(name, age){
        //属性继承
        Father.call(this, name);
        this.age = age;
    }
    Son.prototype = new Father();
    ```

  - 最常用的JS继承方法，缺点是会执行两次构造函数。

- 原型式继承

  - ```javascript
    function object(o){
        function F(){}
        F.prototype = 0;
        return new F();
    }
    ```

  - 缺点：包含的所有引用类型的属性始终都会共享相应的值。

  - 仅适用于需要类似对象代理的场景。

- 寄生式继承

  - 通过返回对象实例的方式实现

    ```javascript
    function object(o) {
      function F(){}
      F.prototype = o;
      return new F();
    }
    
    function createAnother(original) {
      var clone = object(original);
      clone.sayName = function() {
        console.log(this.name);
      }
      return clone;
    }
    var anotherPerson = createAnother(person);
    ```

  - 通过Object.create()方式实现

    ```javascript
    function ChildFactory(origin){
      // 代替object方法
    	let child = Object.create(origin); 
    	child.getPlay = function(){
    		return this.play
    }
    let child = ChildFactory(parent)
    ```

  - 和原型式继承缺点一样，实例使用同一个原型对象，有可能会有篡改原型数据的风险。原型式继承跟原型链异曲同工，所以也难免有这样的弊端。

- 寄生组合式继承

  - 构造函数继承/原型链继承
  
    ```javascript
    function Child() {
      Parent.call(this);
      this.name = 'child';
    }
    Child.prototype = Object.create(Parent.prototype);
    Child.prototype.constructor = Child;
    ```
  
  - class中用的也是这种寄生组合式继承，推荐使用
  
- ES6 class

  - ```javascript
    class Parent {
      constructor(name) {
        this.name= 'parent';
      }
      getName(){
        return this.name;
      }
    }
    
    class Child extends Parent {
      constructor(name = 'child') {
        super(name);
      }
      getPlay() {
        return 'play';
      }
    }
    
    const child = new Child();
    console.log(child.name);
    console.log(child.getName());
    console.log(child.getPlay());
    ```
  
  - class 的本质是寄生组合式继承。
  
- Mxin 多继承模式

  - ```javascript
    Object.assign(Z.prototype, 
      A.prototype, B.prototype,  C.prototype
    );
    ```
  




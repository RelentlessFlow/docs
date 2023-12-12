# 初学者的第一行代码Android 第三版学习笔记

## 第一章 第一个Android项目

### 1. Android Studio无线调试

 	1. 开启开发者选项，打开USB调试，勾选无线调试功能
 	2. 状态栏Android Studio > Preferences > Plugins > ADB Wi-Fi > Installl > Restart
 	3. IDE右下角ADB-Wi-Fi，找到设备，Connect

### 2. Run App 遇到`Installed Build Tools revision 31.0.0 is corrupted. Remove and install again using the SDK Manager.`

1. 找到app/build.gralde，修改这几个地方

```
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'kotlin-android-extensions'
}

android {
    compileSdkVersion 30	// 改为30
    buildToolsVersion "30.0.2"  // 改为30.0.2

    defaultConfig {
        applicationId "com.example.testapplication"
        minSdkVersion 21
        targetSdkVersion 30		// 改为30
        versionCode 1
        versionName "1.0"

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
```

2. 找到状态栏Android Studio > Preferences > Appearance & Behavior > Android SDK 
3. 勾选Android 11.0（R）
4. 重新编译项目，完成

## 第二章 Kotlin快速入门

### 1. 如何运行Kotlin

1. 在包下右键new > Kotlin Class/File > LearnKotlin

   ```kotlin
   package com.example.helloworld
   class LearnKotlin {
   }
   
   fun main() {
       println("Hello World")
   }
   ```

2. 点击main左边的箭头

### 2. Kotlin变量

1. val用来声明一个不可变的变量，赋值以后就不可变了

```kotlin
fun main() {
    val a = 10;
    a = a + 1 // 会报错
}
```

2. var用来声明一个可变的变量

```kotlin
fun main() {
    val a = 10;
    a = a + 1 
}
```

3. var和val都具备自动类型推断系统，kotlin推荐在变量定义时尽量使用val，但是在某些情况，比如延迟赋值下会Kotlin无法推导，需要自行声明变量类型

4. 数据类型

   1. Kotlin抛弃了Java的基本数据类型，它为每种Java基本数据类型都创建了对象数据类型

   | Java基本数据类型 | Kotlin对象数据类型 |
   | ---------------- | ------------------ |
   | int              | Int                |
   | long             | Long               |
   | short            | Short              |
   | Float            | Float              |
   | double           | Double             |
   | boolean          | Boolean            |
   | char             | Char               |
   | byte             | Byte               |

   2. 定义一个带有类型的变量

   ```kotlin
   val sum: Int = 200
   ```

### 3. Kotlin函数

1. Kotlin如何定义一个函数？

   ```kotlin
   fun methedName(param1: Int, param2: Int): Int {
   	return 0
   }
   ```

2. 当函数只有一行代码时，可以这样写

   ```kotlin
   fun largeNumber(num1: Int, num2: Int): Int = max(num1, num2)
   ```

### 4. Kotin程序控制逻辑

1. Kotlin中条件语句包含if，when，when理解成改进的switch语句

```kotlin
fun largeNumber (num: Int, num2: Int) {
	if(num1 > num2) {
		return num1
	} else {
		retrun num2
	}
}
```

2. IF语句与Java的有部分不同，Kotlin可以允许if语句的最后一行代码作为返回值，通过Kotlin语法，可以精简为

```kotlin
fun largeNumber (num1: Int, num2: Int) = if(num1 > num2) num1 else num2
```

3. when语句类似于Java的Switch

```kotlin
fun getScore(name: String) = when (name) {
	"Tom" -> 86
	"Jim" -> 77
	"Jack" -> 95
	"Lily" -> 100
}
fun checkNumber(num: Number) = when(num) {
		is Int -> print("number is Int");	// is相当于Java的instanceof
		is Double -> print("number is Double")
		else -> print("number not suppose")
}
```

4. 独特的for-in循环

```kotlin
for (i in 0..10 step 2) {println(i)}
for (i in 0 until 10 step 2) {println(i)}
for (i in 10 downTo 0) {println(i)}
```

### 5. Kotlin面向对象

#### 定义一个类

```kotlin
class Person(val name: String,val age: Int) {
    var foods = ""
    fun eat() {
        print("$name is eating $foods.He is $age years old.")
    }
    // 方法的重载和返回值
    fun eat(foods: String) :Boolean {
        print("$name is eating ${foods}.He is $age years old.")
        return true;
    }
    fun hello() {
        print("I'm $name, $age years old!")
    }
}
```

#### 创建一个类的实例

```kotlin
val person = Person("张三",20)
```

#### 类的继承

如果您想实现继承Person类。就必须实现Person类的构造方法，并将Person添加open关键字以便设置其为可继承类。

```kotlin
oepn class Person( .....
```

```kotlin
class Student (val sno: String, val grade: Int, name :String, age :Int) 
    :Person(name,age) {
    // init用来实现主构造函数的逻辑
    init {
        print("Object is created!")
    }
    fun introductionByMySelf() {
        print("I'm $name, $age years old,My sno is $sno, I'm $grade grades!")
    }
}
```

这里可以给Person添加一个其他的构造方法用来便于子类继承使用

```kotlin
open class Person(val name: String,val age: Int) {
  .....
  constructor() : this("",20) {
        println("Person's constructor is  executed!")
    }
}
```

这样Student类就可以简化为

```kotlin
// class Student (val sno: String, val grade: Int, name :String, age :Int) :Person(name,age) 
class Student (val sno: String, val grade: Int, name :String, age :Int):Person() {
...
```

此时的Student类的构造函数默认承接Person类构造函数的name和age

其实你可以为Studuent类的构造函数设置一个默认值，这样就避免了constructor()的滥用

```kotlin
open class Person(val name: String = "张三",val age: Int = 20) {.....}
```

如果Student类不想继承Person类默认的姓名的话，你也可以实现构造方法参数的重写

首先需要对Person类构造函数中需要被“重写”的参数添加open关键字

```kotlin
open class Person(val name: String,open val age: Int = 20) { ... }
```

在Student类构造函数中需要重写的参数添加override关键字

````kotlin
// class Student (val sno: String, val grade: Int, name :String, age :Int):Person() {

class Student (val sno: String, val grade: Int, name :String,override val age :Int) 
    :Person() {
......
````

这样Student类中的成员变量age就被彻底的覆盖了，它将拥有独立的内存空间。

如果我将Student类的构造方法的参数民进行更改

```kotlin
//class Student (val sno: String, val grade: Int, name: String,override val age :Int)
	//:Person(name, age) {
class Student (val sno: String, val grade: Int, name2: String,override val age :Int)
	:Person(name, age) {
    fun introductionByMySelf() {
        print("I'm $name, $age years old,My sno is $sno, I'm $grade grades!")
    }
  }
```

你会发现name依然是传入时的参数。

我们再对构造函数进行改造

```kotlin
class Student (val sno: String, val grade: Int, name2: String, age :Int)
  :Person() {
    fun introductionByMySelf() {
        print("I'm $name, $age years old,My sno is $sno, I'm $grade grades!")
    }
}

// super class
open class Person(val name: String = "张三",open val age: Int = 20) { ...
```

你会发现name变为了Person类设置的默认值20

结合上面重写构造方法参数的例子，这说明子类构造方法传递传递的过程其实是子类构造方法的参数传递给父类构造方法

绕了一会自己都绕晕了，这里我们将代码用主构造方法和副构造方法的方式进行重写，可以得到这样的标准化代码

```kotlin
open class Person(val name: String, val age: Int) {
    fun hello() {
        print("I'm $name, $age years old!")
    }
}

class Student (val sno: String, val grade: Int, name: String, age :Int)
    :Person(name,age) {
    // init用来实现主构造函数的逻辑
    init {
        print("Object is created!")
    }
    constructor(name: String,age: Int): this("",0,name,age)
    constructor(): this("",0)
    fun introductionByMySelf() {
        print("I'm $name, $age years old,My sno is $sno, I'm $grade grades!")
    }
}

fun main() {
    val stu1 = Student("a123",3,"张三",20)
    val stu2 = Student("张三",20)
    val stu3 = Student()
}
```

我们可以使用参数默认值的特性对其进行改造

```kotlin
open class Person(val name: String = "", val age: Int = 0) {
    fun hello() = print("I'm $name, $age years old!")
}

class Student (val sno: String= "", val grade: Int= 0, name: String= "", age :Int= 0)
    :Person(name , age) {
    fun introductionByMySelf() = print("I'm $name, $age years old,My sno is $sno, I'm $grade grades!")
}

fun main() {
    val person1 = Person("张三",20)
    val person2 = Person()
    val stu1 = Student("a123",3,"张三",20)
    stu1.introductionByMySelf()
    val stu2 = Student("张三",20)
    val stu3 = Student()
}
```

这样我们的类就既精简又易读了起来。

我们还有一种特殊的构造方法使用方式没有提到，如果类中只有次构造方法，没有主构造方法。

```kotlin
open class Person(val name: String, val age: Int) {
    fun hello() = print("I'm $name, $age years old!")
}

class Student :Person {
    constructor(name: String, age: Int) : super(name, age)
}
// 等价于
class Student(name: String, age: Int) : Person(name, age) {}
```

Kotlin的继承同Java都只允许单继承，若想实现多重继承，依旧需要通过接口实现

Kotlin实现接口的关键字同继承，多重继承/实现 使用,分割

```
interface Study {
    fun readBooks()
    fun doHomework()
}

class Student(name: String, age: Int) : Study, Person(name, age) {
    override fun readBooks() {...}
    override fun doHomework() {...}
}
```

#### data关键字

data修饰过的类会自动的添加Getter和Setter方法，类似于Java的POJO（作为一个Javaer并没看出这玩意什么好用的地方，而且没有体现封装性）

```kotlin
data class Good(val name:String, val id:String)

fun main() {
    val good = Good("海尔冰箱","GA8013");
    println(good.id);
    // good.id = "GA8013" 因为构造方法命名关键字采用了val，这行代码会编译报错
}
```

你这时候可能会想Java一般不都是private然后生成getter和setter方法吗，为什么Kotlin没有这个东西。

其实Kotlin已经自动生成的了默认的Getter和Setter，并且你会发现Kotlin并不允许参数为空，你必须在定义时赋值。

```kotlin
var <propertyName>: <PropertyType> [= <property_initializer>]
  [<getter>]
  [<setter>]
```

这里类似于C#语言。如果你想要修改默认的访问器和修饰器，你可以使用这样的方式。

### 6. Kotlin作用域修饰符

Kotlin函数修饰符与Java基本一致但也有不同。

| 修饰符  | Java                               | Kotlin             |
| ------- | ---------------------------------- | ------------------ |
| public  | 所有类可见                         | 所有类可见（默认） |
| private | 当前类可见                         | 当前类可见         |
| protect | 当前类，子类，同一包路径下的类可见 | 当前类，子类可见   |
| default | 同一包路径下的类可见               | 无                 |
| interna | 无                                 | 同一模块中的类可见 |


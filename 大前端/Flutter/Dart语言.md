# Dart 语言TS开发者速通（ChatGPT）

[toc]

## 一、值类型、变量、常量

### 1. 类型

Dart是一门静态类型的编程语言，这意味着在编译时会对变量的类型进行检查。以下是Dart中的一些常见数据类型：

1. **数字类型**：
   - `int`：整数类型，可以表示整数值。例如：`int age = 30;`
   - `double`：双精度浮点数类型，用于表示带小数点的数字。例如：`double pi = 3.14;`
2. **字符串类型**：
   - `String`：字符串类型，用于表示文本数据。例如：`String name = "Alice";`
3. **布尔类型**：
   - `bool`：布尔类型，用于表示逻辑值（true或false）。例如：`bool isFlutterFun = true;`
4. **列表和集合**：
   - `List`：表示有序的列表，类似于数组。例如：`List<int> numbers = [1, 2, 3];`
   - `Set`：表示无序不重复的集合。例如：`Set<String> uniqueNames = {"Alice", "Bob", "Charlie"};`
5. **映射类型**：
   - `Map`：表示键值对映射，类似于JavaScript中的对象。例如：`Map<String, int> ageMap = {"Alice": 30, "Bob": 25};`
6. **动态类型**：
   - `dynamic`：用于表示可以存储任何类型的值。例如：`dynamic dynamicVar = "Hello";`
7. **可空类型**：
   - `Type?`：Dart 2.12及更高版本引入了可空类型，允许变量的值为空（null）。例如：`int? nullableAge = null;`
8. **枚举类型**：
   - `enum`：用于定义一组命名的常量值。例如：

```dart
enum Color { red, green, blue }
Color selectedColor = Color.blue;
```

### 2. 变量、常量

var声明变量、const、final声明常量，const主要用在局部函数内，final主要用在Class和实例化对象，final做成员变量时，可以由构造函数完成初始化。

**注意：与TS不同，const不可声明实例化对象**

#### const 用法

```dart
void main(List<String> arguments) {
  const String myString = 'hello world';
  print('${myString}!');
}
```

#### final用法

```dart
class Person {
  final String name;
  // Only static fields can be declared as const. (Documentation)
  const int age;
  Person(this.name);
}
```

与TS不同，const不能用来修饰引用数据类型，在Dart中，`const` 只能用于修饰编译时常量，而不是用于自定义类的实例。具体来说，您不能将 `const` 用于自定义类的实例，因为类的实例通常是在运行时创建的，而不是在编译时。

```dart
class Person {
  final String name;
  Person(this.name);
}

void main(List<String> arguments) {
  // Const variables must be initialized with a constant value. (Documentation)
  const person = Person("张三");
}
```

如果const非得修饰实例对象，

#### const、final区别

在Dart中，`final` 和 `const` 都用于声明不可变的变量，但它们之间有一些重要的区别：

1. `final` 变量：

   - `final` 声明的变量只能被赋值一次。一旦赋值后，其值不能再被改变。
   - `final` 变量的值可以在运行时确定，也可以在构造函数中赋值。
   - `final` 变量不要求在声明时初始化，但必须在构造函数中或在变量声明后的某个地方进行初始化。

   ```
   dartCopy codefinal int age = 30;
   final String name;
   
   MyClass(this.name); // 构造函数中初始化
   ```

2. `const` 变量：

   - `const` 声明的变量是编译时常量，其值必须在编译时确定。这意味着 `const` 变量的值必须是在编译时已知的常量表达式。
   - `const` 变量在声明时必须被初始化，不能在构造函数中赋值。它的值在编译时就已经确定，不会在运行时改变。

   ```dart
   const double pi = 3.14;
   const String greeting = "Hello, World!";
   ```

总结 `final` 和 `const` 的主要区别是：

- `final` 是运行时常量，允许在运行时确定其值。
- `const` 是编译时常量，要求在编译时确定其值，并且必须在声明时进行初始化。
- `final` 变量可以具有不同值，但只能被赋值一次。
- `const` 变量的值在编译时已知，不会改变。

### 3. 类型检查

```dart
void main(List<String> arguments) {
  String variable = "variable";
  if (variable is String) {
    print("variable 是一个字符串");
  }

  String? str = variable as String;
  if(str != null) {
    print('variable 是一个字符串');
  }

  if(variable.runtimeType == String) {
    print("variable 是一个字符串");
  }
  
  variable.runtimeType.toString(); // String
}
```

请注意，尽量避免过度使用类型检查，因为它可能暗示您的代码可能需要更好的结构。Dart的静态类型检查通常会在编译时捕获类型错误，因此应该优先考虑使用强类型来确保类型安全。只有在处理不同类型的外部数据或需要运行时动态确定类型的情况下，才应该使用类型检查。

### 4. 包装类型

在Dart中，基本数据类型和对象都是相同的，例如 `int`、`double` 和 `String` 都是类，不需要包装类型。这使得Dart代码更加简洁和直观。

### 5. 类型转化

Dart中的数据类型转换通常涉及类型转换运算符或构造函数。以下是一些常见的数据类型转换方式：

1. **整数转换为浮点数**：您可以使用 `toDouble()` 方法将整数转换为浮点数。

   ```dart
   int intValue = 42;
   double doubleValue = intValue.toDouble();
   ```

2. **浮点数转换为整数**：您可以使用 `toInt()` 方法将浮点数转换为整数。请注意，小数部分将被截断。

   ```dart
   double doubleValue = 3.14159;
   int intValue = doubleValue.toInt();
   ```

3. **字符串转换为整数或浮点数**：您可以使用 `int.parse()` 和 `double.parse()` 函数将字符串转换为整数或浮点数。

   ```dart
   String intString = "42";
   int intValue = int.parse(intString);
   
   String doubleString = "3.14159";
   double doubleValue = double.parse(doubleString);
   ```

4. **整数或浮点数转换为字符串**：您可以使用 `toString()` 方法将整数或浮点数转换为字符串。

   ```dart
   int intValue = 42;
   String intString = intValue.toString();
   
   double doubleValue = 3.14159;
   String doubleString = doubleValue.toString();
   ```

5. **字符串转换为布尔值**：在Dart中，非空的字符串被视为 `true`，空字符串被视为 `false`。

   ```dart
   String nonEmptyString = "Hello";
   bool isTrue = (nonEmptyString == true);
   
   String emptyString = "";
   bool isFalse = (emptyString == false);
   ```

## 二、String

Dart中的字符串类型是内置的，它提供了许多字符串操作方法，包括字符串连接、插值和格式化。以下是一些常见的字符串操作方法和技巧：

1. **字符串连接**：您可以使用 `+` 运算符来连接两个字符串。

   ```dart
   String firstName = "John";
   String lastName = "Doe";
   String fullName = firstName + " " + lastName; // "John Doe"
   ```

2. **字符串插值**：Dart支持字符串插值，使用`${}`来将表达式嵌入到字符串中。

   ```dart
   String name = "Alice";
   String greeting = "Hello, $name!";
   ```

3. **多行字符串**：使用三重引号 `'''` 或 `"""` 可以创建多行字符串。

   ```dart
   String multiLine = '''
     This is a
     multi-line
     string.
   ''';
   ```

4. **字符串长度**：使用 `length` 属性来获取字符串的长度。

   ```dart
   String text = "Hello, World!";
   int length = text.length; // 13
   ```

5. **字符串分割**：使用 `split` 方法来将字符串拆分为列表。

   ```dart
   String sentence = "This is a sample sentence";
   List<String> words = sentence.split(" ");
   ```

6. **字符串查找**：使用 `contains` 和 `indexOf` 方法来查找子字符串是否存在或获取其索引。

   ```dart
   String text = "Dart is fun!";
   bool containsDart = text.contains("Dart"); // true
   int indexIs = text.indexOf("is"); // 5
   ```

7. **字符串替换**：使用 `replaceAll` 或 `replaceFirst` 方法来替换字符串中的子字符串。

   ```dart
   String text = "Hello, world!";
   String newText = text.replaceAll("world", "Dart"); // "Hello, Dart!"
   ```

8. **字符串剪裁**：使用 `substring` 方法来获取字符串的子串。

   ```dart
   String text = "Dart is amazing!";
   String subtext = text.substring(5, 7); // "is"
   ```

9. **字符串大小写转换**：使用 `toLowerCase` 和 `toUpperCase` 方法来将字符串转换为小写或大写。

   ```dart
   String text = "Hello, Dart!";
   String lowercase = text.toLowerCase(); // "hello, dart!"
   String uppercase = text.toUpperCase(); // "HELLO, DART!"
   ```

10. **字符串格式化**：Dart提供了多种字符串格式化的方式，包括使用 `printf` 风格的格式化和 `String` 的 `format` 方法。还可以使用第三方库来进行更复杂的字符串格式化操作。

11. **字符串插值**：字符串插值是一种字符串操作技巧，允许您在字符串中嵌入变量或表达式的值。在Dart中，字符串插值使用`${}`语法来实现，允许将变量、表达式或函数的结果嵌入到字符串中。以下是字符串插值的示例：

    ```dart
    String name = "Alice";
    int age = 30;
    
    String greeting = "Hello, $name!"; // 基本的字符串插值
    String introduction = "My name is $name, and I'm $age years old."; // 包含多个插值
    
    print(greeting); // 输出: Hello, Alice!
    print(introduction); // 输出: My name is Alice, and I'm 30 years old.
    ```

    另外，您还可以在`${}`内使用字符串操作和计算，例如：

    ```dart
    int x = 5;
    int y = 3;
    
    String result = "The sum of $x and $y is ${x + y}"; // 在`${}`中执行计算
    print(result); // 输出: The sum of 5 and 3 is 8
    ```

    ```dart
    String name = "Alice";
    int age = 30;
    
    String greeting = "Hello, $name!"; // 基本的字符串插值
    String introduction = "My name is $name, and I'm $age years old."; // 包含多个插值
    
    print(greeting); // 输出: Hello, Alice!
    print(introduction); // 输出: My name is Alice, and I'm 30 years old.
    ```

    字符串插值不仅限于变量，还可以包括任何表达式，这使得构建动态字符串非常方便。

    需要注意的是，字符串插值只在使用双引号 `"` 或单引号 `'` 创建的字符串字面值中有效，不适用于使用三重引号 `'''` 或 `"""` 创建的多行字符串。如果要在多行字符串中实现类似的效果，可以使用普通字符串连接操作或字符串拼接。
    
    ```dart
    String multiLine = '''
       This is a multi-line string
       with no string interpolation.
    ''';

## 三、 List、Set

基本和 TS 差不多，迭代相关方法比 TS 全面。

### 1. 常用方法

```dart
void main(List<String> arguments) {
  var list = [1, 2, 3];
  List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];


  list.add(4);

  // const 可以用于创建编译时常量，但它不仅仅是对引用的限制，还要求引用的对象本身也必须是不可变的。
  // const c_list = [1, 2, 3];
  // Unsupported operation: Cannot add to an unmodifiable list
  // c_list.add(4);

  var index = list.indexWhere((element) => element == 4); // 3
  list.removeLast();

  list.indexWhere((element) => element == 4); // -4

  list.map((e) => e * 2); // (2, 4, 6)
  var iterableList = list.where((e) => e > 2); // Iterable<int>
  iterableList = iterableList.toList(growable: true); // List<int>

  list.remove(10); // nothing occur
  list.removeAt(0); // remove index 0 element [2, 3]
}
```

### 2. 静态方法

Dart的`List`类提供了许多静态方法，这些方法允许您在不创建`List`实例的情况下执行各种操作。以下是一些常用的`List`静态方法：

1. **`List.from`**：创建一个新的`List`，其元素与另一个可迭代对象相同。例如，您可以将一个`Iterable`转换为`List`。

   ```dart
   Iterable<int> iterable = [1, 2, 3];
   List<int> list = List<int>.from(iterable);
   ```

2. **`List.of`**：创建一个包含指定元素的新`List`。它允许您指定列表的初始内容。

   ```dart
   List<int> list = List.of([1, 2, 3]);
   ```
   
3. **`List.generate`**：根据指定的生成器函数创建一个新的`List`。该函数生成列表中的每个元素。

   ```dart
   List<int> list = List.generate(5, (index) => index * 2);
   ```
   
4. **`List.filled`**：创建一个具有指定长度和初始值的新`List`。

   ```dart
   List<int> list = List.filled(3, 0); // 创建一个长度为3，初始值为0的List
   ```
   
5. **`List.empty`**：创建一个空的、不可变的`List`，用于表示空列表。

   ```dart
   List<int> emptyList = List<int>.empty();
   ```
   
6. **`List.unmodifiable`**：创建一个不可变的`List`，该列表的内容不可更改。

   ```dart
   List<int> list = [1, 2, 3];
   List<int> unmodifiableList = List<int>.unmodifiable(list);
   ```

7. **`List.cast`**：将一个`List`强制转换为另一种类型的`List`，并返回一个新的`List`。

   ```dart
   List<num> numbers = [1, 2, 3];
   List<int> integers = numbers.cast<int>();
   ```

8. **`List.from(Iterable<E> elements, {bool growable: true})`**：创建一个新的`List`，包含指定可迭代对象的所有元素。可选择参数`growable`允许您指定列表是否可增长。

### 3. Set

```dart
void main(List<String> arguments) {
  var list = [1, 2, 3, 3];
  var set = list.toSet(); // {1, 2, 3}
  set.toList(); // [1,2,3]
}
```

## 四、Map

Map数据结构类似JS的Map

### 1. Map 常用函数

```dart
void main(List<String> arguments) {

  Map<String, int> scores = {
    'Alice': 39,
    'Bob': 21,
    'Charlie': 20
  };

  scores['Green'] = 100;

  var greenAge = scores['Green'];

  scores.remove('Green');

  scores['Green']; // null

  scores.containsKey('Green'); // false
  scores.containsValue('20'); // false

  scores.keys; // (Alice, Bob, Charlie) Iterable<String>
  scores.values; // (39, 21, 20)

  scores.forEach((key, value) {
    print('$key: $value');
  });

  for (var key in scores.keys) {
    var value = scores[key];
    print('$key: $value');
  }
}
```

### 2. 字面量对象（dynamic Map）

````dart
void main(List<String> arguments) {

  var person = {
    'name': {
      'firstName': 'Li',
      'secondName': 'Ang'
    },
    'age': 30,
    'city': 'New York'
  };

  var secondName = (person['name'] as dynamic)['secondName'];
  (person['name'] as dynamic)['nickName'] = 'mock';
  var nickName = (person['name'] as dynamic)['nickName'];
  print(nickName);
}
````

### 3. 展开运算符

1. 将一个列表展开为另一个列表：

```dart
List<int> list1 = [1, 2, 3];
List<int> list2 = [4, 5, ...list1];
print(list2); // 输出 [4, 5, 1, 2, 3]
```

2. 合并多个列表：

```dart
List<int> list1 = [1, 2, 3];
List<int> list2 = [4, 5];
List<int> combinedList = [...list1, ...list2];
print(combinedList); // 输出 [1, 2, 3, 4, 5]
```

3. 创建一个新列表，包含旧列表的元素并添加新元素：

```dart
List<int> list1 = [1, 2, 3];
List<int> newList = [...list1, 4, 5];
print(newList); // 输出 [1, 2, 3, 4, 5]
```

4. 解构 Map 对象

```dart
void main() {
  Map<String, dynamic> map1 = {
    'name': 'Alice',
    'age': 30,
  };

  Map<String, dynamic> map2 = {
    'city': 'New York',
    ...map1, // 将 map1 的键值对展开到 map2
  };

  print(map2); // 输出 {'city': 'New York', 'name': 'Alice', 'age': 30}
}
```

## 五、OOP

```dart
// 定义 MapService 类
mixin MapService {
  void showMap() {
    print('Displaying the map');
  }
}

// 定义 UserService 类
mixin UserService {
  void login() {
    print('User login');
  }
}

// 定义控制器类并使用 mixin 集成 MapService 和 UserService
class AppController with MapService, UserService {
  void runApp() {
    showMap(); // 调用 MapService 中的方法
    login();   // 调用 UserService 中的方法
    // 控制器自身的逻辑
  }
}

void main() {
  var controller = AppController();
  controller.runApp();
}
```

### 1. mixin和class

1. **Class（类）**：`class` 用于定义一个类，类是 Dart 中最基本的组织单元，它可以包含属性、方法、构造函数等。类用于创建对象，通过实例化类，您可以创建类的对象，并访问对象的属性和方法。类可以被继承，派生出子类，从而实现面向对象编程中的继承和封装等概念。类通常用于建模数据和行为，是 Dart 中的主要构建块。
2. **Mixin（混入）**：`mixin` 是一种特殊的 Dart 结构，它用于将代码片段注入到类中，以实现代码的重用。Mixin 不是类，它不能被实例化，而是一种用于向类添加功能的方式。Mixin 可以包含方法、属性、getter 和 setter，它们通常用于将功能注入到多个类中，从而实现多重继承的效果。Mixin 通常通过 `with` 关键字与类关联，以实现功能的组合。

主要区别：

- **Class（类）** 是 Dart 中用于创建对象和定义数据和行为的基本结构，它可以被实例化，派生出子类，并包含构造函数等。
- **Mixin（混入）** 不是类，它用于向类中注入功能，不能被实例化，而是通过 `with` 关键字与类关联。Mixin 主要用于实现代码的重用和多重继承。

总之，`class` 是 Dart 中定义类和对象的核心概念，而 `mixin` 是一种用于将功能注入到类中的机制，用于实现多重继承和代码重用。它们各自有不同的用途和特性

## 六、异常处理

1. **异常类**：在 Dart 中，异常是通过异常类来表示的。Dart 提供了一些内置的异常类，如 `Exception`、`Error`、`AssertionError`，以及一些其他自定义的异常类，用于表示不同类型的异常情况。

2. **抛出异常**：要在代码中抛出异常，您可以使用 `throw` 关键字，后跟要抛出的异常对象。例如：

   ```dart
   throw Exception('This is an example exception');
   ```
   
3. **捕获异常**：要捕获异常，您可以使用 `try...catch` 语句块。在 `try` 块中编写可能引发异常的代码，然后在 `catch` 块中捕获异常并处理它。例如：

   ```dart
   try {
     // 可能引发异常的代码
   } catch (e) {
     // 处理异常的代码
     print('Caught an exception: $e');
   }
   ```

   您可以使用多个 `catch` 子句来捕获不同类型的异常，以便根据异常的类型采取不同的处理方式。

4. **最终处理**：您可以使用 `finally` 语句块来执行无论是否发生异常都需要执行的代码。例如：

   ```dart
   try {
     // 可能引发异常的代码
   } catch (e) {
     // 处理异常的代码
   } finally {
     // 最终处理代码
   }
   ```

5. **自定义异常**：您可以创建自定义异常类，以便更好地表示应用程序特定的异常情况。自定义异常类通常继承自 `Exception` 或其他相关的异常类，并可以携带自定义信息。例如：

   ```dart
   class MyCustomException implements Exception {
     final String message;
   
     MyCustomException(this.message);
   }
   ```

6. **异常处理最佳实践**：

   - 捕获尽可能具体的异常类型，以便根据不同的异常类型采取不同的处理方式。
   - 记录异常信息，以便调试和跟踪问题。
   - 不要捕获异常后不进行任何处理，至少应该记录异常信息。
   - 不要滥用异常处理，只在真正需要处理异常的地方使用它。

在 Flutter 应用程序中，异常处理对于处理网络请求、文件操作、用户输入等不可控因素非常重要。合适的异常处理可以提高应用程序的稳定性和可维护性。您可以根据应用程序的需求，采取不同的异常处理策略，如显示错误消息、恢复操作、记录错误信息等。

## 七、函数

### 复杂函数类型定义

```dart
int Function() add(int a, int b, int Function() Function(int rs) callback) {
  return callback(a + b);
}

int Function() mainCallback(int result) {
  return () {
    return result * 2;
  };
}

void main() {
  int Function() result = add(3, 4, mainCallback);
  int finalResult = result();
  print(finalResult); // 输出 14
}
```

### 命名可选参数

在 Dart 中，将函数参数用花括号 `{}` 包围的方式叫做命名可选参数。命名可选参数允许您在调用函数时使用参数的名称来传递值，而不仅仅依赖于参数的位置。这使得函数调用更具可读性，特别是在具有多个可选参数的情况下。

在示例中，`{int seconds = 20}` 中的 `{}` 表示 `seconds` 参数是一个命名可选参数，并且它有一个默认值为 20。这允许您在调用函数时像这样传递参数：

```dart
Future<int> fetchData({int seconds = 20}) async {
  await Future.delayed(Duration(seconds: seconds));
  return 42;
}
```

这使得函数调用更清晰和可维护，特别是当函数具有多个可选参数时。

## 八、枚举

### 枚举定义

```dart
enum FutureStatus { fulfilled, rejected }
```

如果需要给fulfilled、rejected赋予具体的值，请使用抽象类 + 常量属性

```dart
abstract class FutureStatus2 {
  static const int fulfilled = 1;
  static const int rejected = -1;
}
```

### 枚举方法

 ```dart
 FutureStatus s = FutureStatus.fulfilled;
 List<FutureStatus> list = FutureStatus.values;
 int rejectIndex = FutureStatus.rejected.index;
 String rejectName = FutureStatus.rejected.name;
 Type rejectType = FutureStatus.rejected.runtimeType; // extend Object
 ```

## 九、异步

Dart 异步，主要借助Future类和Completer类，Future对应Promise，Completer对应 resole, reject。

### 1. Future 

与JS一样，Future 是一个异步对象， 它 有两种状态，fulfilled，rejected。

它与JS一样，对单个Future 对象采用 future.then()

```dart
Future.delayed(Duration(seconds: 2), () => Future.value(20))
	.then((value) => print('value: $value'))
	.catchError((error) => print('error: $error'))
	.whenComplete(() => print('complete'));
```

Future.value 即 Promise.resolve ，Future.error类似与Promise.reject.

```dart
// 模拟图像压缩函数
Future<String> compressImage(String image) {

  final compressedImage = 'compressed_$image';

  // 模拟异步操作，延迟2秒
  return Future.delayed(Duration(seconds: 1), () {
    // 图像压缩完成
    return Future.value(compressedImage);
  });
}

// 利用 Completer 类 模拟图像上传函数
Future<String> uploadImage(String compressedImage) {
  final completer = Completer<String>();
  final uploadedImage = 'uploaded_$compressedImage';
  // 模拟异步操作，延迟2秒
  Future.delayed(Duration(seconds: 1), () {
    // 图像上传完成
    completer.complete(uploadedImage);
  });

  return completer.future;
}
```

如果是有多个Future实例，可以使用async、await配合try catch使用.

```dart
Future<void> imageSubmit () async {
  try {
    final compressedImage = await compressImage(originalImage);
    print('图像压缩完成: $compressedImage');

    final uploadedImage = await uploadImage(compressedImage);
    print('图像上传完成: $uploadedImage');
  } catch (error) {
    print('出现错误: $error');
  }
}
```

### 2. Completer

`Completer `使用时需要先进行实例化

```dart
final completer = Completer<String>();
```

`completer.complete/completer.completeError` 设置Future结果

```dart
completer.complete(value)//类似 Promise.resolve 但是不直接返回，需要通过return completer.future返回
completer.completeError(error)  //类似 Promise.reject 其他同上
```

Future结果通过 `completer.future` 返回

```dart
completer.isCompleted // bool 是否已经完成
return completer.future // 转为 Future<T>
```

### 3. Future 属性

#### Future 实例属性

- `Future<R> then<R>(FutureOr<R> onValue(T value), {Function? onError});`
- `Future<T> catchError(Function onError, {bool test(Object error)?});`
- `Future<T> whenComplete(FutureOr<void> action());`
- `Future<T> timeout(Duration timeLimit, {FutureOr<T> onTimeout()?});`  Future 执行超时
- `instance.ignore()`  无视这一个Future 实例的结果

#### Future 静态属性

返回结果

- `Future.value`: 返回一个包含指定值的 `Future`。
- `Future.error`: 返回一个失败的 `Future`，并指定一个错误消息或异常对象。
- `Future.sync`: 返回一个表示同步计算结果的`Future`。它通常用于处理同步任务，不会延迟执行。
- `Future.delayed`: 创建一个延迟执行的 `Future`，等待指定的时间后完成。

批量返回结果

1. `Future.wait`: 该方法接收一个 `Iterable<Future>`，等待其中所有的 `Future` 都完成后才返回一个新的 `Future`，该新的 `Future` 包含所有完成的 `Future` 的结果列表。
2. `Future.any`: 与 `Future.wait` 相反，`Future.any` 接收一个 `Iterable<Future>`，并返回其中任何一个 `Future` 完成的结果。

批量操作 Future

1. `Future.forEach(futures, (future) {})` : 对futures 数组进行迭代
2. `Future.doWhile()` 作用不详

利用`Future.forEach` 实现一个类似 `Promise.allSettle`的函数

```dart
enum FutureStatus { fulfilled, rejected }

class SettledResult<T> {
  final FutureStatus status;
  final T? value;
  final Object? error;

  SettledResult.fulfilled(this.value)
      : status = FutureStatus.fulfilled,
        error = null;

  SettledResult.rejected(this.error)
      : status = FutureStatus.rejected,
        value = null;

  @override
  String toString() {
    return 'SettledResult{status: $status, value: $value, error: $error}';
  }
}

abstract class FutureEnhance {
  static Future<List<SettledResult<T>>> waitSettled<T>(
      List<Future<T>> futures) async {
    final results = <SettledResult<T>>[];

    await Future.forEach(futures, (future) async {
      try {
        final value = await future;
        results.add(SettledResult.fulfilled(value));
      } catch (error) {
        results.add(SettledResult.rejected(error));
      }
    });

    return results;
  }
}
```

模拟批量图片压缩上传功能

```dart
import 'dart:async';
import 'future_enhance.dart';

// 模拟图像压缩函数
Future<String> compressImage(String image) {
  final compressedImage = 'compressed_$image';
  return Future.delayed(
      Duration(seconds: 1), () => Future.value(compressedImage));
}

// 模拟图像上传函数
Future<String> uploadImage(String compressedImage) {
  final completer = Completer<String>();
  final uploadedImage = 'uploaded_$compressedImage';
  // 模拟异步操作，延迟2秒
  Future.delayed(Duration(seconds: 2), () => completer.complete(uploadedImage));
  return completer.future;
}

// 图片压缩任务状态
enum ImageDisposeStatus { compressed, uploaded, error }

// 图片压缩任务结果
class ImageDisposeResult {
  final ImageDisposeStatus status;
  final String? result;

  ImageDisposeResult(this.status, this.result);

  @override
  String toString() {
    return 'ImageDisposeResult{status: $status, result: $result}';
  }
}

typedef ImageDisposeRS = Future<List<ImageDisposeResult>>;

// 模拟图片压缩后上传
ImageDisposeRS imageDispose(String originalImage) async {
  final results = <ImageDisposeResult>[];

  try {
    final compressedResult = await compressImage(originalImage);
    results.add(
        ImageDisposeResult(ImageDisposeStatus.compressed, compressedResult));

    final uploadedResult = await uploadImage(compressedResult);
    results
        .add(ImageDisposeResult(ImageDisposeStatus.uploaded, uploadedResult));
  } catch (error) {
    results.add(ImageDisposeResult(ImageDisposeStatus.error, error.toString()));
  }

  return results;
}

List<ImageDisposeRS> generateImageDisposeQueue({ int count = 0 }) {
  return List.generate(count, (index) => imageDispose('${index + 1}.png'));
}

// 递归打印函数
void printRecursive(dynamic obj, [int indent = 0]) {
  final indentation = ' ' * indent;

  if (obj is Map) {
    for (var key in obj.keys) {
      print('$indentation$key: ');
      printRecursive(obj[key], indent + 2);
    }
  } else if (obj is List) {
    for (var i = 0; i < obj.length; i++) {
      print('$indentation[$i]: ');
      printRecursive(obj[i], indent + 2);
    }
  } else if (obj is Iterable || obj is Set) {
    var i = 0;
    for (var item in obj) {
      print('$indentation[$i]: ');
      printRecursive(item, indent + 2);
      i++;
    }
  } else if (obj is String || obj is num || obj is bool || obj == null) {
    print('$indentation$obj');
  } else {
    print('$indentation${obj.toString()}');
  }
}

void main() async {
  List<SettledResult<List<ImageDisposeResult>>> ls =
      await FutureEnhance.waitSettled(generateImageDisposeQueue(count: 10));
  printRecursive([ls]);
}
```

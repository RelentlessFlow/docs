# TypeScript入门

[toc]

## 一、TS基础类型

示例代码

```typescript
// 基础类型 string, number, boolean
const teacherName: string = 'zhangsan'
const teacherAge: number = 28.0
const isMale: boolean = true
// 数组类型
const numberArr: number[] = [1,2,3]
const stringArr: string[] = ['a', 'b', 'c']
const booleanArr: Array<boolean> = [true, true, false]
// 对象类型
const user: {name: string, age: number} = {name: 'dell', age: 18}
const userOne: {name: string, age?: number} = {name: 'dell'}
// 联合类型
function union(id: string|number) { 
    if(typeof id === 'string') { console.log(id.toUpperCase()) }
    else { console.log(id) }
}
// 类型别名
type User = { name: string, age: number }
const userTwo: User =  { name: '占山', age: 10 }
const userThree: User =  { name: '占山', age: 10 }
// any
function showMessage(message: any) { console.log(message) }
// 函数类型
function abc(message: string): number { return 123 }
const def: (age: number) => number = (age: number) => { return 28 }
// 接口类型 Interface
interface Student {
    age: number
    sex?: string
}
interface OldStudent extends Student {  name: string }
const student: Student = { age: 18, sex: 'male' }
const oldStudent: OldStudent = { age: 18, sex: 'female', name: '张三' }
// 交叉类型
type Employee = User & { salary: number }
const employee: Employee = { name: 'dell', age: 18, salary: 1 }
// 断言 Assersion
const dom: null = document.getElementById('#root') as null
const testString: string = 123 as any as string
// 字面量类型
function getPosition(postion: 'left' | 'right'): string {
    return postion
}
// null, undefined
function checkNull(abc: string | null) {
    if(typeof abc === 'string') { }
}
// void
function getNumber(): void {}
```

## 二、TS类型推断与类型收窄

示例代码

```typescript
// TS 开发准则 只要是变量、获取对象属性，都应该有一个明确的类型
// 类型注解：人工的告诉TS，变量或者对象的明确属性类型
const userName: string = '123'
// 类型推断
const userAge = 18
// 如果类型推断能够自动推断出来类型，就没必要去手写类型注解
let userNick = 'dell'
userNick.toLocaleUpperCase()

function getTotal(paramOne: number, paramTwo: number) {
    return paramOne + paramTwo
}

getTotal(1, 2);

const userInfo = { name: 'dell', age: 18 }


// typeof 类型收窄
function uppercase(content: string | number) {
    if(typeof content === 'string') { return content.toUpperCase() }
    return content
}
// 真值收窄
function getString(content?: string) {
    if(content) { return content.toUpperCase() }
}
// 相等收窄
function example(x: string | number, y: string | boolean) {
    if(x === y) { return x.toLocaleLowerCase() }
}

// 对象类型解构的代码怎么写
function getObjectValue({a, b}: {a: string, b: string}) {
    return a + b;
}
getObjectValue({a: '1', b: 2})

// 变量类型以定义变量时的类型为准
let username = '123'
username = '1234'


type Fish = {
    swim: () => {}
}

type Bird = {
    fly: () => {}
}

// In 语法下的类型收窄
function test(animal: Fish | Bird) {
    if('swim' in animal) { return animal.swim() }
    return animal.fly()
}

// InstanceOf 语法下的类型收窄
function test1(param: Date | string) {
    if(param instanceof Date) { return param.getTime() }
    return param.toUpperCase()
}

// animal is Fish 叫做类型陈述语法
function isFish(animal: Fish | Bird): animal is Fish {
    if((animal as Fish).swim !== undefined) { return true }
    return false
}

function test2(animal: Fish | Bird) {
    if(isFish(animal) { return animal.swim(); })
    return animal.fly();
}
```

## 三、函数和泛型

示例代码

```javascript
// 函数和泛型
function getArrayFirstItem<Type>(arr: Type[]): Type {
    return arr[0]
}

const numberArr = [1,2]
const result = getArrayFirstItem(numberArr)

const stringArr = ['1', '2', '3']
const resultOne = getArrayFirstItem(stringArr)
```

## 四、对象类型拓展

示例代码

```typescript
// interface中的readonly只读属性
interface Person {
    readonly name: string
    readonly age: number
}

const dell: Person = { name: 'dell', age: 30 }

// 如何给对象拓展属性
interface ArrayObject {
    [key: string]: string | number
    length: number
}

const obj: ArrayObject = {
    abc: '123',
    length: 0
}

// 对象类型的继承
interface Animal {
    name: string
    age: number
    breath: () => void
}

interface Dog extends Animal {
    bark: () => void
}

const animal: Animal = {
    name: 'panada',
    age: 10,
    breath: () => {}
}

const dog: Dog = {
    name: 'panada',
    age: 10,
    breath: () => {},
    bark: () => {}
}

// 多个对象类型同时进行集成
interface Circle {
    radius: number;
}

interface Colorful {
    color:  string
}

interface ColorfulCircle extends Circle, Colorful {}

const colorfulCircle: ColorfulCircle = {
    radius: 1,
    color: 'red'
}

// 交叉类型
type ColorfulCircleOne = Circle & Colorful
const colorfulCircleOne: ColorfulCircleOne = {
    radius: 1,
    color: 'red'
}
```

## 五、泛型、数组、元祖

实例代码

```typescript
// 泛型
interface Box<Type> {
    content: Type
}

const box: Box<string> = {
    content: 'box'
}

const box1: Box<number> = {
    content: 123
}

// 使用泛型来拓展新的类型
type TypeOrNull<Type> = Type | null
type OneOrMany<Type> = Type | Type[]
// type OneOrManyOrNull<Type> = OneOrMany<Type> | null
type OneOrManyOrNull<Type> = TypeOrNull<OneOrMany<Type>>

// 数组和泛型
interface SelfArray<Type> {
    [key: number]: Type;
    length: number;
    pop(): Type | undefined;
    push(...items: Type[]): number
}
const numberArr: SelfArray<string> = ['1', '2', '3']

// 数组的Readonly修饰符
function doStuff(arr: readonly string[]) {
    // arr.push('123') 报错
}

// 元祖
type Point = readonly [number, number]
const tuple:Point = [1, 2]
function getPoint([x, y]: Point) {
    return x + y
}

const point: Point = [1, 2]

// point[0] = 3; 报错

getPoint(point)

// extends

interface Person {
    name: string
}

function getName<Type extends Person>(person: Type) {
    return person.name
}

getName({name: 'dell', age: 30})

// keyof
interface Teacher {
    name: string
    age: number
    sex: 'male' | 'female'
}

const teacher: Teacher = {
    name: 'Dell',
    age: 30,
    sex: 'male'
}

function getTeacherInfo<T extends keyof Teacher>(teacher: Teacher, key: T) {
    return teacher[key]
}

getTeacherInfo(teacher, 'name')
```

## 六、条件类型

条件类型可以看做是一种类型计算函数，根据已有的类型去生成新的类型

示例代码

```typescript
// 条件类型
interface Animal {
    breath: () => {}
}

interface Dog extends Animal {
    bark: () => {}
}

interface Tank {
    pH: number
}

type Example = Tank extends Animal ? string : number

// 使用条件类型的例子，可以让我们的函数重载的语法变得更简练
interface IdLable { 
    id: number
 }

interface NameLable {
   name: string
}

// function createLabel(key: string): NameLable
// function createLabel(key: number): IdLable
// function createLabel(key: string | number): IdLable | NameLable {
//     if(typeof key === 'string') return { name: key }
//     return { id: key }
// }

// const lable = createLabel('dell')

// 使用条件类型改进函数重载的写法
type IdOrNameLable<T> = T extends number ? IdLable : NameLable
function createLabel<T extends string | number>(key: T): IdOrNameLable<T>
function createLabel(key: string | number): IdLable | NameLable {
    if(typeof key === 'string') { return {name: key} }
    return { id: key }
}
const lable = createLabel('dell')

// 条件类型其他的应用场景
interface Email {
    from: string
    to: string
    message: string    
}

type TypeMessageOf<T> = T extends { message: unknown } ? T['message'] : never
// type EmailMessage = string  使用条件类型可以避免类型的重复声明
const emailObject: Email = {
    from: 'dell@qq.com',
    to: 'lee@qq.com',
    message: 'hello lee'
}
const email: TypeMessageOf<Email> = 'hello lee' // string

// 条件类型其他使用场景
type GetReturnType<T> = T extends (...args: never[]) => infer ReturnType ? ReturnType : never

type example = GetReturnType<() => string> // string
type example1 = GetReturnType<string> // never

// 条件类型其他使用场景
type ToArray<T> = [T] extends [any] ? T[] : never
type stringArray = ToArray<string> // string[]
type stringOrNumberArray = ToArray<string | number> // (string | number)[]
type NeverType = ToArray<never> // never
```

## 七、映射类型

1. *映射类型基础语法*

```javascript
// 映射类型基础语法
interface User {
    readonly name: string;
    readonly age: number;
    id: string;
    male?: boolean
}

type FilterReadOnly<Type> = {
    - readonly[Property in keyof Type] ?: Type[Property]
}

// { name: string; age: number; id: string; }
type PublicUser = FilterReadOnly<User>  

const publicUser: PublicUser = {
    name: 'dell',
    age: 30,
    id: '1'
}

publicUser.age = 31
```

2. *exclude*

```typescript
interface User {
    readonly name: string;
    readonly age: number;
    id: string;
    male?: boolean
}

type DeletePropertyInUserUpdate<T> = {
    [P in keyof T as Exclude<P, 'id' | 'name'>]: T[P]
}

interface UserUpdate extends DeletePropertyInUserUpdate<User> {

}

const userUpdate: UserUpdate = {
    age: 0
}
```

3. *字面量语法例子*

```
interface User {
    readonly name: string;
    readonly age: number;
    id: string;
    male?: boolean
}

type GetPropertyFunctions<T> = {
    [P in keyof T as `get${Capitalize<string & P>}`]: () => T[P]
}

/*
type UserFunctionsType = {
    readonly getName: () => string;
    readonly getAge: () => number;
    getId: () => string;
    getMale?: (() => boolean | undefined) | undefined;
}
*/

type UserFunctionsType = GetPropertyFunctions<User>
```

4. 联合类型

```typescript
type SquareEvent = {
    kind: 'square'
    x: number
    y: number
}
type CircleEvent = {
    kind: 'circle'
    radius: number
}
type GenerateEventsFunctions<Events extends { kind: string }> = {
    [Event in Events as Event['kind']]: (event: Event) => number
}

// type NewType = {
//     square: (event: SquareEvent) => number;
//     circle: (event: CircleEvent) => number;
// }
type NewType = GenerateEventsFunctions<SquareEvent | CircleEvent>
```

## 八、Class

1、继承、构造函数、访问修饰符、getter、setter、static

```typescript
// private, project, public 访问类型
// public 允许我在类的内外被调用
// private 允许在类内被使用
// protected 允许在类内及继承的子类中使用

class Person {
    constructor(private _name: string) {}
    get name() { return this._name }
    set name(name: string) { this._name = name }
}

const person = new Person('dell')

class Teacher extends Person {
    get name(): string {
        return super.name
    }
}

class Demo {
    private static instance: Demo;
    private constructor(public name: string) {}
    static getInstance() {
        if(!this.instance) this.instance = new Demo('object')
        return this.instance;
    }
}

const demo1 = Demo.getInstance()
const demo2 = Demo.getInstance()
console.log(demo1 === demo2) // true
```

2、抽象类

```typescript
abstract class Geom {
  width: number
  getType() { return 'Geom' }
  abstract getArea(): number
}
```




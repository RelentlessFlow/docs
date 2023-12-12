# 十五、DOM

[toc]

## 一、DOM原型链

### 1. DOM构造函数

```html
<h1 id="myEle">ele</h1>
<script>
  function prototypeOut(el) {
    console.dir(el.__proto__);
    el.__proto__ ? prototypeOut(el.__proto__) : '';
  }
  let ele = document.getElementById('myEle');
  prototypeOut(ele);

  // HTMLHeadingElement {…} > HTMLElement {…} > Element {…}
  // > Node {…} > EventTarget {...} > Object() > null
</script>
```

最终得到的节点的原型链为

| 原型               | 说明                                                         |
| ------------------ | ------------------------------------------------------------ |
| Object             | 根对象，提供hasOwnProperty等基本对象操作支持                 |
| EventTarget        | 提供addEventListener、removeEventListener等事件支持方法      |
| Node               | 提供firstChild、parentNode等节点操作方法                     |
| Element            | 提供getElementsByTagName、querySelector等方法                |
| HTMLElement        | 所有元素的基础类，提供childNodes、nodeType、nodeName、className、nodeName等方法 |
| HTMLHeadingElement | Head标题元素类                                               |

### 2. 通过原型链操作DOM

1. 原型链为标题元素增加两个原型方法，改变颜色与隐藏元素

```html
<h2 onclick="this.color('red')">houdunren.com</h2>
<script>
  const h2 = document.querySelector('h2');
  HTMLHeadingElement.prototype = Object.assign(HTMLHeadingElement.prototype, {
    color(color) {
      this.style.color = color;
    },
    hide() {
      this.style.display = 'none'
    },
  })
</script>
```

2. 对象合并属性的实例

```html
<div id="myEle">Element</div>
<script>
  let ele = document.getElementById('myEle');
  Object.assign(ele, {
    innerHTML: 'Element',
    color: 'red',
    change() {
      this.innerHTML = '内容',
      this.style.color = this.color
    },
    onclick() {
      this.change()
    },
  })
</script>
```

3. 对象特性更改样式属性

```javascript
<div id="myEle">Element</div>
<script>
  let ele = document.getElementById('myEle');
  Object.assign(ele.style, {
    color: 'white',
    backgroundColor: 'red',
  })
</script>
```

## 二、节点属性

不同类型的节点拥有不同属性，下面是节点属性的说明与示例

###  nodeType

nodeType指以数值返回节点类型

| nodeType | 说明         |
| -------- | ------------ |
| 1        | 元素节点     |
| 2        | 属性节点     |
| 3        | 文本节点     |
| 8        | 注释节点     |
| 9        | document对象 |

### nodeName

nodeName指定节点的名称

- 获取值为大写形式

| nodeType | nodeName      |
| -------- | ------------- |
| 1        | 元素名称如DIV |
| 2        | 属性名称      |
| 3        | #text         |
| 8        | #comment      |

```html
<div id="app">
  <div>111</div>
  <div>222</div>
  <span>xxx</span>
</div>
<script>
  const div = document.querySelector('#app');
  const span = document.querySelector('span');
  console.log(div.nodeName);  // DIV
  console.log(span.nodeName); // SPAN
</script>
```

### tagName

nodeName可以获取不限于元素的节点名，tagName仅能用于获取标签节点的名称

- tagName存在于Element类的原型中
- 文本、注释节点值为 undefined
- 获取的值为大写的标签名

### nodeValue

使用nodeValue或data函数获取节点值，也可以使用节点的data属性获取节点内容

| nodeType | nodeValue |
| -------- | --------- |
| 1        | null      |
| 2        | 属性值    |
| 3        | 文本内容  |
| 8        | 注释内容  |

## 三、动态与静态

### 动态特性

下例中通过按钮动态添加元素后，获取的元素集合是动态的，而不是上次获取的固定快照。

```javascript
<h1>content1</h1>
<h1>content2</h1>
<button id="add">添加元素</button>

<script>
  let elements = document.getElementsByName('h1');
  console.log(elements);
  let button = document.querySelector('#add');
  button.addEventListener('click', () => {
    document.querySelector('body').insertAdjacentHTML('beforeend', '<h1>添加内容</h1>')
    console.log(elements);
  })
</script>
```

### 静态特性

document.querySelectorAll获取的集合是静态的

```javascript
<h1>content1</h1><h1>content2</h1>
<button id="add">添加元素</button>
<script>
  let elements = document.querySelectorAll('h1');
  console.log(elements.length);
  let button = document.querySelector('#add');
  button.addEventListener('click', () => {
    document.querySelector('body')
    .insertAdjacentHTML('beforeend', '<h1>content</h1>');
    console.log(elements.length)
  })
</script>
```

## 四、NodeList 、HTMLCollection之间的关系

```html
<body>
  <div class="test">
    <p class="p1">Hello</p>
    <p class="p1">World</p>
	</div>
  <script>
    let test = document.getElementsByClassName('test')[0];
    // NodeList(5) [text, p.p1, text, p.p1, text]
    console.log(test.childNodes);
    // HTMLCollection(2) [p.p1, p.p1]
    console.log(test.children); 
  </script>
</body>
```

querySelectorAll:1-->1类型：[object NodeList] children:1-->2类型：[object HTMLCollection] childNodes:1-->2类型：[object NodeList] getElementsByTagName:1-->2类型：[object HTMLCollection] getElementsByClassName:1-->2类型：[object HTMLCollection]

## 遍历节点

### forOf

Nodelist与HTMLCollection是类数组的可迭代对象可以使用for...of进行遍历

```javascript
<div class="ele">elemnet1</div>
<div class="ele">elemnet2</div>
<script>
  const nodes = document.getElementsByTagName('div');
  console.log(toString.call(nodes)); // [object HTMLCollection]
  for(const item of nodes) {
    console.log(toString.call(item)); // [object HTMLDivElement]
  }
</script>
```

### forEach

Nodelist节点列表也可以使用forEach来进行遍历，HTMLCollection则不可以

```html
<script>
  const nodes = document.querySelectorAll('div');
  nodes.forEach((node, key) => {
    console.log(toString.call(node)); // [object HTMLDivElement]
  })
</script>
```

### call/apply

```html
<script>
  const nodes = document.querySelectorAll('div');
  Array.prototype.map.call(nodes, (node, index) => {
    console.log(node, index);
  })
</script>
```

也可以这样

```html
<script>
  const nodes = document.querySelectorAll('div');
  [].filter.call(nodes, (node, index) => {
    console.log(node, index);
  })
</script>
```

### Array.from

Array.from用于将类数组转为组件，并提供第二个迭代函数。所以可以借用Array.from实现遍历

```html
<script>
  const nodes = document.querySelectorAll('div');
  Array.from(nodes, (node, index) => {
    console.log(node, index);
  })
</script>
```

补充：

ArrayConstructor接口 TS源码

```typescript
interface ArrayConstructor {
    /**
     * Creates an array from an iterable object.
     * @param iterable An iterable object to convert to an array.
     */
    from<T>(iterable: Iterable<T> | ArrayLike<T>): T[];

    /**
     * Creates an array from an iterable object.
     * @param iterable An iterable object to convert to an array.
     * @param mapfn A mapping function to call on every element of the array.
     * @param thisArg Value of 'this' used to invoke the mapfn.
     */
    from<T, U>(iterable: Iterable<T> | ArrayLike<T>, mapfn: (v: T, k: number) => U, thisArg?: any): U[];
}
```

### 展开语法

使用展开运算符将节点转为数组

```javascript
const nodes = document.querySelectorAll('div');
  [...nodes].map(node => {
    console.log(node);
})
```

## 五、DOM关系

### 节点关系

节点是父子级嵌套与前后兄弟关系，使用DOM提供的API可以获取这种关系的元素。

- 文本和注释也是节点，所以也在匹配结果中

| 节点属性        | 说明           |
| --------------- | -------------- |
| childNodes      | 获取所有子节点 |
| parentNode      | 获取父节点     |
| firstChild      | 第一个子节点   |
| lastChild       | 最后一个子节点 |
| nextSibling     | 下一个兄弟节点 |
| previousSibling | 上一个兄弟节点 |

### 标签关系

使用childNodes等获取的节点包括文本与注释，但这不是我们常用的，为此系统也提供了只操作元素的关系方法。

| 节点属性               | 说明                                             |
| ---------------------- | ------------------------------------------------ |
| parentElement          | 获取父元素                                       |
| children               | 获取所有子元素                                   |
| childElementCount      | 子标签元素的数量                                 |
| firstElementChild      | 第一个子标签                                     |
| lastElementChild       | 最后一个子标签                                   |
| previousElementSibling | 上一个兄弟标签                                   |
| nextElementSibling     | 下一个兄弟标签                                   |
| contains               | 返回布尔值，判断传入的节点是否为该节点的后代节点 |

## 五、标签获取

系统提供了丰富的选择节点（NODE）的操作方法，返回HTMLElement

### 1、getElementById

### 2、getElementsByName

使用getElementByName获取设置了name属性的元素，虽然在DIV等元素上同样有效，但一般用来对表单元素进行操作时使用。

- 返回NodeList节点列表对象
- NodeList顺序为元素在文档中的顺序
- 需要在 document 对象上使用

### 3、getElementsByTagName

使用getElementsByTagName用于按标签名获取元素

- 返回HTMLCollection节点列表对象
- 是不区分大小的获取

**通配符**

可以使用通配符 ***** 获取所有元素

### 4、getElementsByClassName

## 六、样式选择器

使用getElementsByTagName等方式选择元素不够灵活，建议使用下面的样式选择器操作，更加方便灵活。返回NodeList

### querySelectorAll

使用querySelectorAll根据CSS选择器获取Nodelist节点列表

- 获取的NodeList节点列表是静态的，添加或删除元素后不变

### querySelector

querySelector使用CSS选择器获取一个元素，下面是根据属性获取单个元素

### matches

用于检测元素是否是指定的样式选择器匹配，下面过滤掉所有name属性的LI元素

```html
<div id="app">
  <li>houdunren</li>
  <li>向军大叔</li>
  <li name="houdunwang">houdunwang.com</li>
</div>
<script>
  const nodes = [...document.querySelectorAll('li')].filter(node => {
    return !node.matches(`[name]`)
  })
  console.log(nodes)
</script>
```

### closest

查找最近的符合选择器的祖先元素（包括自身），下例查找父级拥有 `.comment`类的元素

```html
<div class="comment">
  <ul class="comment">
    <li>houdunren.com</li>
  </ul>
</div>

<script>
  const li = document.getElementsByTagName('li')[0]
  const node = li.closest(`.comment`)
  //结果为 ul.comment
  console.log(node)
</script>
```

## 七、标准属性

元素的标准属性具有相对应的DOM对象属性

- 操作属性区分大小写
- 多个单词属性命名规则为第一个单词小写，其他单词大写
- 属性值是多类型并不全是字符串，也可能是对象等
- 事件处理程序属性值为函数
- style属性为CSSStyleDeclaration对象
- DOM对象不同生成的属性也不同

### 属性别名

有些属性名与JS关键词冲突，系统已经起了别名

| 属性  | 别名      |
| ----- | --------- |
| class | className |
| for   | htmlFor   |

### 操作属性

元素的标准属性可以直接进行操作，下面是直接设置元素的className

```html
<div id="app">
  <div class="houdunren" data="hd">houdunren.com</div>
  <div class="houdunwang">houdunwang.com</div>
</div>
<script>
  const app = document.querySelector(`#app`)
  app.className = 'houdunren houdunwang'
</script>
```

下面设置图像元素的标准属性

```html
<img src="" alt="" />
<script>
  let img = document.images[0]
  img.src = 'https://www.houdurnen.com/avatar.jpg'
  img.alt = '后盾人'
</script>
```

## 八、元素特征

对于标准的属性可以使用DOM属性的方式进行操作，但对于标签的非标准的定制属性则不可以。但JS提供了方法来控制标准或非标准的属性

可以理解为元素的属性分两个地方保存，DOM属性中记录标准属性，特征中记录标准和定制属性

- 使用特征操作时属性名称不区分大小写
- 特征值都为字符串类型

| 方法            | 说明     |
| --------------- | -------- |
| getAttribute    | 获取属性 |
| setAttribute    | 设置属性 |
| removeAttribute | 删除属性 |
| hasAttribute    | 属性检测 |

特征是可迭代对象，下面使用for...of来进行遍历操作

```html
<div id="app" content="后盾人" color="red">houdunwang.com</div>
<script>
  const app = document.querySelector('#app')
  for (const { name, value } of app.attributes) {
    console.log(name, value);
    /*
    id app
    content 后盾人
    color red
    */
  }
</script>
```

### 自定义特征

虽然可以随意定义特征并使用getAttribute等方法管理，但很容易造成与标签的现在或未来属性重名。建议使用以data-为前缀的自定义特征处理，针对这种定义方式JS也提供了接口方便操作。

- 元素中以data-为前缀的属性会添加到属性集中
- 使用元素的dataset可获取属性集中的属性
- 改变dataset的值也会影响到元素上

```html
<div class="houdunwang" data-content="后盾人" data-color="red">houdunwang.com</div>

<script>
  let houdunwang = document.querySelector('.houdunwang')
  let content = houdunwang.dataset.content
  console.log(content) //后盾人
  houdunwang.innerHTML = `<span style="color:${houdunwang.dataset.color}">${content}</span>`
</script>
```

多个单词的特征使用驼峰命名方式读取

```html
<div class="houdunwang" data-title-color="red">houdunwang.com</div>
<script>
  let houdunwang = document.querySelector('.houdunwang')
  houdunwang.innerHTML = `
    <span style="color:${houdunwang.dataset.titleColor}">${houdunwang.innerHTML}</span>
  `
</script>
```

改变dataset值也会影响到页面元素上

```html
<div class="myEle" data-title-color="red">element</div>
<script>
  let ele = document.querySelector('.myEle')
  ele.addEventListener('click', function() {
    this.dataset.titleColor = 
      ['red', 'green', 'blue'][Math.floor(Math.random() * 3)]
    this.style.color = this.dataset.titleColor
  })
</script>
```

## 九、创建节点

创建节点的就是构建出DOM对象，然后根据需要添加到其他节点中

###  append（添加元素）

append 也是用于添加元素，同时他也可以直接添加文本等内容。

```html
<body></body>
<script>
  let createDom = document.createElement('div');
  createDom.innerHTML = 'content';
  document.body.append(createDom);
</script>
```

### createTextNode（创建文本对象）

创建文本对象并添加到元素中

```html
<div id="app"></div>
<script>
  let app = document.querySelector('#app');
  let text = document.createTextNode('content');
  app.append(text);
</script>
```

### createElement（创建标签节点）

使用createElement方法可以创建标签节点对象，创建span标签新节点并添加到div#app

```javascript
<div id="app"></div>
<script>
  let app = document.querySelector('#app');
  let span = document.createElement('span');
  span.innerHTML = 'span';
  app.append(span);
</script>
```

使用PROMISE结合节点操作来加载外部JAVASCRIPT文件

```javascript
<script>
  function js(file) {
    return new Promise((resolve, reject) => {
      let js = document.createElement('script');
      js.type = 'text/javascript';
      js.src = file;
      js.onerror = reject;
      document.body.appendChild(js);
    })
  }
  js('1.js')
    .then(() => console.log('加载成功'))
    .catch((error) => console.log(`${error.target.src}`))
</script>
```

### cloneNode&importNode(IE9)

使用cloneNode和document.importNode用于复制节点对象操作

- cloneNode是节点方法
- cloneNode 参数为true时递归复制子节点即深拷贝
- importNode是documet对象方法
- Node.cloneNode 支持到IE6

```html
<div id="app">My App</div>
<script>
  let app = document.querySelector('#app');
  let newApp = app.cloneNode(true);
  document.body.appendChild(newApp);
</script>
```

document.importNode方法是部分IE浏览器不支持的，也是复制节点对象的方法

- 第一个参数为节点对象
- 第二个参数为true时递归复制
- 主要用来插入外部节点，支持到IE9

```javascript
<div id="app">My App</div>
<script>
  let app = document.querySelector('#app');
  let newApp = document.importNode(app, true);
  document.body.appendChild(newApp);
</script>
```

## 十、节点内容

### innerHTML

inneHTML用于向标签中添加html内容，同时触发浏览器的解析器**重绘DOM**。

- innerHTML中只解析HTML标签语法，所以其中的 script 不会做为JS处理
- innerHTML内容进行了重绘，即删除原内容然后设置新内容
- 重绘后产生的button对象没有事件
- 重绘后又产生了新img对象，所以在控制台中可看到新图片在加载

```javascript
<div id="app">
  <div class="myEle">element1</div>
  <div class="myEle">element2</div>
</div>
<script>
  let app = document.querySelector('#app');
  let before = app.innerHTML;
  let after = before + '<h1>后盾人</h1>';
  app.innerHTML = after;
</script>
```

### outerHTML

outerHTML与innerHTML的区别是包含父标签

- outerHTML不会删除原来的旧元素
- 只是用新内容替换替换旧内容，旧内容（元素）依然存在

下面将div#app替换为新内容

```javascript
<div id="app">
  <div class="myEle">element1</div>
  <div class="myEle">element2</div>
</div>
<script>
  let app = document.querySelector('#app');
  let before = app.outerHTML;
  let after = before + '<h1>后盾人</h1>';
  app.outerHTML = after;
  /**
   * <div id=app>
   *  <div class=myEle>element</div>
   *  <div class=myEle>element</div>
   * </div>
   * <h1>后盾人</h1>
</script>
```

### textContent与innerText

textContent与innerText是访问或添加文本内容到元素中

- textContentb部分IE浏览器版本不支持
- innerText部分FireFox浏览器版本不支持
- 获取时忽略所有标签,只获取文本内容
- 设置时将内容中的标签当文本对待不进行标签解析

### insertAdjacentText

将文本插入到元素指定位置，不会对文本中的标签进行解析，包括以下位置

| 选项        | 说明         |
| ----------- | ------------ |
| beforebegin | 元素本身前面 |
| afterend    | 元素本身后面 |
| afterbegin  | 元素内部前面 |
| beforeend   | 元素内部后面 |

## 十一、节点管理

### 推荐方法

| 方法        | 说明                       |
| ----------- | -------------------------- |
| append      | 节点尾部添加新节点或字符串 |
| prepend     | 节点开始添加新节点或字符串 |
| before      | 节点前面添加新节点或字符串 |
| after       | 节点后面添加新节点或字符串 |
| replaceWith | 将节点替换为新节点或字符串 |

## insertAdjacentHTML

将html文本插入到元素指定位置，浏览器会对文本进行标签解析，包括以下位置

| 选项        | 说明         |
| ----------- | ------------ |
| beforebegin | 元素本身前面 |
| afterend    | 元素本身后面 |
| afterbegin  | 元素内部前面 |
| beforeend   | 元素内部后面 |

### insertAdjacentElement

insertAdjacentElement() 方法将指定元素插入到元素的指定位置，包括以下位置

- 第一个参数是位置
- 第二个参数为新元素节点

| 选项        | 说明         |
| ----------- | ------------ |
| beforebegin | 元素本身前面 |
| afterend    | 元素本身后面 |
| afterbegin  | 元素内部前面 |
| beforeend   | 元素内部后面 |

### 过时方法

| 方法         | 说明                           |
| ------------ | ------------------------------ |
| appendChild  | 添加节点                       |
| insertBefore | 用于插入元素到另一个元素的前面 |
| removeChild  | 删除节点                       |
| replaceChild | 进行节点的替换操作             |

### DocumentFragment（性能优化）

> https://developer.mozilla.org/zh-CN/docs/Web/API/DocumentFragment

## 十二、样式管理

通过DOM修改样式可以通过更改元素的class属性或通过style对象设置行样式来完成。

- 建议使用class控制样式，将任务交给CSS处理，更简单高效

### 1. 批量设置

使用JS的className可以批量设置样式

```javascript
<div id="app" class="d-flex container">后盾人</div>
<script>
  let app = document.getElementById('app')
  app.className = 'houdunwang'
</script>
```

也可以通过特征的方式来更改

```javascript
<div id="app" class="d-flex container">后盾人</div>
<script>
  let app = document.getElementById('app')
  app.setAttribute('class', 'houdunwang')
</script>
```

### 2. classList

如果对类单独进行控制使用 classList属性操作

| 方法                    | 说明     |
| ----------------------- | -------- |
| node.classList.add      | 添加类名 |
| node.classList.remove   | 删除类名 |
| node.classList.toggle   | 切换类名 |
| node.classList.contains | 类名检测 |

### 3. 设置行样式

使用style对象可以对样式属性单独设置，使用cssText可以批量设置行样式

##### 样式属性设置

使用节点的style对象来设置行样式

```javascript
<div id="app" class="d-flex container">后盾人</div>
<script>
  let app = document.getElementById('app')
  app.style.backgroundColor = 'red'
  app.style.color = 'yellow'
</script>
```

##### 批量设置行样式

使用 cssText属性可以批量设置行样式

```javascript
<div id="app" class="d-flex container">后盾人</div>
<script>
  let app = document.getElementById('app')
  app.style.cssText = `background-color:red;color:yellow`
</script>
```

也可以通过setAttribute改变style特征来批量设置样式

```javascript
<div id="app" class="d-flex container">后盾人</div>
<script>
  let app = document.getElementById('app')
  app.setAttribute('style', `background-color:red;color:yellow;`)
</script>
```

### 获取样式

##### style（只行内样式）

可以通过style对象，window.window.getComputedStyle对象获取样式属性。

- style对象不能获取行样式外定义的样式

```html
<style> div { color: yellow; } </style>
<div id="app" style="background-color: red; margin: 20px;">Element</div>
<script>
  let app = document.getElementById('app');
  console.log(app.style.backgroundColor);
  console.log(app.style.margin);
  console.log(app.style.marginTop);
  console.log(app.style.color); // ''
</script>
```

##### getComputedStyle（计算后的样式属性）

使用window.getComputedStyle可获取所有应用在元素上的样式属性

- 函数第一个参数为元素
- 第二个参数为伪类
- 这是计算后的样式属性，所以取得的单位和定义时的可能会有不同

```html
<style>
  div { font-size: 35px; color: yellow; }
</style>
<div id="app" style="background-color: red; margin: 20px;">Element</div>
<script>
  let app = document.getElementById('app');
  let fontSize = window.getComputedStyle(app).fontSize;
  console.log(fontSize.slice(0, -2));
  console.log(parseInt(fontSize)); // 35
</script>
```


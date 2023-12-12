# 十六、JS事件

[toc]

## 一、事件监听

使用addEventListener添加事件处理程序有以下几个特点

- transtionend / DOMContentLoaded 等事件类型只能使用 addEventListener 处理
- 同一事件类型设置多个事件处理程序，按设置的顺序先后执行
- 也可以对未来添加的元素绑定事件

| 方法                | 说明             |
| ------------------- | ---------------- |
| addEventListener    | 添加事件处理程序 |
| removeEventListener | 移除事件处理程序 |

1. 参数一事件类型
2. 参数二事件处理程序
3. 参数三为定制的选项

### 事件选项

addEventListener的第三个参数为定制的选项，可传递object或boolean类型

下面是传递对象时的说明

```typescript
interface AddEventListenerOptions extends EventListenerOptions {
    once?: boolean;
    passive?: boolean;
    signal?: AbortSignal;
}
```

- `capture`:  [`Boolean`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Boolean)，表示 `listener` 会在该类型的事件捕获阶段传播到该 `EventTarget` 时触发。

- `once`:  [`Boolean`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Boolean)，表示 `listener 在添加之后最多只调用一次。如果是` `true，` `listener` 会在其被调用之后自动移除。

- `passive`: [`Boolean`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Boolean)，设置为true时，表示 `listener` 永远不会调用 `preventDefault()`。如果 listener 仍然调用了这个函数，客户端将会忽略它并抛出一个控制台警告。查看 [使用 passive 改善的滚屏性能](https://developer.mozilla.org/zh-CN/docs/Web/API/EventTarget/addEventListener#使用_passive_改善的滚屏性能) 了解更多.

- `signal`：[`AbortSignal`](https://developer.mozilla.org/zh-CN/docs/Web/API/AbortSignal)，该 `AbortSignal` 的 [`abort()`](https://developer.mozilla.org/zh-CN/docs/Web/API/AbortController/abort) 方法被调用时，监听器会被移除。

下面使用once:true 来指定事件只执行一次

```javascript
const app = document.querySelector("#app");
app.addEventListener(
  "click",
  function () {
    alert("clicked!");
  },
  { once: true }
);
```

设置 `{ capture: true }` 或直接设置第三个参数为true用来在捕获阶段执行事件

> addEventListener的第三个参数传递true/false 和设置 {capture:true/false}是一样

```html
<div id="app" style="background-color: red">
  <button id="bt">MyButton</button>
</div>
<script>
  const app = document.querySelector('#app');
  const bt = document.querySelector('#bt');
  app.addEventListener( // 先执行
    'click',  function() {alert('div事件')}, 
    {capture: true}
  )
  bt.addEventListener( // 后执行
    'click', function() {alert('btn事件')},
    {capture: true}
  )
</script>
```

设置 `{ capture: false }` 或直接设置第三个参数为false用来在冒泡阶段执行事件

```html
<div id="app" style="background-color: red">
  <button id="bt">MyButton</button>
</div>
<script>
  const app = document.querySelector('#app');
  const bt = document.querySelector('#bt');
  app.addEventListener( 
    'click',  function() {alert('div事件')}, 
    {capture: false} // 后执行
  )
  bt.addEventListener(
    'click', function() {alert('btn事件')},
    {capture: false} // 先执行
  )
</script>
```

## 二、事件对象

执行事件处理程序时，会产生当前事件相关信息的对象，即为事件对事。系统会自动做为参数传递给事件处理程序。

- 大部分浏览器将事件对象保存到window.event中
- 有些浏览器会将事件对象做为事件处理程序的参数传递

事件对象常用属性如下：

| 属性          | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| type          | 事件类型                                                     |
| target        | 事件目标对象，冒泡方式时父级对象可以通过该属性找到在哪个子元素上最终执行事件 |
| currentTarget | 当前执行事件的对象                                           |
| timeStamp     | 事件发生时间                                                 |

## 三、冒泡捕获

### 冒泡行为

标签元素是嵌套的，在一个元素上触发的事件，同时也会向上执行父级元素的事件处理程序，一直到HTML标签元素。

- 大部分事件都会冒泡，但像focus事件则不会
- event.target 可以在事件链中最底层的定义事件的对象
- event.currentTarget == this 即当前执行事件的对象

以下示例有标签的嵌套，并且父子标签都设置了事件，当在子标签上触发事件事会冒泡执行父级标签的事件

```html
<div id="app"><h2>HEADER</h2></div>
<script>
  const app = document.querySelector('#app');
  const h2 = document.querySelector('h2');
  app.addEventListener('click', (event) => {
    console.log(event.currentTarget.nodeName); // DIV
    console.log(event.target.nodeName); // H2
    console.log('app event') // app event
  })
  h2.addEventListener('click', () => {
    console.log(event.currentTarget.nodeName); // H2
    console.log(event.target.nodeName); // H2
    console.log('h2 event'); // h2 event
  })
  // 冒泡顺序 h2.click >>> app.click 
</script>
```

### 阻止冒泡

冒泡过程中的任何事件处理程序中，都可以执行 `event.stopPropagation()` 方法阻止继续进行冒泡传递

- event.stopPropagation() 用于阻止冒泡
- 如果同一类型事件绑定多个事件处理程序 event.stopPropagation() 只阻止当前的事件处理程序
- event.stopImmediatePropagation() 阻止事件冒泡并且阻止相同事件的其他事件处理程序被调用

下例中为h2的事件处理程序添加了阻止冒泡动作，将不会产生冒泡，也就不会执行父级中的事件处理程序了。

```html
<style>
  #app {
    background: #34495e;
    width: 300px;
    padding: 30px;
  }
  #app h2 {
    background-color: #f1c40f;
    margin-right: -100px;
  }
</style>
<div id="app">
  <h2>houdunren.com</h2>
</div>
<script>
  const app = document.querySelector('#app')
  const h2 = document.querySelector('h2')
  app.addEventListener('click', (event) => {
    console.log(`event.currentTarget:${event.currentTarget.nodeName}`)
    console.log(`event.target:${event.target.nodeName}`)
    console.log('app event')
  })
  h2.addEventListener('click', (event) => {
    event.stopPropagation()
    console.log(`event.currentTarget:${event.currentTarget.nodeName}`)
    console.log(`event.target:${event.target.nodeName}`)
    console.log(`h2 event`)
  })
   h2.addEventListener('click', (event) => {
  	console.log('h2 的第二个事件处理程序')
   })
</script>
```

### 事件捕获

事件执行顺序为 捕获 > 事件目标 > 冒泡，在向下传递到目标对象的过程即为事件捕获。事件捕获在实际使用中频率不高。

- 通过设置第三个参数为true或{ capture: true } 在捕获阶段执行事件处理程序

```javascript
const app = document.querySelector('#app')
const h2 = document.querySelector('h2')
app.addEventListener(
  'click',
  (event) => {
    console.log('app event')
  },
  { capture: true }
)
h2.addEventListener('click', (event) => {
  console.log(`h2 event`)
})
```

### 事件代理

借助冒泡思路，我们可以不为子元素设置事件，而将事件设置在父级。然后通过父级事件对象的event.target查找子元素，并对他做出处理。

- 这在为多个元素添加相同事件时很方便
- 会使添加事件变得非常容易

下面是为父级UL设置事件来控制子元素LI的样式切换

```html
<style>
  .hd {
    background-color: red;
  }
</style>
<ul><li>ELE1</li><li>ELE2</li></ul>
<script>
  'use strict'
  const ul = document.querySelector('ul')
  ul.addEventListener('click', ()=> {
    if(event.target.nodeName === 'LI') {
      event.target.classList.toggle('hd');
    }
  })
</script>
```

可以使用事件代理来共享事件处理程序，不用为每个元素单独绑定事件

```html
<ul>
  <li data-action="hidden">HIDDEN</li>
  <li data-action="color" data-color="red">COLOR</li>
</ul>
<script>
  class EventCreator {
    constructor(el) {
      el.addEventListener('click', (e) => {
        const action = e.target.dataset.action
        console.log(action);
        this[action](e) // 相当于 this.color(e)
      })
    }
    hidden() {
      event.target.hidden = true;
    }
    color() {
      event.target.style.color = event.target.dataset.color;
    }
  }
  new EventCreator(document.querySelector('ul'));
</script>
```

## 三、默认行为

JS中有些对象会设置默认事件处理程序，比如A链接在点击时会进行跳转。

一般默认处理程序会在用户定义的处理程序后执行，所以我们可以在我们定义的事件处理中取消默认事件处理程序的执行。

- 使用onclick绑定的事件处理程序，return false 可以阻止默认行为
- 推荐使用`event.preventDefault()`阻止默认行为

下面阻止超链接的默认行为

```html
<a href="https://www.houdunren.com">后盾人</a>
<script>
  document.querySelector('a').addEventListener('click', () => {
    event.preventDefault()
    alert(event.target.innerText)
  })
</script>
```

## 四、其他事件

### 文档和窗体事件

| 事件名              | 说明                                                         |
| ------------------- | ------------------------------------------------------------ |
| window.onload       | 文档解析及外部资源加载后                                     |
| DOMContentLoaded    | 文档解析后执行，不需要等待图片/样式文件等外部资源加载，该事件只能通过addEventListener设置 |
| window.beforeunload | 文档刷新或关闭时                                             |
| window.unload       | 文档卸载时                                                   |
| scroll              | 页面滚动时                                                   |

### 鼠标事件

| 事件名      | 说明                                                      |
| ----------- | --------------------------------------------------------- |
| click       | 鼠标单击事件，同时触发 mousedown/mouseup                  |
| dblclick    | 鼠标双击事件                                              |
| contextmenu | 点击右键后显示的所在环境的菜单                            |
| mousedown   | 鼠标按下                                                  |
| mouseup     | 鼠标抬起时                                                |
| mousemove   | 鼠标移动时                                                |
| mouseover   | 鼠标移动时                                                |
| mouseout    | 鼠标从元素上离开时                                        |
| mouseup     | 鼠标抬起时                                                |
| mouseenter  | 鼠标移入时触发，不产生冒泡行为                            |
| mosueleave  | 鼠标移出时触发，不产生冒泡行为                            |
| oncopy      | 复制内容时触发                                            |
| scroll      | 元素滚动时，可以为元素设置overflow:auto; 产生滚动条来测试 |

### 禁止复制

```html
<body>
  houdunren.com
  <script>
    document.addEventListener('copy', () => {
      event.preventDefault()
      alert('禁止复制内容')
    })
  </script>
</body>
```

### 键盘事件

针对键盘输入操作的行为有多种事件类型

| 事件名  | 说明                                              |
| ------- | ------------------------------------------------- |
| Keydown | 键盘按下时，一直按键不松开时keydown事件会重复触发 |
| keyup   | 按键抬起时                                        |

###  表单事件

下面是可以用在表单上的事件类型

| 事件类型        | 说明                                                         |
| --------------- | ------------------------------------------------------------ |
| focus           | 获取焦点事件                                                 |
| blur            | 失去焦点事件                                                 |
| element.focus() | 让元素强制获取焦点                                           |
| element.blur()  | 让元素失去焦点                                               |
| change          | 文本框在内容发生改变并失去焦点时触发，select/checkbox/radio选项改变时触发事件 |
| input           | Input、textarea或 select 元素的 `value` 被修改时，会触发 `input` 事件。而 change 是鼠标离开后或选择一个不同的option时触发。 |
| submit          | 提交表单                                                     |

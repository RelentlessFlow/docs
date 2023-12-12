# 一、CSS面试题

[toc]

## 一. CSS盒模型？分类？属性设置？

### 1. 盒模型定义

CSS基础框盒模型是CSS规范的-一个模块，它定义了一种长方形的盒子，包括它们各自的内边距( padding)与外边距( margin)，并根据视觉格式化模型来生成元素，对其进行布置、编排、布局(layout) 。常被直译为盒子模型、盒模型或框模型

一个完整的盒模型包括contentBox,paddingBox,borderBox,marginBox 四个部分。

### 2. 盒模型分类

standard-box和ie-box两种

ie盒模型与standard-box区别：

ie盒模型：box-sizing: border-box

Standard-box：box-sizing: content-box

## 二、BFC问题

### 1. BFC

块格式化上下文(BlockFomattingContext,BFC)是Web页面的可视CSS渲染的一部分，是块盒子的布局过程发生的区域，也是浮动元素与其他元素交互的区域。
简单的说BFC是一个完全独立的空间，这个空间里子元素的渲染不会影响到外面的布局。

### 2. 如果创建BFC

```html
<head>
  <style>
    section {
      background-color: red;
      color: black;
      width: 200px;
      line-height: 100px;
      text-align: center;
      margin: 50px;
    }
    .box-container {
      overflow: hidden;
      /* display: flex; */
      /* display: table-cell; */
      /* display: inline-block; */ 
    }
  </style>
</head>
<body>
  <section>box-one</section>
  <section>box-one</section>
</body>
```

两个盒子之间的上下margin间距为50px发生了margin 重叠(塌陷)， 以最大的为准，如果第-一个 section的margin为60的话，两个P之间的距离就是60，以最大的为准。

### 3. 如果解决

使用一个带有overflow:hiddren 的大盒子进行包裹。

```html
<head>
  <style>
    section {
      background-color: red;
      color: black;
      width: 200px;
      line-height: 100px;
      text-align: center;
      margin: 50px;
    }
    .box-container {
      overflow: hidden;
      /* display: flex; */
      /* display: table-cell; */
      /* display: inline-block; */ 
    }
  </style>
</head>
<body>
  <div class="box-container">
    <section>box-one</section>
  </div>
  <div class="box-container">
    <section>box-two</section>
  </div>
</body>
</html>
```

### 4. 创建BFC的方式

- display: table-cell
- display: flex
- display: inline-block
- overflow: hidden
- position: absolute
- position: fixed

完整的创建BFC的方式有如下込些:

1. 根元素（)

2. 浮幼元素(元素的foat不是none)
3. 絶対定位元素(元素的position カabsolute或fixed)
4. 行内快元素(元素的displayカinline-block )
5. 表格単元格(元素的displayカtable-cell, HTM表格単元格默圦カ垓値)
6. 表格柝題(元素的displayカtable- caption, HTMI表格柝題默人刃亥値)
7. 匿名表格単元格元素(元素的display:table、 table-row、 table-row group、table-header group、table footer-group (分別是HTMLtable、row、 tbody、 thead、 tfoot 的默认属性)或inline-table )

8. overflow 汁算値(Computed)不为visible 的块元素
9. display 値カflow-root的元素
10. contain 値カlayout、content 或paint的元素
11. 弹性元素(display 为flex 或inline- flex元素的直接子元素)
12. 网格元素(display 为grid或inline-gnid元素的直接子元素)
13. 多列容器(元素的column-count或column- width (en-US)不为auto,包括column-count为1)
14. column-span为all的元素始终会创建一-个新的BFC，即使该元素没有包裹在一个多列容器中(标准变更，Chromebug)。

### 5. BFC 解决了什么问题

1. margin重叠问题
2. float导致父容器高度塌陷问题

```css
<head>
	<style>
	.container {
      background-color: red;
      overflow: hidden;
      /* display: inline-block; */
      /* display: flex; */
  }
	.box {
      width: 100px;
      height: 100px;
      margin: 100px;
      background: blue;
      float: left;
  }
	</style>
</head>
<body>
  <div class="container">
    <div class="box"></div>
    <div class="box"></div>
  </div>
</body>
```

## 三、CSS选择器

### 1. CSS定义

**层叠样式表** (Cascading Style Sheets，缩写为 **CSS**），是一种 [样式表](https://developer.mozilla.org/zh-CN/docs/Web/API/StyleSheet) 语言，用来描述 [HTML](https://developer.mozilla.org/zh-CN/docs/Web/HTML) 或 [XML](https://developer.mozilla.org/zh-CN/docs/Web/XML/XML_Introduction)（包括如 [SVG](https://developer.mozilla.org/zh-CN/docs/Web/SVG)、[MathML](https://developer.mozilla.org/zh-CN/docs/Web/MathML)、[XHTML](https://developer.mozilla.org/zh-CN/docs/Glossary/XHTML) 之类的 XML 分支语言）文档的呈现。CSS 描述了在屏幕、纸质、音频等其它媒体上的元素应该如何被渲染的问题。（mdn）

### 2. CSS选择器有什么

标签选择器 `h1{}`		通配选择器 `*{}`		类选择器`.{}`		

ID选择器`#unique{}`		标签属性选择器`a[title]`		伪类选择器`p:first-child{}`

伪元素选择器`p:first-child{}`		后代选择器`article p`		子代选择器`article > p`

相邻兄弟选择器`hl + p`		通用兄弟选择器`hl ~ p `

### 3. 标签属性选择器

```css
<style>
    a[title] { color: purple; }
    a[href="https://exmaple.org"] {color: green;}
    /* 存在href属性并且在属性值包含'exmaple'的<a>元素 */
    a[href*='example'] {font-size: 2em;}
    /* 存在href属性并且属性值结尾是.org的<a>元素 */
    a[href$='org'] {font-style: italic;}
    /* 存在class属性并且属性值以空格分隔的'logo'的<a>元素 */
    a[class='logo'] {padding: 2px;}
</style>
```

### 4. 伪元素选择器

伪元素是一个附加至选择器末的关键词，允许你对被选择元素的特定部分修改样式。

```css
p::first-line {
	color: blue;
	 text-transform: uppercase; 
}
```

#### 标准伪元素索引

- [`::after (:after)`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::after)
- [`::backdrop`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::backdrop) 
- [`::before (:before)`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::before)
- [`::cue (:cue)`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::cue)
- [`::first-letter (:first-letter)`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::first-letter)
- [`::first-line (:first-line)`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::first-line)
- [`::grammar-error`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::grammar-error) 
- [`::marker`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::marker) 
- [`::placeholder`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::placeholder) 
- [`::selection`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::selection)
- [`::slotted()`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::slotted)
- [`::spelling-error`](https://developer.mozilla.org/zh-CN/docs/Web/CSS/::spelling-error) 

### 5. 通用兄弟选择器
通用兄弟选择器:位置无须紧邻，只须同层级，A~B 选择A元素之后所有同层级B元素。

```html
<head>
<style>
  p ~ span { color: red; }
<style/>
</head>
<body>
  <span>This is not red.</span>
  <p>Here is a paragraph.</p>
  <code>Here is some code.</code>
  <span>This is red</span>
  <span>This is red</span>
</body>
```

## 四、CSS 优先级

1. 什么是CSS优先级？

   CSS优先级是基于不同选择器组成的匹配规则。

2. CSS选择级的优先级？

!import > 行内样式 > ID选择器 > 类、伪类、属性选择器> 标签、伪元素选择器 > 通配符、子类选择器、兄弟选择器

## 五、CSS属性继承

CSS可以继承的属性：

- 字体：font，font-family，font-size，font-style，font-variant，font-weight
- 字母间距：letter-spacing
- 文字展示：line-height，text-align，text-ident，text-transfrom
- 字间距：word-spacing

## 六、px/em/vm/vh

#### px/em/rem/vw/vh的概念

- px:就是pixel像素的缩写，可以简单理解为网页开发的基本长度单位
- em: em是一个相对长度单位，相对于当前元素内文本的字体尺寸。
- rem: rem是CSS3新增的-一个相对单位，基于html 元素的字体大小来决定，通常配合媒体查询用于解决移动端适配问题。
- vw和vh: vw和vh是相对于视口的长度单位，1vw即值为视口宽度的1%，1vh意味着值为视口高度的1 %。

#### 面试口诀: 一绝三香(相)
px:	绝对单位，网页开发基本长度单位
em:	相对单位，相对当前盒子字体大小进行计算
rem:	相对单位，相对根元素html字体大小进行计算
vw+vh:	相对单位，相对当前网页视口宽度和高度进行计算

## 七、CSS实现左边定宽，右边自适应

非严格意义

- float+calc
- inline-block-calc
- postion+padding

严格意义

- flex布局
- table布局
- grid布局

### 1. float + calc实现

width: calc(100% - 200px); float:left

```html
<head>
	<style>
    * {margin: 0; padding: 0;}
    .box-wrapper {
      width: 600px; height: 400px;
      border: 1px solid #000;
    }
    .left-box {
      float: left; width: 200px; height: 100%;
      background: red;
    }
    .right-box {
      float: right; 
      width: calc(100% - 200px); height: 100%;
      background: blue;
    }
  </style>
</head>
<body>
	<div class="box-wrapper">
    <div class="left-box">left-box</div>
    <div class="right-box">right-box</div>
  </div>
</body>
```

### 2. inline-block-calc实现

和float差不多，都是通过cal属性进行宽度的计算 

display: inline-block; width: calc(100% - 200px); 

```css
* {margin: 0; padding: 0; letter-spacing: 0;}
    .box-wrapper {
      width: 600px; height: 400px;
      border: 1px solid #000;
      font-size: 0;
    }
    .left-box {
      display: inline-block;
      width: 200px; height: 100%;
      background: red;
    }
    .right-box {
      display: inline-block;
      width: calc(100% - 200px); height: 100%;
      background: blue;
    }
```

### 3. postion + padding实现

absolute相当于一个块把底下那个块覆盖了

```css
* {margin: 0; padding: 0; letter-spacing: 0;}
    .box-wrapper {
      width: 600px; height: 400px;
      position: relative;
      border: 1px solid #000;
    }
    .left-box {
     width: 200px; height: 100%;
     background-color: red;
     position: absolute;
    }
    .right-box {
      padding-left: 200px;
      height: 100%;
      background-color: blue;
    }
```

### 4. Flex实现

设置父容器display: flex ，设置子容器flex:1，容器会自动撑满父容器。

```css
* {margin: 0; padding: 0;}
.box-wrapper {
  display: flex;
  width: 600px;
  height: 400px;
  border: 1px solid #000;
}
.left-box {
  width: 200px;
  height: 100%;
  background: red;
}
.right-box {
  flex: 1;
  background: blue;
}
```

### 5. Table实现

设置父容器display: table ，设置子容器display: table-ceil;

```css
* {margin: 0; padding: 0;}
    .box-wrapper {
      display: table;
      width: 600px;
      height: 400px;
      border: 1px solid #000;
    }
    .left-box {
      display: table-cell;
      width: 200px;
      height: 100%;
      background: red;
    }
    .right-box {
      display: table-cell;
      flex: 1;
      background: blue;
    }
```

### 6. Gird实现

设置父容器display: gird; grid-template-columns: 200px auto;

```css
* {margin: 0; padding: 0;}
    .box-wrapper {
      display: grid;
      grid-template-columns: 200px auto;
      width: 600px;
      height: 400px;
      border: 1px solid #000;
    }
    .left-box {
      background: red;
    }
    .right-box {
      background: blue;
    }
```

## 八、CSS实现绝对居中

- 定宽高
  - 绝对定位 + 负margin值
  - 绝对定位 + margin auto
- 不定宽高
  - 绝对定位 + transform
  - table-cell
  - flex布局

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009182151390.png" alt="image-20221009182151390" style="zoom:50%;" />

### 1. 绝对定位 + 负margin值 实现

1. 父元素position: relative; 子元素设置position: absolute;

2. 子元素设置margin-left: -50px;(元素自身宽度的一半)

```html
<head>
  <style>
    .box-wrapper {
      position: relative;
      height: 300px; width: 300px;
      border: 1px solid red;
    }
    .box {
      position: absolute;
      top: 50%; left: 50%;
      margin-left: -60px; margin-top: -60px;
      height: 120px; width: 120px;
      background: blue;
    }
  </style>
</head>
<body>
  <div class="box-wrapper">
    <div class="box" />
  </div>
</body>
```

### 2. 绝地定位 + margin: auto 实现

```css
.box-wrapper {
      position: relative;
      height: 300px; width: 300px;
      border: 1px solid red;
    }
    .box {
      position: absolute;
      top: 0;  bottom: 0;  /* 垂直居中 */
      right: 0; left: 0; /* 水平居中 */
      margin: auto;
      height: 100px; width: 100px;
      background: blue;
    }
```

### 3. 绝对定位 + transfrom 实现

> 类似于绝对定位 + 负margin值

父元素设置position: relative;

子元素设置   position: absolute;  left: 50%; top: 50%; 

 **transform: translate(-50%, -50%);**

```css
.box-wrapper {
  position: relative;
  height: 300px; width: 300px;
  border: 1px solid red;
}
.box {
  position: absolute;
  left: 50%; top: 50%;
  transform: translate(-50%, -50%);
  margin: auto;
  height: 100px; width: 100px;
  background: blue;
}
```

### 4. Flex布局 实现

```css
.box-wrapper {
    display: flex;
    justify-content: center;
    align-items: center;
    width: 300px; height: 300px;
    border: 1px solid red;
}
.box {
    height: 100px; width: 100px;
    background: blue;
}
```

## 八、CSS 清除浮动

为什么要清楚浮动？

```html
<head>
<style>
    .box-container {
      width: 142px; padding: 10px; 
      border: 1px solid red;
    }
    .img {
      width: 45px; height: 45px; 
      float: left; margin-right: 10px;
    }
    .right-box { float: right; }
    .right-box-title {
      font-size: 16px; color: aqua;
    }
    .right-box-content {
      font-size: 12px; color: blueviolet;
    }
  </style>
</head>
<body>
  <div class="box-container">
    <div class="img"></div>
    <div class="right-box">
      <div class="right-box-title">java工程师</div>
      <div class="right-box-content">综合就业率第一</div>
    </div>
  </div>
</body>
```

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009182159592.png" alt="image-20221009182159592"  />

Float 设置过的元素不占用原本的文档流，会导致父容器高度塌陷

解决办法：

- 父元素固定宽高
  - 优点:简单，代码量少，没有兼容问题
  - 缺点:内部元素高度不确定的情况下无法使用
    优点:简单，代码量少，没有兼容问题
- 添加新元素
	- 缺点:需要添加无语义的html元素，代码不够
	- 优雅，不便于后期的维护
 - 使用伪元素
    - 优点:仅用css实现，不容易出现怪问题
    - 缺点:仅支持IE8以上和非IE浏览器
- 触发父元素BFC
	- 优点:仅用css实现，代码少，浏览器支持好
	- 缺点:用overflow: hidden触发BFC的情况下，可能会使内部本应正常显示的元素被裁剪

### 1. 添加新元素实现

在父容器添加一个属性为clear:both的元素把父容器的高度撑起来。

```html
<head>
  <style>
  .clear-element { clear: both; }
  </style>
</head>
<body>
  <div class="box-container">
    <div class="img"></div>
    <div class="right-box">
      <div class="right-box-title">java工程师</div>
      <div class="right-box-content">综合就业率第一</div>
    </div>
    <div class="clear-element"></div>
  </div>
</body>
```

### 2. 伪元素实现

和第一种实现方式很相似，只不过它的元素是使用伪类创建的。

```css
.box-container::after {
		display: block; clear: both;
	 	content: ""; height: 0;
}
```

### 3. 触发BFC实现

在父容器添加属性overflow: hidden 触发文档bfc

```
.box-container {
      width: 142px; padding: 10px; 
      border: 1px solid red;
      overflow: hidden; /* 触发bfc */
}
```

其他处理bfc问题的解决办法可以参考问题二。

## 九、CSS画三角形

```html
<style>
  .triangle {
      /* transparent 透明的 */
      width: 0; border: 10px solid transparent;
      /* border-top 三角的位置相反，top三角朝下 */
      border-top: 10px solid #f40;
      border-left: 10px solid #f40;
      border-bottom: 10px solid #f40;
      border-right: 10px solid #f40;
    }
</style>
<div class="triangle"></div>
```

CSS画三角形可以避免发送HTTP请求，节约带宽。

## 十、CSS如何三栏布局

### 1. 浮动布局实现

- 优点:浮动布局兼容性好
- 缺点:大部分业务场景下无缺点

### 2. table布局实现

-  优点：兼容性好
- 缺点：table布局落后

```html
<style>
    * {margin: 0;padding: 0;}
    .box {width: 100%; display: table; height: 100px;}
    div {display: table-cell;}
    .left {width: 100px; background: red;}
    .center {background: green;}
    .right {width: 100px; background: blue;}
</style>
<body>
  <div class="box">
    <div class="left">left</div>
    <div class="center">center</div>
    <div class="right">right</div>
  </div>
</body>
```

### 3. 定位布局实现（绝对相对定位）

- 使用简单
- 大部分业务场景无缺点

```html
<style>
  * {margin: 0;padding: 0;}
  .box {position: relative;}
  div {height: 100px; position: absolute;}
  .left {left: 0px; width: 100px; background: red;}
  .center {left: 100px; right: 100px; background: green;}
  .right {right: 0px;width: 100px;background: blue;}
</style>
<body>
  <div class="box">
    <div class="left">left</div>
    <div class="center">center</div>
    <div class="right">right</div>
  </div>
</body>
```

### 4. Flex布局实现

- PC端仅支持IE9以上浏览器

```css
* {margin: 0;padding: 0; }
div {height: 100px; display: flex;}
.left {width: 100px; background: red;}
.center {flex: 1; background: green;}
.right {width: 100px;background: blue;}
```

## 十一、CSS性能优化

- 属性简写：减少生产包体积
- 图标替换：减少http请求节约带宽
- 删除0和单位：减少生产包体积
- 背景图和精灵图：减少http请求节约带宽

### 1. 属性设置使用简写

```css
p {
	margin-top: 10px;
	margin-right: 20px;
	margin-bottom: 30px;
	margin-left: 40px;
}

p{ margin: 10px 20px 30px 40px }
```

### 2. 用CSS替换图片

1. 用CSS画三角形
2. 用CSS画箭头
3. 用CSS画圆形

### 3. 删除不必要的0和单位

```css
.box { width: 0.2em; padding: 0px; }
.box { width: .2em; padding: 0 }
```

### 4. 用css精灵图代替单个文件加载

其实说白了就是将精灵图设为一个大背景，然后通过background-position来移动背景图，从而显示出我们想要显示出来的部分。

精灵图虽然实现了缓解服务器压力以及用户体验等问题，但还是有一个很大的不足，那就是牵一发而动全身。这些图片的背景都是我们详细测量而得出来的，如果需要改动页面，将会是很麻烦的一项工作。。。

## N、补充

### 1. 匿名表格単元格元素

**`display`** 属性可以设置元素的内部和外部显示类型 *display types*。元素的外部显示类型 *outer display types* 将决定该元素在[流式布局](https://developer.mozilla.org/zh-CN/docs/Web/CSS/CSS_Flow_Layout)中的表现（[块级或内联元素](https://developer.mozilla.org/zh-CN/docs/Web/CSS/CSS_Flow_Layout)）；元素的内部显示类型 *inner display types* 可以控制其子元素的布局（例如：[flow layout](https://developer.mozilla.org/zh-CN/docs/Web/CSS/CSS_Flow_Layout)，[grid](https://developer.mozilla.org/zh-CN/docs/Web/CSS/CSS_Grid_Layout) 或 [flex](https://developer.mozilla.org/zh-CN/docs/Web/CSS/CSS_Flexible_Box_Layout)）。

#### Internal

<display-internal>

有些布局模型（如 `table` 和 `ruby`）有着复杂的内部结构，因此它们的子元素可能扮演着不同的角色。这一类关键字就是用来定义这些“内部”显示类型，并且只有在这些特定的布局模型中才有意义。

display: table-cell 类似inline-block

```
table-cell
```

These elements behave like `](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/td) HTML elements.

```
table-row
```

These elements behave like HTML elements.

### 2. inline-block间隙问题

问题：

在使用display:inline-block列表布局经常会遇到“换行符/空格间隙问题”。如下：

```html
<head>
    <meta charset="UTF-8">
    <title>inline-block的空隙问题</title>
    <style>
        * {
            margin: 0;
            padding: 0;
        }
        .box {
            padding: 20px;
        }
        .main{
            display: inline-block;
            width: 100px;
            height: 100px;
            background-color: lightpink;
        }
    </style>
</head>
<body>
<div class="box">
    <div class="main"></div>
    <div class="main"></div>
</div>
</body>
```

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009182210561.png" alt="image-20221009182210561" style="zoom:80%;" />

解决方案：

添加CSS`font-size:0;letter-spacing: -3px;`

```css
* {
margin: 0;
padding: 0;
/* Chrome/IE6/IE7兼容性较差 */
font-size: 0;
/* 换行符间隙清零 */
letter-spacing: -3px;
}
```


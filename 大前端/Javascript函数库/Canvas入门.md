# 一、Canvas的基本用法

> 参考资料：https://developer.mozilla.org/zh-CN/docs/Web/API/Canvas_API

**Canvas API** 提供了一个通过[JavaScript](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript) 和 [HTML](https://developer.mozilla.org/zh-CN/docs/Web/HTML)的[``](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Element/canvas)元素来绘制图形的方式。它可以用于动画、游戏画面、数据可视化、图片编辑以及实时视频处理等方面。

Canvas API主要聚焦于2D图形。而同样使用`<canvas>`元素的 [WebGL API](https://developer.mozilla.org/zh-CN/docs/Web/API/WebGL_API) 则用于绘制硬件加速的2D和3D图形。

## 一、Canvas元素

```html
<canvas id="tutorial" width="150" height="150"></canvas>
```

- 与img标签很像，但是它并没有 src 和 alt 属性
- `<canvas>` 标签只有两个属性**——** [`width`](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Element/canvas#attr-width)和[`height`](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Element/canvas#attr-height)。这些都是可选的，并且同样利用 [DOM](https://developer.mozilla.org/zh-CN/docs/Glossary/DOM)[properties](https://developer.mozilla.org/zh-CN/docs/Web/API/HTMLCanvasElement) 来设置。
- 没有设置宽度和高度，canvas会初始化宽度为300像素和高度为150像素。
- 元素可以使用[CSS](https://developer.mozilla.org/zh-CN/docs/Glossary/CSS)来定义大小，但在绘制时图像会伸缩以适应它的框架尺寸
- **需要**结束标签(`</canvas>`)。

## 二、渲染上下文（The rendering context）

- [`Canvas`](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Element/canvas) 元素创造了一个固定大小的画布，它公开了一个或多个**渲染上下文**，其可以用来绘制和处理要展示的内容。
- 其他种类的上下文也许提供了不同种类的渲染方式； [WebGL](https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API) 使用了基于[OpenGL ES](https://www.khronos.org/opengles/)的3D上下文 ("experimental-webgl") 。
- Canvas元素有一个叫做 [`getContext()`](https://developer.mozilla.org/zh-CN/docs/Web/API/HTMLCanvasElement/getContext) 的方法，这个方法是用来获得渲染上下文和它的绘画功能。`getContext()`接受一个参数，即上下文的类型。对于2D图像而言，如本教程，你可以使用 [`CanvasRenderingContext2D`](https://developer.mozilla.org/zh-CN/docs/Web/API/CanvasRenderingContext2D)。

```javascript
var canvas = document.getElementById('tutorial');
var ctx = canvas.getContext('2d');
```

## 三、检查支持性

通过简单的测试`getContext()`方法的存在，脚本可以检查编程支持性。

```javascript
var canvas = document.getElementById('tutorial');

if (canvas.getContext){
  var ctx = canvas.getContext('2d');
  // drawing code here
} else {
  // canvas-unsupported code here
}
```

## 四、模版骨架

```html
<html>
  <head>
    <title>Canvas tutorial</title>
    <script type="text/javascript">
      function draw(){
        var canvas = document.getElementById('tutorial');
        if (canvas.getContext){
          var ctx = canvas.getContext('2d');
        }
      }
    </script>
    <style type="text/css">
      canvas { border: 1px solid black; }
    </style>
  </head>
  <body onload="draw();">
    <canvas id="tutorial" width="150" height="150"></canvas>
  </body>
</html>
```

上面的脚本中包含一个叫做draw()的函数，当页面加载结束的时候就会执行这个函数。通过使用在文档上加载事件来完成。只要页面加载结束，这个函数，或者像是这个的，同样可以使用 [`window.setTimeout()` (en-US)](https://developer.mozilla.org/en-US/docs/Web/API/setTimeout)， [`window.setInterval()` (en-US)](https://developer.mozilla.org/en-US/docs/Web/API/setInterval)，或者其他任何事件处理程序来调用。

### TS项目骨架

```typescript
function draw():void {
  const canvas = <HTMLCanvasElement>document.getElementById('canvas');
  const ctx = canvas.getContext('2d');
  ctx?.fillRect(25, 25, 100, 100);
  ctx?.clearRect(45, 45, 60, 60);
  ctx?.strokeRect(50, 50, 50 ,50);
}
```

# 二、使用Canvas来绘制图形

## 一、珊格

Canvas元素默认被网格覆盖，通常来说网格中的一个单元相当于canvas元素中的一像素。栅格的起点为左上角（坐标为（0,0））。所有元素的位置都相对于原点定位。所以图中蓝色方形左上角的坐标为距离左边（X轴）x像素，距离上边（Y轴）y像素（坐标为（x,y））。

![img](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/Canvas_default_grid.png)

## 二、绘制矩形

canvas提供了三种方法绘制矩形：

- [`fillRect(x, y, width, height)`](https://developer.mozilla.org/zh-CN/docs/Web/API/CanvasRenderingContext2D/fillRect)

  绘制一个填充的矩形

- [`strokeRect(x, y, width, height)`](https://developer.mozilla.org/zh-CN/docs/Web/API/CanvasRenderingContext2D/strokeRect)

  绘制一个矩形的边框

- [`clearRect(x, y, width, height)`](https://developer.mozilla.org/zh-CN/docs/Web/API/CanvasRenderingContext2D/clearRect)

  清除指定矩形区域，让清除部分完全透明。

### 绘制矩形例子

```typescript
function draw():void {
  const canvas = <HTMLCanvasElement>document.getElementById('canvas');
  const ctx = canvas.getContext('2d');
  ctx?.fillRect(25, 25, 100, 100);
  ctx?.clearRect(45, 45, 60, 60);
  ctx?.strokeRect(50, 50, 50 ,50);
}
```

![image-20220414152042927](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20220414152042927.png)

## 三、绘制路径

### 1、 绘制路径步骤

1. 首先，需要创建路径起始点。`beginPath();`

2. 然后使用画图敏玲去画出路径`stroke()`
3. 之后把路径封闭。`closePath()`
4. 一旦路径生成，你就能通过描边或者填空路径来渲染图形`fill()`

### 2、函数API

- `beginPath()`新建一条路径，生成之后，图形绘制命令被指向到路径上生成路径。

- `closePath()`闭合路径之后图形绘制命令又重新指向到上下文中。
- `stroke()` 通过线条来绘制图形轮廓。
- `fill()`过填充路径的内容区域生成实心的图形。
- `arc()`绘制圆

```typescript
interface CanvasPath {
  	// x,y：圆心位置，radius：半径 startAngle:开始弧度
    arc(x: number, y: number, radius: number, startAngle: number, endAngle: number, counterclockwise?: boolean): void;
    arcTo(x1: number, y1: number, x2: number, y2: number, radius: number): void;
    bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number): void;
    closePath(): void;
    ellipse(x: number, y: number, radiusX: number, radiusY: number, rotation: number, startAngle: number, endAngle: number, counterclockwise?: boolean): void;
    lineTo(x: number, y: number): void;
    moveTo(x: number, y: number): void;
    quadraticCurveTo(cpx: number, cpy: number, x: number, y: number): void;
    rect(x: number, y: number, w: number, h: number): void;
}
```

`arc()`

- startAngle=0 它绘制圆从半径中间右侧的位置开始。

- 它的绘制方法默认为顺时针。
- anticlockwise为false 相当于显示它的绘制轨迹
- anticlockwise为true 相当于显示它的没有绘制完的区域
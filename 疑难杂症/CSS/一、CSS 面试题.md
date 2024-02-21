# CSS 面试题

## 一、布局

### 圣杯布局

核心思路：

1. 给外层设置postion left 和posting right
2. 给中间盒子 设置width 100%
3. 给左边盒子设置margin-right 为100%，position: relative, right: $leftSideWidth
4. 给右边盒子设置maigin-right 为 自身宽度

完整代码

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <style>
        *, body, header, footer, main, section {
            margin: 0;
            padding: 0;
        }

        body {
            min-width: 550px;
            background: gainsboro;
            margin: 10px;
            border: 1px solid black;
        }

        header {
            background-color: yellow;
        }

        footer {
            background-color: yellow;
            clear: both;
        }

        main {
            background-color: aquamarine;
            padding: 0 150px 0 200px;
        }

        main section.column {
            float: left;
        }

        main section.column.left {
            width: 200px;
            margin-right: -100%;
            position: relative;
            right: 200px;
            background-color: violet;
        }

        main section.column.main {
            width: 100%;
            background-color: red;
        }

        main section.column.right {
            width: 150px;
            background-color: beige;
            margin-right: -150px;
        }

    </style>
</head>
<body>
    <header>header</header>
    <main>
        <section class="left column">
            left
        </section>
        <section class="main column">
            main
        </section>
        <section class="right column">
            right
        </section>
    </main>
    <footer>footer</header>
</body>
</html>
```

### 双飞翼布局

核心思路

1. 三个拦，main里套个wrapper
2. main 设置 100%，wrapper 设置 左右外边距
3. 左边栏 设置 margin-left: -100%
4. 右边拦 设置 margin-left: -190px

完整代码

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>

    <style>
        *, body, main, header, footer, aside {
            padding: 0;
            margin: 0;
        }

        body {
            min-width: 500px;
        }

        main.main {
            width: 100%;
            height: 200px;
            background-color: #ccc;
        }

        main.main .main-wrapper {
            margin: 0 190px 0 190px;
        }

        aside.left {
            width: 190px;
            height: 200px;
            background-color: aqua;
            margin-left: -100%;
        }

        aside.right {
            width: 190px;
            height: 200px;
            background-color: yellow;
            margin-left: -190px;
        }

        .column {
            float: left;
        }
    </style>

</head>
<body>
    <main class="column main">
        <div class="main-wrapper">main</div>
    </main>
    <aside class="column left">left</aside>
    <aside class="column right">right</aside>
</body>
</html>
```

### 三个色子

核心思路

外面套一个flex盒子，里面三个，第一个align-selft: flex-start，第二个align-selft:center，第三个align-selft:flex-end

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <style>
        .container {
            width: 500px;
            height: 500px;
            background: antiquewhite;
            display: flex;
            justify-content: space-between;
        }

        .container .item {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background-color: gray;
        }

        .container .item:nth-child(2) {
            align-self: center;
        }

        .container .item:nth-child(3) {
            align-self: flex-end;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="item"></div>
        <div class="item"></div>
        <div class="item"></div>
    </div>
</body>
</html>
```

### 水平居中

inline元素：text-align: center

block元素：margin：auto

absolite元素：left：50% + margin-left 负值

### 垂直居中

inline元素：line-height 的 值等于height

absolute：top：50% + margin-top 负值

absolute：transform（-50%，-50%）

absolute：top left right，buttom = 0 + margin：auto

### line-height

- 一般直接继承
- 1.5 为 当前font-size * 1.5
- 百分比 为 body * 200%

```css
/* 第一种情况 */
body { font-size: 20px; line-height: 50px; }
p { font-size: 16px; } /* line-height: 50px */

/* 第二种情况 */
body { font-size: 20px; line-height: 1.5; }
p { font-size: 16px; } /* line-height: 24px */

/* 第三种情况！！！ */
body { font-size: 20px; line-height: 200%; }
p { font-size: 16px; } /* line-height: 40px */
```

### 移动端响应式

**rem + 媒体查询**

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/image-20240221145850430.png" alt="image-20240221145850430" style="zoom:50%;" />=

rem 是长度单位，实际长度为根元素 * rem

可以配合媒体查询做响应式，缺点是有阶梯形

**vh、vh**

 网页视口宽度，但是在微前端和iframe中 无法保证视口宽度为整个网页，导致长度计算失效
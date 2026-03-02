## 内容垂直水平居中

核心代码

```css
		flex-direction: column; // 列排列 row 行排列
		display: -webkit-flex; /* Safari */
    -webkit-justify-content: center; /* Safari 6.1+ */
	  align-items: center; // 垂直
    display: flex;
    justify-content: center; // 水平
		flexBasis: 20 // 弹性盒元素的长度
```



```html
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>菜鸟教程(runoob.com)</title>
<style>
#main {
    width: 400px;
    height: 150px;
    border: 1px solid #c3c3c3;
    display: -webkit-flex; /* Safari */
    -webkit-justify-content: center; /* Safari 6.1+ */
	  align-items: center;
    display: flex;
    justify-content: center;
}

#main div {
    width: 70px;
    height: 70px;
}
</style>
</head>
<body>

<div id="main">
  <div style="background-color:coral;"></div>
  <div style="background-color:lightblue;"></div>
  <div style="background-color:khaki;"></div>
  <div style="background-color:pink;"></div>
</div>

<p><b>注意:</b> Internet Explorer 10 及更早版本浏览器不支持 justify-content 属性。</p>
<p><b>注意:</b> Safari 6.1 及更新版本通过 -webkit-justify-content 属性支持该属性。</p>

</body>
</html>
```


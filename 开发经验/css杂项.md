## 技巧

#### 1. 按钮和背景常用颜色

```css
background: linear-gradient(to bottom, #f3f3f3, #ddd, #f3f3f3); /* 按钮颜色 */
background-color: #ddd; /* 背景色 */
```

### 好看的滑动条

#### 2. CSS3 appearance 属性

使 div 元素看上去像一个按钮：

也可以取消一些类似range input的高亮效果

```css
div{
appearance:button;
-moz-appearance:button; /* Firefox */
-webkit-appearance:button; /* Safari and Chrome */
}

```

#### 3. ::-webkit-slider-thumb（滑动条的按钮）

> https://developer.mozilla.org/zh-CN/docs/Web/CSS/::-webkit-slider-thumb

这是type为range的input标签内的一种伪类样式,用于设置range的滑块的具体样式,该伪类只在内核为webkit/blink的浏览器中有效

```css
input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  height: 20px;
  width: 20px;
  background: #FF8A65;
  border-radius: 50%;
  cursor: pointer;
}
```

#### 4. 利用transform实现div快速居中

```css
.right #title {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  text-transform: capitalize;
}
```

#### 5. 英文单词首字母大写

> https://www.w3school.com.cn/cssref/pr_text_text-transform.asp

```
text-transform: capitalize;
```

#### 6. CSS :before 选择器

在每个 <p> 元素的内容之前插入新内容：

```css
p:before
{ 
  content:"台词：";
  color: #fff;
  font-size: 20px;
}
```

#### 6. 背景图片缩放

```css
background: url(${pic1});
background-size: contain;
```

#### 7. 段落样式

```css
p{
  display: block;
  margin-block-start: 1em;
  margin-block-end: 1em;
  margin-inline-start: 0px;
  margin-inline-end: 0px;
}
```

#### 8. （微信小程序）限制两行文字，超出行数隐藏。

不知道为啥，写死的

```css
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  text-overflow: ellipsis;
```

### 9. CSS. 同心圆

```css
width: 15px;
height: 15px;
border-radius: 50%;
padding: 3px;
border: 1px solid $colorD;
background-color: $colorD;
background-clip:content-box;
```

### 10. 纯CSS实现点击div显示隐藏

```html
<div>
  <label for="checkbox">菜单</label>
  <input id="checkbox" type="checkbox" />
  <p class="menu">我是一个菜单呀</p>
</div>

<style>
  #checkbox {
    display:none;
  }
  #checkbox:checked ~ .menu   {
    display:block;
  }
  #checkbox ~ .menu {
    display:none;
  }
</style>
```

### 11、居中自动剪裁图片

```css
.cover { object-fit: cover; }
```

### 12、图片1比1自适应 9宫格

```jsx
<div className={'pictures'}>
	<Grid columns={3} gap={7}>
		{pop.img.map(item => (
			<Grid.Item><div className={'picture'}><Image src={item} fit='fill' /></div></Grid.Item>
		))}
	</Grid>
</div>
```

```css
.pictures {
	.picture {
		position: relative;
		width: 100%;
		padding-bottom: 100%;
	.		adm-image {
				position: absolute; top: 0; left: 0; width: 100%; height: 100%;
			}
		}
  }
}
```

### 13、CSS Module

:global 取第三方组件内class

```less
@import '@/styles/index.less';

.calendar {

    &_dot {
        font-family: 800;
        font-size: 40px;
        color: @primaryColor;
        margin-top: 10px;

        :global(.van-calendar__selected-day) & {
            color: @textColor-8;
        }
    }
}
```


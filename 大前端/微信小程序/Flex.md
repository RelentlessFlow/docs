# Flex 详解

```css
.container {
  height: 700rpx;
  background-color: gray;

  display: flex;
  /* main-axis 方向 */
  flex-direction: row;
  /* main-axis 排列方式 */
  justify-content: center;
  /* cross-axis排列方式 */
  align-items: center;
  /* 处理换行 */
  /* main-axis空间不足item，是否换行 */
  flex-wrap: wrap;
  /* 多行item cross-axis 排列方式 ，可以覆盖item设置的align-self */
  align-content: center; 
  
} 

/* 处理item排列方式 */
.box {
  width: 150rpx;
  height: 150rpx;
  font-size: 40rpx;

  /* 可以通过align-self 覆盖flex container 设置的align-items */
  align-self: flex-start;
}
.order1 {
  order: -1;  /*决定flex items的排布顺序*/
}

/* flex-grow 决定了flex items如何扩展 (不同于flex直接通过父容器计算size，它通过剩余size计算)
  当flex container 在main axis方向上有剩余得size时，flex-grow属性才会有效
  如果所有flex items 的flex-grow 综合sum不超过1，这直接乘以剩余size就是扩展大小
  如果超过1 扩展size=剩余size*flex-grow/sum
*/
/* flex-shrink 和 flex-grow 相反，flex-grow 使剩余空间使得item size膨胀，flex-shrink是item size 超过父容器，使item收缩
*/
/*
  flex-basis 可以重新设置item占据主轴的空间
*/
.color1 { background-color: red;}
.color2 { background-color: yellow;}
.color3 { background-color: blue;flex-basis: 300rpx;}
```


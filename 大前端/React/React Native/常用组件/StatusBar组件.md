# StatusBar

>控制应用状态栏的组件。

## 和导航器一起使用的注意事项[#](https://reactnative.cn/docs/statusbar#和导航器一起使用的注意事项)

由于`StatusBar`可以在任意视图中加载，可以放置多个且后加载的会覆盖先加载的。因此在配合导航器使用时，请务必考虑清楚`StatusBar`的放置顺序。

````javascript
/**
 * 状态栏组件案例
 */
const StatusBarDemo = () => {
  // 状态栏样式类型，默认，黑色，白色
  const styleTypes = ['default',
    'dark-content', 'light-content'];
  const [statusBarStyle,setStatusBarStyle] 
    = useState(styleTypes[0]);
  // 循环修改状态栏样式类型
  const changeStatusBarStyle = () => {
    const styleId = styleTypes.indexOf(statusBarStyle) + 1;
    setTextVarios(styleId);
    if(styleId == styleTypes.length) {
      return setStatusBarStyle(styleTypes[0]);
    }
    return setStatusBarStyle(styleTypes[styleId]);
  }
  // 状态栏可见性 
  const [statusBarVisable,setStatusBarVisable] 
    = useState(true);
  const changeStatusBarVisable = () => {
    setStatusBarVisable(!statusBarVisable);
  }

  const [textVarios,setTextVarios] 
    = useState("测试变量")

  return (
    <View style={style_StatusBarDemo.textStyle}>
      <StatusBar 
        hidden={!statusBarVisable}
        barStyle={statusBarStyle}
      />
      <Text style={style_StatusBarDemo.textStyle}>
        StatusBar status is {statusBarStyle} !
        StatusBar Visibility: {!statusBarVisable ? 'Hidden': 'Visable'}      </Text>
      <Button title="change StatusBar Style"
        onPress={() => {changeStatusBarStyle()}}
      />
      <Button title="change StatusBar Visable"
        onPress={() => {changeStatusBarVisable()}}
      />
      <Text>{textVarios}</Text>
    </View>
  )
}
const style_StatusBarDemo = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: '#ECF0F1',
  },
  textStyle: {
    textAlign: 'center'
  }
})
````

## 静态 API[#](https://reactnative.cn/docs/statusbar#静态-api)

有些场景并不适合使用组件，因此`StatusBar`也暴露了一个静态 API。然而不推荐大家同时通过静态 API 和组件来定义相同的属性，因为静态 API 定义的属性值在后续的渲染中会被组件中定义的值所覆盖。

### `setBackgroundColor()`[#](https://reactnative.cn/docs/statusbar#setbackgroundcolor)

```jsx
static setBackgroundColor(color: string, [animated]: boolean)
```

设置状态栏的背景色。仅限 Android。

**参数：**

| 名称     | 类型    | 必需 | 说明             |
| :------- | :------ | :--- | :--------------- |
| color    | string  | 是   | 背景色           |
| animated | boolean | 否   | 是否启用过渡动画 |

### `setBarStyle()`[#](https://reactnative.cn/docs/statusbar#setbarstyle)

```jsx
static setBarStyle(style: StatusBarStyle, [animated]: boolean)
```

设置状态栏的样式

**参数：**

| 名称     | 类型                                                         | 必需 | 说明               |
| :------- | :----------------------------------------------------------- | :--- | :----------------- |
| style    | [StatusBarStyle](https://reactnative.cn/docs/statusbar#statusbarstyle) | 是   | 要设置的状态栏样式 |
| animated | boolean`setHidden()`[#](https://reactnative.cn/docs/statusbar#sethidden) | 否   | 是否启用过渡动画   |

### `setHidden()`[#](https://reactnative.cn/docs/statusbar#sethidden)

```jsx
static setHidden(hidden: boolean, [animation]: StatusBarAnimation)
```

显示／隐藏状态栏

**参数：**

| 名称      | 类型                                                         | 必需 | 说明                             |
| :-------- | :----------------------------------------------------------- | :--- | :------------------------------- |
| hidden    | boolean                                                      | 是   | 是否隐藏状态栏                   |
| animation | [StatusBarAnimation](https://reactnative.cn/docs/statusbar#statusbaranimation) | 否   | 改变状态栏显示状态的动画过渡效果 |

### **StatusBarAnimation[#](https://reactnative.cn/docs/statusbar#statusbaranimation)常量：**

| VALUE | 说明     |
| :---- | :------- |
| none  | 没有动画 |
| fade  | 渐变效果 |
| slide | 滑动效果 |

### StatusBarStyle[#](https://reactnative.cn/docs/statusbar#statusbarstyle)

| VALUE         | 说明                                             |
| :------------ | :----------------------------------------------- |
| default       | 默认的样式（IOS 为白底黑字、Android 为黑底白字） |
| light-content | 黑底白字                                         |
| dark-content  | 白底黑字（需要 Android API>=23）                 |


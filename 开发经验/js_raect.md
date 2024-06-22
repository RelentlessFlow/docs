# 开发经验

## JavaScript

### *用于更新复杂对象的value值*

```js
/**
  * 用于更新复杂对象的value值
  * @param {需要更新的对象的key的路径，比如obj.a.b.c，对应的keys就是[obj,a,b,c]} keys 
  * @param {需要更新的value} value 
  * @param {需要更新的目标对象} target 
  */
updateObjectValueByKeys = (keys, value, target) => {
  try {
    let address = target;
    keys.forEach((d, i) => {
      if (i < keys.length - 1) {
        if (address[d] === undefined) {
          address[d] = {};
        }
        address = address[d];
      }
    });
    const finalKey = keys[keys.length - 1];
    address[finalKey] = value;
  } catch (e) {
    console.log(e);
  }
}
```

### 对象转一维对象数组

```javascript
const objectToObjArray = (o = {}) => {
  const newArr = [];
  const obj = JSON.parse(JSON.stringify(o));
  Object.entries(obj).forEach((item) => {
    newArr.push({ [item[0]]: item[1] });
  });
  return newArr;
};
```

### 随机数

```tsx
function getRandomInteger(min: number, max: number) {
    // 使用 Math.floor() 向下取整，确保结果为整数
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
```



## React

1. 父组件拦截所有子组件点击事件

```jsx
export default class PreventClick extends Component {
  constructor(props) {
    super(props);
    this.myRef = createRef(null);
  }
  componentDidMount() {
    this.myRef.current.addEventListener('click', (e) => {
      e.stopPropagation()
    });
  }
  render() {
    return (
      <div ref={this.myRef}>{this.props.children}</div> )
  }
}
```


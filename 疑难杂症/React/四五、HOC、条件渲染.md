# 四、HOC、Render Props、Hooks

> https://www.imooc.com/article/79154

## 简易例子

```jsx
import React, { Component } from 'react'
export default class App extends Component {
  render() {
    return ( <div> <DisplaySize/> </div> )
  }
}
const withSize = (MyComponent) => {
  return class getSize extends MyComponent {
    state = {
      xPos: document.documentElement.clientWidth,
      yPos: document.documentElement.clientHeight
    }
    getPos = () => {
      this.setState({
        xPos: document.documentElement.clientWidth,
        yPos: document.documentElement.clientHeight
      })
    }
    componentDidMount() { window.addEventListener('resize', this.getPos) }
    componentWillUnmount() { window.removeEventListener('resize', this.getPos) }
    render() { return (<MyComponent {...this.state}/>) }
  }
}
class Display extends Component {
  constructor(props) { super(props); }
  render() {
    const { xPos, yPos } = this.props;
    return <div>xPos: {xPos} yPos：{yPos} </div>
  }
}
const DisplaySize = withSize(Display);
```

## Hooks代替HOC

```jsx
import { useEffect, useState } from "react"

const useSize = () => {
  const getPos = () => {
    return {
      x: document.documentElement.clientWidth,
      y: document.documentElement.clientHeight
    }
  }
  const [pos, setPos] = useState(getPos())
  useEffect(() => {
    window.addEventListener('resize', () => { setPos(getPos()) })
    return () => { window.removeEventListener('resize', () => { getPos() }) }
  }, [])
  
  return {x: pos.x, y: pos.y}
}

const App = () => {
  const {x, y} = useSize();
  return <div> xPos: {x} yPos: {y} </div>
}

export default App;
```

# 五、React 条件渲染

1. if else 语句
2. 使用元素变量
3. 使用switch语句
4. 三元运算符
5. 逻辑运算符&&
6. 使用立即调用函数表达式（IIFE）
7. 使用增强的JSX：JSX Control Statements
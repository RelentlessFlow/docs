# 八、shouldComponentUpdate、PureComponent、memo

[toc]

## 一、组件优化例子

当父组件的state，props发生更新时，会导致子组件发生不必要的重新渲染。

```jsx
export default class App extends Component {
  constructor(props) { super(props); this.state = { x: 0 } }
  render() {
    const { x } = this.state;
    return (<>
      <Child/><div>{x}</div>
      <button onClick={() => {this.setState({x: x + 1})}}>+</button>
    </>)
  }
}

class Child extends Component {
  constructor(props) {super(props);}
  render() {
    console.log('Child render');
    return (<div>Child</div>)
  }
}
```

### 解决方法一：给组件赋一个name的props，并使用shouldComponentUpdate进行优化。

```jsx
export default class App extends Component {
  constructor(props) { super(props); this.state = { x: 0 } }
  render() {
    const { x } = this.state;
    return (<>
      <Child name="child"/><div>{x}</div>	// 添加name属性
      <button onClick={() => {this.setState({x: x + 1})}}>+</button>
    </>)
  }
}

class Child extends Component {
  constructor(props) {super(props);}
  shouldComponentUpdate(nextProps, nextState) { 	// 使用shouldComponentUpdate进行判断
    if(this.props.name === nextProps.name) return false
    return true;
  }
  render() {
    console.log('Child render');
    return (<div>Child</div>)
  }
}
```

### 解决方法二：使用PureComponent

```jsx
class Child extends PureComponent { 	// 使用PureComponent
  constructor(props) {super(props);}
  render() {
    console.log('Child render');
    return (<div>Child</div>)
  }
}
```

### 解决方法三：使用React.memo()

```jsx
export default class App extends Component {
  constructor(props) { super(props); this.state = { x: 0 } }
  render() {
    const { x } = this.state;
    return (<>
      <ChildMemo/><div>{x}</div>
      <button onClick={() => {this.setState({x: x + 1})}}>+</button>
    </>)
  }
}
class Child extends Component {
  constructor(props) {super(props);}
  render() {
    console.log('Child render');
    return (<div>Child</div>)
  }
}
const ChildMemo = React.memo(Child);	// React.memo
```

**当遇到函数式组件时，使用memo代替PureComponent**

```jsx
export default class App extends Component {
  constructor(props) { super(props); this.state = { x: 0 } }
  render() {
    const { x } = this.state;
    return (<>
      <Child/><div>{x}</div>
      <button onClick={() => {this.setState({x: x + 1})}}>+</button>
    </>)
  }
}
const Child = React.memo(() => { 	//  React.memo
  console.log('Child');
  return <div></div>
})
```

### PureComponent与React.memo区别

React.memo是一个高阶组件，本质就是一个函数。基本形式如下：

```jsx
React.memo(functionl Component, areEqual)
```

React.memo与PureComponent作用一样，都是用来减少组件渲染。区别如下：

1. React.memo针对函数式组件，PureComponent针对类组件。
2. React.memo可以传入第二个参数，props比较函数，自定义比较逻辑，PureComponent只会使用默认的props浅比较。
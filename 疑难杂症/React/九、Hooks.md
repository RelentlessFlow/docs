# 九、Hooks

[toc]

## 一、useState

### 1. useState基本用法

```jsx
const App = () => {
  const [count, setCount] = useState(0)
  const add = () => { setCount(count + 1) }
  return <div> {count}
    <button onClick={() => {add()}}>Add</button>
  </div>
}
```

### 2. useState模仿redux（参数为对象时）

```jsx
const App = () => {
  const [count, countDispatch] = useState({type: 'add', value: 0})
  const add = () => {
    countDispatch((preState) => {
      return preState.type === 'add' ? {
        ...preState, value: preState.value + 1
      } : preState
    })
  }
  return <div> {count.value}
    <button onClick={() => {add()}}>Add</button>
  </div>
}
```

**当useState中的参数为一个对象时，建议使用useReducer**

### 3、useReducer模仿redux（参数为对象时）

```jsx
const App = () => {
  const countReducer = (state, action) => {
    switch(action.type) {
      case 'add': return state + 1;
      case 'minus': return state - 1;
      default: return state;
    }
  }
  const [count, countDispatch] = useReducer(countReducer, 0)
  const add = () => { countDispatch({type: 'add'}) }
  return <div>{count}<button onClick={() => {add()}}>Add</button></div>
}
```

## 二、useContext

```jsx
import React, { Component, createContext, useContext } from "react"

const AppContext = createContext()

const App = () => {
  return <AppContext.Provider value="myValue">
    <Father/>
  </AppContext.Provider>
}

class Father extends Component {
  render() { return ( <>
  <ChildOne /><ChildTwo /><ChildThree />
  </> ) }
}
class ChildOne extends Component {
  render() {
    return (
      <AppContext.Consumer>
        { value => <div>{value}</div> }
      </AppContext.Consumer>
    )
  }
}

class ChildTwo extends Component {
  static contextType = AppContext
  render() {
    const value = this.context;
    return (<div>{value}</div>)
  }
}

const ChildThree = (props) => {
  const value = useContext(AppContext)
  return (<div>{value}</div>)
}

export default App
```

## 三、useRef

### 1、useRef基本用法

```jsx
import React, { createRef, useRef } from "react"
const App = () => {
  const inputRef = useRef()
  const onClick = () => { inputRef.current.focus(); }
  return <div>
    <input type={'text'} ref={inputRef} />
    <button onClick={onClick}>聚焦</button>
  </div>
}
export default App;
```

### 2、forwardRef

**子组件为函数式组件且作为父组件的ref时，要使用forwardRef**

**演示一段错误代码：**

```
const Foo = () => {
  const inputRef = useRef()
  const onClick = () => { inputRef.current.focus(); }
  return <div>
    <input type={'text'} ref={inputRef} />
    <button onClick={onClick}>聚焦</button>
  </div>
}

const  App = () => {
  const inputRef = createRef()
  const onClick = () => {
    console.log(inputRef);
  }
  return <>
    <Foo ref={inputRef} onClick={onClick} />
  </>
}
```

这段代码控制台会报如下错误

```
react-dom.development.js:86 Warning: Function components cannot be given refs. Attempts to access this ref will fail. Did you mean to use React.forwardRef()?

Check the render method of `App`.
    at Foo (http://localhost:3000/static/js/bundle.js:31:65)
    at App
```

**正确用法：使用forwardRef接收父组件传递过来的ref**

```jsx
import React, { forwardRef, useRef } from "react"

const Foo = forwardRef((props, inputRef) => {
  return <div>
    <input type={'text'} ref={inputRef} />
    <button onClick={props.onClick}>聚焦</button>
  </div>
})

const  App = () => {
  const inputRef = useRef(); // createRef()
  const onClick = () => { inputRef.current.focus(); }
  return <><Foo ref={inputRef} onClick={onClick} /></>
}

export default App;
```


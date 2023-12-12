四种绑定ref的方式

1. 字符串绑定，不推荐，Ref存储于refs中，本质是给React工作，不推荐。

```javascript
class Demo extends React.Component {
  showData = () => {
    const {input1} = this.refs
    alert(input1.value)
  }
  render() {
    return(
      <div>
        <input ref="input1" type="text" placeholder="点击按钮提示数据" />
        <button onClick={this.showData}>点我提示左侧的数据</button>
      </div>
    )
  }
}
class App extends React.Component {
  render() {
    return (
      <div>
        <Demo />
      </div>
    )
  }
}
ReactDOM.render(<App />, document.getElementById("root"));
```

2. 通过回调函数的形式进行绑定，推荐，但是在DOM重新渲染时，会调用Render函数，并且执行两次回调，第一次回调返回的参数会null，这里会有问题。第二次才是真正的DOM。

```javascript
class Demo extends React.Component {
  showData = () => {
    const {input1} = this;
    alert(input1.value)
  }
  render() {
    return(
      <div>
        <input ref={r => this.input1 = r} type="text" placeholder="点击按钮提示数据" />
        <button onClick={this.showData}>点我提示左侧的数据</button>
      </div>
    )
  }
}
class App extends React.Component {
  render() {
    return (
      <div>
        <Demo />
      </div>
    )
  }
}
ReactDOM.render(<App />, document.getElementById("root"));
```

3. 由于回调函数的形式会导致两次传递回调返回值时第一次返回值为null的问题，可以通过为类定义绑定函数的方式来解决。React认为这不是问题，非必要情况不用单独定义绑定函数。

```javascript
class Demo extends React.Component {
  showData = () => {
    const {input1} = this;
    alert(input1.value)
  }
  refInput1Bind = (c) => {this.input1 = c;}
  render() {
    return(
      <div>
        <input ref={r => this.input1 = r} type="text" placeholder="点击按钮提示数据" />
        <button onClick={this.showData}>点我提示左侧的数据</button>
      </div>
    )
  }
}
class App extends React.Component {
  render() {
    return (
      <div>
        <Demo />
      </div>
    )
  }
}
ReactDOM.render(<App />, document.getElementById("root"));
```

4. React提供了React.createRef() API，调用后可以返回一个容器，该容器可以存储ref所标识的节点，该容器是专人专用。

```javascript
class Demo extends React.Component {
  input1Ref = React.createRef()
  showData = () => {
    const inputValue = this.input1Ref.current.value;
    console.log(inputValue);
  }
  render() {
    return(
      <div>
        <input ref={this.input1Ref} type="text" placeholder="点击按钮提示数据" />
        <button onClick={this.showData}>点我提示左侧的数据</button>
      </div>
    )
  }
}
class App extends React.Component {
  render() {
    return (
      <div>
        <Demo />
      </div>
    )
  }
}
ReactDOM.render(<App />, document.getElementById("root"));
```


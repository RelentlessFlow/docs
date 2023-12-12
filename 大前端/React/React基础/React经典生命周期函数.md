```javascript
class Life extends React.Component {
  constructor(props) {
    super(props);
    console.log("Life构造函数被执行constructor!");
  }
  state = {
    count : 0
  }
  addCount = () => {
    let count = this.state.count
    this.setState({count: count+=1})
  }
  unmountComponent = () => {
    ReactDOM.unmountComponentAtNode(document.getElementById("root"));
  }
  componentWillMount() {
    console.log("Life将要被挂载componentWillMount");
  }

  shouldComponentUpdate() {
    console.log("Life State被修改了,组件应该被更新!shouldComponentUpdate");
    return true;
  }

  componentWillUpdate() {
    console.log("Life组件将被（强制）更新componentWillUpdate")
  }

  componentDidUpdate() {
    console.log("Life组件已经更新了componentDidUpdate")
  }

  componentDidMount() {
    console.log("Life组件已经挂载完成了componentDidMount")
  }

  componentWillUnmount() {
    console.log("Life组件即将卸载componentDidUnmount")
  }


  render() {
    console.log("Life即将被渲染render")
    return (
      <div>
        <p>{this.state.count}</p>
        <button onClick={this.addCount}>+1 </button>
        <button onClick={this.unmountComponent}>销毁 </button>
        <MyChild content={this.state.count}></MyChild>
      </div>
    )
  }
}

class MyChild extends React.Component {
  componentWillReceiveProps() {
    console.log("子组件的Props被接收了componentWillRecieveProps")
  }
  render() {
    return ( <p>{this.props.content}</p> )
  }
}

class App extends React.Component {
  render() {
    return (
      <div>
        <Life/>
      </div>
    )
  }
}
ReactDOM.render(<App />, document.getElementById("root"));
```

![img](https://upload-images.jianshu.io/upload_images/16775500-8d325f8093591c76.jpg?imageMogr2/auto-orient/strip|imageView2/2)


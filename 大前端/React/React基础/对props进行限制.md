```
npm install --save prop-types
```

```js
class Person extends React.Component {
  render() {
    const {name,age,sex} = this.props
    return (
      <ul>
        <li>姓名: {name}</li>
        <li>年龄: {age+1}</li>
        <li>性别: {sex}</li>
      </ul>
    )
  }
}

Person.propTypes = {
  name:PropTypes.string.isRequired,
  sex:PropTypes.string,
  age:PropTypes.number,
  speak:PropTypes.func,
}

Person.defaultProps = {
  sex:'男',
  age:18
}
class App extends React.Component {
  render() {
    const p1 = {name:"jerry", age:18, sex:"男"}
    return (
      <div>
        <Person {...p1}></Person>
        <Person name="jerry" age={19} sex="男"></Person>
        <Person name="jerry" age={20} sex="男"></Person>
      </div>
    )
  }
}

ReactDOM.render(<App />, document.getElementById("root"));
```

简写形式：

```js
class Person extends React.Component {
  static propTypes = {
    name:PropTypes.string.isRequired,
    sex:PropTypes.string,
    age:PropTypes.number,
    speak:PropTypes.func,
  }
  static defaultProps = {
    sex:'男',
    age:18
  }
  render() {
    const {name,age,sex} = this.props
    return (
      <ul>
        <li>姓名: {name}</li>
        <li>年龄: {age+1}</li>
        <li>性别: {sex}</li>
      </ul>
    )
  }
}
class App extends React.Component {
  render() {
    const p1 = {name:"jerry", age:18, sex:"男"}
    return (
      <div>
        <Person {...p1}></Person>
        <Person name="jerry" age={19} sex="男"></Person>
        <Person name="jerry" age={20} sex="男"></Person>
      </div>
    )
  }
}
ReactDOM.render(<App />, document.getElementById("root"));
function speak() {console.log("我说话了");}
```


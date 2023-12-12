```javascript
//1.创建组件
class Weather extends React.Component{
	//初始化状态
	state = {isHot:false,wind:'微风'}

	render(){
		const {isHot,wind} = this.state
		return <h1 onClick={this.changeWeather}>今天天气很{isHot ? '炎热' : '凉爽'}，{wind}</h1>
	}

//自定义方法————要用赋值语句的形式+箭头函数
	changeWeather = ()=>{
		const isHot = this.state.isHot
		this.setState({isHot:!isHot})
	}
}
//2.渲染组件到页面
ReactDOM.render(<Weather/>,document.getElementById('test'))
```


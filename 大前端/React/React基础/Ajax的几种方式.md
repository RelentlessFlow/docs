1. 使用axios.js

````javascript
axios.get(`/api1/search/users?q=${keyword}`).then(
	response => {
		PubSub.publish('updateListStateMQ',{isLoading: false,users: response.data.items})
	},
	error => {
		PubSub.publish('updateListStateMQ',{isLoading: false,err: error.message})
	}
)

// async await
try {
  const response = await axios.get(`/api1/search/users?q=${keyword}`)
  PubSub.publish('updateListStateMQ',{isLoading: false,users: response.data.items})
}catch (e) {
  PubSub.publish('updateListStateMQ',{isLoading: false,error: e.message})
}
````

2. 使用ES6 FetchAPI

```javascript
fetch(`/api1/search/users?q=${keyword}`)
	.then((response) => {
		console.log("联系服务器成功了", response);
		return response.json();
	})
	.then((response) => {
		console.log("获取数据成功了", response);
	})
	.catch((error) => {
		console.log(error);
});

// 可简写为
search = async() => {
  const {
      keyWordElement: { value: keyword },
    } = this;
  try {
		const response = await fetch(`api1/search/users?q=${keyword}`)
		const result = await response.json()
		} catch(error) {
			console.log('请求出错',error)
		}
}
```


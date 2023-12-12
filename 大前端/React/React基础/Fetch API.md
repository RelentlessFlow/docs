# Fetch API

```javascript
fetch(`/api1/search/users?q=${keyword}`).then(
      response => {
        console.log("联系服务器成功了",response)
        return response.json()
      },
      error => {console.log("联系服务器哦失败了",error)}
    ).then(
      response => {console.log("获取数据成功了",response)},
      error => {console.log("获取数据失败了了",error)}
    )
```


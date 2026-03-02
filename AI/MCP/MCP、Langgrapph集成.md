# Langgraph

用户激活了会话，发起WS连接，SERVER拿到TOOL，把TOOL放到MAP里

用户发起会话消息（create runid），服务端从MAP或获取工具列表，LLM输出。

用户关闭会话



Chat 组件绑定 一个 threadId，如果 threadId 变更，Chat 组件 强制重新渲染，并执行对应的Effect函数

在Effect函数中，



WS 断开连接，WS发起连接

服务端WS客户端断开连接后，从MAP中删除userid的工具

```
useEffect(() =>. {
	const ws = ws.coneect()
	
	return () => ws.disconnect()
}, [threaId])
```


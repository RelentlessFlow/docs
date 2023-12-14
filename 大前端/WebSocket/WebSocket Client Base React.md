# WebSocket Client Base React

### 基于 Ahooks实现

https://ahooks.js.org/zh-CN/hooks/use-web-socket

```typescript
import {useWebSocket} from "ahooks";
import {useCallback, useEffect, useState} from "react";

type MessageData = {
	event: string,
	origin: unknown
};

export default () => {
	const [historyMessages, setHistoryMessages] = useState<MessageEvent<MessageData | string>[]>([]);
	const {sendMessage, latestMessage, readyState} = useWebSocket('ws://localhost:4000') as Omit<ReturnType<typeof useWebSocket>, 'latestMessage'> & {
		latestMessage: MessageEvent<MessageData | string>
	};

	useEffect(() => {
		if (!latestMessage) return;
		setHistoryMessages(prevState => ([...prevState, latestMessage]))
	}, [latestMessage]);

	const serverSend = useCallback(() => {
		const sendData = {
			event: "subscribeMessage",
			data: "测试消息"
		}
		sendMessage(JSON.stringify(sendData));
	}, [sendMessage])

	return {
		historyMessages,
		latestMessage,
		readyState,
		serverSend,
	}
}

export type {
	MessageData
}
```

### 基于 Hook 简易实现

```typescript
export default (url: string) => {

  const [isTrust, setIsTrust] = useState(false);
  const [history, setHistory] = useState<Array<{
    time: Date, data: unknown
  }>>([]);
  const socketRef = useRef<WebSocket | null>(null);

  const connect = useCallback(() => {
    const socket = new WebSocket(url);
    socketRef.current = socket;
    socket.addEventListener('open', (event) => {
      setIsTrust(event.isTrusted);
    });
    socket.addEventListener("message", (event) => {
      const data = JSON.parse(event.data);
      setHistory(prevState => [...prevState, {
        time: new Date(), data
      }]);
    });

    return () => socket?.close()
  }, [])

  const send = () => {
    if(!socketRef.current || !isTrust) return;
    const socket = socketRef.current;
    const sendData = {
      // event : "subscribeMessage",
      event : "test",
      data : "测试消息"
    }
    socket?.send(JSON.stringify(sendData));
  }

  useEffect(connect, []);

  return {
    isTrust,
    history,
    connect,
    send
  }
}
```
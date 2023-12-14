# WebSocket Server Base Nest

仓库地址：https://github.com/RelentlessFlow/nest-websocket

## 基于 原生 WS 库

**大致流程**

- 编写WS 适配器
- 注册WS 适配器
- 编写 应用层 Gateway、Service 等

**1、WS适配器 ws.adapter.ts**

```typescript
import * as WebSocket from 'ws';
import { WebSocketAdapter, INestApplicationContext } from '@nestjs/common';
import { MessageMappingProperties } from '@nestjs/websockets';
import { Observable, fromEvent, EMPTY } from 'rxjs';
import { mergeMap, filter } from 'rxjs/operators';

export class WsAdapter implements WebSocketAdapter {
  constructor(private app: INestApplicationContext) {}

  create(port: number, options: any = {}): any {
    console.log('ws create');
    return new WebSocket.Server({ port, ...options });
  }

  bindClientConnect(server, callback: () => unknown) {
    console.log('ws bindClientConnect, server:', server);
    server.on('connection', callback);
  }

  bindMessageHandlers(
    client: WebSocket,
    handlers: MessageMappingProperties[],
    process: (data: any) => Observable<any>,
  ) {
    console.log('[waAdapter]有新的连接进来');
    fromEvent(client, 'message')
      .pipe(
        mergeMap((data) =>
          this.bindMessageHandler(client, data, handlers, process),
        ),
        filter((result) => result),
      )
      .subscribe((response) => client.send(JSON.stringify(response)));
  }

  bindMessageHandler(
    client: WebSocket,
    buffer,
    handlers: MessageMappingProperties[],
    process: (data: any) => Observable<any>,
  ): Observable<any> {
    let message = null;
    try {
      message = JSON.parse(buffer.data);
    } catch (error) {
      console.log('ws解析json出错', error);
      return EMPTY;
    }

    const messageHandler = handlers.find(
      (handler) => handler.message === message.event,
    );
    if (!messageHandler) {
      return EMPTY;
    }
    return process(messageHandler.callback(message.data));
  }

  close(server) {
    console.log('ws server close');
    server.close();
  }
}
```

**2、main.js注册 WS 适配器**

```typescript
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { WsAdapter } from './adapter/ws.adapter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.useWebSocketAdapter(new WsAdapter(app));
  await app.listen(3000);
}
bootstrap();
```

**3、应用测**

message.gateway.ts

```typescript
import { Logger } from '@nestjs/common';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  SubscribeMessage,
  WebSocketGateway,
} from '@nestjs/websockets';
import { MessagesService } from './messages.service';
import {prefs} from "@hapi/joi";

@WebSocketGateway(4000, { cors: true, transports: ['websocket'] })
export class MessageGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  constructor(private readonly messagesService: MessagesService) {}

  handleConnection(@ConnectedSocket() client: any) {
    this.logger.log(`Client Connected: ${client}`);
  }

  afterInit(server: any) {
    this.logger.log(`After Server Init: ${server}`);
  }

  handleDisconnect(@ConnectedSocket() client: any) {
    this.logger.log(`Client Disconnect: ${client}`);
  }

  private logger: Logger = new Logger('MessageGateway');

  @SubscribeMessage('test')
  hello(@MessageBody() payload: Record<string, any>): any {
    return {
      event: 'test',
      origin: payload,
      msg: 'test msg',
    };
  }

  @SubscribeMessage('subscribeMessage')
  async hello2(@MessageBody() payload: Record<string, any>, @ConnectedSocket() client: any) {
    const newMessage = await this.messagesService.createMessage(JSON.stringify(payload));
    client.send(JSON.stringify({ event: 'tmp', data: '数据库存储完成.' }));
    return { event: 'subscribeMessage', origin: payload };
  }
}
```
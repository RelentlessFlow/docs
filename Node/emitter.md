https://stackoverflow.com/questions/50709059/maxlistenersexceededwarning-possible-eventemitter-memory-leak-detected-11-mess



```typescript
/* eslint-disable no-empty */
import { EventEmitter } from 'events'

// 设置最大监听数（取消默认限制）
EventEmitter.defaultMaxListeners = 0

const emitter = new EventEmitter()

// 每秒打印内存、CPU 使用信息
setInterval(() => {
  const mem = process.memoryUsage()
  const cpu = process.cpuUsage()

  console.log(`--- 资源占用 ---`)
  console.log(`内存 RSS: ${(mem.rss / 1024 / 1024).toFixed(2)} MB`)
  console.log(`内存 HeapUsed: ${(mem.heapUsed / 1024 / 1024).toFixed(2)} MB`)
  console.log(`CPU User: ${cpu.user / 1000} ms`)
  console.log(`CPU System: ${cpu.system / 1000} ms`)
  console.log(`监听器数量: ${emitter.listenerCount('test')}`)
  console.log('---------------------\n')
}, 1000)

// 构造一个 200KB 的 Buffer 数据
function create200KPayload() {
  return Buffer.alloc(200 * 1024, 'x') // 200KB
}

// 添加监听器，每个监听器处理它自己的 payload
for (let i = 0; i < 100_000; i++) {
  const payload = create200KPayload()

  emitter.on('test', () => {
    // 强制访问 payload，确保物理内存被分配并使用
    let sum = 0
    for (let j = 0; j < payload.length; j += 1024) {
      sum += payload[j]
    }
    // 防止优化
    if (sum === -1) console.log('不会发生')
  })

  if (i % 5000 === 0) {
    console.log(`添加了 ${i} 个监听器...`)
  }
}

console.log('✅ 已添加 10 万个监听器，每个携带 200KB 数据')

// 延迟 3 秒后触发所有监听器
setTimeout(() => {
  console.time('触发耗时')
  emitter.emit('test')
  console.timeEnd('触发耗时')
}, 3000)
```


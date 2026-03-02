# React 节流防抖

trailing 延迟结束后调用

leading 延迟开始前调用

### 防抖

leading 为true会立即执行一次，然后在累计一段时间后执行第二次

trailing 为true无作用，为false 函数就不执行了

```tsx
onClick={debounce(() => console.log('hello'), 500, { leading: true })}
```

### 节流

```tsx
onClick={throttle(() => handleAuthSub(), 2000, { trailing: false })}
```
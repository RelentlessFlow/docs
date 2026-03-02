# Taro Hooks

## useDidShow

useDidShow 每次页面展示都会执行一次，适用于对数据实时性要求较高的场景。

例如当用户在表格中选择某一天记录跳转记录详情，在详情页中做了修改，再次返回该页面时，useDidShow就会再次执行，获取最新的数据。

**注意：**useDidShow Hooks 只能在页面中使用，不能在组件中使用。

示例：

```tsx
useDidShow(async () => {
    const { data: detail } = await getFamilyMemberDetail(id);
    setDetail(detail);
});
```

如果想在组件中使用，并且在组件挂载完成后也会执行，用这个写法：

## useShow

```tsx
import { useMount } from '@hera/common';
import { useDidShow } from '@tarojs/taro';
import { useRef } from 'react';

/**
 * 组件首次渲染和组件切换显示的时候执行的 hook
 *
 * @description 在 子组件中调用 useLoad 或者 useDidShow 的时候会存在不执行的情况，所以需要使用 useMount 做兜底，但 useDidShow 和 useMount 相冲突，所以内部进行处理，首次的时候在 useMount中执行，非首次的情况在 useDidShow 中执行
 * @param callback 回调函数
 * @param mount 是否只首次执行
 */
export function useShow(callback: () => void, mount?: boolean) {
    const mountRef = useRef(true);

    useMount(() => {
        callback();
        mountRef.current = false;
    });

    useDidShow(() => {
        if (!mount && mountRef.current === false) {
            callback();
        }
    });
}

/**
 * 只在组件 mount 时执行的 hook
 *
 * @example
 *
 *  useMount(fn)
 */
export function useMount(fn) {
  React.useEffect(function () {
    fn();
  }, []);
}
```

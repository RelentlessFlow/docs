# Taro 开发经验

[toc]

## Hooks相关

### useDidShow

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

### useShow

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

## 样式相关

### pxTransform [#](https://nervjs.github.io/taro-docs/docs/size#api)

用于行内样式单位转换

## 工程化

### Taro小程序分包

Taro分包，主要为了解决微信小程序主包大小最大不超过2MB的需求，分包不超过10MB的需求。

### 分包配置[#](https://docs.taro.zone/docs/independent-subpackage)

```json
{
  "pages": [
    "pages/index"
  ],
  "subpackages": [
    {
      "root": "moduleA",
      "pages": [
        "pages/rabbit",
        "pages/squirrel"
      ]
    }, {
      "root": "moduleB",
      "pages": [
        "pages/pear",
        "pages/pineapple"
      ],
      "independent": true
    }
  ]
}
```

### 分包注意事项

```
1、将页面从主包拆分时，注意页面的关联依赖，如果依赖被主包被其他页面引用，先不要分包
2、如果依赖项较少，且没有与其他页面产生依赖，拆出来。
3、拆分后一定要做测试，测试是否可用。
4、拆分后还要将其他跳转逻辑一并修改，并将跳转逻辑逐个进行测试。
5、依赖较多的时候，需要将页面、请求、组件逐个进行拆分
```

第二个版本

```
1.注意被转移的页面里面是否有存在相对路径引用
2.分组件到子包的时候注意有没有其他地方在用
3.分完所有路劲都要改
4.分完一定记得测
5.不确定一定要问，因为这个没人会去测
```


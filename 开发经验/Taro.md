# Taro 开发经验

[toc]

## Hooks相关

### useDidShow

useDidShow 每次页面展示都会执行一次，包括第一次，适用于对数据实时性要求较高的场景。

例如当用户表格中某个按钮后跳转到另外一个页面，在另一个页面中对数据做了修改，再返回该页面时，useDidShow就会再次执行，获取最新的数据。

**注意：**useDidShow Hooks 只能在页面中使用，不能在组件中使用。

示例：

```tsx
useDidShow(async () => {
    const { data: detail } = await getFamilyMemberDetail(id);
    setDetail(detail);
});
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

1、将页面从主包拆分时，注意页面的关联依赖，如果依赖被主包被其他页面引用，先不要分包

2、如果依赖项较少，且没有与其他页面产生依赖，拆出来。

3、拆分后一定要做测试，测试是否可用。

4、拆分后还要将其他跳转逻辑一并修改，并将跳转逻辑逐个进行测试。

5、依赖较多的时候，需要将页面、请求、组件逐个进行拆分
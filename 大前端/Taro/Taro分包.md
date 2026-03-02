# Taro小程序分包

Taro分包，主要为了解决微信小程序主包大小最大不超过2MB的需求，分包不超过10MB的需求。

## 分包配置[#](https://docs.taro.zone/docs/independent-subpackage)

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

## 分包注意事项

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


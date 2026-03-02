```javascript
{
  // 1. Symbol 作为对象属性
  const PROP_NAME = Symbol('name');
  const PROP_AGE = Symbol('age');
  let obj = {
    [PROP_NAME]: '一斤代码',
    [PROP_AGE]: 24
  }
  obj[PROP_AGE]; // 24
  // 24 '一斤代码'
  Object.getOwnPropertySymbols(obj).forEach(item => item.description);
  Reflect.ownKeys(obj); // [ Symbol(name), Symbol(age) ]
}
{
  // 2. Symbol 作为常量值
  const TYPE_AUDIO = Symbol()
  const TYPE_VIDEO = Symbol()
  const TYPE_IMAGE = Symbol()
  function handleFileResource(resource) {
    switch(resource.type) {
      case TYPE_AUDIO:
        playAudio(resource)
        break
      case TYPE_VIDEO:
        playVideo(resource)
        break
      case TYPE_IMAGE:
        previewImage(resource)
        break
      default:
        throw new Error('Unknown type of resource')
    }
  }
}
{
  // 3. 应用场景3：使用Symbol定义类的私有属性/方法
  // https://www.cnblogs.com/linziwei/p/10818101.html
}
```


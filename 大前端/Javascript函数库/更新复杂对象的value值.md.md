```javascript
/**
  * 用于更新复杂对象的value值
  * @param {需要更新的对象的key的路径，比如obj.a.b.c，对应的keys就是[obj,a,b,c]} keys 
  * @param {需要更新的value} value 
  * @param {需要更新的目标对象} target 
  */
updateObjectValueByKeys = (keys, value, target) => {
  try {
    let address = target;
    keys.forEach((d, i) => {
      if (i < keys.length - 1) {
        if (address[d] === undefined) {
          address[d] = {};
        }
        address = address[d];
      }
    });
    const finalKey = keys[keys.length - 1];
    address[finalKey] = value;
  } catch (e) {
    console.log(e);
  }
}
```


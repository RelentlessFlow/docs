# Key的几种处理办法

1. `<div key={+new Date() + Math.random()}>`

2. 使用uuid：https://www.npmjs.com/package/uuid
3. 使用uniqid：https://www.npmjs.com/package/uniqid（建议）
4. Date.now()

## uniqid

### A Unique Hexatridecimal ID generator.

It will always create unique id's based on the current time, process and machine name.

```shell
// install with npm 
npm install uniqid

// install with yarn
yarn add uniqid
```

## Usage

```
import uniqid from 'uniqid';

console.log(uniqid()); // -> 4n5pxq24kpiob12og9
console.log(uniqid(), uniqid()); // -> 4n5pxq24kriob12ogd, 4n5pxq24ksiob12ogl
```

## Usage with Require

```
var uniqid = require('uniqid'); 

console.log(uniqid()); // -> 4n5pxq24kpiob12og9
console.log(uniqid(), uniqid()); // -> 4n5pxq24kriob12ogd, 4n5pxq24ksiob12o
```

## React Native Key处理办法

`npm install react-native-uuid`

```javascript
import uuid from 'react-native-uuid';
uuid.v4(); // ⇨ '11edc52b-2918-4d71-9058-f7285e29d894'
```


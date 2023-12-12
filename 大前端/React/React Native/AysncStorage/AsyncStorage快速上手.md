[toc]

# AsyncStorage快速上手

## Async Storage环境搭建

NPM：

```
npm install @react-native-async-storage/async-storage
```

Yarn:

```
yarn add @react-native-async-storage/async-storage
```

Expo CLI:

```
expo install @react-native-async-storage/async-storage
```

IOS请使用CocoaPods去添加RNAsyncStorage到你的项目

```
npx pod-install
```

高版本默认链接，如有链接问题请阅读https://react-native-async-storage.github.io/async-storage/docs/install

## API

### `getItem`通过Key获取数据

```js
static getItem(key: string, [callback]: ?(error: ?Error, result: ?string) => void): Promise
```

**Example**

```javascript
getMyObject = async () => {
  try {
    const jsonValue = await AsyncStorage.getItem('@key')
    return jsonValue != null ? JSON.parse(jsonValue) : null
  } catch(e) {
    // read error
  }

  console.log('Done.')
}
```

### `setItem`存储数据

```react
static setItem(key: string, value: string, [callback]: ?(error: ?Error) => void): Promise
```

**Example**:

```react
setObjectValue = async (value) => {
  try {
    const jsonValue = JSON.stringify(value)
    await AsyncStorage.setItem('key', jsonValue)
  } catch(e) {
    // save error
  }

  console.log('Done.')
}
```

### `mergeItem`合并数据项

```js
static mergeItem(key: string, value: string, [callback]: ?(error: ?Error) => void): Promise
```

**Example**:

```react
const USER_1 = {
  name: 'Tom',
  age: 20,
  traits: {
    hair: 'black',
    eyes: 'blue'
  }
}

const USER_2 = {
  name: 'Sarah',
  age: 21,
  hobby: 'cars',
  traits: {
    eyes: 'green',
  }
}


mergeUsers = async () => {
  try {
    //save first user
    await AsyncStorage.setItem('@MyApp_user', JSON.stringify(USER_1))

    // merge USER_2 into saved USER_1
    await AsyncStorage.mergeItem('@MyApp_user', JSON.stringify(USER_2))

    // read merged item
    const currentUser = await AsyncStorage.getItem('@MyApp_user')

    console.log(currentUser)

    // console.log result:
    // {
    //   name: 'Sarah',
    //   age: 21,
    //   hobby: 'cars',
    //   traits: {
    //     eyes: 'green',
    //     hair: 'black'
    //   }
    // }
  }
}
```

### `removeItem`移除某一项

```js
static removeItem(key: string, [callback]: ?(error: ?Error) => void): Promise
```

**Example**

```react
removeValue = async () => {
  try {
    await AsyncStorage.removeItem('@MyApp_key')
  } catch(e) {
    // remove error
  }

  console.log('Done.')
}
```

### `getAllKeys`获取某一项

```js
static getAllKeys([callback]: ?(error: ?Error, keys: ?Array<string>) => void): Promise
```

**Example**

```react
getAllKeys = async () => {
  let keys = []
  try {
    keys = await AsyncStorage.getAllKeys()
  } catch(e) {
    // read key error
  }

  console.log(keys)
  // example console.log result:
  // ['@MyApp_user', '@MyApp_key']
}
```

### `multiGet`获取多个数据项

```js
static multiGet(keys: Array<string>, [callback]: ?(errors: ?Array<Error>, result: ?Array<Array<string>>) => void): Promise
```

**Example**:

```react
getMultiple = async () => {

  let values
  try {
    values = await AsyncStorage.multiGet(['@MyApp_user', '@MyApp_key'])
  } catch(e) {
    // read error
  }
  console.log(values)

  // example console.log output:
  // [ ['@MyApp_user', 'myUserValue'], ['@MyApp_key', 'myKeyValue'] ]
}
```

### `multiSet`设置多个数据项

```js
static multiSet(keyValuePairs: Array<Array<string>>, [callback]: ?(errors: ?Array<Error>) => void): Promise
```

**Example**:

```react
multiSet = async () => {
  const firstPair = ["@MyApp_user", "value_1"]
  const secondPair = ["@MyApp_key", "value_2"]
  try {
    await AsyncStorage.multiSet([firstPair, secondPair])
  } catch(e) {
    //save error
  }

  console.log("Done.")
}
```

### `clear`清空存储项

```
static clear([callback]: ?(error: ?Error) => void): Promise
```

**Example**:

```react
clearAll = async () => {
  try {
    await AsyncStorage.clear()
  } catch(e) {
    // clear error
  }

  console.log('Done.')
}
```

### `useAsyncStorage`自动创建基于Key的增删改查

源码：

```react
static useAsyncStorage(key: string): {
  getItem: (
    callback?: ?(error: ?Error, result: string | null) => void,
  ) => Promise<string | null>,
  setItem: (
    value: string,
    callback?: ?(error: ?Error) => void,
  ) => Promise<null>,
  mergeItem: (
    value: string,
    callback?: ?(error: ?Error) => void,
  ) => Promise<null>,
  removeItem: (callback?: ?(error: ?Error) => void) => Promise<null>,
}
```

**返回值：**

`object`

**Specific Example**:

```react
import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { useAsyncStorage } from '@react-native-async-storage/async-storage';

export default function App() {
  const [value, setValue] = useState('value');
  const { getItem, setItem } = useAsyncStorage('@storage_key');

  const readItemFromStorage = async () => {
    const item = await getItem();
    setValue(item);
  };

  const writeItemToStorage = async newValue => {
    await setItem(newValue);
    setValue(newValue);
  };

  useEffect(() => {
    readItemFromStorage();
  }, []);

  return (
    <View style={{ margin: 40 }}>
      <Text>Current value: {value}</Text>
      <TouchableOpacity
        onPress={() =>
          writeItemToStorage(
            Math.random()
              .toString(36)
              .substr(2, 5)
          )
        }
      >
        <Text>Update value</Text>
      </TouchableOpacity>
    </View>
  );
}
```

## 值得关注的一些特性

### Android存储容量限制

> 参考文档：https://react-native-async-storage.github.io/async-storage/docs/limits

AsyncStorage for Android 使用 SQLite 作为存储后端。虽然它有[自己的大小限制](https://www.sqlite.org/limits.html)，Android 系统也有两个已知的限制：总存储大小和每个条目的大小限制。

- 默认情况下，总存储大小上限为 6 MB。您可以通过[使用功能标志指定新大小来](https://react-native-async-storage.github.io/async-storage/docs/advanced/db_size)增加此大小[。](https://react-native-async-storage.github.io/async-storage/docs/advanced/db_size)
- 每个条目受 WindowCursor 大小的限制，WindowCursor 是一个用于从 SQLite 读取数据的缓冲区。[目前它的大小约为 2 MB](https://cs.android.com/android/platform/superproject/+/master:frameworks/base/core/res/res/values/config.xml;l=2103)。这意味着一次读取的单个项目不能大于 2 MB。AsyncStorage 没有受支持的解决方法。我们建议将您的数据保持在低于该值的水平，将其分成多个条目，而不是一个庞大的条目。这是[`multiGet`](https://react-native-async-storage.github.io/async-storage/docs/api#multiget)和[`multiSet`](https://react-native-async-storage.github.io/async-storage/docs/api#multiset)API可以发挥作用的地方。

### 下一代存储接口

> 参考文档：https://react-native-async-storage.github.io/async-storage/docs/advanced/next

**支持的平台**：Android

#### 为何迁移

持久层的当前实现是使用[SQLiteOpenHelper](https://developer.android.com/reference/android/database/sqlite/SQLiteOpenHelper)创建的，这是一个管理数据库创建和迁移的助手类。即使这种方法很强大，但缺乏编译时查询验证和将 SQLite 查询映射到实际值的大样板，使得这种实现容易出现许多错误。

此异步存储功能改进了持久层，使用现代方法访问 SQLite（使用[Room](https://developer.android.com/training/data-storage/room)），将可能的异常减少到最低限度。最重要的是，它允许从本机端访问 AsyncStorage，这在[Brownfield 集成中](https://react-native-async-storage.github.io/async-storage/docs/advanced/brownfield#android)很有用[。](https://react-native-async-storage.github.io/async-storage/docs/advanced/brownfield#android)

#### 启用

1. 在您的项目`android`目录中，找到根`build.gradle`文件。将 Kotlin 依赖项添加到`buildscript`：

```react
buildscript {
    ext {
        // other extensions
+        kotlinVersion = '1.5.31'
    }
    
    dependencies {
        // other dependencies
+        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion"
    }
}
```

2. 在同一目录（通常`android`）中找到`gradle.properties`文件（如果它不存在，则创建一个）并添加以下行：

```
AsyncStorage_useNextStorage=true
```

## 与RN一起实践

tool.js

```javascript
export const propertyVerify = (value, warn = "Parameter does not conform to role.", type="string") => {
  if(value == null || value == undefined || value == "" || typeof value != type) {
    console.warn(warn);
    return false;
  }
  return true;
}
```

connect_store.js

```javascript
import {propertyVerify} from './tools'
import AsyncStorage,{useAsyncStorage} from '@react-native-async-storage/async-storage';

const _connect = {
  connectedKey : "",
  connectedName : "",
}

export const createConnect = (key="", name="") => {
  if(propertyVerify(name)) {
    _connect.connectedKey = key;
    _connect.connectedName = name;
  }
  return _connect;
}

export const setConnectStorage = async (key, connect) => {
  try {
    const jsonValue = JSON.stringify(connect);
    await AsyncStorage.setItem(key, jsonValue);
  } catch(e) {
    console.error("Set connect storage error!", e);
  }
}

export const getConnectStorage = async (key) => {
  try {
    const value = await AsyncStorage.getItem(key);
    if(value !== null) {
      return value;
    }
  } catch(e) {
    console.error("Get connect storage error!", e);
  }
}
```

index.js

```react
import React from 'react';
import {View, StyleSheet, Button, Text} from 'react-native';
import {setConnectStorage, getConnectStorage, createConnect} from '../../../app/store/connect_store';

const Index = () => {
  let key = "current_conn";
  const setCurrentConnect = (id, name) => {
    setConnectStorage(key, createConnect(key=id,name=name));
    console.info("Done!")
  }
  const getCurrentConnect = async () => {
    const conn = await getConnectStorage(key);
    console.log(conn, "!!!");
  }
  return (
    <View>
      <Button
        title={"Add Info1"}
         onPress={()=>setCurrentConnect("id9988","TP-link 7188")}
      />
      <Button
        title={"Add Info2"}
         onPress={()=>setCurrentConnect("id9990","TP-link 71885G")}
      />
      <Button
        title={"Get Info"}
        onPress={getCurrentConnect}
      />
    </View>
  );
}

const styles = StyleSheet.create({})

export default Index;
```


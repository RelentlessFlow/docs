# 使用滚动视图ScrollView

## 基本使用

```javascript
import React, { Component } from 'react';
import {View, StyleSheet, ScrollView, Text} from 'react-native';
import uuid from 'react-native-uuid';
export default class Index extends Component {
  render() {
    const myArr = [...Array.from({ length: 100 }).keys()]
    return (
      <View>
        <ScrollView>
          {
            myArr.map((index, idx) => (
              <Text key={uuid.v4()} style={{ fontSize: 50 }}>Scroll me plz1</Text>
            ))
          }
        </ScrollView>
      </View>
    );
  }
}
const styles = StyleSheet.create({})
```


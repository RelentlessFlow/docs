# TextInput组件

参考文档：https://www.react-native.cn/docs/textinput#editable

案例：

```javascript
import React from 'react';
import { View, TextInput, SafeAreaView, Alert } from 'react-native';

function UselessTextInput(props) {
  return (
    <TextInput
      {...props} // 将父组件传递来的所有props传递给TextInput;比如下面的multiline和numberOfLines
      maxLength={40}
      style={{padding:0}}
    />
  );
}

export default function UselessTextInputMultiline() {
  const [value, onChangeText] = React.useState('');

  // 你可以试着输入一种颜色，比如red，那么这个red就会作用到View的背景色样式上
  return (
    <SafeAreaView>
    <View
      style={{
        backgroundColor: value,
        borderBottomColor: '#000000',
        borderBottomWidth: 1,
      }}>
      <UselessTextInput
        defaultValue={'请输入...'}  // value为null时，显示此字符串
        placeholder={'Please placeholder'}  // value为空串‘’，显示此字符串
        multiline={false}  // 允许多行文本
        numberOfLines={10}
        onChangeText={text => onChangeText(text)}
        value={value}
        autoCapitalize='none' //sentences(default) characters words none
        autoCorrect={false} // 拼写矫正
        caretHidden={false} // 隐藏光标
        dataDetectorTypes="phoneNumber" // 根据内容不同自动跳转相关的App
        onSubmitEditing={()=>Alert.alert(
          title = '当前背景颜色为',
          message= value
        )}
      />
    </View>
    </SafeAreaView>
  );
}
```


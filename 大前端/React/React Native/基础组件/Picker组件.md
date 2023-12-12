# Picker组件

>  参考文档:https://github.com/react-native-picker/picker#onvaluechange

## Getting started

```
$ npm install @react-native-picker/picker --save
```

or

```
$ yarn add @react-native-picker/picker
```

#### iOS

CocoaPods on iOS needs this extra step:

```
npx pod-install
```
**<u>*注意：请务必cd到ios目录下执行本操作。*</u>**

```react
import React, { useState, useRef } from "react";
import { View, Text, Alert, Button } from "react-native";
import { Picker } from "@react-native-picker/picker";

const Index = () => {
  const [languagesArrs, setLanguagesArrs] = useState([
    ["Java", "java"],
    ["JavaScript", "js"],
  ]);
  const pickerRef = useRef();
  const [selectedLanguage, setSelectedLanguage] = useState(languagesArrs[0][1]);
  return (
    <View>
      <Picker
        ref={pickerRef}
        selectedValue={selectedLanguage}
        onValueChange={(itemValue, itemIndex) => setSelectedLanguage(itemValue)}
      >
        {languagesArrs.map((value, index) => {
          return <Picker.Item label={value[0]} value={value[1]} />;
        })}
      </Picker>
      <Button title="选中的值" onPress={() => Alert.alert(selectedLanguage)} />
    </View>
  );
};

export default Index;
```
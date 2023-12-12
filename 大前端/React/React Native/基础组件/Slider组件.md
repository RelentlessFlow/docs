# Slider组件

> 参考文档：https://github.com/callstack/react-native-slider

## Installation & Usage

To install this module `cd` to your project directory and enter the following command:

```
yarn add @react-native-community/slider
```

or

```
npm install @react-native-community/slider --save
```

If using iOS please remember to install cocoapods by running: `npx pod-install` 
For web support please use `@react-native-community/slider@next`

## **Migrating from the core `react-native` module**

This module was created when the Slider was split out from the core of React Native. 
To migrate to this module you need to follow the installation instructions above and then change you imports from:

```
import { Slider } from 'react-native';
```

to:

```
import Slider from '@react-native-community/slider';
```

## 实例

```javascript
import React, {useState} from "react";
import { View, StyleSheet ,Text} from "react-native";
import Slider from "@react-native-community/slider";

const Index = () => {
  const [sliderValue,setSliderValue] = useState(0);
  return (
    <View>
      <Slider
        style={{ width: 200, height: 40 }}
        minimumValue={0}
        maximumValue={20}
        step={2}
        value={sliderValue}
        minimumTrackTintColor="blue"
        // maximumTrackTintColor="#000000"
        maximumTrackTintColor="grey"
        onValueChange={(value)=>{setSliderValue(value)}}
      />
      <Text>设置的值为：{sliderValue}</Text>
    </View>
  );
};
export default Index;
```


# WebView组件

## 1、依赖配置

### 依赖安装

```
$ yarn add react-native-webview
```

or

```
$ npm install --save react-native-webview
```

### 链接组件

 react-native 0.60 将自动执行link步骤

```
$ react-native link react-native-webview
```

### iOS & macOS:

If using CocoaPods, in the `ios/` or `macos/` directory run:

```
$ pod install
```

### Android:

Android - react-native-webview version <6: This module does not require any extra step after running the link command 🎉

Android - react-native-webview version >=6.X.X: Please make sure AndroidX is enabled in your project by editting `android/gradle.properties` and adding 2 lines:(我刚才试了一下，貌似不用自己加)

```
android.useAndroidX=true
android.enableJetifier=true
```

## 实例

### Basic inline HTML

The simplest way to use the WebView is to simply pipe in the HTML you want to display. Note that setting an `html` source requires the [originWhiteList](https://github.com/react-native-webview/react-native-webview/blob/master/docs/Reference.md#originWhiteList) property to be set to `['*']`.

```react
import React, { Component } from 'react';
import { WebView } from 'react-native-webview';

export default function Index() {
  return (
    <WebView
      originWhitelist={['*']}
      source={{ html: '<h1>This is a static HTML source!</h1>' }}
      />
  )
}
```


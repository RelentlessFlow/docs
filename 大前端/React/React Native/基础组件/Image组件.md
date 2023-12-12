# Image组件

## 在 Android 上支持 GIF 和 WebP 格式图片[#](https://www.react-native.cn/docs/image#在-android-上支持-gif-和-webp-格式图片)

默认情况下 Android 是不支持 GIF 和 WebP 格式的。你需要在`android/app/build.gradle`文件中根据需要手动添加以下模块：

```yaml
dependencies {
  // 如果你需要支持Android4.0(API level 14)之前的版本
  implementation 'com.facebook.fresco:animated-base-support:1.3.0'

  // 如果你需要支持GIF动图
  implementation 'com.facebook.fresco:animated-gif:2.5.0'

  // 如果你需要支持WebP格式，包括WebP动图
  implementation 'com.facebook.fresco:animated-webp:2.5.0'
  implementation 'com.facebook.fresco:webpsupport:2.5.0'

  // 如果只需要支持WebP格式而不需要动图
  implementation 'com.facebook.fresco:webpsupport:2.5.0'
}
```

## 案例



```react
import React,{Component} from 'react';
import {View, StyleSheet, SafeAreaView, Text, Image, Alert, Button} from 'react-native';

class Index extends Component {
  state = {
    imgUrlObj : {
      defaultImgUrl : 'http://qlogo1.store.qq.com/qzone/2351723616/2351723616/100.img',
      currentImgUrl : 'https://profile.csdnimg.cn/B/3/3/2_qq_36833171.png'
    },
  }
  setCurrentImg = (url) => {
    const {imgUrlObj} = this.state;
    let stateObj = Object.assign({}, imgUrlObj,
        {currentImgUrl:url});
    this.setState({
      imgUrlObj: stateObj
    });
  }
  setCurrentImgToDefault = () => {
    this.setCurrentImg(this.state.imgUrlObj.defaultImgUrl);
  }
  render() {
    const {defaultImgUrl:def,currentImgUrl:cur} = this.state.imgUrlObj;
    return (
      <SafeAreaView style={{flex: 1}}>
        <Button
          onPress={()=>
            this.setCurrentImg("http://qlogo4.store.qq.com/qzone/1700754239/1700754239/100")
          }
          title="更换图片"
        />
        <View
          style={[{flex: 1},{alignItems: 'center'}]}
          >
          <Image
            source={{
              uri: cur,
              width: 200,
              height: 200,
            }}
            // 当加载错误的时候调用此回调函数。
            onError={this.setCurrentImgToDefault}
            // 下载进度的回调事件
            onProgress={()=>{console.log("onProgress")}}
            // 加载结束后，不论成功还是失败，调用此回调函数。
            onLoadEnd={()=>{console.log("onLoadEnd")}}
            resizeMode='stretch' // cover，contain，stretch，repeat，center
            // blurRadius={10}
          />        
        </View>
      </SafeAreaView>
    );
  }
}

const styles = StyleSheet.create({})
export default Index;
```


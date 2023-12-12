# ScrollView组件

ScrollView 必须有一个确定的高度才能正常工作

一般来说我们会给 ScrollView 设置`flex: 1`以使其自动填充父容器的空余空间，但前提条件是所有的父容器本身也设置了 flex 或者指定了高度，否则就会导致无法正常滚动，你可以使用元素查看器来查找具体哪一层高度不正确。

长列表尽量用FlatList，效率会比较高。

## 综合实例

```react
import React from 'react';
import {StyleSheet, Text, View, ScrollView, SafeAreaView, Button, RefreshControl} from 'react-native';
import uuid from 'react-native-uuid';

const index = () => {
  // 列表刷新状态保存
  const [refreshing, setRefreshing] = React.useState(false);
  const myArr = [...Array.from({length: 100}).keys()];
  // 异步列表刷新
  const onRefresh = React.useCallback(() => {
    const wait = (timeout) => {
      return new Promise(resolve => {
        setTimeout(resolve, timeout);
      });
    }
    setRefreshing(true);
    wait(1000).then(() => setRefreshing(false));
  }, []);
  return (
    <SafeAreaView style={{flex: 1}}>
      <Button
        title="Return Top"
        onPress={()=> {
          this.myScrollView.scrollTo({x: 0, y: 0, animated: true});
        }}
      />
       <Button
        title="To End"
        onPress={()=> {
          this.myScrollView.scrollToEnd({animated: true});
        }}
      />

      <ScrollView
        contentContainerStyle={styles.contentContainer}
        // 用户拖拽滚动视图的时候，是否要隐藏软键盘。 
        keyboardDismissMode='on-drag' // none(default) on-drag
        onScrollBeginDrag={()=>{console.log('当用户开始拖动此视图时调用此函数。')}}
        onScrollEndDrag={()=>{console.log('当用户停止拖动此视图时调用此函数。')}}
        onMomentumScrollBegin={()=>{console.log('滚动动画开始时调用此函数。')}}
        onMomentumScrollEnd={()=>{console.log('滚动动画结束时调用此函数。')}}
        horizontal={false} // true为水平滚动
        decelerationRate="normal" // fast滚动较快距离短 enum('fast', 'normal'), ,number:float
        ref={(r) => {this.myScrollView = r}}
        style={[{borderTopColor:"black",borderTopWidth:2}]}
        refreshControl={<RefreshControl 
          refreshing={refreshing} onRefresh={onRefresh} />}
        >
        {myArr.map((index, idx) => (
          <Text key={uuid.v4()} 
            style={styles.scrollViewItemText}
            numberOfLines={1} // 行数
            ellipsizeMode='tail' // 超出部分省略
            >
            {index} Item1111111111111
          </Text>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
};

export default index;

const styles = StyleSheet.create({
  contentContainer: {
    padding: 10,
    alignItems: "center"
  },
  scrollViewItemText: {
    fontSize: 50,    
  },
});
```

## RefreshControl组件

```react
import React from 'react';
import {
  ScrollView,
  RefreshControl,
  StyleSheet,
  Text,
  SafeAreaView,
} from 'react-native';



const Index = () => {
  const [refreshing, setRefreshing] = React.useState(false);
  const onRefresh = React.useCallback(() => {
    const wait = (timeout) => {
      return new Promise(resolve => {
        setTimeout(resolve, timeout);
      });
    }
    setRefreshing(true);
    wait(1000).then(() => setRefreshing(false));
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        contentContainerStyle={styles.scrollView}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        <Text>Pull down to see RefreshControl indicator</Text>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: 20,
  },
  scrollView: {
    flex: 1,
    backgroundColor: 'pink',
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default Index;
```


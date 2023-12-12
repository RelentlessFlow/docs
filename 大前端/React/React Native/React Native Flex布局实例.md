# React Native Flex布局实例

## 一、简单布局案例

```react
import React, {Component} from 'react';
import {
  View,
  StyleSheet,
  Text,
  Dimensions,
  Alert,
  SafeAreaView,
} from 'react-native';

class Test extends Component {
  render() {
    let MainHeight = Dimensions.get('window').height;
    return (
      <>
        <SafeAreaView style={{flex: 0, backgroundColor: 'red'}}>  
        </SafeAreaView>
        <SafeAreaView style={styles.container}>
          <View style={styles.container_top}><Text>top</Text></View>
          <View style={styles.container_main}><Text>main</Text></View>
          <View style={styles.container_bottom}>
            <View style={styles.container_bottom_item}>
            <Text style={styles.container_bottom_item_text}>item1</Text>
            </View>
            <View style={styles.container_bottom_item}>
              <Text style={styles.container_bottom_item_text}>item2</Text>
            </View>
            <View style={styles.container_bottom_item}>
              <Text style={styles.container_bottom_item_text}>item3</Text>
            </View>
          </View>
        </SafeAreaView>
        <SafeAreaView style={{flex: 0, backgroundColor: 'green'}}>
        </SafeAreaView>
      </>
    );
  }
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "",
    flexDirection: "column"
  },
  container_top: {
    flex:1,
    backgroundColor: "grey"
  },
  container_main: {
    flex:2,
    backgroundColor: "yellow"
  },
  container_bottom: {
    backgroundColor: "darkgrey",
    flex:3,
    flexDirection: "row"
  },
  container_bottom_item: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  container_bottom_item_text: {
    fontSize: 40
  }
});

export default Test;
```

## 二、综合布局案例

```react
  import React, {Component} from 'react';
  import {View, StyleSheet, ScrollView, Text, Image, Dimensions, SafeAreaView} from 'react-native';
  import uuid from 'react-native-uuid';
  import Icon from 'react-native-vector-icons/FontAwesome';

  export default class Index extends Component {
    render() {
      function Render({if: cond, children}) {
        return cond ? children : null;
      }
      const group_pic_url =
        'https://himg.bdimg.com/sys/portrait/item/public.1.bbb10a9d.8Mw8fm0VgE0LFE49EdkbDg.jpg';
      const myArr = [...Array.from({length: 20}).keys()];
      // 获取在线设备逻辑
      const deviceTypes = ['Android', 'IOS', 'iPad', 'Mac', 'Android', 'Windows'];
      // let onlineDevices = ['IOS', 'Mac',"iPad"];
      let onlineDevices = ['IOS', 'Mac', 'iPad'];
      const currentDevice = 'IOS';
      getOtherOnlineDevice = () => {
        return onlineDevices.filter(value => {
          return value === currentDevice ? null : value;
        });
      };
      getOtherOnlineDeviceStr = () => {
        let str = '';
        getOtherOnlineDevice().forEach(value => {
          str = str + value + ',';
        });
        return str.slice(0, str.length - 1);
      };
      isOtherOnlineDevice = () => {
        return getOtherOnlineDevice().length > 0 ? true : false;
      };

      return (
        <SafeAreaView style={{flex: 1}}>
        <View style={styles.home}>
          <View style={styles.user}>
            <View style={styles.user_avator}>
              <Image
                style={styles.user_avator_img}
                source={{uri: group_pic_url}}
              />
            </View>
            <View style={styles.user_info}>
              <View style={styles.user_info_name}>
                <Text style={styles.user_info_name_text}>
                  爱吃辣的机器人
                </Text>
              </View>
              <View style={styles.user_info_login}>
                <Text style={styles.user_info_login_status}>·</Text>
                <Text style={styles.user_info_login_phone}>
                  iPhone 12 Pro在线 - 5G {'>'}
                </Text>
              </View>
            </View>
            <View style={styles.user_button}>
              <Icon name="search" style={styles.user_button_icon} />
            </View>
            <View style={styles.user_button}>
              <Icon name="plus" style={styles.user_button_icon} />
            </View>
          </View>
          <View style={styles.search}>
            <Icon name="search" style={styles.search_icon} />
            <Text style={styles.search_text}>搜索</Text>
          </View>
          <Render if={isOtherOnlineDevice()}>
            <View style={styles.login_status}>
              <View style={styles.login_status_icon}>
                <Icon name="desktop" style={styles.login_status_icon_content} />
              </View>
              <View style={styles.login_status_content}>
                <Text style={styles.login_status_content_text}>
                  {getOtherOnlineDeviceStr()} QQ 已登录
                </Text>
              </View>
              <View style={styles.login_status_end}>
                <Text>{'>'}</Text>
              </View>
            </View>
          </Render>
          <ScrollView
            style={styles.group_message}
            horizontal={false}
            keyboardDismissMode="on-drag">
            {myArr.map(index => (
              <View
                key={uuid.v4()}
                style={[
                  styles.group_item,
                  index == 0 ? styles.group_item_bg : undefined,
                ]}>
                <View style={styles.group_item_left}>
                  <Image
                    style={styles.group_item_left_pic}
                    source={{uri: group_pic_url}}
                  />
                </View>
                <View style={styles.group_item_middle}>
                  <Text style={styles.group_item_middle_title}>44{index+1}寝室</Text>
                  <Text style={styles.group_item_middle_content}>
                    张振楠5铺：[图片]
                  </Text>
                </View>
                <View style={styles.group_item_right}>
                  <Text style={styles.group_item_right_date}>昨天</Text>
                  <View style={styles.group_item_right_count}>
                    <Text style={styles.group_item_right_count_text}>90</Text>
                  </View>
                </View>
              </View>
            ))}
          </ScrollView>
          <View style={styles.index_nav}>
            <View style={styles.index_nav_item}>
              <Icon name="search" style={styles.index_nav_item_icon} />
              <Text style={styles.index_nav_item_text}>消息</Text>
            </View>
            <View style={styles.index_nav_item}>
              <Icon name="search" style={styles.index_nav_item_icon} />
              <Text style={styles.index_nav_item_text}>联系人</Text>
            </View>
            <View style={styles.index_nav_item}>
              <Icon name="search" style={styles.index_nav_item_icon} />
              <Text style={styles.index_nav_item_text}>动态</Text>
            </View>
          </View>
        </View>
        </SafeAreaView>
      );
    }
  }

  let MainHeight = Dimensions.get('window').height;
  const styles = StyleSheet.create({
    home: {
      flexDirection: "column",
      flex: 1
    },
    // 顶部用户信息
    user: {
      display: "flex",
      flexDirection: "row",
      marginHorizontal: 15,
    },
    user_avator: {
      flex: 0.9,
      alignItems: "center",
      justifyContent: "center",
    },
    user_avator_img: {
      width: 36,
      height: 36,
      borderRadius: 20
    },
    user_info: {
      flex: 6,
      paddingLeft: 10,
      flexDirection: "column"
    },
    user_info_name: {
      marginTop: 5
    },
    user_info_name_text: {
      fontSize: 19,
      fontWeight: "600"
      
    },
    user_info_login: {
      flexDirection: "row",
      alignItems: "center",
      paddingLeft: 5,
    },
    user_info_login_status: {
      fontWeight: "900",
      color: "green",
    },
    user_info_login_phone: {
      paddingLeft: 2,
      fontSize: 12
    },
    user_button: {
      flex: 0.8,
      justifyContent: "center",
      alignItems: "center"
    },
    user_button_icon: {
      fontSize: 19.5,
    },
    // 搜索
    search: {
      margin: 15,
      paddingVertical: 10,
      display: 'flex',
      flexDirection: 'row',
      backgroundColor: '#f6f6f6',
      alignItems: 'center',
      justifyContent: 'center',
    },
    search_icon: {
      color: '#9c9c9c',
      marginRight: 7,
    },
    search_text: {
      color: '#9c9c9c',
    },
    // 登陆状态
    login_status: {
      display: 'flex',
      flexDirection: 'row',
      padding: 10,
      backgroundColor: 'rgb(246, 246, 246)',
      borderBottomEndRadius: 1,
      borderStyle: 'solid',
      borderBottomWidth: 1,
      borderBottomColor: '#f6f6f6',
    },
    login_status_icon: {
      flex: 1,
      alignContent: 'center',
      justifyContent: 'center',
    },
    login_status_icon_content: {
      textAlign: 'center',
      width: 50,
      fontSize: 20,
    },
    login_status_content: {
      flex: 4,
      justifyContent: 'center',
    },
    login_status_content_text: {
      color: '#9c9c9c',
    },
    login_status_end: {
      flex: 1,
      alignItems: 'flex-end',
      paddingRight: 5,
    },
    // 消息列表
    group_message: {
    },
    group_item: {
      flex: 1,
      flexDirection: 'row',
      padding: 10,
    },
    group_item_bg: {
      backgroundColor: 'rgb(246, 246, 246)',
    },
    group_item_left: {
      justifyContent: 'center',
      alignContent: 'center',
      flex: 1,
    },
    group_item_left_pic: {
      borderRadius: 20,
      width: 50,
      height: 50,
    },
    group_item_middle: {
      flex: 4,
    },
    group_item_middle_title: {
      flex: 1,
      letterSpacing: 1,
      paddingTop: 5,
      fontSize: 18,
    },
    group_item_middle_content: {
      flex: 1,
      paddingTop: 4,
      fontWeight: '500',
      color: '#9c9c9c',
    },
    group_item_right: {
      flex: 1,
      alignItems: 'flex-end',
    },
    group_item_right_date: {
      flex: 1,
      color: '#9c9c9c',
      fontWeight: '400',
    },
    group_item_right_count: {
      flex: 1,
      borderRadius: 15,
      backgroundColor: 'darkgrey',
      alignContent: 'center',
      justifyContent: 'center',
      paddingHorizontal: 7,
    },
    group_item_right_count_text: {
      color: 'aliceblue',
      fontWeight: '600',
      fontSize: 12,
    },
    // 底部导航栏
    index_nav: {
      alignItems: "flex-end",
      justifyContent: "flex-end",
      paddingVertical: 5,
      flexDirection: "row",
      backgroundColor: "fefefe",
    },
    index_nav_item: {
      flex: 1,
      justifyContent: "flex-end",
      alignItems: "center",
    },
    index_nav_item_icon: {
      fontSize: 18,
      fontWeight: "100",
      padding: 4
    },
    index_nav_item_text: {
      fontSize: 14,
      fontWeight: "400",
      letterSpacing: -1
    }
  });
```


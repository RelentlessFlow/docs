[toc]

# MQTT

## 一、中国移动MQTT平台

### 1. 添加产品步骤

1. 顶部“产品服务” > “
1. OneNET Studio” > 左侧产品管理 > 新建产品
1. 参考配置如下

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181559673.png" alt="image-20221009181559673" style="zoom:50%;" />

3. 左侧设备管理，找到刚刚创建的设备，点击详情。

### 2. 激活产品步骤

1. 下载软件MQTT FX 软件。http://www.jensd.de/apps/mqttfx/1.7.1/

2. 在MQTT 软件中点击齿轮按钮，添加一个Profile

3. 配置Profile

   1. MQTT配置参考文档：https://open.iot.10086.cn/doc/v5/develop/detail/638

      1. 参考文档对应设备信息

         <img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181609290.png" alt="image-20221009181609290" style="zoom:50%;" />

   2. Token生成器：https://open.iot.10086.cn/doc/mqtt/book/manual/auth/tool.html

      1. RES 格式：products/所属产品ID/devices/设备名字
         1. 例子：products/VRqhDHF2wL/devices/my_tv
      2. et：填写时间戳。
         1. 时间戳生成工具：https://tool.lu/timestamp/
      3. Key: 设备密钥
         1. <img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181617631.png" alt="image-20221009181617631" style="zoom:50%;" />
      4. 生成后将id 添加到Password

   <img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181623196.png" alt="image-20221009181623196" style="zoom:50%;" />

   4. 点击Apply，Cancel，添加Convert，再点击Disconvert。即可看到设备管理中的设备状态显示“在线”。

      <img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181630237.png" alt="image-20221009181630237" style="zoom:50%;" />

### 3. WaireShark数据包分析

1. 抓包，右键选择 Copy With ...

   <img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181636135.png" alt="image-20221009181636135" style="zoom:50%;" />

2. 数据包分析： MQTTA + 设备名称 + 换行 + username + password

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181643869.png" alt="image-20221009181643869" style="zoom:50%;" />

## 二、8266 连接MQTT

### 8266发送MQTT协议到移动MQTT平台

1. 8266设置（指令请参考8266 文档）

   1. 首先设置`WIFI模式AT+CWMODE=1`
   2. 连接热点 `AT+CWJAP="用户名","密码"`
   3. 查询热点IP `AT+CIFSR`
   4. 连接移动MQTT`AT+CIPSTART="TCP"," studio-mqtt.heclouds.com",1883`
   5. 设置非透传模式 `AT+CIPMODE=0`

2. 抓包

   1. 打开MQTT软件连接设备再断开

   2. 使用Wireshark过滤包，抓包步骤同上。

      **注意：**如果Connect不不好用，连不上，请使用Token工具重新设成时间戳和密钥，然后填写到软件的Password字段中
      
      <img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181652561.png" alt="image-20221009181652561" style="zoom:50%;" />

3. 8266发送包并断开连接

   1. 将复制到的包通过8266发送到MQTT平台

      <img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181701208.png" alt="image-20221009181701208" style="zoom:50%;" />

   2. 设置长度, AT+CIPSEND=2

   3. 发送e000,断开

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181707771.png" alt="image-20221009181707771" style="zoom:50%;" />

## 三、发布数据到MQTT平台（温度传感器例子）

### 1. 为产品新建设置物模型

https://open.iot.10086.cn/studio/device/productManage/ > 产品管理 > 选择需要设置的设备 > 点击详情

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181713480.png" alt="image-20221009181713480" style="zoom:50%;" />

### 2. 新建自定义物模型

设置物模型 > 添加自定义功能点 > 设置相关配置 > 添加

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181719573.png" alt="image-20221009181719573" style="zoom:50%;" />

### 3. 使用MQTT软件发布数据到MQTT

1. 发送请求以及请求数据

   地址：$sys/VRqhDHF2wL/my_tv/thing/property/post

   `VRqhDHF2wL` 设备ID `my_tv` 设备名
   
   ```json
   {"id": "123","version" : "1.0","params": {"wendu": {"value": 12.6}}}
   ```

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181726137.png" alt="image-20221009181726137" style="zoom:50%;" />

2. 点击Publish多发几次，value的值可以随意填写，但是不能超过范围。

### 4. 查看历史发送数据

左侧 设备管理 > 选择刚才发送的设备 > 详情 > 在下方找到对应的属性查看历史数据即可

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181732127.png" alt="image-20221009181732127" style="zoom:50%;" />

​	<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181739773.png" alt="image-20221009181739773" style="zoom:50%;" />

## 四、订阅与发布中国移动MQTT平台

### 1. 使用MQTT软件订阅

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181745622.png" alt="image-20221009181745622" style="zoom:50%;" />

### 2. 在平台模拟数据发送

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181752942.png" alt="image-20221009181752942" style="zoom:50%;" />

### 3. 属性设置与订阅结果接收

每当你点击一次属性设置的时候平台就会生成调试日志，并在MQTT软件中呈现数据设置的结果

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181801492.png" alt="image-20221009181801492" style="zoom:50%;" />

## 8266 MQTT综合实战

1. `AT+CWMODE=1`
2. `AT+CWJAP="iPhone","987654321"`
3. `AT+CIFSR`
4. `AT+CIPSTART="TCP","studio-mqtt.heclouds.com",1883`（传输层）
5. `AT+CIPMODE=0`
6. `AT+CIPSEND=155` 长度
7. `E000` 结束发送
8. `AT+CIPCLOSE` 断开链接

连接命令16进制 155长度

```
10980100044d51545404c2003c00056d795f7476000a5652716844484632774c007976657273696f6e3d323031382d31302d3331267265733d70726f64756374732532465652716844484632774c253246646576696365732532466d795f74762665743d31363631323435303331266d6574686f643d6d6435267369676e3d7934694450753659703834464f377378706364635351253344253344
```

断开链接 2长度

```
e000
```

发送JSON数据 113长度（21.1 度）

```
306f0029247379732f5652716844484632774c2f6d795f74762f7468696e672f70726f70657274792f706f73747b226964223a2022313233222c2276657273696f6e22203a2022312e30222c22706172616d73223a207b2277656e6475223a207b2276616c7565223a2032312e317d7d7d
```

订阅命令 47

```
822d00010028247379732f5652716844484632774c2f6d795f74762f7468696e672f70726f70657274792f73657400
```

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/image-20221009181810171.png" alt="image-20221009181810171" style="zoom:80%;" />

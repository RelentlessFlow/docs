# 二、关于对Vue的MVVM的理解

## **什么是MVVM？**

**概念介绍：**
[MVVM](https://so.csdn.net/so/search?q=MVVM&spm=1001.2101.3001.7020)分为三个部分：分别是M（Model，模型层 ），V（View，视图层），VM（ViewModel，V与M连接的桥梁，也可以看作为控制器）
1、 M：模型层，主要负责业务数据相关；
2、 V：视图层，顾名思义，负责视图相关，细分下来就是html+css层；
3、 VM：V与M沟通的桥梁，负责监听M或者V的修改，是实现MVVM双向绑定的要点；
MVVM支持双向绑定，意思就是当M层数据进行修改时，VM层会监测到变化，并且通知V层进行相应的修改，反之修改V层则会通知M层数据进行修改，以此也实现了视图与模型层的相互解耦；
**关系图：**

![在这里插入图片描述](https://md-1304276643.cos.ap-beijing.myqcloud.com/uPic/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBAc3VwcmVsdWM=,size_20,color_FFFFFF,t_70,g_se,x_16.png)
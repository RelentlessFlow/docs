# 二、XR-Frame典型案例

## AR：扫描图片视频 2D Marker

### 大体流程

1. AR场景加载完成后保存ar-system对象到this实例（handleReady）

   ```
   <xr-scene ar-system="modes:Marker" bind:ready="handleReady">
   ```

   ```
   handleReady: function ({ detail }) {
   	const xrScene = this.scene = detail.value;
   }
   ```

2. 新建asset-load视频资源，新建asset-material资源（id为mat），将视频作为一种背景，赋给material的uniforms属性，修改camera为AR相机

   ```xml
   <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
       <xr-asset-load type="video-texture" asset-id="hikari" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/xr-frame-team/2dmarker/hikari-v.mp4" options="loop:true" />
       <!-- 把视频作为背景图片传递给材质作为背景色，再将材质渲染到mat这个物体上， -->
       <xr-asset-material asset-id="mat" effect="simple" uniforms="u_baseColorMap: video-hikari" />
   </xr-assets>
   ```

3. 新建ar-tracker AR追踪器，新建mesh网格，将之前创建好的mat材质资源（那个视频的方块）赋给material属性

   ```xml
   <xr-ar-tracker mode="Marker" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/xr-frame-team/2dmarker/hikari.jpg" bind:ar-tracker-switch="handleTrackerSwitch">
               <!-- 当AR追踪器追踪成功后，加载mat物体（实际上就是个视频） -->
               <xr-mesh node-id="mesh-plane" geometry="plane" material="mat" />
           </xr-ar-tracker>
           <!-- AR相机：https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/render/camera.html#AR%E7%9B%B8%E5%85%B3 -->
   ```

4. 绑定ar-tracker的追踪状态事件：bind:ar-tracker-switch="handleTrackerSwitch"，控制视频的播放暂停

### 视图层

```xml
<!-- ar-system 组件：https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/ar/ -->
<!-- bind:ready 用于在AR场景加载完成后保存 AR场景对象 -->
<xr-scene ar-system="modes:Marker" bind:ready="handleReady">
    <!-- xr-assets 资源系统：https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/assets/ -->
    <!-- handleAssetsProgress 用于展示资源加载进度，可以做来做进度条 -->
    <!-- handleAssetsLoaded 用于标记资源加载已完成，可以用来处理一些复杂情况，这里用于资源加载完成后，再展示 ar-tracker -->
    <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
        <!-- xr-asset-load：https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/assets/elements.html -->
        <xr-asset-load type="video-texture" asset-id="hikari" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/xr-frame-team/2dmarker/hikari-v.mp4" options="loop:true" />
        <!-- 把视频作为背景图片传递给材质作为背景色，再将材质渲染到mat这个物体上， -->
        <xr-asset-material asset-id="mat" effect="simple" uniforms="u_baseColorMap: video-hikari" />
    </xr-assets>
    <xr-node wx:if="{{loaded}}">
        <!-- ar-tracker AR追踪器：https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/ar/tracker.html -->
        <xr-ar-tracker mode="Marker" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/xr-frame-team/2dmarker/hikari.jpg" bind:ar-tracker-switch="handleTrackerSwitch">
            <!-- 当AR追踪器追踪成功后，加载mat物体（实际上就是个视频） -->
            <xr-mesh node-id="mesh-plane" geometry="plane" material="mat" />
        </xr-ar-tracker>
        <!-- AR相机：https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/render/camera.html#AR%E7%9B%B8%E5%85%B3 -->
        <xr-camera id="camera" node-id="camera" position="1 1 1" clear-color="0.925 0.925 0.925 1" background="ar" is-ar-camera />
    </xr-node>
</xr-scene>
```

### 逻辑层

```javascript
Component({
    behaviors: [require('../common/share-behavior').default],
    properties: {},
    data: {
        loaded: false, // 资源加载完成，再加载ar-tracker音视频对象视频
    },
    // this对象上的属性
    scene: null,
    // 生命周期
    lifetimes: { async attached() {} },
    // 方法
    methods: {
        handleReady: function ({ detail }) {
            const xrScene = this.scene = detail.value;
            console.log('xr-scene', xrScene);
        },
        handleAssetsProgress: function ({ detail }) {
            // 资源加载进度
            console.log('assets progress', detail.value);
        },
        handleAssetsLoaded: function ({ detail }) {
            // 资源加载完成
            console.log('assets loaded', detail.value);
            this.setData({ loaded: true });
        },
        handleTrackerSwitch: function ({ detail }) {
            // 实时检测ar-tracker相机识别成功
            const active = detail.value;
            // 根据识别结果对视频资源进行播放暂停操作
            const video = this.scene.assets.getAsset('video-texture', 'hikari');
            if (active) {
                video.play();
            } else {
                video.stop();
            }
        }
    },
})
```

## AR：OSD Maker（物体识别）

OSD Maker实现出来的效果和2D Marker效果差不多，代码也差不多。

### 与 2D Marker区别

识别比较快，模型没法跟过去，适合用来识别特点角度的大模型，比如说在特点角度拍摩天大楼，不成熟，少用。

> OSD（One-shot Detection）Marker识别模式，也会将传入的`src`或是`image`（`image`类型资源`id`，优先使用）作为特征去识别。但不同于2D Marker，这是一个纯屏幕空间算法，只会影响到所有子节点的位置和缩放，不会影响旋转。其一般以一个现实中物体的照片作为识别源，来识别出这个物体的在屏幕中的二维区域，我们已经做好了到三维空间的转换，但开发者需要自己保证`tracker`下模型的比例是符合识别源的。OSD模式在识别那些二维的、特征清晰的物体效果最好，比如广告牌。

### 代码实现

#### 视图层

```xml
<xr-scene ar-system="modes:OSD" id="xr-scene" bind:ready="handleReady">
    <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
        <xr-asset-material asset-id="simple" effect="simple" />
        <xr-asset-material asset-id="text-simple" effect="simple" />
    </xr-assets>
    <xr-node>
        <xr-ar-tracker mode="OSD" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/marker/osdmarker-test.jpg" bind:ar-tracker-switch="handleToySwitch">
            <xr-node wx:if="{{toyReady}}" rotation="0 180 0">
                <xr-mesh node-id="text-wrap" position="0.9 0.4 0" rotation="90 0 0" scale="0.8 1 0.2" geometry="plane" material="simple" uniforms="u_baseColorFactor: 0.2 0.6 0.4 0.95" states="alphaMode: BLEND"></xr-mesh>
                <xr-mesh node-id="text-wrap-sub" position="0.9 0.1 0" rotation="90 0 0" scale="0.8 1 0.4" geometry="plane" material="simple" uniforms="u_baseColorFactor: 0 0 0 0.95" states="alphaMode: BLEND"></xr-mesh>
                <!-- 文本处于beta版本，功能不完备，仅支持使用独立材质的基础渲染，不能更新渲染（修复中） -->
                <xr-text node-id="text-name" position="0.7 0.36 0.01" scale="0.1 0.1 1" material="text-simple" value="牛年公仔"></xr-text>
                <xr-text node-id="text-name" position="0.6 0.16 0.01" scale="0.06 0.06 1" material="text-simple" value="牛年发布的奶牛公仔"></xr-text>
                <xr-text node-id="text-name" position="0.6 0.06 0.01" scale="0.06 0.06 1" material="text-simple" value="礼盒中还包含玩具盲盒"></xr-text>
            </xr-node>
        </xr-ar-tracker>

        <xr-ar-tracker mode="OSD" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/gz-tower/day.jpg" bind:ar-tracker-switch="handleDaySwitch">
            <xr-node wx:if="{{gzDayReady}}" rotation="0 180 0">
                <xr-mesh node-id="text-wrap" position="1 0.4 0" rotation="90 0 0" scale="1 1 0.2" geometry="plane" material="simple" uniforms="u_baseColorFactor: 0.2 0.6 0.4 0.95" states="alphaMode: BLEND"></xr-mesh>
                <xr-mesh node-id="text-wrap-sub" position="1 0.1 0" rotation="90 0 0" scale="1 1 0.4" geometry="plane" material="simple" uniforms="u_baseColorFactor: 0 0 0 0.95" states="alphaMode: BLEND"></xr-mesh>
                <xr-text node-id="text-name" position="0.85 0.36 0.01" scale="0.1 0.1 1" material="text-simple" value="广州塔"></xr-text>
                <xr-text node-id="text-name" position="0.6 0.18 0.01" scale="0.05 0.05 1" material="text-simple" value="广州塔（英语：Canton Tower）"></xr-text>
                <xr-text node-id="text-name" position="0.6 0.08 0.01" scale="0.05 0.05 1" material="text-simple" value="又称广州新电视塔，昵称小蛮腰"></xr-text>
                <xr-text node-id="text-name" position="0.6 -0.02 0.01" scale="0.05 0.05 1" material="text-simple" value="海拔高程600米，距离珠江南岸125米"></xr-text>
            </xr-node>
        </xr-ar-tracker>


        <xr-camera id="camera" node-id="camera" position="1 1 1" clear-color="0.925 0.925 0.925 1" far="2000" background="ar" is-ar-camera></xr-camera>
    </xr-node>
    <xr-node node-id="lights">
        <xr-light type="ambient" color="1 1 1" intensity="0.3" />
        <xr-light type="directional" rotation="30 60 0" color="1 1 1" intensity="1" />
    </xr-node>
</xr-scene>
```

#### 逻辑层

```javascript
Component({
    behaviors: [require('../common/share-behavior').default],
    data: {
        loaded: false, // 资源加载完成，暂时没用到 
        toyReady: false, // 展示玩偶信息
        gzDayReady: false, // 展示广州塔信息
    },
    lifetimes: {
        async attached() { }
    },
    methods: {
        handleReady({ detail }) {
            const xrScene = this.scene = detail.value;
            console.log('xr-scene', xrScene);
        },
        handleAssetsProgress: function ({ detail }) {
            console.log('assets progress', detail.value);
        },
        handleAssetsLoaded: function ({ detail }) {
            this.setData({ loaded: true });
        },
        handleToySwitch: function ({ detail }) {
            const active = detail.value;
            if (active) {
                this.setData({ toyReady: true });
            } else {
                this.setData({ toyReady: false });
            }
        },
        handleDaySwitch: function ({ detail }) {
            const active = detail.value;
            if (active) {
                this.setData({ gzDayReady: true });
            } else {
                this.setData({ gzDayReady: false });
            }
        },
    }
})
```

## AR：Share 截图和分享

### 大体流程

1. 编写一个点击事件，判定点击区域

   ```javascript
   handleShare(event) {
   	const { clientX, clientY } = event.touches[0];
   	const { frameWidth: width, frameHeight: height } = this.scene;
   
   	if (clientY / height > 0.7 && clientX / width > 0.7) {
   		this.scene.share.captureToFriends();
   	}
   }
   ```

2. 在AR场景加载完成后绑定该事件

   ```xml
   <xr-scene id="xr-scene" bind:ready="handleReady">
   ```

   ```javascript
   handleReady({ detail }) {
   	this.scene = detail.value;
   	this.scene.event.add('touchstart', this.handleShare.bind(this));
   }
   ```

## AR：AR图片视频识别综合案例

### ar-tacker-2d页面

**视图层**

```xml
<view class="page">
    <xr-tracker-2d
        disable-scroll
        id="xr-frame"
        width="{{xrFrame.renderWidth}}"
        height="{{xrFrame.renderHeight}}"
        style="width:{{xrFrame.width}}px;height:{{xrFrame.height}}px;display:block;"   
    />
    <view class="share">
        <view class="share_button" bind:tap="share">分享画面</view>
    </view>
</view>
```

**逻辑层**

```javascript
// pages/ar-tracker-2d/index.ts
Page({
  // 自定义对象
  xrFrameInstance: null,
  // Page自带对象
  data: {
    xrFrame: {
      width: 300,
      height: 300,
      renderWidth: 300,
      renderHeight: 300,
    }
  },
  onReady() {
    this.xrFrameInstance = this.selectComponent("#xr-frame")
  },
  onLoad() {
    const { windowWidth, windowHeight, pixelRatio } = wx.getSystemInfoSync();
    const xrFrame = {
      width: windowWidth,
      height: windowHeight,
      renderWidth: windowWidth * pixelRatio,
      renderHeight: windowHeight * pixelRatio,
    }
    this.setData({ xrFrame });
  },
  share() {
    this.xrFrameInstance.handleShare();
  },
})
```

### xr-tracker-2d组件

**配置层**

```json
{
    "component": true,
    "usingComponents": {},
    "renderer": "xr-frame"
}
```

**视图层**

```xml
<xr-scene id="xr-scene" ar-system="modes:Marker" bind:ready="handleReady">
  <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">        
    <xr-asset-load type="video-texture" asset-id="asset-video-flower" src="{{video.src}}" options="loop:true" />
    <xr-asset-material asset-id="mat" effect="simple" uniforms="u_baseColorMap: video-asset-video-flower" />
  </xr-assets>
  <xr-node>
    <xr-ar-tracker mode="Marker" src="{{marker.img}}" bind:ar-tracker-switch="handleTrackerSwitch">
      <xr-mesh 
        wx:if="{{assetLoaded && video.loaded}}" 
        node-id="mesh-plane" 
        geometry="plane" 
        material="mat" 
        scale="{{marker.width}} 1 {{marker.height}}"
        
      />
    </xr-ar-tracker>
    <xr-camera id="camera" node-id="camera" position="1 1 1" background="ar" near="0.1" far="2000" clear-color="0.96 0.96 0.96 1" is-ar-camera />
  </xr-node>
</xr-scene>
```

**逻辑层**

```javascript
Component({
  data: {
    showLoading: false,
    assetLoaded: false,
    marker: {
      img: "https://pic.amlab.com.cn/wechat/niao-chao-yi-shu/markerImg/haibaomarker.jpg",
      width: 1,
      height: 1,
    },
    video: {
      src: "https://pic.amlab.com.cn/wechat/niao-chao-yi-shu/video/haibaomarker-video.mp4",
      loaded: false,
    },
  },
  lifetimes: {},
  methods: {
    // 事件
    handleReady({ detail }) {
      this.scene = detail.value;
      this.videoHandler();
    },
    handleAssetsProgress: function ({ detail }) {
      const {
        value: { progress },
      } = detail;
      // 资源加载进度
      wx.showLoading({
        title: `资源加载中 ${progress*100}%`,
      });
    },
    handleAssetsLoaded: function () {
      this.setData({
        assetLoaded: true,
      });
      wx.hideLoading();
    },
    handleTrackerSwitch: function ({ detail }) {
      // 实时检测ar-tracker相机识别成功
      const active = detail.value;
      // 根据识别结果对视频资源进行播放暂停操作
      const video = this.scene.assets.getAsset("video-texture", "asset-video-flower");
      if (active) {
        video.play();
      } else {
        video.stop();
      }
    },
    // 方法
    // 视频比例处理函数
    videoHandler() {
      const { marker, video } = this.data;
      this.setData({
        marker: { ...marker, loaded: false },
      });
      wx.getImageInfo({
        src: this.data.marker.img,
        success: (res) => {
          const { width, height } = res;
          const widthDivideHeight = width / height;
          this.setData({
            video: {
              ...video,
              loaded: true,
            },
            marker: {
              ...marker,
              width: 1,
              height: (1 / widthDivideHeight).toFixed(2),
            },
          });
        },
        fail: (res) => {
          console.error(res);
        },
      });
    },
    // 场景分享函数
    handleShare() {
      this.scene.share.captureToFriends();
    },
  },
});

```

## AR：AR手部识别

AR Hand文档：https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/ar/tracker.html#Hand

### 特征点

![img](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/hand.d0aa58d9.jpg)

### 手势姿态（`0~18`，`-1`为无效）：

![img](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/gesture.14eef626.jpg)

### AR Hand产品销售案例

#### 页面层

constant.js

```javascript
const products = [
    {
        "id": "1_gltf-mac_mini",
        "title": "Mac Mini",
        "subTitle": "银色",
        "sku": ["8+256 3699", "8+512 4999", "16+512 7999"],
        "gltfId": "gltf-mac_mini",
        "gltfSource": "https://md-1304276643.cos.ap-beijing.myqcloud.com/Temp/mac_mini.glb",
        "gltfRotation": "295 0 0",
        "gltfPositon": "0 3 -5",
        "gltfScale": "1 1 1",
        "autoplay": false,
        "imgSource": "https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/20230901094010.png",
      },
      {
        "id": "2_gltf-iphone12_pro",
        "title": "iPhone12 Pro",
        "subTitle": "海军蓝",
        "sku": ["128G 7999", "256G 8699", "512G 1099"],
        "gltfId": "gltf-iphone12_pro",
        "gltfSource": "https://md-1304276643.cos.ap-beijing.myqcloud.com/Temp/iphone_12_pro.glb",
        "gltfRotation": '',
        "gltfPositon": "0 0.5 -2",
        "gltfScale": "0.01 0.01 0.01",
        "autoplay": false,
        "imgSource": "https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/20230901093936.png",
      },
      {
        "id": "2_gltf-macbookpro16_2019",
        "title": "MacbookPro16 2019",
        "subTitle": "深空灰",
        "sku": ["16+512 18999", "16+1T 21999", "32+1T 26999"],
        "gltfId": "gltf-macbookpro16_2019",
        "gltfSource": "https://md-1304276643.cos.ap-beijing.myqcloud.com/Temp/macbook.glb",
        "gltfRotation": "0 270 40",
        "gltfPositon": "0 1 -2",
        "gltfScale": "2 2 2",
        "autoplay": false,
        "imgSource": "https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/20230901094100.png",
      }
];

export {  products };
```

```less
.page {
    height: 100vh;
    width: 100vw;
    overflow-x: hidden;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    flex-direction: column;
    flex-wrap: nowrap;
    background-color: #000;
    position: relative;

    .button-group {
        position: absolute;
        top: 70%;
        left: 50%;
        width: 400rpx;
        height: 400rpx;
        margin-left: -200rpx;
        margin-top: -200rpx;
        justify-content: space-between;
        align-items: center;
        display: flex;
        flex-direction: column;

        .button {
            color: #fff;
            width: 240rpx;
            height: 100rpx;
            line-height: 100rpx;
            text-align: center;
            background-color: rgba(255, 255, 255, 0.616);
            border-radius: 20px;
            font-size: 20px;
        }
    }

    .products {
        position: absolute;
        bottom: 0;
        width: 100%;
        height: 300rpx;
        display: grid;
        grid-template-columns: auto auto auto;
        grid-gap: 10px;
        background-color: #fff;
        overflow: auto;

        .product {
            .product-image {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
        }
    }
}
```

pages/wxml

```xml
<view class="page">
    <xr-hand
        disable-scroll
        id="xr-frame"
        width="{{xrProps.renderWidth}}"
        height="{{xrProps.renderHeight}}"
        style="width:{{xrProps.width}}px;height:{{xrProps.height}}px;display:block;"
        product="{{xrProps.product}}"
        bind:info="handleInfo"
    />
    <view class="button-group">
        <view class="button" bind:tap="share">分享画面</view>
        <!-- <view class="button">gesture: {{xrData.gesture}}</view> -->
        <!-- <view class="button">score: {{xrData.score}}</view> -->
    </view>
    <view class="products" wx:if="{{xrProps.products}}">
        <view class="product" wx:for="{{xrProps.products}}" wx:for-item="product">
            <image class="product-image" src="{{product.imgSource}}" data-product="{{product}}" bind:tap="handleProductTap" />
        </view>
    </view>
</view>
```

pages/index.js

```javascript
import { products } from "./constant";
Page({
  // 自定义对象
  xrFrameInstance: null,
  // Page自带对象
  data: {
    xrProps: {
      width: 300,
      height: 300,
      renderWidth: 300,
      renderHeight: 300,
      products: null, 
      product: null,
    },
    xrData: {
      gesture: 0,
      score: 0,
    },
  },
  // 生命周期
  onReady() {
    this.xrFrameInstance = this.selectComponent("#xr-frame");
  },
  async onLoad() {
    // 获取屏幕尺寸
    const { windowWidth, windowHeight, pixelRatio } = wx.getSystemInfoSync();
    const xrProps = {
      width: windowWidth,
      height: windowHeight,
      renderWidth: windowWidth * pixelRatio,
      renderHeight: windowHeight * pixelRatio,
    };
    this.setData({ xrProps });
    // 获取XR数据
    wx.showLoading({ title: "获取网络资源中" })
    const { products } = await this.getProducts();
    xrProps.products = products;
    xrProps.product = products[0];
    this.setData({ xrProps });
    wx.hideLoading();
  },
  // 事件
  handleInfo: function ({ detail }) {
    this.setData({ xrData: { ...detail } });
  },
  handleProductTap: function (e) {
    const { product } = e.currentTarget.dataset;
    const { xrProps } = this.data;
    this.setData({ xrProps: { ...xrProps, product } });
  },
  // 函数
  getProducts() {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({
          products: products,
        })
      }, 1000)
    })
  },
  share() {
    this.xrFrameInstance.handleShare();
  },
});
```

index.json

```json
{
  "usingComponents": {
      "xr-hand": "../../components/xr-hand/index"
  },
  "disableScroll": true,
  "navigationBarTitleText": "",
  "navigationBarBackgroundColor": "#ffffff00",
  "navigationStyle": "custom"
}
```

#### 组件层

index.json

```json
{
    "component": true,
    "usingComponents": {},
    "renderer": "xr-frame"
}
```

index.wxml

```xml
<xr-scene ar-system="modes:Hand" bind:ready="handleReady" bind:ar-ready="handleARReady" bind:ar-error="handleArError">
  <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
    <xr-asset-material asset-id="simple" effect="simple" />
    <xr-asset-material asset-id="text-simple" effect="simple" />
  </xr-assets>
  <xr-node wx:if="{{arReady}}">
    <xr-ar-tracker id='tracker' mode="Hand" auto-sync="9">
      <!-- 产品模型 -->
      <xr-gltf wx:if="{{dynamicAssetReady}}" node-id="{{product.gltfId}}" position="0 0.5 -2" rotation="{{product.gltfRotation || '0 '+rotate+' 0'}}" scale="{{product.gltfScale}}" model="{{product.gltfId}}" anim-autoplay="{{product.autoplay}}" />
      <xr-node wx:if="{{gesture !== -1}}" node-id="product-info">
        <!-- 产品信息 -->
        <!-- 蒙板 -->
        <xr-mesh node-id="text-wrap" position="-1.1 0.51 1.2" rotation="90 180 0" scale="0.8 1 0.2" geometry="plane" material="simple" receive-shadow uniforms="u_baseColorFactor: 0.2 0.6 0.4 0.95" states="alphaMode: BLEND"></xr-mesh>
        <!-- 文字 -->
        <!-- 标题 -->
        <xr-text node-id="text-name" position="-0.7 0.56 1" rotation="30 180 0" scale="0.1 0.1 1" material="text-simple" value="{{product.title}}"></xr-text>
        <!-- 副标题 -->
        <xr-text node-id="text-name" position="-0.7 0.46 1" rotation="30 180 0" scale="0.06 0.06 1" material="text-simple" value="{{product.subTitle}}"></xr-text>
        <!-- 描述信息 -->
        <xr-text wx:for="{{product.sku}}" wx:for-item="sku" node-id="text-name" position="-0.7 {{0.36-index*0.1}} 1" rotation="30 180 0" scale="0.06 0.06 1" material="text-simple" value="{{sku}}" />
      </xr-node>
    </xr-ar-tracker>
    <xr-camera id="camera" node-id="camera" clear-color="0.925 0.925 0.925 1" background="ar" is-ar-camera near="0.01"></xr-camera>
  </xr-node>
  <xr-node node-id="lights">
    <xr-light type="ambient" color="1 1 1" intensity="5" />
    <xr-light type="directional" rotation="45 180 0" color="1 1 1" intensity="10" />
  </xr-node>
</xr-scene>
```

index.js

```javascript
Component({
  // this 自定义属性
  xrScene: null,
  rotateInterval: null,
  // Component 自带属性
  properties: {
    product: {
      type: Object,
      value: null,
      observer: function (newVal, oldVal) {
        console.log("newVal, oldVal", newVal, oldVal);
        this.dynamicAssetLoader(newVal, oldVal);
      },
    },
  },
  data: {
    arReady: false,
    assetReady: true,
    dynamicAssetReady: false,
    ready: false,
    rotate: 0,
    rotateIncrease: false,
    gesture: -1,
    score: 0,
  },
  lifetimes: {
    attached: function () {},
    detached: function () {
      clearInterval(this.intervalRotate);
    },
  },
  methods: {
    handleReady({ detail }) {
      wx.showLoading({ title: "AR系统初始化" });
      const xrScene = detail.value;
      this.scene = xrScene;
      xrScene.event.add("tick", this.handleTick.bind(this));
    },
    handleAssetsProgress: function ({ detail }) {
      const {
        value: { progress },
      } = detail;
      wx.showLoading({ title: `资源加载中${(progress * 100).toFixed(0)}%` });
    },
    handleARReady: function () {
      this.setData({ arReady: true });
    },
    handleAssetsLoaded: function () {
      wx.showLoading({ title: "资源加载完成" });
      this.setData({ assetReady: true });
    },
    handleArError: function () {
      wx.showToast({ title: "AR场景加载失败", icon: "error" });
    },
    handleTick: function () {
      const xrSystem = wx.getXrFrameSystem();
      const trackerEl = this.scene.getElementById("tracker");
      if (!trackerEl) {
        return;
      }
      const tracker = trackerEl.getComponent(xrSystem.ARTracker);
      if (!tracker.arActive) {
        return;
      }
      const gesture = tracker.gesture;
      // 获取总体置信度
      const score = tracker.score;

      this.setData({ gesture, score });
      this.triggerEvent("info", { gesture, score });
    },
    // 动画加载模型
    dynamicAssetLoader: async function (gltf, oldGltf) {
      wx.showLoading({ title: "模型加载中" });
      const { data, scene } = this;
      const { dynamicAssetReady } = data;
      if (dynamicAssetReady && oldGltf) {
        // 如果之前加载过产品的网络资源，释放掉
        scene.assets.releaseAsset("gltf", oldGltf.gltfId);
        this.setData({ dynamicAssetReady: false });
      }
      await scene.assets.loadAsset({
        type: "gltf",
        assetId: gltf.gltfId,
        src: gltf.gltfSource,
      });
      this.setData({ dynamicAssetReady: true });
      wx.hideLoading();
    },
    // 场景分享函数
    handleShare() {
      this.scene.share.captureToFriends();
    },
  },
  observers: {
    "gesture": function ( gesture ) {
      const { rotateInterval } = this; 
      if(gesture === -1) {
        rotateInterval && clearInterval(rotateInterval)
        this.rotateInterval = setInterval(() => {
          let { rotate, rotateIncrease } = this.data;
          rotateIncrease ? (rotate += 1) : (rotate -= 1);
          rotateIncrease = rotate === 360;
          this.setData({ rotate, rotateIncrease });
        }, 50);
      }
    },
  },
});
```

### AR Hand 动画案例

利用Animation、ShadowRoot完成模型的动态加载

#### 视图层

```xml
<xr-scene ar-system="modes:Hand"
          bind:ready="handleReady"
          bind:ar-ready="handleARReady"
          bind:ar-error="handleArError"
>
  <xr-node wx:if="{{arReady}}">
    <xr-ar-tracker id='tracker' mode="Hand" auto-sync="5">
      <xr-shadow position="0 0 0" rotation="0 0 0" scale="1 1 1" id="shadow-root"></xr-shadow>
    </xr-ar-tracker>
    <xr-camera id="camera" node-id="camera" clear-color="0.925 0.925 0.925 1" background="ar" is-ar-camera near="0.01"></xr-camera>
  </xr-node>
  <xr-node node-id="lights">
    <xr-light type="ambient" color="1 1 1" intensity="5" />
    <xr-light type="directional" rotation="45 180 0" color="1 1 1" intensity="10" />
  </xr-node>
</xr-scene>
```

逻辑层

```javascript
const initTracker = {
  gesture: -1,
  score: 0
}

const gltfPosition = [
    [0, -0.2, 0], [0.12, -0.32, 0], [0.27, -0.4, 0]
];

Component({
  // this 自定义属性
  scene: null,
  shadowRoot: null,
  // Component 自带属性
  properties:{
    tracker: {
      type: Object,
      value: initTracker,
    },
  },
  data: {
    arReady: false,
    animFlag: false,
  },
  lifetimes: {
    attached: function () {},
    detached: function () {},
  },
  methods: {
    // 事件
    handleReady: async function({ detail }) {
      this.scene = detail.value;
      await wx.showLoading({ title: "AR系统初始化" });
    },
    handleARReady: async function () {
      this.setData({ arReady: true });
      this.shadowRoot = this.scene.getElementById('shadow-root');
      await this.initShadowTracker();
      await wx.hideLoading();
    },
    handleArError: async function () {
      this.setData({ arReady: false });
      await wx.showLoading({ title: "AR场景加载失败", icon: "error" });
      setTimeout(() => wx.hideLoading());
    },
    // 场景分享函数
    handleShare: function () {
      this.scene.share.captureToFriends();
    },
    // 初始化用于Tracker的AR模型
    initShadowTracker: async function () {
      const { shadowRoot, scene, data } = this;
      const xrFrameSystem = wx.getXrFrameSystem();
      // 一、加载gltf资源
      const gltfSource = 'https://md-1304276643.cos.ap-beijing.myqcloud.com/Gltf/heart_knot.glb';
      const {value: model} = await scene.assets.loadAsset({
        type: 'gltf',
        assetId: 'asset-gltf-heart_knot',
        src: gltfSource
      });
      // 二、加载gltf元素
      gltfPosition.map(async (pos, index) => {
        // 1、新建元素
        const gltfElement = scene.createElement(xrFrameSystem.XRGLTF);
        // 2、处理位置变换
        const transComp = gltfElement.getComponent(xrFrameSystem.Transform);
        transComp.setData({ scale: [0.6, 0.6, 0.6], position: pos });
        // 3、处理gltf模型
        const gltfComp = gltfElement.getComponent(xrFrameSystem.GLTF);
        gltfComp.setData({ model, nodeId: `gltf-heart_knot_${index+1}` });
        // 4、处理触控轮廓
        const meshShapeComp = gltfElement.addComponent(xrFrameSystem.CapsuleShape);
        meshShapeComp.setData({ autoFit: true });
        // 5、展示触控轮廓
        const shapeGizmosComp = gltfElement.addComponent(xrFrameSystem.MeshShape);
        // 6、处理模型动画
        // 1）新建动画组件Animator
        const animatorComp = gltfElement.addComponent(xrFrameSystem.Animator);
        // 2）定义关键帧
        const stepOne = {
          "scale": [0.6, 0.6, 0.6],
          "rotation": [0, 0, 0],
          "position": pos
        };
        const stepTwo = {
          "scale": [1, 1, 1],
          "rotation": [0, 1.8, 0],
          "position": pos
        };
        const stepThree = {
          "scale": [2, 2, 2],
          "rotation": [0, 3.6, 0],
          "position": gltfPosition[1]
        };
        // 3）新建关键帧对象
        const keyframe = new xrFrameSystem.KeyframeAnimation(scene, {
          "keyframe": {
            "zoom_in": {
              "0": stepOne,
              "50": stepTwo,
              "100": stepThree
            },
            "zoom_out": {
              "0": stepThree,
              "50": stepTwo,
              "100": stepOne
            }
          },
          "animation": {
            "zoom_in": {
              "keyframe": "zoom_in",
              "duration": 1,
              "ease": "ease-in",
              "loop": 0,
              "delay": 1,
              "direction": "both"
            },
            "zoom_out": {
              "keyframe": "zoom_out",
              "duration": 1,
              "ease": "ease-in",
              "loop": 0,
              "delay": 1,
              "direction": "both"
            }
          }
        })
        // 5）为动画组件设置Animation对象（keyframe为KeyframeAnimation，KeyframeAnimation继承自Animation）
        animatorComp.setData({ keyframe });
        // 6、处理触控事件
        gltfComp.el.event.add("touch-shape", () => {
          const newFlag = !this.data.animFlag;
          this.setData({ animFlag: newFlag })
          if(newFlag) {
            animatorComp.pause('zoom_out');
            animatorComp.play('zoom_in');
          }
          if(!newFlag) {
            animatorComp.pause('zoom_in');
            animatorComp.play('zoom_out');
          }
        });
        // 3、添加元素到Shadow节点
        shadowRoot.addChild(gltfElement);
      });
    },
  },

  observers: {},
});

export {
  initTracker
}
```

## Gltf模型——头盔案例（带光照）

gltf文档：https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/gltf/introduction.html

### 如何使用gltf模型

1. 声明gltf资源

```xml
<xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
	<xr-asset-load type="gltf" asset-id="gltf-damageHelmet" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/damage-helmet/index.gltf" />
</xr-assets>
```

2. 使用GLTF组件

```xml
<xr-gltf node-id="gltf-damageHelmet" position="0 0 0" rotation="0 0 0" scale="1.2 1.2 1.2" model="gltf-damageHelmet"></xr-gltf>
```

### 完整案例

#### 视图层

```xml
<xr-scene id="xr-scene" bind:ready="handleReady">
  <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
    <xr-asset-load type="env-data" asset-id="env1" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/env-test.bin" />
    <xr-asset-load type="gltf" asset-id="gltf-damageHelmet" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/damage-helmet/index.gltf" />
  </xr-assets>
  <xr-env env-data="env1" />
  <xr-node>
    <xr-node node-id="camera-target" position="0 0 0"></xr-node>
    <xr-gltf node-id="gltf-damageHelmet" position="0 0 0" rotation="0 0 0" scale="1.2 1.2 1.2" model="gltf-damageHelmet"></xr-gltf>
    <xr-camera
      id="camera" node-id="camera" position="0 0 3" clear-color="0.925 0.925 0.925 1"
      near="0.1" far="2000"
      target="camera-" background="skybox" camera-orbit-control=""
    ></xr-camera>
  </xr-node>
  <xr-node node-id="lights">
    <xr-light type="ambient" color="1 1 1" intensity="0.3" />
    <xr-light type="directional" rotation="40 180 0" color="1 1 1" intensity="2" />
  </xr-node>
</xr-scene>
```

xr-camera中的near="0.1" far="2000"为投影方式中的**近裁剪平面**和**远裁剪平面**，camera-orbit-control="" **允许用户自行旋转摄像头**。

> https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/render/camera.html#%E6%8A%95%E5%BD%B1%E6%96%B9%E5%BC%8F

xr-light中ambient为环境光，directional为平行光

主光源包含两部分——按照编写顺序第一个写的环境光和平行光：

1. 环境光：类型是`ambient`，支持颜色`color`和亮度`intensity`，直接影响物体的基础颜色和亮度。
2. 平行光：类型是`directional`，支持颜色`color`和亮度`intensity`，以及通过旋转`rotation`决定的方向，为物体表面通过不同光照算法提供明暗。

intensity 光照强度，color 光照颜色

> https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/render/light.html#%E9%98%B4%E5%BD%B1

#### 逻辑层

```javascript
Component({
  data: {},
  lifetimes: {},
  methods: {
    // 事件
    handleAssetsProgress: function ({ detail }) {
      const {
        value: { progress },
      } = detail;
      wx.showLoading({
        title: `资源加载中 ${progress*100}%`,
      });
    },
    handleAssetsLoaded: function () {
      wx.hideLoading();
    },
    // 场景分享函数
    handleShare() {
      this.scene.share.captureToFriends();
    },
  },
});
```

## Gltf模型：无光照gltf案例

gltf模型本身带光泽，不需要灯光

```xml
<xr-scene id="xr-scene" bind:ready="handleReady">
  <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
    <xr-asset-load type="gltf" asset-id="gltf-girl" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/just_a_girl/index.glb" />
  </xr-assets>
  <xr-node>
    <xr-node node-id="camera-target" position="0 0 0"></xr-node>
    <xr-gltf node-id="gltf-girl" position="0 -0.5 0" rotation="0 0 0" scale="0.01 0.01 0.01" model="gltf-girl"></xr-gltf>
    <xr-camera
      id="camera" node-id="camera" position="0 0.4 3" clear-color="0.925 0.925 0.925 1"
      near="0.1"far="2000"
      target="camera-target" 
    />
  </xr-node>
</xr-scene>
```

## Gltf模型：多光照场景

### 视图层

```xml
<xr-scene id="xr-scene" bind:ready="handleReady">
  <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
    <xr-asset-load type="gltf" asset-id="gltf-Sponza" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/Sponza/glTF/Sponza.gltf" />
  </xr-assets>
  <xr-node>
    <xr-node node-id="camera-target" position="0 2 0"></xr-node>
    <xr-gltf node-id="mesh-gltf-Sponza" position="0 -2 0.5" rotation="0 0 0" scale="2 2 2" model="gltf-Sponza"></xr-gltf>
    <xr-camera
      id="camera" node-id="camera" position="-5 2 0" clear-color="0.925 0.925 0.925 1"
      near="0.1" far="1000"
      target="camera-target"
      camera-orbit-control=""
    />
  </xr-node>
  <xr-node node-id="lights">
    <xr-light type="ambient" color="1 1 1" intensity="1" />
    <!-- xr-light:四种灯光:directional平行光,ambient环境光, point点光源,spot 聚光灯 -->
    <!-- directional平行光,rotation三个参数 ,默认是从模型正面照射-->
    <!-- 第一个参数是以上下,就是纵截面那个圆进行旋转,90度即模型头顶,180度即为模型后面,  -->
    <!-- 第二个参数是以左右,就是横截面那个圆进行旋转,90度即模型左手边,180度即为模型后面,  -->
    <!-- 第三个参数不知道干啥的  -->
    <xr-light type="directional" color="1 1 1" rotation="120 -40 0" intensity="4" />
    <!-- point点光源,spot 聚光灯-->
    <!-- rotation三个参数,默认是从模型的左手往右手照射 -->
    <!-- 第一个参数是以左右,就是横截面那个圆进行旋转,90度即模型从左手到头顶,180度即为模型右边,  -->
    <!-- 后面两个参不知道干啥用的 -->
    <!-- 大体调试思路 -->
    <!-- 1. 设置rotation为90 0 0,光源正好在正方面 -->
    <!-- 2. 调节position,
      第一个参数为光源在场景的前后位置,
      第二个参数为光源的高度,因为是锥形光,高度越高,光打在模型上约柔和,高度太低,光线反而散发不出来 
    -->
    <!-- 聚光灯是个锥型, 锥体的锥角由inner-cone-angle和outer-cone-angle控制,光线更柔和,其他参数spot和point基本一致  -->
    <xr-light type="spot" color="0.8 0.8 0.2"
      rotation="90 0 0" position="20 10 0"
      range="20" intensity="1000"
      inner-cone-angle="5" outer-cone-angle="24"
    />
  </xr-node>
</xr-scene>
```

### 逻辑层

```javascript
Component({
  interval: null,
  data: {
    num: 0,
  },
  lifetimes: {
    attached: function () {},
    detached: function () {
      clearInterval(this.interval);
    },
  },
  observers: {},
  methods: {
    // 事件
    handleAssetsProgress: function ({ detail }) {
      const {
        value: { progress },
      } = detail;
      // 资源加载进度
      wx.showLoading({
        title: `资源加载中 ${progress * 100}%`,
      });
    },
    handleAssetsLoaded: function () {
      wx.hideLoading();
      this.interval = setInterval(() => {
        const num = this.data.num;
        console.log(num);
        this.setData({ num: num + 1 });
      }, 500);
    },
    // 场景分享函数
    handleShare() {
      this.scene.share.captureToFriends();
    },
  },
});
```

### 灯光(Light)

> https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/render/light.html#%E9%98%B4%E5%BD%B1

xr-light有四种灯光：

- directional平行光
- ambient环境光,
- point点光源
- spot 聚光灯

**1、 ambient 环境光**

ambient环境光使用比较简单，设置下intensity就行了

```xml
<xr-light type="ambient" color="1 1 1" intensity="0.1" />
```

**2、 directional 平行光**

这个灯光需要设置旋转方向rotation：

rotation有三个参数，默认是从模型的正前面往后面照射

- 第一个参数是以上下,就是纵截面那个圆进行旋转,90度即模型头顶,180度即为模型后面
- 第二个参数是以左右,就是横截面那个圆进行旋转,90度即模型左手边,180度即为模型后面
- 第三个参数不知道干啥的

```xml
<xr-light type="directional" color="1 1 1" rotation="120 -40 0" intensity="4" />
```

**3、 point 点光源**

这个灯光需要设置旋转方向rotation，和position位置

rotation三个参数,默认是从模型的左手往右手照射

第一个参数是以左右,就是横截面那个圆进行旋转,90度即模型从左手到头顶,180度即为模型右边

后面两个参不知道干啥用的

**4、 spot 聚光灯**

这个灯源用法和point 差不多，多了两个参数：inner-cone-angle，outer-cone-angle

聚光灯是个锥型, 锥体的锥角由inner-cone-angle和outer-cone-angle控制,光线更柔和,其他参数spot和point基本一致

### point 和spot 大体调试思路

1. 设置rotation为90 0 0,光源正好在正方面

2. 调节position

   第一个参数为光源在场景的前后位置

   第二个参数为光源的高度, 如果是锥形光, 高度不要太低了，高度越高,光打在模型上约柔和,高度太低,光线反而散发不出来

**技巧：**可以用一个定时器，去动态的设置灯光的位置，找到最合适的点。

**实际上这个定时器可以控制大部分物体的位置,但是不能控制摄像机的位置.**

## Gltf模型：动画

部分gltf模型自带动画

```xml
<xr-asset-load type="gltf" asset-id="miku-kawaii" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/shiteyanyo-hatsune-miku/index.glb" />
```

加上这一个属性：`anim-autoplay`

```xml
<xr-gltf position="1.8 -0.5 1.5" scale="0.12 0.12 0.12" rotation="0 180 0" model="miku" anim-autoplay></xr-gltf>
```

### 帧动画

帧动画是一种内置的动画实现，就是写json

具体看这个，我没看懂

> https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/animation/keyframe.html

### Morph Target动画

参考链接：https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/gltf/specification.htm

好像就是一种gltf内置的动画，不需要特殊的配置

```xml
<xr-asset-load type="gltf" asset-id="home" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/pokemon_loreleis_arena/index.glb" />
```

```xml
<xr-gltf position="0 2.4 0" scale="0.03 0.03 0.03" model="baibianguai" cast-shadow anim-autoplay></xr-gltf>
```

### GLTF阴影

| cast-shadow    | GLTF.castShadow    | GLTF模型是否投射阴影 |
| -------------- | ------------------ | -------------------- |
| receive-shadow | GLTF.receiveShadow | GLTF模型是否接受阴影 |

### 示例代码

**视图层**

```xml
<xr-scene id="xr-scene" bind:ready="handleReady">
  <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
    <xr-asset-load type="gltf" asset-id="home" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/pokemon_loreleis_arena/index.glb" />
    <xr-asset-load type="gltf" asset-id="baibianguai" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/baibianguai/index.glb" />  </xr-assets>
  <xr-node>
    <xr-node node-id="camera-target" position="0 1 0" />
    <xr-gltf position="0 2.4 0" scale="0.03 0.03 0.03" model="baibianguai" cast-shadow anim-autoplay></xr-gltf>
    <xr-gltf position="0 0 0" scale="100 100 100" model="home" cast-shadow anim-autoplay></xr-gltf>
    <xr-camera
      id="camera" node-id="camera" 
      position="0 4 8" clear-color="0.925 0.925 0.925 1"
      target="camera-target"
      camera-orbit-control=""
    />
  </xr-node>
  <xr-node node-id="lights">
    <xr-light type="ambient" color="1 1 1" intensity="1" />
    <xr-light type="directional" color="1 1 1" rotation="120 40 0" intensity="4" />
  </xr-node>
</xr-scene>
```

## Gltf动态加载模型

```javascript
netAssetLoader: async function() {
    const { data, scene } = this;
    const { product } = data;
    const { value } = await scene.assets.loadAsset({type: 'gltf', assetId: product.gltfId, src: product.gltfSource});
    console.log('netAssetLoader', value);
    this.setData({ netAssetReady: true })
},
```

## Mesh：内置几何、光照简单案例

可用来测试光照、模型效果

内置材质几何：https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/builtin/geometry.html

```xml
<xr-scene id="xr-scene" bind:ready="handleReady">
  <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
    <xr-asset-material asset-id="standard-mat" effect="standard" />
  </xr-assets>
  <xr-node>
    <xr-mesh node-id="mesh-plane" position="0 -0.02 -4" rotation="0 0 0" scale="5 1 5" geometry="plane" material="standard-mat" uniforms="u_baseColorFactor:0.48 0.78 0.64 1" receive-shadow></xr-mesh>
    <xr-mesh id="cube" node-id="mesh-cube" position="-1 0.5 -3.5" scale="1 1 1" rotation="0 45 0" geometry="cube" material="standard-mat" uniforms="u_baseColorFactor:0.298 0.764 0.85 1" cast-shadow></xr-mesh>
    <xr-mesh node-id="mesh-cylinder" position="1 0.7 -3.5" scale="1 0.7 1" geometry="cylinder" material="standard-mat" uniforms="u_baseColorFactor:1 0.776 0.364 1" cast-shadow></xr-mesh>
    <xr-mesh node-id="mesh-sphere" position="0 1.25 -5" scale="1.25 1.25 1.25" geometry="sphere" material="standard-mat" uniforms="u_baseColorFactor:0.937 0.176 0.368 1" cast-shadow></xr-mesh>
    <xr-camera
      id="camera" node-id="camera" position="0 1.6 8" clear-color="0.925 0.925 0.925 1"
      target="mesh-sphere"
      camera-orbit-control=""
    ></xr-camera>
  </xr-node>
  <xr-node node-id="lights">
    <xr-light type="ambient" color="1 1 1" intensity="1" />
    <xr-light type="directional" rotation="0 180 0" color="1 1 1" intensity="3" cast-shadow/>
  </xr-node>
</xr-scene>
```

```javascript
Component({
  // this对象上的属性
  scene: null,
  // Component构造方法内置属性
  data: {},
  lifetimes: {},
  methods: {
    handleReady: function ({ detail }) {
      this.scene = detail.value;
    },
    // 场景分享函数
    handleShare() {
      this.scene.share.captureToFriends();
    },
  },
});
```

## Mesh：视频纹理

整体用法和图片纹理差不多，只不过多了视频的播放暂停控制

### 视图层

```xml
<xr-scene id="xr-scene" bind:ready="handleReady">
  <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
    <!-- 作为长方体的贴图 资源 -->
    <xr-asset-load
      type="video-texture" asset-id="cat"
      src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/videos/cat.mp4" options="autoPlay:true,loop:true,abortAudio:false,placeHolder:https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/videos/cat.jpg"
    />
    <!-- 作为摄像机的背景环境 资源 -->
    <xr-asset-load
      type="video-texture" asset-id="skybox"
      src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/videos/office-skybox.mp4" options="autoPlay:true,loop:true,placeHolder:https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/videos/office-skybox.jpg"
    />
    <!-- 标准材质 -->
    <xr-asset-material asset-id="standard-mat" effect="standard" />
  </xr-assets>
  <!-- 摄像机的背景环境 -->
  <xr-env sky-map="video-skybox" />
  <xr-node>
    <!-- 摄像机朝向的位置，默认 0 0 0 -->
    <xr-node node-id="target" />
    <!-- 一个长方体，标准材质，uniforms 设置为视频作为背景 -->
    <!-- cube-shape表示触控时的物体轮廓，这里为立方体轮廓 -->
    <!-- touch-shape	为轮廓交互事件 -->
    <xr-mesh
      node-id="mesh-cube" scale="1.6 0.9 0.9"
      geometry="cube" material="standard-mat"
      uniforms="u_baseColorMap:video-cat"
      cube-shape="autoFit:true"
      bind:touch-shape="handleTouchCube"
      bind:untouch-shape="handleUnTouchCube"
      bind:drag-shape="handleDragCube"
    />
    <xr-camera
      id="camera" node-id="camera" position="0 1.2 4" 
      clear-color="0.925 0.925 0.925 1" background="skybox"
      target="target" camera-orbit-control=""
    ></xr-camera>
  </xr-node>
  <xr-node node-id="lights">
    <xr-light type="ambient" color="1 1 1" intensity="1" />
    <xr-light type="directional" rotation="0 180 0" color="1 1 1" intensity="3" cast-shadow/>
  </xr-node>
</xr-scene>
```

### 逻辑层

```javascript
const initcubeTouch = {
  touch: false,
  drag: false,
  untouch: false,
};
Component({
  // this对象上的属性
  scene: null,
  // Component构造方法内置属性
  data: {
    cubeTouch: { ...initcubeTouch },
  },
  lifetimes: {},
  methods: {
    // 事件
    handleReady: function ({ detail }) {
      this.scene = detail.value;
    },
    handleAssetsProgress: function ({ detail }) {
      const {
        value: { progress },
      } = detail;
      wx.showLoading({
        title: `资源加载中 ${progress * 100}%`,
      });
    },
    handleAssetsLoaded: function () {
      wx.hideLoading();
    },
    handleReady: function ({ detail }) {
      this.scene = detail.value;
    },
    // Cube 触摸控制
    handleTouchCube: async function () {
      this.setData({
        cubeTouch: { ...initcubeTouch, touch: true },
      });
      setTimeout(() => {
        const { touch, untouch, drag } = this.data.cubeTouch;
        if(touch && untouch && !drag) this.videoController()
        this.setData({
          cubeTouch: { ...initcubeTouch }
        })
      }, 300);
    },
    handleUnTouchCube: async function () {
      this.setData({
        cubeTouch: { ...this.data.cubeTouch, untouch: true },
      });
    },
    handleDragCube: async function () {
      this.setData({
        cubeTouch: { ...this.data.cubeTouch, drag: true },
      });
    },
    // 方法
    videoController() {
      const xrSystem = wx.getXrFrameSystem();
      const video = this.scene.assets.getAsset("video-texture", "cat");

      if (!video) {
        return;
      }
      if (video.state === xrSystem.EVideoState.Playing) {
        video.pause();
      } else if (video.state === xrSystem.EVideoState.Paused) {
        video.resume();
      }
    },
    // 场景分享函数
    handleShare() {
      this.scene.share.captureToFriends();
    },
  },
});
```

### 轮廓相关

参考文档：

> https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/physics/shape.html#%E8%BD%AE%E5%BB%93%E7%A7%8D%E7%B1%BB

如果想要与场景中的物体进行互动，比如说点击、拖拽物体，那么这个物体得先拥有一个*轮廓*才行。

轮廓包括：创建轮廓、轮廓种类、轮廓交互、轮廓可视化这几块

**注意：轮廓交互那里的点击事件和拖拽事件会有点冲突，建议做下单独的处理，可以参考上面的代码**

## Animation：简易动画

1. 首先创建需要构建动画的Mesh

```xml
<xr-mesh node-id="mesh-plane" 
      position="0 -0.02 -4" rotation="0 0 0" 
      scale="5 1 5" geometry="plane" 
      material="standard-mat" 
      uniforms="u_baseColorFactor:0.48 0.78 0.64 1" receive-shadow
/>
```

2. 构建动画描述文件json

   miniprogram\assets\animation\basic-animation.json

```json
{
  "keyframe": {
  	"plane": {
      "0": {
        "material.u_baseColorFactor": [0.48, 0.78, 0.64, 1]
      },
      "50": {
        "material.u_baseColorFactor": [0.368, 0.937, 0.176, 1]
      },
      "100": {
        "material.u_baseColorFactor": [0.176, 0.368, 0.937, 1]
      }
    }
  },
  "animation": {
  	"plane": {
      "keyframe": "plane",
      "duration": 4,
      "ease": "linear",
      "loop": 400000,
      "delay": 1,
      "direction": "both"
    }
  }
}
```

3. 加载动画文件，挂载对应的动画到Mesh上

```json
<xr-mesh node-id="mesh-plane" 
      position="0 -0.02 -4" rotation="0 0 0" 
      scale="5 1 5" geometry="plane" 
      material="standard-mat" 
      uniforms="u_baseColorFactor:0.48 0.78 0.64 1" receive-shadow
      anim-keyframe="basic-anim" anim-autoplay="clip:plane, speed:2"
/>
```

### Animation参数配置

> https://developers.weixin.qq.com/miniprogram/dev/api/xr-frame/interfaces/IAnimationPlayOptions.html#Properties

**delay**

• `Optional` **delay**: `number`

播放延迟，默认为`0`。

------

**direction**

• `Optional` **direction**: `"forwards"` | `"backwards"` | `"both"`

播放方向，默认为`forwards`。

------

**loop**

• `Optional` **loop**: `number`

循环次数，默认为`0`。

------

**speed**

• `Optional` **speed**: `number`

播放速度，默认为`1`。

### Animation完整案例

#### 视图层

```xml
<xr-scene id="xr-scene" bind:ready="handleReady">
  <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded" >
    <xr-asset-load type="texture" asset-id="image-wife" src="/assets/image/wife.png" />
    <xr-asset-load asset-id="basic-anim" type="keyframe" src="/assets/animation/basic-animation.json"/>
    <xr-asset-material
      asset-id="wife-mat" 
      effect="standard" 
      uniforms="u_baseColorMap: image-wife" 
      states="alphaMode: BLEND"
      renderQueue="2500" 
    />
    <xr-asset-material asset-id="standard-mat" effect="standard" />
  </xr-assets>
  <xr-node>
    <xr-node node-id="camera-target" position="0 2.5 1.2"></xr-node>
    <xr-mesh node-id="wife-plane" geometry="cube" position="0 5 -10" scale="10 10 0.5" material="wife-mat"/>
    <xr-mesh node-id="mesh-plane" 
      position="0 -0.02 -4" rotation="0 0 0" 
      scale="5 1 5" geometry="plane" 
      material="standard-mat" 
      uniforms="u_baseColorFactor:0.48 0.78 0.64 1" receive-shadow
      anim-keyframe="basic-anim" anim-autoplay="clip:plane, speed:2"
    />
    <xr-mesh 
      id="cube" node-id="mesh-cube" 
      position="-1 0.5 -3.5" scale="1 1 1" rotation="0 45 0" 
      geometry="cube" material="standard-mat" 
      uniforms="u_baseColorFactor:0.298 0.764 0.85 1" cast-shadow
      anim-keyframe="basic-anim" anim-autoplay="clip:cube, speed:2"
    />
    <xr-mesh 
      node-id="mesh-cylinder" position="1 0.7 -3.5" scale="1 0.7 1" 
      geometry="cylinder" material="standard-mat" 
      uniforms="u_baseColorFactor:1 0.776 0.364 1" cast-shadow
      anim-keyframe="basic-anim" anim-autoplay="clip:cylinder, speed:2"
    />
    <xr-mesh 
      node-id="mesh-sphere" position="0 2 -5" 
      scale="1.25 1.25 1.25" geometry="sphere" 
      material="standard-mat" 
      uniforms="u_baseColorFactor:0.937 0.176 0.368 1" cast-shadow
      anim-keyframe="basic-anim" anim-autoplay="clip:sphere, speed:2"
    />
    <xr-camera
      id="camera" node-id="camera" position="0 2 4" clear-color="0.925 0.925 0.925 1" 
      target="camera-target"
      camera-orbit-control=""
    />
  </xr-node>
  <xr-node node-id="lights">
    <xr-light type="ambient" color="1 1 1" intensity="1" />
    <xr-light type="directional" rotation="0 180 0" color="1 1 1" intensity="3" cast-shadow/>
  </xr-node>
</xr-scene>
```

#### 动画JSON

```json
{
  "keyframe": {
    "cube": {
      "0": {
        "position": [-3, 0, -4],
        "scale": [0.8, 0.8, 0.8]
      },
      "50": {
        "position": [0, 0.2, -4],
        "scale": [1, 1, 1]
      },
      "100": {
        "position": [3, 0, -4],
        "scale": [0.8, 0.8, 0.8]
      }
    },
    "sphere": {
      "0": {
        "position": [-3, 0, 0],
        "scale": [0.8, 0.8, 0.8]
      },
      "50": {
        "position": [0, 0.2, 0],
        "scale": [1, 1, 1]
      },
      "100": {
        "position": [3, 0, 0],
        "scale": [0.8, 0.8, 0.8]
      }
    },
    "cylinder": {
      "0": {
        "position": [-3, 0, -2],
        "rotation": [0, 0, 0]
      },
      "50": {
        "rotation": [0, 0, -3.14]
      },
      "100": {
        "position": [3, 0, -2],
        "rotation": [0, 0, 3.14]
      }
    },
    "plane": {
      "0": {
        "material.u_baseColorFactor": [0.48, 0.78, 0.64, 1]
      },
      "50": {
        "material.u_baseColorFactor": [0.368, 0.937, 0.176, 1]
      },
      "100": {
        "material.u_baseColorFactor": [0.176, 0.368, 0.937, 1]
      }
    },
    "spotLight": {
      "0": {
        "position": [-4, 1, -4]
      },
      "25": {
        "position": [-4.3, 0.5, -2]
      },
      "75": {
        "position": [-3, 1.5, 2]
      },
      "100": {
        "position": [-4, 1, 4]
      }
    }
  },
  "animation": {
    "cube": {
      "keyframe": "cube",
      "duration": 1,
      "ease": "ease-out",
      "loop": 400000,
      "delay": 1,
      "direction": "both"
    },
    "sphere": {
      "keyframe": "sphere",
      "duration": 1,
      "ease": "ease-out",
      "loop": 400000,
      "delay": 1,
      "direction": "both"
    },
    "cylinder": {
      "keyframe": "cylinder",
      "duration": 1,
      "ease": "ease-in",
      "loop": 400000,
      "delay": 1,
      "direction": "both"
    },
    "plane": {
      "keyframe": "plane",
      "duration": 4,
      "ease": "linear",
      "loop": 400000,
      "delay": 1,
      "direction": "both"
    },
    "spotLight": {
      "keyframe": "spotLight",
      "duration": 2,
      "ease": "ease-in-out",
      "loop": 400000,
      "delay": 1,
      "direction": "both"
    }
  }
}
```

## Touch：交互相关

一个简单的地球旋转交互

### 视图层

```xml
<xr-scene id="xr-scene" bind:ready="handleReady">
  <xr-assets bind:progress="handleAssetsProgress" bind:loaded="handleAssetsLoaded">
    <xr-asset-load type="texture" asset-id="earth-texture" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/2k_earth_daymap.jpeg" />
    <xr-asset-load type="texture" asset-id="moon-texture" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/2k_moon.jpeg" />
    <xr-asset-load type="texture" asset-id="sky" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/dark-cosmos.jpg" />
    <xr-asset-material asset-id="standard-mat" effect="standard" />
    <xr-asset-material asset-id="earth-mat" effect="standard" uniforms="u_baseColorMap: earth-texture" render-queue="501"/>
    <xr-asset-material asset-id="moon-mat" effect="standard" uniforms="u_baseColorMap: moon-texture" render-queue="503"/>
    <xr-asset-material asset-id="moon-silhouette" effect="simple" uniforms="u_baseColorFactor: 0.476 0.82 0.957 1.0" states="depthTestWrite: false" render-queue="502"/>
  </xr-assets>
  <xr-env sky-map="sky" is-sky2d/>
  <xr-node>
    <xr-mesh 
      node-id="mesh-earth" 
      position="0 0 0" scale="8 8 8" 
      geometry="sphere" material="earth-mat" 
      bind:drag-shape="handleEarthRotation" 
      sphere-shape 
      receive-shadow 
      cast-shadow
    />
    <xr-camera
      id="camera" node-id="camera" position="0 20 -35" clear-color="0 0 0 1"
      target="mesh-earth"
      background="skybox"
    />
  </xr-node>
  <xr-node node-id="lights">
    <xr-light type="ambient" color="1 1 1" intensity="0.1" />
    <xr-light 
      id="directional-light" 
      type="directional" 
      rotation="0 60 0" 
      color="1 1 1" intensity="5" 
      shadow-distance="40" 
      cast-shadow shadow-bias="0.004"
    />
  </xr-node>
</xr-scene>
```

### 逻辑层

```javascript
Component({
  // this对象上的属性
  scene: null,
  // Component构造方法内置属性
  data: {},
  lifetimes: {},
  methods: {
    // 事件
    handleReady: function ({ detail }) {
      this.scene = detail.value;
    },
    handleAssetsProgress: function ({ detail }) {
      const {
        value: { progress },
      } = detail;
      wx.showLoading({
        title: `资源加载中${progress * 100}%`,
      });
    },
    handleAssetsLoaded: function () {
      wx.hideLoading();
    },
    handleEarthRotation: function({detail}) {
      const { target, deltaX, deltaY } = detail.value;
      // X轴旋转
      target._components.transform.rotation.y += deltaX / 300;
      // Y轴旋转
      target._components.transform.rotation.x -= deltaY / 300;
    },
    // 方法
    // 场景分享函数
    handleShare() {
      this.scene.share.captureToFriends();
    },
  },
});
```

## Node：可见性与图层

两种方式可以控制可见性：

### 第一种：visible属性

1. 声明组件Props

```xml
<xr-node-visible
    disable-scroll
    id="xr-frame"
    width="{{xrFrame.renderWidth}}"
    height="{{xrFrame.renderHeight}}"
    style="width:{{xrFrame.width}}px;height:{{xrFrame.height}}px;display:block;"
    cubeVisible="{{false}}"
/>
```

```javascript
properties: {
    cubeVisible: {
      type: Boolean,
      value: true,
      observer: function (newVal, oldVal) {}
    },
},
```

2. 在组件内引入Props

```xml
<xr-mesh visible="{{cubeVisible}}" id="cube" ..... />
```

### 第二种：cullMask

cullMask是挂在camera上一个属性，可以用来过滤节点，具体的过滤规则参考官网文档

> https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/core/node.html#%E5%8F%AF%E8%A7%81%E6%80%A7%E4%B8%8E%E5%9B%BE%E5%B1%82

## Shadow DOM：多模型删减 

可以用代码来动态的加载资源、模型等。

### 大致流程

1. 新建Shadow DOM节点
2. 获取Shadow DOM节点
3. 处理场景中的环境
4. 创建资源 >>> 创建元素 >>> 添加元素到根节点 >>> 获取元素中的组件 >>> 在组件中挂在资源

### 代码实现

#### Page 视图层

```xml
<view class="page">
    <xr-shadow
        disable-scroll
        id="xr-frame"
        width="{{xrFrame.renderWidth}}"
        height="{{xrFrame.renderHeight}}"
        style="width:{{xrFrame.width}}px;height:{{xrFrame.height}}px;display:block;"
        meshCount="{{xrData.meshCount}}"
    />
    <view class="button-group">
        <view class="button" bind:tap="share">分享画面</view>
        <view class="button" bind:tap="changeCount" data-action="add">增加模型</view>
        <view class="button" bind:tap="changeCount" data-action="remove">减少模型</view>
    </view>
</view>
```

#### Page 逻辑层

```javascript
// pages/ar-tracker-2d/index.ts
Page({
  // 自定义对象
  xrFrameInstance: null,
  // Page自带对象
  data: {
    xrFrame: {
      width: 300,
      height: 300,
      renderWidth: 300,
      renderHeight: 300,
    },
    xrData: {
      meshCount: 0,
    }
  },
  onReady() {
    this.xrFrameInstance = this.selectComponent("#xr-frame")
  },
  onLoad() {
    const { windowWidth, windowHeight, pixelRatio } = wx.getSystemInfoSync();
    const xrFrame = {
      width: windowWidth,
      height: windowHeight,
      renderWidth: windowWidth * pixelRatio,
      renderHeight: windowHeight * pixelRatio,
    }
    this.setData({ xrFrame });
  },
  share() {
    this.xrFrameInstance.handleShare();
  },
  changeCount(e) {
    const { action } = e.currentTarget.dataset;
    let { xrData } = this.data;
    let { meshCount } = xrData;
    switch(action) {
      case "add": meshCount += 1; break;
      case "remove": meshCount -= 1; break;
    }
    xrData = { ...xrData, meshCount };
    this.setData({ xrData });
  }
})
```

#### Component 视图层

```xml
<xr-scene id="xr-scene" bind:ready="handleReady">
  <xr-shadow id="shadow-root"></xr-shadow>
</xr-scene>
```

#### Component 逻辑层

```javascript
Component({
  // this对象上的属性
  scene: null,
  // Component构造方法内置属性
  properties: {
    meshCount: {
      type: Number,
      value: 0,
      observer: function (newVal, oldVal) {
        newVal > oldVal ? this.addOne() : this.removeOne();
      }
    },
  },
  data: {},
  lifetimes: {},
  methods: {
    // 事件
    async handleReady({ detail }) {
      wx.showLoading({ title: `场景加载中`});
      await this.initialScene(detail.value);
      wx.hideLoading();
    },
    // 函数
    async initialScene(scene) {
      // XR场景加载完成，保存scene到this实例对象上
      this.scene = scene;
      // 存放添加进场景里的模型，在移除模型时可以快速检索
      this.meshList = [];
      // 一、获取XR框架实例
      const xrFrameSystem = wx.getXrFrameSystem()
      // 二、获取Shadow DOM的根节点 
      this.shadowRoot = scene.getElementById('shadow-root');
      // 三、处理场景中的环境：创建资源 >>> 创建元素 >>> 添加元素到根节点 >>> 获取元素中的组件 >>> 在组件中挂在资源
      // 1、为scene加载env资源
      const {value: envData} = await scene.assets.loadAsset({type: 'env-data', assetId: 'env1', src: 'https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/env-test.bin'});
      // 2、创建环境元素
      const envElement = scene.createElement(xrFrameSystem.XREnv);
      // 3、在根节点中添加环境元素
      this.shadowRoot.addChild(envElement);
      // 4、获取环境元素中的组件
      const envComp = envElement.getComponent(xrFrameSystem.Env);
      // 5、把环境资源添加到环境元素中的组件
      envComp.setData({envData: envData});
      // 四、处理gltf模型，思路同处理场景中的环境
      const {value: model} = await scene.assets.loadAsset({type: 'gltf', assetId: 'damage-helmet', src: 'https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/damage-helmet/index.glb'});
      // 把模型保存，用于反复添加使用
      this.gltfModle = model;
      const gltfElement = scene.createElement(xrFrameSystem.XRGLTF);
      this.shadowRoot.addChild(gltfElement);
      const gltfComp = gltfElement.getComponent(xrFrameSystem.GLTF);
      gltfComp.setData({model: model});
      // 五、处理环境中的相机，思路同上
      const cameraElement = scene.createElement(xrFrameSystem.XRCamera);
      this.shadowRoot.addChild(cameraElement);
      cameraElement.getComponent(xrFrameSystem.Transform).position.setValue(0, 0, 9);
      cameraElement.getComponent(xrFrameSystem.Camera).setData({
        target: gltfElement.getComponent(xrFrameSystem.Transform),
        background: 'skybox'
      });
      cameraElement.addComponent(xrFrameSystem.CameraOrbitControl, {});
    },
    addOne() {
      // 一、先让场景里加模型
      const xrFrameSystem = wx.getXrFrameSystem()
      const pos = [Math.random(), Math.random(), Math.random()].map(v => (v * 2 - 1) * 6);
      const gltfElement = this.scene.createElement(xrFrameSystem.XRGLTF);
      this.shadowRoot.addChild(gltfElement);
      gltfElement.getComponent(xrFrameSystem.Transform).position.setArray(pos);
      gltfElement.getComponent(xrFrameSystem.GLTF).setData({model: this.gltfModle});
      // 二、把添加好的模型记录到数组里
      this.meshList.push(gltfElement);
    },
    removeOne() {
      // 从数组里取出最顶上那个刚加进去的模型
      const element = this.meshList.pop();
      if (element) {
        // 从场景里（shadowRoot）移除这个模型
        this.shadowRoot.removeChild(element);
      }
    },
    // 场景分享函数
    handleShare() {
      this.scene.share.captureToFriends();
    },
  },
});
```

## Particles：旋转云粒子效果

> https://developers.weixin.qq.com/miniprogram/dev/component/xr-frame/particles/

粒子系统就像是与把一个带有贴图的模型（节点）复制了很多份，每份模型都有独立的动画效果。

### 简易案例

#### 视图层

```xml
<xr-scene id="xr-scene" bind:ready="handleReady"   bind:assetsLoaded="handleLoaded">
  <xr-assets>
    <xr-asset-load type="texture" asset-id="sky" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/dark-cosmos.jpg" />   
    <xr-asset-load type="texture" asset-id="circleCurve" src="https://mmbizwxaminiprogram-1258344707.cos.ap-guangzhou.myqcloud.com/xr-frame/demo/particles/circlecurve.png" />
  </xr-assets>
  <xr-node>
    <xr-mesh node-id="mesh-plane" position="0 -1 0" rotation="0 0 0" scale="5 0.2 5"
      geometry="cube" material="blue-mat" uniforms="u_baseColorFactor:0.48 0.78 0.64 1"
    ></xr-mesh>
    <xr-env sky-map="sky" is-sky2d/>
    <xr-particle 
      id="magicField" 
      position="0 0 0" rotation="90 0 0"
      texture="circleCurve"
      capacity="1000" size="2" angle="0 360" speed="0.1" render-mode="off"
      angular-speed="180" life-time="0.5" emit-rate="6"
    />
    <xr-camera
      id="camera" node-id="camera" position="0 6 -12" clear-color="0.1 0.1 0.1 1"
      target="mesh-plane" background="skybox"
      camera-orbit-control=""
    />
  </xr-node>
  <xr-node node-id="lights">
    <xr-light type="ambient" color="1 1 1" intensity="0.3" />
    <xr-light type="directional" rotation="90 0 0" color="1 1 1" intensity="2.5"  />
  </xr-node>
</xr-scene>
```

### xr-particle 标签属性

1. texture：描绘粒子形态的基本纹理，直接用asset的图片
2. capacity：容许同时存在的最多粒子数量，默认1，**建议改大点，200以上**
3. size：number[]，粒子的大小,"最小值 最大值(可选)"，**建议设置大点**
4. angle：粒子的起始角度,"最小值 最大值(可选)"，**设置之后粒子可以旋转**
5. speed：粒子运动速度，**默认速度挺快的，可以考虑改小点**
6. render-mode：渲染模式，**写off**
7. angular-speed：每秒钟粒子旋转的角度(单位:角度)，**这个可以让粒子运动更加平滑自然**
8. life-time：粒子的生命周期时长区间,"最小值 最大值(可选)"，**可选**
9. emit-rate：每秒钟允许生成的最多粒子数量，**可选**

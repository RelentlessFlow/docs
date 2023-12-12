# 三、Image组件

> Image可以优化图片的性能，是img元素的拓展
>
> 具体特性看这篇文章：https://www.nextjs.cn/docs/basic-features/image-optimization

## 一、使用本地图片

要使用本地图像，请`import`您的`.jpg`、`.png`或`.webp`文件：

```jsx
import profilePic from '../public/me.png'
```

不支持动态`await import()`或 `require()`。`import`必须是静态的，以便在构建时进行分析。

静态图片不需要指定图片的width和height

```tsx
import Image from 'next/image'
import profilePic from '../public/me.png'

function Home() {
  return (
    <>
      <h1>My Homepage</h1>
      <Image
        src={profilePic}
        alt="Picture of the author"
        // width={500} automatically provided
        // height={500} automatically provided
        // blurDataURL="data:..." automatically provided
        // placeholder="blur" // Optional blur-up while loading
      />
      <p>Welcome to my homepage!</p>
    </>
  )
}
```

## 二、使用远程图片

要使用远程图像，`src`属性应该是一个URL字符串，可以是[相对](https://www.nextjs.cn/docs/basic-features/image-optimization#loaders)的，也可以是[绝对的](https://www.nextjs.cn/docs/basic-features/image-optimization#domains)。由于Next.js在构建过程中无法访问远程文件，因此您需要手动提供[`width`](https://www.nextjs.cn/docs/api-reference/next/image#width)、[`height`](https://www.nextjs.cn/docs/api-reference/next/image#height)和可选的[`blurDataURL`](https://www.nextjs.cn/docs/api-reference/next/image#blurdataurl)道具：

```tsx
import Image from 'next/image'

export default function Home() {
  return (
    <>
      <h1>My Homepage</h1>
      <Image
        src="/me.png"
        alt="Picture of the author"
        width={500}
        height={500}
      />
      <p>Welcome to my homepage!</p>
    </>
  )
}
```

### 1、配置远程域名

有时您可能想要访问远程图像，但仍然使用内置的Next.js图像优化API。为此，请将`loader`保持其默认设置，并为Image `src`输入绝对URL。

为了保护您的应用程序免受恶意用户的侵害，您必须定义您打算以这种方式访问的远程域列表。这是在您的`next.config.js`文件中配置的，如下所示：

```js
module.exports = {
  images: {
    domains: ['example.com', 'example2.com'],
  },
}
```

### 2、使用OSS对象云存储优化图像

>https://www.nextjs.cn/docs/api-reference/next/image#built-in-loaders
>
>（看了下官网都是仅支持国外的云提供商）

在`next.config.js`文件中配置`loader``path`前缀

```js
module.exports = {
  images: {
    loader: 'imgix',
    path: 'https://example.com/myaccount/',
  },
}
```

### 3、图片大小

一般来说 图片大小的配置有三种

1. 自动，使用[静态导入](https://www.nextjs.cn/docs/basic-features/image-optimization#local-images)
2. 明确地，通过包括`height`**和**`width`属性
3. 隐式地，通过使用`layout="fill"`，使图像展开以填充其父元素。

当不知道图片大小的时候：

>**使用`layout='fill'`**
>
>`fill`布局模式允许您的图像按其父元素调整大小。考虑使用CSS在页面上提供图像的父元素空间，然后使用带有`fill`、`contain`或`cover`的[`objectFit property`](https://www.nextjs.cn/docs/api-reference/next/image#objectfit)以及[`objectPosition property`](https://www.nextjs.cn/docs/api-reference/next/image#objectposition)来定义图像应如何占用该空间。

### 4、定义Image图片组件的CSS

文档：https://www.nextjs.cn/docs/api-reference/next/image#device-sizes

例子：https://image-component.nextjs.gallery

## 三、LCP图像

LCP大致可以理解为页面最大渲染的内容（Banner、背景图片等），具体关于LCP的介绍参考下面两种文章：

https://blog.csdn.net/pzy_666/article/details/123019010

https://www.wbolt.com/largest-contentful-paint.html

为Image组件添加priority，该图片即被标记为LCP元素，Next.js将特别优先加载图像

```tsx
import Image from 'next/image'

export default function Home() {
  return (
    <>
      <h1>My Homepage</h1>
      <Image
        src="/me.png"
        alt="Picture of the author"
        width={500}
        height={500}
        priority
      />
      <p>Welcome to my homepage!</p>
    </>
  )
}
```


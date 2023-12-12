# 二、CSS

## 几种引入样式的办法

### 一、全局样式

对于全局样式表（例如 `bootstrap` 或 `nprogress`），你应该在 `pages/_app.js` 文件中对齐进行导入（import）。 例如：

```tsx
// pages/_app.js
import 'bootstrap/dist/css/bootstrap.css'

export default function MyApp({ Component, pageProps }) {
  return <Component {...pageProps} />
}
```

对于导入第三方组件所需的 CSS，可以在组件中进行。例如：

### 二、组件级样式（CSS ）

Next.js 通过 `[name].module.css` 文件命名约定来支持 [CSS 模块](https://github.com/css-modules/css-modules) 。

此行为使 CSS 模块成为包含组件级 CSS 的理想方法。 CSS 模块文件 **可以导入（import）到应用程序中的任何位置**。

components/Button.module.css

```
.error {
  color: white;
  background-color: red;
}
```

然后，创建 `components/Button.js` 文件，导入（import）并使用上述 CSS 文件：

```tsx
import styles from './Button.module.css'

export function Button() {
  return (
    <button
      type="button"
      // Note how the "error" class is accessed as a property on the imported
      // `styles` object.
      className={styles.error}
    >
      Destroy
    </button>
  )
}
```

在生产环境中，所有 CSS 模块文件将被自动合并为 **多个经过精简和代码分割的** `.css` 文件。 这些 `.css` 文件代表应用程序中的热执行路径（hot execution paths），从而确保为应用程序绘制页面加载所需的最少的 CSS。

### 三、Sass支持

#### 安装

```bash
npm install sass
```

#### Sass参数

如果要配置 Sass 编译器，可以使用 `next.config.js` 文件中的 `sassOptions` 参数进行配置。

例如，添加 `includePaths`：

```
const path = require('path')

module.exports = {
  sassOptions: {
    includePaths: [path.join(__dirname, 'styles')],
  },
}
```

#### Sass变量

定义Sass变量

```
/* variables.module.scss */
$primary-color: #64FF00

:export {
  primaryColor: $primary-color
}
```

引入Sass变量

```
// pages/_app.js
import variables from '../styles/variables.module.scss'

export default function MyApp({ Component, pageProps }) {
  return (
    <Layout color={variables.primaryColor}>
      <Component {...pageProps} />
    </Layout>
  )
}
```

### 四、CSS-in-JS方案

1. 内联

```
function HiThere() {
  return <p style={{ color: 'red' }}>hi there</p>
}

export default HiThere
```

2. ~~styled-jsx（不支持SSR和TS）~~

我们引入了 [styled-jsx](https://github.com/vercel/styled-jsx) 以支持作用域隔离（isolated scoped）的 CSS。 此目的是支持类似于 Web 组件的 “影子（shadow）CSS”，但不幸的是 [不支持服务器端渲染且仅支持 JS](https://github.com/w3c/webcomponents/issues/71)。

```jsx
function HelloWorld() {
  return (
    <div>
      Hello world
      <p>scoped!</p>
      <style jsx>{`
        p {
          color: blue;
        }
        div {
          background: red;
        }
        @media (max-width: 600px) {
          div {
            background: blue;
          }
        }
      `}</style>
      <style global jsx>{`
        body {
          background: black;
        }
      `}</style>
    </div>
  )
}

export default HelloWorld
```

**还是用Tailwind CSS或者Sass吧 😄**

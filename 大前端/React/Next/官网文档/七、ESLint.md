# 六、ESLint

自**11.0.0**版本起，Next.js开箱即用提供集成的[ESLint](https://eslint.org/)体验。将`next lint`作为脚本添加到`package.json`：

```json
"scripts": {
  "lint": "next lint"
}
```

如果您尚未在应用程序中配置ESLint，您将在安装和配置过程中得到指导。

```bash
yarn lint

# You'll see a prompt like this:
#
# ? How would you like to configure ESLint?
#
# ❯   Base configuration + Core Web Vitals rule-set (recommended)
#     Base configuration
#     None
```

ESlint包含三种选项

- **严格**：包括Next.js的基本ESLint配置以及更严格的[Core Web Vitals规则集](https://www.nextjs.cn/docs/basic-features/eslint#core-web-vitals)。这是开发人员首次设置ESLint的推荐配置。`{ "extends": "next/core-web-vitals" }`

- **基础**：包括Next.js的基础ESLint配置。`{"extends": "next"}`

- 取消

## ESlint配置

详细配置：https://www.nextjs.cn/docs/basic-features/eslint#caching

eslint-config-next内置了三种配置规则集

- [`eslint-plugin-react`](https://www.npmjs.com/package/eslint-plugin-react)
- [`eslint-plugin-react-hooks`](https://www.npmjs.com/package/eslint-plugin-react-hooks)
- [`eslint-plugin-next`](https://www.npmjs.com/package/@next/eslint-plugin-next)

### 自定义配置或monorepo项目配置

```json
{
  "extends": "next",
  "settings": {
    "next": {
      "rootDir": "/packages/my-app/"
    }
  }
}
```

### 禁用规则

如果您想修改或禁用受支持的插件提供的任何规则（`react`，`react-hooks`，`next`），您可以使用`.eslintrc`中的`rules`属性直接更改它们：

```
{
  "extends": "next",
  "rules": {
    "react/no-unescaped-entities": "off",
    "@next/next/no-page-custom-font": "off"
  }
}
```

## 配合prettier

ESLint还包含代码格式化规则，这些规则可能会与您现有的[Prettier](https://prettier.io/)设置冲突。我们建议在您的ESLint配置中包含[eslint-config-prettier](https://github.com/prettier/eslint-config-prettier)，以使ESLint和Prettier一起工作。

首先，安装依赖项：

```bash
npm install --save-dev eslint-config-prettier
# or
yarn add --dev eslint-config-prettier
```

然后，将`prettier`添加到您现有的ESLint配置中：

```json
{
  "extends": ["next", "prettier"]
}
```

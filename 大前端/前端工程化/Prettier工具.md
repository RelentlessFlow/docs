# 一、Prettier的使用

> 参考资料：https://prettier.io

## Install

首先安装下依赖

npm:`npm install --save-dev --save-exact prettier`

yarn:`yarn add --dev --exact prettier`

然后，创建一个空白的控制文件让编辑器和其他的工具知道你在使用Prettier

```shell
echo {}> .prettierrc.json
```

然后，创建一个[.prettierignore](https://prettier.io/docs/en/ignore.html) 文件让Prettier CLI和编辑器能够知道那些文件是不进行格式化的

例子：

```properties
# Ignore artifacts:
build
coverage
```

现在。使用Prettier格式化全部的文件

```shell
npx prettier --write .
```

## 提交预处理钩子（Pre-commit Hook）

You can use Prettier with a pre-commit tool. This can re-format your files that are marked as “staged” via `git add` before you commit.（在git commit之前给你自动格式化好）

**Step1  [lint-staged](https://github.com/okonet/lint-staged)**

```shell
npx mrm@2 lint-staged
```

**Step2 检查一下package.json**

```json
"devDependencies": {
    "husky": "^7.0.4",
    "lint-staged": "^12.2.2",
    "prettier": "2.5.1"
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.{js,css,md, ts, tsx}": "prettier --write"
  }
```

## 为TypeScript提供支持

配置package.json

添加ts和tsx支持

```json
"lint-staged": {
    "*.{js,css,md, ts, tsx}": "prettier --write"
  }
```

## ESLint (and other linters)

If you use ESLint, install [eslint-config-prettier](https://github.com/prettier/eslint-config-prettier#installation) to make ESLint and Prettier play nice with each other. It turns off all ESLint rules that are unnecessary or might conflict with Prettier. There’s a similar config for Stylelint: [stylelint-config-prettier](https://github.com/prettier/stylelint-config-prettier)

(See [Prettier vs. Linters](https://prettier.io/docs/en/comparison.html) to learn more about formatting vs linting, [Integrating with Linters](https://prettier.io/docs/en/integrating-with-linters.html) for more in-depth information on configuring your linters, and [Related projects](https://prettier.io/docs/en/related-projects.html) for even more integration possibilities, if needed.)

ESLint和Prettier在某些工具上可能有冲突，请进行以下操作

1. 安装 eslint-config-prettier

```shell
npm install eslint-config-prettier
```

2. 配置package.json

```json
"eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest",
      "prettier" //  "prettier"
    ]
  },
```


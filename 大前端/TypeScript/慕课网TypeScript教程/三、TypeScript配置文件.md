# 三、TypeScript配置文件

[toc]

配置文件参考：https://www.tslang.cn/docs/handbook/tsconfig-json.html

1. 编译文件包含项配置

```json
"files": ["./demo.ts"],
"include": ["./demo.ts", "./demo2.ts"],
"exclude": ["./demo2.ts"],
```

2. 其他常用配置

```
"outDir": "./build",
"rootDir": "./src",
"allowJs": true,
"checkJs": true,
"sourceMap": true,
"noUnusedLocals": true,
"noUnusedParameters": true,
```




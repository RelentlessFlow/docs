# ASP.NET Core环境 Taghelper

使用“ASPNETCORE_ENVIRONMENT”变量设置应用程序环境名称

```html
    <environment include="Development">
        <link href="~/lib/twitter-bootstrap/css/bootstrap.css" rel="stylesheet" />
    </environment>

    <environment exclude="Development">
        <link rel="stylesheet"                href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css"
              integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh"
              crossorigin="anonymous"
              asp-fallback-href="~/lib/twitter-bootstrap/css/bootstrap.css"
              asp-fallback-test-class="sr-only"
              asp-fallback-test-property="position"
              asp-fallback-test-value="absolute">
    </environment>
```

`integrity`用于对CDN资源进行一个完整性检查，

`asp-fallback-href`用于当目标资源加载失败时，启动备用的资源。

`asp-fallback-test-class`用于检查是否为只读状态

`asp-fallback-test-value`设置为True可以绕过文件完整性检查，一般不用设置。
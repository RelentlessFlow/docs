# Razor视图用法

### 布局页

#### 使用方法：

1. 创建布局页面

2. 子页面中使用`Layout = "~/Views/Shared/_Layout.cshtml";`引用布局

3. 可以直接在ViewStart中制定_Layout，就无需在子页面中引用布局页面了。

   MvcMovie/Views/_ViewStart.cshtml

   ```c#
   @{
       Layout = "~/Views/Shared/_Layout.cshtml";
   }
   ```

#### 布局页面标签

##### @Styles.Render("~/Content/css") 

​	在页面上可以用@Styles.Render("~/Content/css") 来加载css

​	首先要在App_Start 里面BundleConfig.cs 文件里面 添加要包含的css文件

```c#
public static void RegisterBundles(BundleCollection bundles)
        {
  					// 打包器，用于将实际路径引用为虚拟路径
  					
  					// {version}可用于匹配版本
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                "~/Scripts/jquery-{version}.js"));
  					// *用于匹配所有以jquery.validate的文件
            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                "~/Scripts/jquery.validate*"));
            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at https://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                "~/Scripts/modernizr-*"));
            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                "~/Scripts/bootstrap.js"));
            bundles.Add(new StyleBundle("~/Content/css").Include(
                "~/Content/bootstrap.css",
                "~/Content/site.css"));
        }
```

在Web.config中对`<compilation debug="true" targetFramework="4.7.2"/>`属性进行修改，可以切换发布模式和生产模式。

##### @Scripts.Render("~/bundles/modernizr")

​	效果同上

##### @Html.ActionLink

​	简化了超链接的使用。四种使用方式

1. @Html.ActionLink("linkText", "actionName")

   `@Html.ActionLink("detial", "Detial")`  >>> `<a href="/Products/Detail">detail</a>`

2.  @Html.ActionLink("linkText", "actionName","controllerName") 

   `@Html.ActionLink("detail", "Detail", "Products")` >>> `<a href="Products/Detail">detail</a>`

3. @Html.ActionLink("linkText", "actionName","controllerName",routeValues) 

   `@Html.ActionLink("detail", "Detail", ，"Products"，new{ id = 1 })` >>> 

   `<a href="Products/Detail/1">detail</a>`

4. @Html.ActionLink("linkText", "actionName", "controllerName", routeValues, htmlAttributes)

​        `@Html.ActionLink("detail", "Detail", "Products"，new{ id = 1 }, new{ target = "_blank" })` >>>

​		`<a href="Products/Detail/1" target="_blank">detail</a>`

​		如果写成new{ target="_blank", class="className" }则会报错，因为Class是C#的关键字，此时应该写成@class="className"。

 ##### @RenderBody()标签

这个标签就是一个占位符，当一个视图使用了布局页的时候，该视图就会被加载到占位符的位置

母版页定义了这个标签，子页的内容作为占用。

##### @RenderSection("scripts", required: false)

布局页面还有节（Section）的概念，也就是说，如果某个视图模板中定义了一个节，那么可以把它单独呈现出来

第一步，在模板视图中定义节点

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@ViewBag.Title - Movie App</title>
    @Styles.Render("~/Content/css")
    @Scripts.Render("~/bundles/modernizr")
  	// 定义及诶单
    @RenderSection("green")
</head>
```

第二步，在子页中实现

```html
<p>Hello from our View Template!</p>

@section green {
    green这个节
}

<h2>title</h2>
```

注意：这种方式要求所有子页必须实现母版页的节点。

可以使用它的另外一个重载@RenderSection("hahah",false),第二个参数代表它不是必须的，就不会抛出异常。 还有，当我在母版页中定义了@RenderSection("SubMenu",false)的时候，我希望当所有子页都没有实现这个Section的时候，母版页可以有自己的呈现内容，就可以用

```html
</head>
<body>
@RenderSection("green",false) @*设置不是必须实现*@
<hr/>
    @if (IsSectionDefined("green"))
    {
        @RenderSection("green",false)
    }
    else
    {
        <h1>没有一个子页面实现green,我就输出我自己设置的内容</h1>
    }
```


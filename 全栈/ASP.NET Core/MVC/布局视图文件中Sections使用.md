# 布局视图文件中Sections使用

##### 1、Section是为了在布局视图中，可以让某些页面的元素有组织的放置在一起

```c#
// 在_Layout.cshtml添加如下语句，required为false机位该元素是非必实现项
@RenderSection("Scripts",required:false)

// 在视图文件中添加如下语句
@section Scripts{
    <script src="~/js/CustomScript.js"></script>
}
```



##### 2、Section可以强制性使用或者可选择性的使用

##### 3、需要渲染Section的使用可以调用RenderSection


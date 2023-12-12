# ViewStart的使用

ViewStart可以解决布局视图的重复修改问题。

ViewStart文件支持分层。

如果使用？

​	1、在Views中创建_ViewsStart.cshtml（MVC视图起始页）

​	2、在Views/Shared中创建_Layout.cshtml

​	3、在Views/Home/Details.cshtml添加如下代码

```json
@{
    Layout = Layout;
    ViewBag.Title = "学生测试页";
}
```

​	这时Details.cshtml会自动加载ViewStart中指定的布局文件。

​		如果你认为当前的项目布局文件不满意，**可以在Views/Home单独添加_Layout.cshtml**，此时Detais.cshtml	会优先加载最近的起始页，这是你就可以修改最近的那个起始页，将其中的代码修改为以下样式

```json
@{
    Layout = "_Layout2";
}
```

​		这时需要你在Views/Shared中手动创建_Layout2.cshtml，这样details就可以去优先加载刚刚创建好的_Layout2了。

​		理想的项目起始页应当是这样的：

```json
@{
  if(User.IsInRole("Admin"))
  {
  	Layout = "_AdminLayout";
	}
	else
	{
    Layout = "_NonAdminLayout";
  }
}
```



**注意**：ViewStart中的代码会在单个视图的代码前运行
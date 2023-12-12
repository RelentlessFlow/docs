# _ViewsImports.cshtml：MVC视图导入页面

_ViewsImports.cshtml可以简化视图中的包导入过程。

​	使用步骤：

​		1、首先确认需要导入的包，之后在Views目录下创建_ViewsStart.cshtml

​		2、删除_ViewsStart.cshtml默认内容，输入using语句，如下：

```json
@using StudentManagement.Models;
@using StudentManagement.ViewModels;
```

​		3、将原来的Views/Home/Detail.cshtml替换为原来的内容

```json
@model StudentManagement.ViewModels.HomeDetailsViewModel;
@{
    Layout = Layout;
    ViewBag.Title = "学生测试页";
}
```

​		⬇️	

```
@model HomeDetailsViewModel;
@{
    Layout = Layout;
    ViewBag.Title = "学生测试页";
}
```

​		将原来的Views/Home/Index.cshtml替换为原来的内容

```json
@model IEnumerable<StudentManagement.Models.Student>
@{
    Layout = Layout;
    ViewBag.Title = "学生测试页";
}
```

​		⬇️	

```json
@model IEnumerable<Student>
@{
    Layout = Layout;
    ViewBag.Title = "学生测试页";
}
```




# ViewBag的使用 

## ViewBag和ViewData的区别

![image-20191207170813518](https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20191207170813518.png)

**HomeController.cs**

```c#
public IActionResult Details()
        {
            Student model = _studentRepository.GetStudent(1);
            // 将PageTitle和Student模型对象在ViewBag
            // 我们正在使用动态属性PageTitle和Student
            ViewBag.PageTitle = "学生详情";
            ViewBag.Student = model;
            return View();
        }
```

**Detail.cshtml**

```c#
@using StudentManagement.Models;

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
</head>
<body>
    <h3>@ViewBag.PageTitle</h3>


    <div>
        姓名 : @ViewBag.Student.Name
    </div>

    <div>
        邮箱 ：@ViewBag.Student.Email
    </div>

    <div>
        班级名称：@ViewBag.Student.ClassName
    </div>
</body>
</html>
```


# ViewData的使用

**Controllers/HomeController.cs**

```c#
public IActionResult Details()
        {
            Student model = _studentRepository.GetStudent(1);
            ViewData["PageTitle"] = "学生详情";
            ViewData["Student"] = model;
            return View();
        }
```

**Views/Home/Details.cshtml**

```c#
@using StudentManagement.Models;

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
</head>
<body>
    <h3>@ViewData["PageTitle"]</h3>

    @{ 
        var student = ViewData["Student"] as Student;
    }

    <div>
        姓名 : @student.Name
    </div>

    <div>
        邮箱 ：@student.Email
    </div>

    <div>
        班级名称：@student.ClassName
    </div>
</body>
</html>
```


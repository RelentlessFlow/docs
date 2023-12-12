# ViewModel

ViewModel就是DTO，数据传输对象。

<img src="https://md-1304276643.cos.ap-beijing.myqcloud.com//PicGo/image-20191207175308329.png" alt="image-20191207175308329" style="zoom:50%;" />

**ViewModels/HomeDetailsViewModel.cs**

```c#
using StudentManagement.Models;
using System;

namespace StudentManagement.ViewModels
{
    public class HomeDetailsViewModel
    {
        public Student Student { get; set; }
        public String PageTitle { get; set; }
    }
}
```

**Controllers/HomeController.cs**

```c#
public class HomeController : Controller
    {
        private readonly IStudentRepoository _studentRepository;
	
		public HomeController(IStudentRepoository studentRepository)
        {
            _studentRepository = studentRepository;
        }
		public IActionResult Details()
        {
            // 实例化HomeDetailsViewModel并存储Student详细信息和PageTitle
            HomeDetailsViewModel homeDetailsViewModel = new HomeDetailsViewModel()
            {
                Student = _studentRepository.GetStudent(1),
                PageTitle = "Student Details"
            };
            // 讲ViewModel对象传递给View()方法
            return View(homeDetailsViewModel);
        }
}
```

Views/Details.cshtml

```c#
@model StudentManagement.ViewModels.HomeDetailsViewModel;
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
</head>
<body>
    <h3>@Model.PageTitle</h3>


    <div>
        姓名 : @Model.Student.Name
    </div>

    <div>
        邮箱 ：@Model.Student.Email
    </div>

    <div>
        班级名称：@Model.Student.ClassName
    </div>
</body>
</html>
```


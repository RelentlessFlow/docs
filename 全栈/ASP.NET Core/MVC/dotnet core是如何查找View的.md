# MVC中如何查找View

**HomeController.cs**

```c#
public IActionResult Details()
        {
            Student model = _studentRepository.GetStudent(1);
            //return Json(model);
            //return new ObjectResult(model);
            //return View("TextView");

            //return View("MyViews/Test.cshtml");
            return View("~/MyViews/Test.cshtml"); // 绝对路径 (推荐)
            //return View("../../MyViews/Test"); //相对路径
        }
```

![image-20191207131341721](assets/img/dotnet core是如何查找View的.img/image-20191207131341721.png)


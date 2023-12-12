# View Component

​		如果你想要在一个可服用的“组件”中编写业务逻辑，传统的ASP中只提供了ParticalView，

无法添加业务逻辑，使用ChildAction开销太大，直接在Controller写无法服用。

​		使用View Component可以填写也业务逻辑，也可以使用Razor语法。

## 业务需求：

​	添加一个专门用来显示员工总数和部门总数的可复用组件。

### Model：

```c#
public class CompanySummary
{
    public int  EmployeeCount { get; set; }
    public int AverageDepartmentEmployeeCount { get; set; }
}
```

### 添加控制器：

​	Three/ViewComponents/CompanySummaryViewComponent.cs

```c#
public class CompanySummaryViewComponent : ViewComponent
    {
        private readonly IDepartmentService _departmentService;

        public CompanySummaryViewComponent(IDepartmentService departmentService)
        {
            _departmentService = departmentService;
        }

        public async Task<IViewComponentResult> InvokeAsync(string title)
        {
            ViewBag.Title = title;
            var summary = await _departmentService.GetCompanySummary();
            return View(summary);
        }
    }
```

### 添加View

Three/Views/Shared/Components/CompanySummary/Default.cshtml

```c#
@model Three.Models.CompanySummary

<div class="small">
    <div class="row h3">@ViewBag.Title</div>
    <div class="row">
        <div class="col-md-8">员工总数</div>
        <div class="col-md-4">@Model.EmployeeCount</div>
    </div>
    <div class="row">
        <div class="col-md-8">部门平均总数</div>
        <div class="col-md-4">@Model.AverageDepartmentEmployeeCount</div>
    </div>
</div>
```

### 在另外的Razor中使用

两种方式，第二种是TagHelper的形式。

```c#
 @await Component.InvokeAsync("CompanySummary",new {title = "部门列表页的汇总"})
 <vc:company-summary title="部门列表页的汇总"></vc:company-summary>
```

**注意：TagHelper需要导入命名空间**

_ViewImport.cshtml

```
@addTagHelper "*, Microsoft.AspNetCore.Mvc.TagHelpers"
@addTagHelper "*, Three"
```

预览效果

```
部门列表页的汇总
		员工总数																			 268
		部门平均总数																		89
```


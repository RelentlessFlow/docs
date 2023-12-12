# TagHelper

### 如何引用TagHelper？

在_ViewImports.cshtml中引入以下依赖

```json
@addTagHelper *, Microsoft.AspNetCore.Mvc.TagHelpers
@addTagHelper *, AuthoringTagHelpers
```

index.cshtml

```html
 <a asp-controller="home" asp-action="details" asp-route-id="@student.Id">查看</a>
```

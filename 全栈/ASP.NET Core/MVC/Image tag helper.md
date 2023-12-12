# ASP.NET Image tag helper

```c#
<img asp-append-version="true" class="card-img-top" src="~/images/watermark.png" />
```

- Image TagHelper 增强了<img>标签，为静态图像文件提供“缓存破坏行为”。
- 生成唯一的散列值并将其附加到图片的URL。此唯一字符串会提示浏览器从服务器重新加载页面，而不是从浏览器重新加载。
- 只有当磁盘上的文件发生更改时，将会重新计算生成新的哈希值，缓存才会失效。
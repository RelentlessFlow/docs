# ViewBag用法

控制器：

```c#
public ActionResult Welcome(string name, int numTimes = 1) 
        { 
            ViewBag.Message = "Hello " + name;
            ViewBag.NumTimes = numTimes;
            
            return View();
        }
```

View：

```html
@{
    ViewBag.Title = "Welcome";
}

<h2>Welcome</h2>

<ul>
    @for (int i = 0; i < ViewBag.NumTimes; i++)
    {
        <li>@ViewBag.Message</li>
    }
</ul>
```


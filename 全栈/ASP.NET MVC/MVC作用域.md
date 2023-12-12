# MVC内置对象及其作用域

## MVC内置对象

1. Request 请求

2. Response   响应

3. Session 会话
4. Coookie 缓存
5. Application  当前网站对象
6.  Server 服务器对象         

## Request

```c#
				public ActionResult Index2()
        {
            return Content($"{Request.QueryString["name"]} - {Request.QueryString["age"]} - {Request.QueryString["id"]}");
        }
				
				// String参数既可以获取接受Get也可以接受Post
				[HttpGet]
				public ActionResult Index2(string name,string pwd)
        {
            return Content(name);
        }
				// 传入Model	input表单的name属性要于Model字段一一对应
				[HttpPost]
				public ActionResult Login(Models.LoginViewModel model){}
```

```c#
				public ActionResult PostData()
        {
            return Content(Request.Form["loginame"]);
        }
```

```c#
				public ActionResult FileData()
        {
            // SaveAs方法需要物理路径
            Request.Files["file"].SaveAs(Request.MapPath("~/uploads" + Request.Files["file"].FileName));
            return Content("ok");
        }
```

```c#
				public ActionResult RequestHeader()
        {
            Request.Headers["hello"] = "world";
            return Content(Request.Headers["token"]);
        }
```

## Response

```c#
				public ActionResult ResponseData()
        {
        		// 重定向
            Response.Redirect("https://www.baidu.com");
            return Content("");
        }
```

## Session

Session会话保存在服务器中，存储少量重要数据比如账号

Session是一个键值对

Session的存活时间 20min

Session销毁 Abandon/Clear

```c#
public ActionResult SessionData()
        {
            Session["user"] = Request.Form["user"];
            return Content("会话中的数据是:" + Session["user"]);
        }

        public ActionResult GetSession()
        {
            return Content("当前会话的数据是:" + Session["user"]);
        }
```

## Cookie

```c#
// Cookie
        public ActionResult CookieSave()
        {
            Response.Cookies.Add(new HttpCookie("token")
            {
                Value = "abc123",
                Expires = DateTime.Now.AddDays(7) // Cookie时效性
            });
            return Content("ok");
        }
        public ActionResult CookieGet()
        {
            return Content(Request.Cookies["token"].Value);
        }

        public ActionResult CookieClear()
        {
            Response.Cookies.Add(new HttpCookie("token")
            {
                Value = "abc123",
                Expires = DateTime.Now.AddDays(-1) // Cookie时效性
            });
            return Content("ok");
        }
```

## Application

```c#
public ActionResult ApplicationGet()
        {
            return Content(HttpContext.Application["user"].ToString());
        }
```

## Server

```c#
public ActionResult ServerDemo()
        {
            // 路径不变，内容发生变化
            // Server.Transfer 转发
            // Server.MapPath 虚拟路径转物理路径
            // Server.HTMLEncode
            // Server.HTMLDecode
            // Server.UrlEncode
            // Server.UrlDecode
            Server.Transfer("/WebForm1.aspx");
            return Content("");
        }
```


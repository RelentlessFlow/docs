# Asp.Net Core配置文件

**lanchSetting.json**

```json
{
  "iisSettings": {
    "windowsAuthentication": false, 
    "anonymousAuthentication": true, 
    "iisExpress": {
      "applicationUrl": "http://localhost:51959",
      "sslPort": 0
    }
  },
  "profiles": {
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
        // IIS下的自定义配置信息
        // "MyKey": "lanchSetting.json iis of MyKey values"
      }
    },
    "StudentManagement": {
      "commandName": "Project",
      "launchBrowser": true,
      "applicationUrl": "http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        // 5000 CMD端口下的自定义配置信息
        "MyKey": "lanchSetting.json cmd of MyKey values"
      }
    }
  }
}
```

**appsetting.json**

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning"
    }
  }
  // "AllowedHosts": "*",
  // "MyKey": "appsetting.json of MyKey values"
}

```

**Startup.cs**

```c#
 app.Run(async (context) =>
            {
                // 进程名
                var processName = System.Diagnostics.Process.GetCurrentProcess().ProcessName;
                var configVal = _configuration["MyKey"];
                await context.Response.WriteAsync("processName");
            });
```


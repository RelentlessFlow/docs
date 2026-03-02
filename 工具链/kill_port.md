```bat
@echo off
echo 正在查找占用端口 2149 的进程...

:: 查找占用端口的进程 ID
for /f "tokens=5" %%i in ('netstat -ano ^| findstr :2149') do (
    set PID=%%i
    goto :kill
)

echo 未找到占用端口 2149 的进程。
pause
exit /b

:kill
echo 发现占用端口 2149 的进程 ID: %PID%
echo 正在尝试终止进程...

:: 结束进程
taskkill /PID %PID% /F

if %ERRORLEVEL% equ 0 (
    echo 成功关闭占用端口 2149 的进程。
) else (
    echo 关闭进程失败，请检查权限或其他问题。
)

pause
exit /b
```


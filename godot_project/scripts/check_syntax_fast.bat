@echo off
REM 快速 Godot 语法检查脚本
REM 使用简化的 Godot 命令，提高检查效率

echo ========================================
echo Godot 快速语法检查器 v2.0
echo ========================================

REM 设置项目路径和 Godot 路径
set PROJECT_PATH=%~dp0..
set GODOT_PATH=D:\develop\Godot\Godot_v4.3-beta2_win64_console.exe

REM 检查 Godot 是否存在
if not exist "%GODOT_PATH%" (
    echo 错误: 找不到 Godot 可执行文件
    echo 请检查路径: %GODOT_PATH%
    pause
    exit /b 1
)

echo 项目路径: %PROJECT_PATH%
echo Godot 路径: %GODOT_PATH%
echo.

REM 创建临时输出文件
set TEMP_OUTPUT=%TEMP%\godot_syntax_fast.txt

echo 开始语法检查...
echo.

REM 使用简化的 Godot 命令进行语法检查
"%GODOT_PATH%" --headless --quit --auto-exit --path "%PROJECT_PATH%" > "%TEMP_OUTPUT%" 2>&1

REM 检查退出码
if %ERRORLEVEL% equ 0 (
    echo ✅ 语法检查完成 - 没有发现错误
    echo.
    echo 🎉 恭喜！所有语法检查通过！
    del "%TEMP_OUTPUT%" 2>nul
    exit /b 0
) else (
    echo ❌ 语法检查完成 - 发现错误 (退出码: %ERRORLEVEL%)
    echo.
)

REM 快速统计错误数量
set ERROR_COUNT=0
for /f %%i in ('findstr /c:"SCRIPT ERROR" "%TEMP_OUTPUT%" ^| find /c /v ""') do set ERROR_COUNT=%%i

set WARNING_COUNT=0
for /f %%i in ('findstr /c:"WARNING:" "%TEMP_OUTPUT%" ^| find /c /v ""') do set WARNING_COUNT=%%i

echo ========================================
echo 检查结果统计
echo ========================================
echo 脚本错误数量: %ERROR_COUNT%
echo 警告数量: %WARNING_COUNT%
echo.

if %ERROR_COUNT% gtr 0 (
    echo 发现 %ERROR_COUNT% 个脚本错误
    echo.
    echo 前 10 个错误:
    findstr /c:"SCRIPT ERROR" "%TEMP_OUTPUT%" | head -10
    echo.
    echo 完整错误日志已保存到: %TEMP_OUTPUT%
    echo 建议: 使用文本编辑器打开查看详细错误信息
) else (
    echo 恭喜！没有发现脚本错误。
)

echo.
echo 检查完成！

REM 清理临时文件
del "%TEMP_OUTPUT%" 2>nul

REM 根据错误数量设置退出码
if %ERROR_COUNT% gtr 0 (
    exit /b 1
) else (
    exit /b 0
)

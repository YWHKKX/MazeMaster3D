@echo off
REM 检查特定文件的语法错误
REM 用法: check_specific_files.bat [文件路径1] [文件路径2] ...

echo ========================================
echo Godot 特定文件语法检查器 v2.0
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

REM 检查是否提供了文件参数
if "%~1"=="" (
    echo 用法: check_specific_files.bat [文件路径1] [文件路径2] ...
    echo 示例: check_specific_files.bat main.gd ResourceManager.gd
    echo.
    echo 可用的脚本文件:
    dir /b "%PROJECT_PATH%\scripts\*.gd" 2>nul
    echo.
    pause
    exit /b 1
)

echo 项目路径: %PROJECT_PATH%
echo Godot 路径: %GODOT_PATH%
echo.

REM 创建临时输出文件
set TEMP_OUTPUT=%TEMP%\godot_specific_syntax.txt

echo 开始检查特定文件...
echo.

REM 对每个文件进行单独检查
set TOTAL_ERRORS=0
set CHECKED_FILES=0

:check_loop
if "%~1"=="" goto :check_done

set CURRENT_FILE=%~1
echo 检查文件: %CURRENT_FILE%

REM 使用简化的 Godot 命令检查特定文件
"%GODOT_PATH%" --headless --quit --auto-exit --path "%PROJECT_PATH%" --script "%PROJECT_PATH%\scripts\%CURRENT_FILE%" > "%TEMP_OUTPUT%" 2>&1

REM 检查退出码
if %ERRORLEVEL% equ 0 (
    echo ✅ %CURRENT_FILE% - 没有语法错误
) else (
    echo ❌ %CURRENT_FILE% - 发现语法错误
    set /a TOTAL_ERRORS+=1
    
    REM 显示该文件的错误
    echo 错误详情:
    findstr /c:"SCRIPT ERROR" "%TEMP_OUTPUT%" | head -5
    echo.
)

set /a CHECKED_FILES+=1
shift
goto :check_loop

:check_done
echo ========================================
echo 检查完成统计
echo ========================================
echo 检查文件数量: %CHECKED_FILES%
echo 有错误的文件: %TOTAL_ERRORS%
echo.

if %TOTAL_ERRORS% gtr 0 (
    echo 发现 %TOTAL_ERRORS% 个文件有语法错误
    echo 详细错误信息已保存到: %TEMP_OUTPUT%
) else (
    echo 🎉 所有检查的文件都没有语法错误！
)

echo.
echo 检查完成！

REM 清理临时文件
del "%TEMP_OUTPUT%" 2>nul

REM 根据错误数量设置退出码
if %TOTAL_ERRORS% gtr 0 (
    exit /b 1
) else (
    exit /b 0
)

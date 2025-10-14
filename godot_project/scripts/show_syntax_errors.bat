@echo off
REM 显示语法错误摘要 - 优化版本

echo ========================================
echo Godot 语法错误摘要 (优化版)
echo ========================================

REM 设置项目路径
set PROJECT_PATH=%~dp0..
set RESULTS_FILE=%PROJECT_PATH%\syntax_check_results.txt

REM 检查结果文件是否存在
if not exist "%RESULTS_FILE%" (
    echo 错误: 找不到语法检查结果文件
    echo 请先运行: check_syntax_fast.bat
    echo.
    pause
    exit /b 1
)

echo 分析文件: %RESULTS_FILE%
echo.

REM 检查文件大小
for %%A in ("%RESULTS_FILE%") do set FILE_SIZE=%%~zA
set /a FILE_SIZE_MB=%FILE_SIZE%/1024/1024

if %FILE_SIZE_MB% gtr 10 (
    echo ⚠️ 警告: 结果文件过大 (%FILE_SIZE_MB% MB)
    echo 建议: 使用 check_syntax_fast.bat 重新检查
    echo.
)

REM 简单统计错误数量
echo 正在统计错误...
set ERROR_COUNT=0
set WARNING_COUNT=0

REM 使用更简单的方法统计
findstr /c:"SCRIPT ERROR" "%RESULTS_FILE%" >nul 2>&1
if %ERRORLEVEL% equ 0 (
    for /f %%i in ('findstr /c:"SCRIPT ERROR" "%RESULTS_FILE%" ^| find /c /v ""') do set ERROR_COUNT=%%i
)

findstr /c:"WARNING:" "%RESULTS_FILE%" >nul 2>&1
if %ERRORLEVEL% equ 0 (
    for /f %%i in ('findstr /c:"WARNING:" "%RESULTS_FILE%" ^| find /c /v ""') do set WARNING_COUNT=%%i
)

echo ========================================
echo 错误统计
echo ========================================
echo 脚本错误数量: %ERROR_COUNT%
echo 警告数量: %WARNING_COUNT%
echo 文件大小: %FILE_SIZE_MB% MB
echo.

if %ERROR_COUNT% gtr 0 (
    echo ========================================
    echo 前 10 个关键错误
    echo ========================================
    findstr /c:"SCRIPT ERROR" "%RESULTS_FILE%" | head -10
    echo.
    echo 完整错误列表: %RESULTS_FILE%
    echo.
    echo 建议修复顺序:
    echo 1. 修复 main.gd 的语法错误
    echo 2. 修复 ResourceManager.gd 的语法错误
    echo 3. 使用 check_syntax_fast.bat 重新检查
) else (
    echo 🎉 恭喜！没有发现脚本错误。
)

echo ========================================
echo 快速操作
echo ========================================
echo 1. 快速检查: check_syntax_fast.bat
echo 2. 检查特定文件: check_specific_files.bat [文件名]
echo 3. 完整检查: check_syntax_godot.bat
echo.

pause

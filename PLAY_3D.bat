@echo off
echo ========================================
echo    MazeMaster3D - Godot 3D版本启动器
echo ========================================
echo.

echo 检查Godot引擎...
if not exist "D:\develop\Godot\Godot_v4.3-beta2_win64.exe" (
    echo 错误: 未找到Godot引擎
    echo 请确认Godot已安装在 D:\develop\Godot\ 路径下
    pause
    exit /b 1
)

echo 启动Godot项目...
"D:\develop\Godot\Godot_v4.3-beta2_win64.exe" --path godot_project --editor=false --verbose
if errorlevel 1 (
    echo 错误: Godot启动失败
    pause
    exit /b 1
)

echo.
echo 游戏已退出
pause

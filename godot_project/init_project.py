#!/usr/bin/env python3
"""
MazeMaster3D Godot项目初始化脚本
自动设置开发环境和验证项目配置
"""

import os
import sys
import subprocess
import platform
from pathlib import Path


def print_header():
    """打印项目标题"""
    print("=" * 60)
    print("    MazeMaster3D - Godot项目初始化")
    print("=" * 60)
    print()


def check_python_version():
    """检查Python版本"""
    print("1. 检查Python版本...")
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print(f"❌ Python版本过低: {version.major}.{version.minor}")
        print("   需要Python 3.8+")
        return False
    else:
        print(f"✅ Python版本: {version.major}.{version.minor}.{version.micro}")
        return True


def check_godot_installation():
    """检查Godot安装"""
    print("\n2. 检查Godot安装...")

    # 常见的Godot安装路径
    godot_paths = [
        "godot",
        "C:\\Program Files\\Godot\\Godot_v4.3.2-stable_win64.exe",
        "/usr/bin/godot",
        "/usr/local/bin/godot",
        "/Applications/Godot.app/Contents/MacOS/Godot"
    ]

    for path in godot_paths:
        try:
            result = subprocess.run([path, "--version"],
                                    capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                version = result.stdout.strip()
                print(f"✅ Godot版本: {version}")
                return True
        except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
            continue

    print("❌ 未找到Godot引擎")
    print("   请从 https://godotengine.org/download/ 下载并安装Godot 4.3+")
    return False


def install_python_dependencies():
    """安装Python依赖"""
    print("\n3. 安装Python依赖...")

    requirements_file = Path("requirements_godot.txt")
    if not requirements_file.exists():
        print("❌ 未找到requirements_godot.txt文件")
        return False

    try:
        result = subprocess.run([
            sys.executable, "-m", "pip", "install", "-r", str(
                requirements_file)
        ], capture_output=True, text=True)

        if result.returncode == 0:
            print("✅ Python依赖安装成功")
            return True
        else:
            print(f"❌ Python依赖安装失败: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ 安装过程中发生错误: {e}")
        return False


def test_python_bridge():
    """测试Python桥接"""
    print("\n4. 测试Python桥接...")

    try:
        result = subprocess.run([
            sys.executable, "test_python_bridge.py"
        ], capture_output=True, text=True, timeout=30)

        if result.returncode == 0:
            print("✅ Python桥接测试通过")
            return True
        else:
            print(f"❌ Python桥接测试失败:")
            print(result.stderr)
            return False
    except subprocess.TimeoutExpired:
        print("❌ Python桥接测试超时")
        return False
    except Exception as e:
        print(f"❌ 测试过程中发生错误: {e}")
        return False


def create_directories():
    """创建必要的目录"""
    print("\n5. 创建项目目录...")

    directories = [
        "assets/models/characters",
        "assets/models/buildings",
        "assets/models/environments",
        "assets/textures/characters",
        "assets/textures/buildings",
        "assets/textures/environments",
        "assets/sounds/music",
        "assets/sounds/sfx",
        "assets/shaders",
        "scenes/UI",
        "scenes/Characters",
        "scenes/Buildings",
        "scenes/Environments",
        "scenes/Effects"
    ]

    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)

    print("✅ 项目目录创建完成")


def create_gitignore():
    """创建.gitignore文件"""
    print("\n6. 创建.gitignore文件...")

    gitignore_content = """# Godot
.godot/
.import/
export.cfg
export_presets.cfg

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/

# 编辑器
.vscode/
.idea/
*.swp
*.swo

# 操作系统
.DS_Store
Thumbs.db

# 临时文件
*.tmp
*.temp
*.log

# 存档文件
*.save
*.json
!project.godot
"""

    with open(".gitignore", "w", encoding="utf-8") as f:
        f.write(gitignore_content)

    print("✅ .gitignore文件创建完成")


def print_next_steps():
    """打印后续步骤"""
    print("\n" + "=" * 60)
    print("项目初始化完成！")
    print("=" * 60)
    print()
    print("下一步操作:")
    print("1. 启动Godot编辑器:")
    print("   godot --path .")
    print()
    print("2. 或者使用启动脚本:")
    if platform.system() == "Windows":
        print("   PLAY_3D.bat")
    else:
        print("   ./PLAY_3D.sh")
    print()
    print("3. 开始开发:")
    print("   - 编辑场景文件 (scenes/)")
    print("   - 编写脚本 (scripts/)")
    print("   - 添加资源 (assets/)")
    print()
    print("4. 查看文档:")
    print("   README_GODOT.md")
    print()
    print("祝您开发愉快！🎮")


def main():
    """主函数"""
    print_header()

    # 检查系统要求
    if not check_python_version():
        sys.exit(1)

    if not check_godot_installation():
        print("\n⚠️  警告: Godot未安装，但可以继续初始化项目")

    # 安装依赖
    if not install_python_dependencies():
        print("\n⚠️  警告: Python依赖安装失败，请手动安装")

    # 创建项目结构
    create_directories()
    create_gitignore()

    # 测试Python桥接
    if not test_python_bridge():
        print("\n⚠️  警告: Python桥接测试失败，请检查代码")

    # 打印后续步骤
    print_next_steps()


if __name__ == "__main__":
    main()

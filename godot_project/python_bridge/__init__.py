"""
Python桥接模块
连接Python游戏逻辑和Godot 3D引擎
"""

from .game_logic import *
from .bridge import *

__version__ = "1.0.0"
__author__ = "MazeMaster3D Team"

# 导出主要类和函数
__all__ = [
    "GameLogic",
    "GodotBridge",
    "Vector3",
    "ResourceType",
    "BuildingType",
    "CharacterType",
    "ResourceData",
    "BuildingData",
    "CharacterData",
    "game_logic",
    "bridge",
    "initialize_bridge",
    "update_bridge",
    "process_input",
    "get_game_data",
    "get_all_resources",
    "get_all_buildings",
    "get_all_characters",
    "get_game_statistics"
]

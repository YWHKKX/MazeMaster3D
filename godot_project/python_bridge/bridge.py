"""
Python桥接接口 - 连接Python游戏逻辑和Godot引擎
提供Python和GDScript之间的数据交换接口
"""

import json
from typing import Dict, List, Any, Optional
from .game_logic import (
    game_logic,
    Vector3,
    ResourceType,
    BuildingType,
    CharacterType,
    initialize,
    update,
    get_game_state,
    build_building,
    summon_character,
    get_resource,
    save_game,
    load_game
)


class GodotBridge:
    """Godot桥接类 - 处理Python和Godot之间的通信"""

    def __init__(self):
        self.is_initialized = False
        self.callbacks: Dict[str, callable] = {}

    def initialize(self):
        """初始化桥接"""
        if self.is_initialized:
            return

        # 初始化Python游戏逻辑
        initialize()

        self.is_initialized = True
        print("Godot桥接初始化完成")

    def register_callback(self, event_name: str, callback: callable):
        """注册回调函数"""
        self.callbacks[event_name] = callback
        print(f"注册回调: {event_name}")

    def call_godot_function(self, function_name: str, *args, **kwargs):
        """调用Godot函数"""
        if function_name in self.callbacks:
            try:
                return self.callbacks[function_name](*args, **kwargs)
            except Exception as e:
                print(f"调用Godot函数 {function_name} 时发生错误: {e}")
                return None
        else:
            print(f"未找到Godot函数: {function_name}")
            return None

    def update_game(self, delta: float):
        """更新游戏"""
        if not self.is_initialized:
            return

        update(delta)

    def get_game_data(self) -> Dict[str, Any]:
        """获取游戏数据"""
        return get_game_state()

    def execute_build_building(self, building_type: str, x: float, y: float, z: float) -> bool:
        """执行建造建筑"""
        result = build_building(building_type, x, y, z)
        if result:
            # 通知Godot建筑创建成功
            self.call_godot_function(
                "on_building_created", building_type, x, y, z)
        return result

    def execute_summon_character(self, character_type: str, x: float, y: float, z: float) -> bool:
        """执行召唤角色"""
        result = summon_character(character_type, x, y, z)
        if result:
            # 通知Godot角色创建成功
            self.call_godot_function(
                "on_character_created", character_type, x, y, z)
        return result

    def get_resource_amount(self, resource_type: str) -> int:
        """获取资源数量"""
        return get_resource(resource_type)

    def save_game_data(self, filename: str):
        """保存游戏数据"""
        save_game(filename)
        self.call_godot_function("on_game_saved", filename)

    def load_game_data(self, filename: str):
        """加载游戏数据"""
        load_game(filename)
        self.call_godot_function("on_game_loaded", filename)

    def process_input(self, input_data: Dict[str, Any]):
        """处理输入数据"""
        input_type = input_data.get("type", "")

        if input_type == "build_building":
            building_type = input_data.get("building_type", "")
            x = input_data.get("x", 0.0)
            y = input_data.get("y", 0.0)
            z = input_data.get("z", 0.0)
            return self.execute_build_building(building_type, x, y, z)

        elif input_type == "summon_character":
            character_type = input_data.get("character_type", "")
            x = input_data.get("x", 0.0)
            y = input_data.get("y", 0.0)
            z = input_data.get("z", 0.0)
            return self.execute_summon_character(character_type, x, y, z)

        elif input_type == "get_resource":
            resource_type = input_data.get("resource_type", "")
            return self.get_resource_amount(resource_type)

        elif input_type == "save_game":
            filename = input_data.get("filename", "save.json")
            self.save_game_data(filename)
            return True

        elif input_type == "load_game":
            filename = input_data.get("filename", "save.json")
            self.load_game_data(filename)
            return True

        else:
            print(f"未知输入类型: {input_type}")
            return False

    def get_all_resources(self) -> Dict[str, int]:
        """获取所有资源"""
        resources = {}
        for resource_type in ResourceType:
            resources[resource_type.value] = game_logic.get_resource(
                resource_type)
        return resources

    def get_all_buildings(self) -> List[Dict[str, Any]]:
        """获取所有建筑"""
        buildings = []
        for building in game_logic.buildings:
            building_data = {
                "type": building.type.value,
                "position": {
                    "x": building.position.x,
                    "y": building.position.y,
                    "z": building.position.z
                },
                "health": building.health,
                "max_health": building.max_health,
                "is_built": building.is_built
            }
            buildings.append(building_data)
        return buildings

    def get_all_characters(self) -> List[Dict[str, Any]]:
        """获取所有角色"""
        characters = []
        for character in game_logic.characters:
            character_data = {
                "type": character.type.value,
                "position": {
                    "x": character.position.x,
                    "y": character.position.y,
                    "z": character.position.z
                },
                "health": character.health,
                "max_health": character.max_health,
                "is_alive": character.is_alive,
                "current_action": character.current_action
            }
            characters.append(character_data)
        return characters

    def validate_position(self, x: float, y: float, z: float) -> bool:
        """验证位置是否有效"""
        # 检查位置是否在有效范围内
        if abs(x) > 100 or abs(z) > 100:
            return False

        # 检查Y坐标是否合理
        if y < -10 or y > 20:
            return False

        return True

    def get_building_cost(self, building_type: str) -> Dict[str, int]:
        """获取建筑成本"""
        try:
            bt = BuildingType(building_type)
            costs = game_logic.building_costs.get(bt, {})
            return {rt.value: amount for rt, amount in costs.items()}
        except ValueError:
            return {}

    def get_character_cost(self, character_type: str) -> Dict[str, int]:
        """获取角色成本"""
        try:
            ct = CharacterType(character_type)
            costs = game_logic.character_costs.get(ct, {})
            return {rt.value: amount for rt, amount in costs.items()}
        except ValueError:
            return {}

    def can_afford_building(self, building_type: str) -> bool:
        """检查是否能建造建筑"""
        try:
            bt = BuildingType(building_type)
            return game_logic.can_afford_building(bt)
        except ValueError:
            return False

    def can_afford_character(self, character_type: str) -> bool:
        """检查是否能召唤角色"""
        try:
            ct = CharacterType(character_type)
            return game_logic.can_afford_character(ct)
        except ValueError:
            return False

    def get_game_statistics(self) -> Dict[str, Any]:
        """获取游戏统计信息"""
        return {
            "game_time": game_logic.game_time,
            "total_resources": sum(game_logic.get_resource(rt) for rt in ResourceType),
            "buildings_count": len(game_logic.buildings),
            "characters_count": len(game_logic.characters),
            "alive_characters": len([c for c in game_logic.characters if c.is_alive]),
            "built_buildings": len([b for b in game_logic.buildings if b.is_built])
        }


# 全局桥接实例
bridge = GodotBridge()


def get_bridge() -> GodotBridge:
    """获取桥接实例"""
    return bridge


def initialize_bridge():
    """初始化桥接"""
    bridge.initialize()


def update_bridge(delta: float):
    """更新桥接"""
    bridge.update_game(delta)


def process_input(input_data: Dict[str, Any]):
    """处理输入"""
    return bridge.process_input(input_data)


def get_game_data() -> Dict[str, Any]:
    """获取游戏数据"""
    return bridge.get_game_data()


def get_all_resources() -> Dict[str, int]:
    """获取所有资源"""
    return bridge.get_all_resources()


def get_all_buildings() -> List[Dict[str, Any]]:
    """获取所有建筑"""
    return bridge.get_all_buildings()


def get_all_characters() -> List[Dict[str, Any]]:
    """获取所有角色"""
    return bridge.get_all_characters()


def get_game_statistics() -> Dict[str, Any]:
    """获取游戏统计信息"""
    return bridge.get_game_statistics()

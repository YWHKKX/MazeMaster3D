"""
Python桥接模块 - 游戏逻辑
将2D版本的游戏逻辑集成到Godot 3D版本中
"""

import json
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from enum import Enum


class ResourceType(Enum):
    """资源类型枚举"""
    GOLD = "gold"
    MANA = "mana"
    FOOD = "food"
    RAW_GOLD = "raw_gold"
    CREATURES = "creatures"


class BuildingType(Enum):
    """建筑类型枚举"""
    DUNGEON_HEART = "dungeon_heart"
    TREASURY = "treasury"
    DEMON_LAIR = "demon_lair"
    ORC_LAIR = "orc_lair"
    ARCANE_TOWER = "arcane_tower"
    ARROW_TOWER = "arrow_tower"


class CharacterType(Enum):
    """角色类型枚举"""
    GOBLIN_ENGINEER = "goblin_engineer"
    GOBLIN_WORKER = "goblin_worker"
    ORC_WARRIOR = "orc_warrior"
    IMP = "imp"
    ARCHER = "archer"
    KNIGHT = "knight"


@dataclass
class Vector3:
    """3D向量类"""
    x: float = 0.0
    y: float = 0.0
    z: float = 0.0

    def __str__(self):
        return f"Vector3({self.x}, {self.y}, {self.z})"

    def distance_to(self, other: 'Vector3') -> float:
        """计算到另一个向量的距离"""
        dx = self.x - other.x
        dy = self.y - other.y
        dz = self.z - other.z
        return (dx * dx + dy * dy + dz * dz) ** 0.5


@dataclass
class ResourceData:
    """资源数据类"""
    type: ResourceType
    amount: int = 0
    generation_rate: float = 0.0
    storage_capacity: int = 0


@dataclass
class BuildingData:
    """建筑数据类"""
    type: BuildingType
    position: Vector3
    health: int = 100
    max_health: int = 100
    is_built: bool = False
    production_rates: Dict[ResourceType, float] = None
    storage_capacity: Dict[ResourceType, int] = None

    def __post_init__(self):
        if self.production_rates is None:
            self.production_rates = {}
        if self.storage_capacity is None:
            self.storage_capacity = {}


@dataclass
class CharacterData:
    """角色数据类"""
    type: CharacterType
    position: Vector3
    health: int = 100
    max_health: int = 100
    speed: float = 2.0
    attack_damage: int = 10
    defense: int = 5
    is_alive: bool = True
    current_action: str = "idle"


class GameLogic:
    """游戏逻辑类 - 核心游戏逻辑实现"""

    def __init__(self):
        self.resources: Dict[ResourceType, ResourceData] = {}
        self.buildings: List[BuildingData] = []
        self.characters: List[CharacterData] = []
        self.game_time: float = 0.0
        self.is_initialized: bool = False

        # 建筑和角色成本配置
        self.building_costs = self._init_building_costs()
        self.character_costs = self._init_character_costs()

    def _init_building_costs(self) -> Dict[BuildingType, Dict[ResourceType, int]]:
        """初始化建筑成本"""
        return {
            BuildingType.DUNGEON_HEART: {
                ResourceType.GOLD: 0,
                ResourceType.MANA: 0
            },
            BuildingType.TREASURY: {
                ResourceType.GOLD: 200,
                ResourceType.MANA: 50
            },
            BuildingType.DEMON_LAIR: {
                ResourceType.GOLD: 300,
                ResourceType.MANA: 100
            },
            BuildingType.ORC_LAIR: {
                ResourceType.GOLD: 250,
                ResourceType.MANA: 75
            },
            BuildingType.ARCANE_TOWER: {
                ResourceType.GOLD: 400,
                ResourceType.MANA: 150
            },
            BuildingType.ARROW_TOWER: {
                ResourceType.GOLD: 150,
                ResourceType.MANA: 25
            }
        }

    def _init_character_costs(self) -> Dict[CharacterType, Dict[ResourceType, int]]:
        """初始化角色成本"""
        return {
            CharacterType.GOBLIN_ENGINEER: {
                ResourceType.GOLD: 150,
                ResourceType.MANA: 50,
                ResourceType.FOOD: 20
            },
            CharacterType.GOBLIN_WORKER: {
                ResourceType.GOLD: 100,
                ResourceType.MANA: 25,
                ResourceType.FOOD: 15
            },
            CharacterType.ORC_WARRIOR: {
                ResourceType.GOLD: 200,
                ResourceType.MANA: 75,
                ResourceType.FOOD: 30
            },
            CharacterType.IMP: {
                ResourceType.GOLD: 80,
                ResourceType.MANA: 30,
                ResourceType.FOOD: 10
            }
        }

    def initialize(self):
        """初始化游戏逻辑"""
        if self.is_initialized:
            return

        # 初始化资源
        self._init_resources()

        # 创建地牢之心
        self._create_dungeon_heart()

        self.is_initialized = True
        print("Python游戏逻辑初始化完成")

    def _init_resources(self):
        """初始化资源"""
        self.resources = {
            ResourceType.GOLD: ResourceData(ResourceType.GOLD, 1000),
            ResourceType.MANA: ResourceData(ResourceType.MANA, 500),
            ResourceType.FOOD: ResourceData(ResourceType.FOOD, 200),
            ResourceType.RAW_GOLD: ResourceData(ResourceType.RAW_GOLD, 0),
            ResourceType.CREATURES: ResourceData(ResourceType.CREATURES, 0)
        }
        print("资源系统初始化完成")

    def _create_dungeon_heart(self):
        """创建地牢之心"""
        heart = BuildingData(
            type=BuildingType.DUNGEON_HEART,
            position=Vector3(0, 0, 0),
            health=1000,
            max_health=1000,
            is_built=True
        )
        heart.production_rates[ResourceType.MANA] = 2.0
        self.buildings.append(heart)
        print("地牢之心创建完成")

    def update(self, delta: float):
        """更新游戏逻辑"""
        if not self.is_initialized:
            return

        self.game_time += delta

        # 更新资源生成
        self._update_resource_generation(delta)

        # 更新建筑生产
        self._update_building_production(delta)

        # 更新角色AI
        self._update_character_ai(delta)

    def _update_resource_generation(self, delta: float):
        """更新资源生成"""
        for resource_type, resource_data in self.resources.items():
            if resource_data.generation_rate > 0:
                amount = int(resource_data.generation_rate * delta)
                if amount > 0:
                    resource_data.amount += amount

    def _update_building_production(self, delta: float):
        """更新建筑生产"""
        for building in self.buildings:
            if building.is_built:
                for resource_type, rate in building.production_rates.items():
                    amount = int(rate * delta)
                    if amount > 0:
                        self.add_resource(resource_type, amount)

    def _update_character_ai(self, delta: float):
        """更新角色AI"""
        for character in self.characters:
            if character.is_alive:
                # 这里将实现角色AI逻辑
                pass

    def get_resource(self, resource_type: ResourceType) -> int:
        """获取资源数量"""
        if resource_type in self.resources:
            return self.resources[resource_type].amount
        return 0

    def add_resource(self, resource_type: ResourceType, amount: int):
        """增加资源"""
        if resource_type not in self.resources:
            self.resources[resource_type] = ResourceData(resource_type)

        self.resources[resource_type].amount += amount
        print(f"增加资源 {resource_type.value}: +{amount}")

    def consume_resource(self, resource_type: ResourceType, amount: int) -> bool:
        """消耗资源"""
        if resource_type not in self.resources:
            return False

        current = self.resources[resource_type].amount
        if current >= amount:
            self.resources[resource_type].amount -= amount
            print(f"消耗资源 {resource_type.value}: -{amount}")
            return True
        else:
            print(f"资源不足 {resource_type.value}: 需要 {amount}, 可用 {current}")
            return False

    def can_afford_building(self, building_type: BuildingType) -> bool:
        """检查是否能建造建筑"""
        costs = self.building_costs.get(building_type, {})
        for resource_type, amount in costs.items():
            if not self.has_resource(resource_type, amount):
                return False
        return True

    def can_afford_character(self, character_type: CharacterType) -> bool:
        """检查是否能召唤角色"""
        costs = self.character_costs.get(character_type, {})
        for resource_type, amount in costs.items():
            if not self.has_resource(resource_type, amount):
                return False
        return True

    def has_resource(self, resource_type: ResourceType, amount: int) -> bool:
        """检查是否有足够资源"""
        return self.get_resource(resource_type) >= amount

    def build_building(self, building_type: BuildingType, position: Vector3) -> bool:
        """建造建筑"""
        if not self.can_afford_building(building_type):
            return False

        # 消耗资源
        costs = self.building_costs.get(building_type, {})
        for resource_type, amount in costs.items():
            if not self.consume_resource(resource_type, amount):
                return False

        # 创建建筑
        building = BuildingData(
            type=building_type,
            position=position,
            is_built=True
        )
        self._setup_building_properties(building)
        self.buildings.append(building)

        print(f"建造建筑 {building_type.value} 在位置 {position}")
        return True

    def _setup_building_properties(self, building: BuildingData):
        """设置建筑属性"""
        if building.type == BuildingType.TREASURY:
            building.health = 500
            building.max_health = 500
            building.storage_capacity[ResourceType.GOLD] = 10000
        elif building.type == BuildingType.DEMON_LAIR:
            building.health = 800
            building.max_health = 800
            building.production_rates[ResourceType.FOOD] = 1.0
        elif building.type == BuildingType.ORC_LAIR:
            building.health = 600
            building.max_health = 600
            building.production_rates[ResourceType.FOOD] = 0.5
        elif building.type == BuildingType.ARCANE_TOWER:
            building.health = 400
            building.max_health = 400
        elif building.type == BuildingType.ARROW_TOWER:
            building.health = 300
            building.max_health = 300

    def summon_character(self, character_type: CharacterType, position: Vector3) -> bool:
        """召唤角色"""
        if not self.can_afford_character(character_type):
            return False

        # 消耗资源
        costs = self.character_costs.get(character_type, {})
        for resource_type, amount in costs.items():
            if not self.consume_resource(resource_type, amount):
                return False

        # 创建角色
        character = CharacterData(
            type=character_type,
            position=position
        )
        self._setup_character_properties(character)
        self.characters.append(character)

        # 更新生物数量
        self.add_resource(ResourceType.CREATURES, 1)

        print(f"召唤角色 {character_type.value} 在位置 {position}")
        return True

    def _setup_character_properties(self, character: CharacterData):
        """设置角色属性"""
        if character.type == CharacterType.GOBLIN_ENGINEER:
            character.health = 80
            character.max_health = 80
            character.speed = 3.0
            character.attack_damage = 15
            character.defense = 5
        elif character.type == CharacterType.GOBLIN_WORKER:
            character.health = 60
            character.max_health = 60
            character.speed = 2.5
            character.attack_damage = 10
            character.defense = 3
        elif character.type == CharacterType.ORC_WARRIOR:
            character.health = 120
            character.max_health = 120
            character.speed = 2.0
            character.attack_damage = 25
            character.defense = 8
        elif character.type == CharacterType.IMP:
            character.health = 40
            character.max_health = 40
            character.speed = 4.0
            character.attack_damage = 12
            character.defense = 2

    def get_game_state(self) -> Dict[str, Any]:
        """获取游戏状态"""
        return {
            "game_time": self.game_time,
            "resources": {rt.value: rd.amount for rt, rd in self.resources.items()},
            "buildings_count": len(self.buildings),
            "characters_count": len(self.characters)
        }

    def save_game(self, filename: str):
        """保存游戏"""
        game_data = {
            "game_time": self.game_time,
            "resources": {rt.value: rd.amount for rt, rd in self.resources.items()},
            "buildings": [
                {
                    "type": b.type.value,
                    "position": {"x": b.position.x, "y": b.position.y, "z": b.position.z},
                    "health": b.health,
                    "is_built": b.is_built
                }
                for b in self.buildings
            ],
            "characters": [
                {
                    "type": c.type.value,
                    "position": {"x": c.position.x, "y": c.position.y, "z": c.position.z},
                    "health": c.health,
                    "is_alive": c.is_alive
                }
                for c in self.characters
            ]
        }

        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(game_data, f, indent=2, ensure_ascii=False)

        print(f"游戏保存到: {filename}")

    def load_game(self, filename: str):
        """加载游戏"""
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                game_data = json.load(f)

            # 恢复游戏状态
            self.game_time = game_data.get("game_time", 0.0)

            # 恢复资源
            resources_data = game_data.get("resources", {})
            for rt_name, amount in resources_data.items():
                try:
                    resource_type = ResourceType(rt_name)
                    if resource_type not in self.resources:
                        self.resources[resource_type] = ResourceData(
                            resource_type)
                    self.resources[resource_type].amount = amount
                except ValueError:
                    print(f"未知资源类型: {rt_name}")

            print(f"游戏从 {filename} 加载完成")

        except FileNotFoundError:
            print(f"存档文件不存在: {filename}")
        except json.JSONDecodeError:
            print(f"存档文件格式错误: {filename}")
        except Exception as e:
            print(f"加载游戏时发生错误: {e}")


# 全局游戏逻辑实例
game_logic = GameLogic()


def initialize():
    """初始化游戏逻辑"""
    game_logic.initialize()


def update(delta: float):
    """更新游戏逻辑"""
    game_logic.update(delta)


def get_game_state() -> Dict[str, Any]:
    """获取游戏状态"""
    return game_logic.get_game_state()


def build_building(building_type: str, x: float, y: float, z: float) -> bool:
    """建造建筑"""
    try:
        bt = BuildingType(building_type)
        position = Vector3(x, y, z)
        return game_logic.build_building(bt, position)
    except ValueError:
        print(f"未知建筑类型: {building_type}")
        return False


def summon_character(character_type: str, x: float, y: float, z: float) -> bool:
    """召唤角色"""
    try:
        ct = CharacterType(character_type)
        position = Vector3(x, y, z)
        return game_logic.summon_character(ct, position)
    except ValueError:
        print(f"未知角色类型: {character_type}")
        return False


def get_resource(resource_type: str) -> int:
    """获取资源数量"""
    try:
        rt = ResourceType(resource_type)
        return game_logic.get_resource(rt)
    except ValueError:
        print(f"未知资源类型: {resource_type}")
        return 0


def save_game(filename: str):
    """保存游戏"""
    game_logic.save_game(filename)


def load_game(filename: str):
    """加载游戏"""
    game_logic.load_game(filename)

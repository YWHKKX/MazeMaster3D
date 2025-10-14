extends MonsterBase
class_name StoneGolem

## 石魔像 - 无敌坦克，最高防御力
## 战斗等级: ⭐⭐⭐⭐⭐
## [已迁移] 从旧的 Monster 基类迁移到新的 MonsterBase

func _ready() -> void:
	super._ready()
	if not character_data:
		_init_stone_golem_data()
	is_combat_unit = true
	add_to_group(GameGroups.MONSTERS)
	add_to_group("stone_golems")

func _init_stone_golem_data() -> void:
	var data = CharacterData.new()
	data.character_name = "石魔像"
	data.creature_type = Enums.CreatureType.STONE_GOLEM
	data.max_health = 4500
	data.attack = 45
	data.armor = 25
	data.speed = 30
	data.size = 28 # 巨型单位
	data.attack_range = 4.0
	data.attack_cooldown = 2.5
	data.detection_range = Constants.SEARCH_RANGE_STONE_GOLEM
	data.cost_gold = GameBalance.STONE_GOLEM_COST
	data.upkeep = GameBalance.STONE_GOLEM_UPKEEP
	character_data = data
	_init_from_character_data()

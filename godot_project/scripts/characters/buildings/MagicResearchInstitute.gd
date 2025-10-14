extends Building
class_name MagicResearchInstitute

## 🔮 魔法研究院
## 提供魔法研究和法术开发功能

# 研究属性
var research_slots: int = 2 # 同时研究项目数
var research_speed_multiplier: float = 1.5 # 研究速度倍率
var mana_generation_rate: float = 0.3 # 法力生成速度（每秒）
var spell_power_bonus: float = 0.20 # 法术威力加成（20%）

# 研究状态
var current_research: Array = [] # 当前研究项目
var completed_research: Array = [] # 已完成研究

func _init():
	super._init()
	
	# 基础属性
	building_name = "魔法研究院"
	building_type = BuildingTypes.MAGIC_RESEARCH_INSTITUTE
	
	# 建筑属性
	max_health = 350
	health = max_health
	armor = 6
	
	# 1x1 建筑
	building_size = Vector2(1, 1)
	
	# 建造属性
	cost_gold = 600
	engineer_cost = 300 # 工程师建造成本（建筑成本的一半）
	build_time = 240.0
	engineer_required = 2
	
	# 魔法研究院已创建

func _ready():
	super._ready()
	
	# 🔧 [模型系统] 加载魔法研究院3D模型
	_load_building_model()
	
	_setup_research_system()
	# 魔法研究院就绪

func _load_building_model():
	"""加载魔法研究院3D模型"""
	var MagicResearchInstituteModelScene = preload("res://img/scenes/buildings/magic_research_institute_base.tscn")
	var model = MagicResearchInstituteModelScene.instantiate()
	model.name = "Model"
	add_child(model)
	
	LogManager.info("🔮 魔法研究院模型已加载")

func _setup_research_system():
	"""设置研究系统"""
	# 获取资源管理器引用
	if GameServices.resource_manager:
		resource_manager = GameServices.resource_manager
		# 已连接到ResourceManager
	else:
		# 未找到ResourceManager
		pass

func _process(delta):
	# 只有完成状态才生成法力
	if status == BuildingStatus.COMPLETED:
		_generate_mana(delta)
		_process_research(delta)

func _generate_mana(delta: float):
	"""生成法力值"""
	if resource_manager and resource_manager.has_method("add_mana"):
		var mana_generated = mana_generation_rate * delta
		resource_manager.add_mana(mana_generated)

func _process_research(delta: float):
	"""处理研究进度"""
	for research in current_research:
		if resource_manager and resource_manager.has_method("can_spend_mana"):
			var mana_cost = research.mana_per_second * delta
			if resource_manager.can_spend_mana(mana_cost):
				resource_manager.spend_mana(mana_cost)
				research.progress += delta * research_speed_multiplier
				
				# 研究完成
				if research.progress >= research.required_time:
					_complete_research(research)

func _complete_research(research):
	"""完成研究"""
	current_research.erase(research)
	completed_research.append(research)
	# 研究完成

func start_research(research_name: String, required_time: float, mana_per_second: float) -> bool:
	"""开始新的研究项目"""
	if current_research.size() >= research_slots:
		# 研究槽位已满
		return false
	
	var research = {
		"name": research_name,
		"progress": 0.0,
		"required_time": required_time,
		"mana_per_second": mana_per_second
	}
	
	current_research.append(research)
	# 开始研究
	return true

func get_spell_power_bonus() -> float:
	"""获取法术威力加成"""
	return spell_power_bonus if status == BuildingStatus.COMPLETED else 0.0

func _get_status_name() -> String:
	match status:
		BuildingStatus.PLANNING: return "规划中"
		BuildingStatus.UNDER_CONSTRUCTION: return "建造中"
		BuildingStatus.COMPLETED: return "已完成"
		BuildingStatus.DAMAGED: return "受损"
		BuildingStatus.DESTROYED: return "被摧毁"
		_: return "未知"

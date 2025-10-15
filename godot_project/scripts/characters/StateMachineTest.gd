extends Node
class_name StateMachineTest

## 状态机系统测试脚本
## 
## 用于测试三个阵营的状态机系统是否正常工作

## ============================================================================
## 测试配置
## ============================================================================

@export var test_beasts: bool = true
@export var test_heroes: bool = true
@export var test_monsters: bool = true
@export var test_count: int = 3

## ============================================================================
## 测试方法
## ============================================================================

func _ready() -> void:
	# 延迟执行测试，确保所有系统初始化完成
	call_deferred("run_tests")

func run_tests() -> void:
	"""运行所有测试"""
	print("=== 状态机系统测试开始 ===")
	
	if test_beasts:
		test_beast_state_machine()
	
	if test_heroes:
		test_hero_state_machine()
	
	if test_monsters:
		test_monster_state_machine()
	
	# 等待一段时间后打印统计信息
	await get_tree().create_timer(2.0).timeout
	print_state_machine_stats()
	
	print("=== 状态机系统测试完成 ===")

func test_beast_state_machine() -> void:
	"""测试野兽状态机"""
	print("\n--- 测试野兽状态机 ---")
	
	for i in range(test_count):
		var beast = BeastBase.new()
		beast.name = "TestBeast_%d" % i
		beast.debug_mode = true
		beast.global_position = Vector3(i * 5, 0, 0)
		
		# 添加到场景
		get_tree().current_scene.add_child(beast)
		
		# 验证状态机是否正确创建
		if beast.state_machine:
			print("✅ 野兽 %s 状态机创建成功" % beast.name)
			print("   状态机子节点: %s" % beast.state_machine.get_children().map(func(child): return child.name))
		else:
			print("❌ 野兽 %s 状态机创建失败" % beast.name)

func test_hero_state_machine() -> void:
	"""测试英雄状态机"""
	print("\n--- 测试英雄状态机 ---")
	
	for i in range(test_count):
		var hero = HeroBase.new()
		hero.name = "TestHero_%d" % i
		hero.debug_mode = true
		hero.global_position = Vector3(i * 5, 0, 5)
		
		# 添加到场景
		get_tree().current_scene.add_child(hero)
		
		# 验证状态机是否正确创建
		if hero.state_machine:
			print("✅ 英雄 %s 状态机创建成功" % hero.name)
			print("   状态机子节点: %s" % hero.state_machine.get_children().map(func(child): return child.name))
		else:
			print("❌ 英雄 %s 状态机创建失败" % hero.name)

func test_monster_state_machine() -> void:
	"""测试怪物状态机"""
	print("\n--- 测试怪物状态机 ---")
	
	for i in range(test_count):
		var monster = MonsterBase.new()
		monster.name = "TestMonster_%d" % i
		monster.debug_mode = true
		monster.global_position = Vector3(i * 5, 0, 10)
		
		# 添加到场景
		get_tree().current_scene.add_child(monster)
		
		# 验证状态机是否正确创建
		if monster.state_machine:
			print("✅ 怪物 %s 状态机创建成功" % monster.name)
			print("   状态机子节点: %s" % monster.state_machine.get_children().map(func(child): return child.name))
		else:
			print("❌ 怪物 %s 状态机创建失败" % monster.name)

func print_state_machine_stats() -> void:
	"""打印状态机统计信息"""
	print("\n--- 状态机统计信息 ---")
	StateManager.get_instance().print_state_machine_stats()

## ============================================================================
## 手动测试方法
## ============================================================================

func test_faction_relationships() -> void:
	"""测试阵营关系"""
	print("\n--- 测试阵营关系 ---")
	
	var beast = BeastBase.new()
	var hero = HeroBase.new()
	var monster = MonsterBase.new()
	
	# 测试野兽与其他阵营的关系
	print("野兽 vs 英雄: %s" % ("中立" if beast.is_neutral_to(hero) else "敌对"))
	print("野兽 vs 怪物: %s" % ("中立" if beast.is_neutral_to(monster) else "敌对"))
	
	# 测试英雄与怪物的关系
	print("英雄 vs 怪物: %s" % ("敌对" if hero.is_enemy_of(monster) else "友方"))
	
	# 清理测试对象
	beast.queue_free()
	hero.queue_free()
	monster.queue_free()

func test_state_transitions() -> void:
	"""测试状态转换"""
	print("\n--- 测试状态转换 ---")
	
	var beast = BeastBase.new()
	beast.debug_mode = true
	get_tree().current_scene.add_child(beast)
	
	# 等待状态机运行一段时间
	await get_tree().create_timer(5.0).timeout
	
	print("野兽当前状态: %s" % beast.state_machine.current_state.name if beast.state_machine else "无状态机")
	
	# 清理测试对象
	beast.queue_free()

## ============================================================================
## 输入处理
## ============================================================================

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		run_tests()
	elif event.is_action_pressed("test_factions"):
		test_faction_relationships()
	elif event.is_action_pressed("test_transitions"):
		test_state_transitions()

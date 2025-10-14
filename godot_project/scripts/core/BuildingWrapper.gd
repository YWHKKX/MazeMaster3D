extends Node3D
class_name BuildingWrapper

## 建筑包装器脚本
## 
## 用于包装 RefCounted 对象（如金矿）使其能够作为建筑使用
## 提供 get_building_size() 方法以适配 BuildingFinder API

func get_building_size() -> Vector2:
	"""获取建筑大小
	
	Returns:
		Vector2: 建筑大小（格子数）
	"""
	if has_meta("building_size"):
		return get_meta("building_size")
	else:
		return Vector2(1, 1) # 默认1x1

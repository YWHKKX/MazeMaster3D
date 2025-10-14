# MazeMaster3D

一个基于 Godot 4.x 的 3D 地下城建造RTS游戏

---

## 🎮 项目简介

从 Python/Pygame 版本迁移到 Godot 3D，具有：
- 🏰 地下城建造系统
- ⚛️ RTS即时战略玩法
- 🎯 完整的单位和建筑系统
- 🤖 智能AI行为（基于状态机）
- ⚔️ 完整战斗系统（物理、特效、动画）

---

## ✅ 开发状态

**阶段1（基础架构）**：✅ 100%  
**阶段2（移动系统优化）**：✅ 100%  
**阶段3（金矿包装器修复）**：✅ 100%
- 常量系统 ✅
- 状态机框架 ✅
- 角色基类 ✅
- 所有单位迁移 ✅
- 统一移动API ✅
- 建筑寻路优化 ✅
- 金矿包装器系统修复 ✅

**阶段4（核心系统）**：✅ 100%
- CharacterManager重构 ✅
- CombatManager重构 ✅
- 完整物理系统 ✅
- 特效管理系统 ✅
- 投射物系统 ✅
- 动画控制器 ✅

---

## 🎯 新增系统

### 移动系统优化 (v4.0)
- ✅ 统一移动API（MovementHelper.process_navigation）
- ✅ 建筑寻路优化（BuildingFinder.get_walkable_position_near_building）
- ✅ 金矿包装器系统修复（解决RefCounted对象位置设置问题）
- ✅ 动态避障系统（分层避障，全局路径+局部避障）
- ✅ 路径缓存系统（LRU策略，5秒过期）

### 物理系统
- ✅ 射线检测地面悬浮（贴合地形起伏）
- ✅ 完整击退效果（velocity + 衰减）
- ✅ 碰撞层级管理

### 战斗系统
- ✅ 16种攻击类型（近战/远程/魔法）
- ✅ 投射物系统（箭矢/火球/子弹）
- ✅ 特效对象池（VFXPool + VFXManager）
- ✅ 动画控制器（AnimationController）

### 文件结构
```
godot_project/
├── scripts/
│   ├── effects/          # 特效系统
│   │   ├── VFXPool.gd
│   │   └── VFXManager.gd
│   ├── combat/           # 战斗系统
│   │   ├── Projectile.gd
│   │   ├── ProjectileManager.gd
│   │   └── AnimationController.gd
│   └── ...
└── scenes/
    └── projectiles/      # 投射物场景
        ├── Arrow.tscn
        ├── Fireball.tscn
        └── Bullet.tscn
```

---

## 🔧 使用指南

### 远程攻击示例
```gdscript
# 在角色中执行远程攻击
func attack_target(target: CharacterBase):
    execute_ranged_attack(target, projectile_manager)
```

### 应用击退效果
```gdscript
# 击退目标
target.apply_knockback(direction, 20.0)
```

### 播放特效
```gdscript
# 通过VFXManager播放特效
vfx_manager.play_hit_effect(position, Enums.AttackType.MELEE_SWORD)
```

---

## 📚 文档

- `scripts/core/state_machine/README.md` - 状态机指南
- `scripts/characters/README.md` - 角色系统指南
- `文档/物理系统.md` - 物理系统设计
- `文档/战斗系统.md` - 战斗系统设计

---

## 🚀 技术特性

- **状态机驱动AI**：14个状态类，完全模块化
- **场景实例化**：使用.tscn场景文件
- **组系统查询**：高效的单位管理
- **对象池优化**：特效和投射物池化
- **物理真实感**：地面悬浮 + 击退效果
- **数据驱动**：Resource配置，易于调整

---

**版本**：3.0  
**引擎**：Godot 4.2+  
**语言**：GDScript  
**质量**：⭐⭐⭐⭐⭐

**MazeMaster3D - 完整功能实现，准备开发！** 🎉

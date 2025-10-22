#!/usr/bin/env python3
"""
组件更新工具
批量更新所有组件文件，为每个组件设计独特的图形和材质
"""

import os
import re
from pathlib import Path

# 组件配置
COMPONENT_CONFIGS = {
    # 基础构件
    "Floor_Stone": {
        "id": 1,
        "type": "floor",
        "material": "stone",
        "size": (0.33, 0.05, 0.33),
        "color": (0.6, 0.6, 0.6),
        "roughness": 0.8,
        "metallic": 0.1,
        "uv_scale": (2, 2)
    },
    "Floor_Wood": {
        "id": 2,
        "type": "floor",
        "material": "wood",
        "size": (0.33, 0.05, 0.33),
        "color": (0.6, 0.4, 0.2),
        "roughness": 0.6,
        "metallic": 0.0,
        "uv_scale": (2, 2)
    },
    "Floor_Metal": {
        "id": 3,
        "type": "floor",
        "material": "metal",
        "size": (0.33, 0.05, 0.33),
        "color": (0.7, 0.7, 0.8),
        "roughness": 0.2,
        "metallic": 0.9,
        "uv_scale": (1.5, 1.5)
    },
    "Wall_Stone": {
        "id": 4,
        "type": "wall",
        "material": "stone",
        "size": (0.33, 0.33, 0.05),
        "color": (0.6, 0.6, 0.6),
        "roughness": 0.8,
        "metallic": 0.1,
        "uv_scale": (1.5, 2)
    },
    "Wall_Wood": {
        "id": 5,
        "type": "wall",
        "material": "wood",
        "size": (0.33, 0.33, 0.05),
        "color": (0.6, 0.4, 0.2),
        "roughness": 0.6,
        "metallic": 0.0,
        "uv_scale": (2, 2)
    },
    "Wall_Metal": {
        "id": 6,
        "type": "wall",
        "material": "metal",
        "size": (0.33, 0.33, 0.05),
        "color": (0.7, 0.7, 0.8),
        "roughness": 0.2,
        "metallic": 0.9,
        "uv_scale": (1.5, 1.5)
    },
    "Door_Wood": {
        "id": 7,
        "type": "door",
        "material": "wood",
        "size": (0.33, 0.33, 0.05),
        "color": (0.6, 0.4, 0.2),
        "roughness": 0.5,
        "metallic": 0.1,
        "uv_scale": (1, 2)
    },
    "Door_Metal": {
        "id": 8,
        "type": "door",
        "material": "metal",
        "size": (0.33, 0.33, 0.05),
        "color": (0.7, 0.7, 0.8),
        "roughness": 0.3,
        "metallic": 0.8,
        "uv_scale": (1, 2)
    },
    "Window_Small": {
        "id": 9,
        "type": "window",
        "material": "glass",
        "size": (0.33, 0.33, 0.05),
        "color": (0.8, 0.9, 1.0, 0.3),
        "roughness": 0.0,
        "metallic": 0.0,
        "transparency": True,
        "uv_scale": (1, 1)
    },
    "Window_Large": {
        "id": 10,
        "type": "window",
        "material": "glass",
        "size": (0.33, 0.33, 0.05),
        "color": (0.8, 0.9, 1.0, 0.3),
        "roughness": 0.0,
        "metallic": 0.0,
        "transparency": True,
        "uv_scale": (1, 1)
    },
    # 魔法构件
    "Magic_Crystal": {
        "id": 30,
        "type": "decoration",
        "material": "magic",
        "size": (0.2, 0.3, 0.2),
        "color": (0.3, 0.1, 0.8, 0.8),
        "roughness": 0.1,
        "metallic": 0.0,
        "emission": (0.2, 0.1, 0.6),
        "emission_energy": 1.0,
        "transparency": True,
        "uv_scale": (1, 1)
    },
    "Magic_Altar": {
        "id": 31,
        "type": "decoration",
        "material": "stone",
        "size": (0.3, 0.2, 0.3),
        "color": (0.4, 0.2, 0.6),
        "roughness": 0.3,
        "metallic": 0.1,
        "emission": (0.1, 0.05, 0.3),
        "emission_energy": 0.3,
        "uv_scale": (1, 1)
    },
    "Energy_Rune": {
        "id": 32,
        "type": "decoration",
        "material": "magic",
        "size": (0.3, 0.05, 0.3),
        "color": (0.8, 0.8, 0.2),
        "roughness": 0.0,
        "metallic": 0.0,
        "emission": (0.6, 0.6, 0.1),
        "emission_energy": 0.8,
        "uv_scale": (1, 1)
    },
    "Summoning_Circle": {
        "id": 33,
        "type": "decoration",
        "material": "magic",
        "size": (0.3, 0.05, 0.3),
        "color": (0.6, 0.1, 0.1),
        "roughness": 0.0,
        "metallic": 0.0,
        "emission": (0.4, 0.05, 0.05),
        "emission_energy": 0.6,
        "uv_scale": (1, 1)
    },
    "Mana_Pool": {
        "id": 34,
        "type": "decoration",
        "material": "magic",
        "size": (0.3, 0.1, 0.3),
        "color": (0.1, 0.3, 0.8),
        "roughness": 0.0,
        "metallic": 0.0,
        "emission": (0.05, 0.2, 0.6),
        "emission_energy": 0.7,
        "uv_scale": (1, 1)
    },
    # 装饰构件
    "Chandelier": {
        "id": 35,
        "type": "decoration",
        "material": "metal",
        "size": (0.2, 0.3, 0.2),
        "color": (0.8, 0.7, 0.4),
        "roughness": 0.2,
        "metallic": 0.8,
        "emission": (1.0, 0.9, 0.7),
        "emission_energy": 1.2,
        "uv_scale": (1, 1)
    },
    "Fountain": {
        "id": 36,
        "type": "decoration",
        "material": "stone",
        "size": (0.3, 0.4, 0.3),
        "color": (0.7, 0.7, 0.8),
        "roughness": 0.4,
        "metallic": 0.1,
        "uv_scale": (1, 1)
    },
    "Statue_Stone": {
        "id": 37,
        "type": "decoration",
        "material": "stone",
        "size": (0.2, 0.5, 0.2),
        "color": (0.8, 0.8, 0.9),
        "roughness": 0.3,
        "metallic": 0.0,
        "uv_scale": (1, 1)
    },
    "Banner_Cloth": {
        "id": 38,
        "type": "decoration",
        "material": "fabric",
        "size": (0.1, 0.4, 0.3),
        "color": (0.8, 0.2, 0.2),
        "roughness": 0.9,
        "metallic": 0.0,
        "uv_scale": (3, 3)
    },
    "Ornament": {
        "id": 39,
        "type": "decoration",
        "material": "decorative",
        "size": (0.15, 0.15, 0.15),
        "color": (0.9, 0.7, 0.3),
        "roughness": 0.5,
        "metallic": 0.3,
        "uv_scale": (1.5, 1.5)
    }
}


def generate_component_tscn(component_name, config):
    """生成组件.tscn文件内容"""
    size = config["size"]
    color = config["color"]
    roughness = config["roughness"]
    metallic = config["metallic"]
    uv_scale = config["uv_scale"]

    # 处理颜色透明度
    if len(color) == 4:
        color_str = f"Color({color[0]}, {color[1]}, {color[2]}, {color[3]})"
        has_transparency = True
    else:
        color_str = f"Color({color[0]}, {color[1]}, {color[2]}, 1.0)"
        has_transparency = False

    # 生成UID
    import random
    uid = f"uid://{random.randint(100000, 999999)}"

    content = f"""[gd_scene load_steps=4 format=3 uid="{uid}"]

[ext_resource type="Script" path="res://scripts/characters/buildings/components/BuildingComponent.gd" id="1_8x7y2"]

[sub_resource type="BoxMesh" id="BoxMesh_1"]
size = Vector3({size[0]}, {size[1]}, {size[2]})

[sub_resource type="StandardMaterial3D" id="StandardMaterial3D_1"]
albedo_color = {color_str}
roughness = {roughness}
metallic = {metallic}"""

    # 添加特殊属性
    if "emission" in config:
        emission = config["emission"]
        emission_energy = config.get("emission_energy", 1.0)
        content += f"""
emission_enabled = true
emission = Color({emission[0]}, {emission[1]}, {emission[2]})
emission_energy = {emission_energy}"""

    if has_transparency or config.get("transparency", False):
        content += f"""
transparency = BaseMaterial3D.TRANSPARENCY_ALPHA"""

    content += f"""
uv1_scale = Vector2({uv_scale[0]}, {uv_scale[1]})

[node name="{component_name}" type="MeshInstance3D"]
script = ExtResource("1_8x7y2")
component_type = "{config['type']}"
component_material = "{config['material']}"
component_id = {config['id']}
mesh = SubResource("BoxMesh_1")
surface_material_override/0 = SubResource("StandardMaterial3D_1")
"""

    return content


def update_component_file(file_path, component_name):
    """更新组件文件"""
    if component_name not in COMPONENT_CONFIGS:
        print(f"WARNING: 未找到组件配置: {component_name}")
        return False

    config = COMPONENT_CONFIGS[component_name]
    content = generate_component_tscn(component_name, config)

    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"SUCCESS: 更新组件: {component_name}")
        return True
    except Exception as e:
        print(f"ERROR: 更新失败 {component_name}: {e}")
        return False


def main():
    """主函数"""
    components_dir = Path("scenes/buildings/components")

    if not components_dir.exists():
        print(f"ERROR: 组件目录不存在: {components_dir}")
        return

    updated_count = 0
    total_count = 0

    for tscn_file in components_dir.glob("*.tscn"):
        component_name = tscn_file.stem
        total_count += 1

        if update_component_file(tscn_file, component_name):
            updated_count += 1

    print(f"\nSUCCESS: 组件更新完成: {updated_count}/{total_count}")


if __name__ == "__main__":
    main()

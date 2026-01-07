@tool
class_name Soil extends Resource

## 土壌の名前
@export var name: StringName
## 栄養を蓄えられる量
@export var capacity: NutrientAmount
## タイル作成に必要な栄養消費量
@export var cost: NutrientAmount
## 衝突判定を持つかどうか、Navigationの更新をトリガーするための一時的な対応
@export var has_collision: bool = false

@export_group("Sounds")
@export var building_sound: AudioStream

## 土壌変化を試みる
func _to_string() -> String:
	if resource_name != name:
		resource_name = _make_string()
	return resource_name

func _make_string() -> String:
	return name


static func from_tiledata(td: TileData) -> Soil:
	return td.get_custom_data_by_layer_id(0) as Soil

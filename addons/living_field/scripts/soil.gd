@tool
class_name Soil extends Resource

@export var name: StringName
@export var cost: NutrientStorageConfig
@export var has_collision: bool = false

## 土壌変化を試みる
func _to_string() -> String:
	if resource_name != name:
		resource_name = _make_string()
	return resource_name

func _make_string() -> String:
	return name


static func from_tiledata(td: TileData) -> Soil:
	return td.get_custom_data_by_layer_id(0) as Soil

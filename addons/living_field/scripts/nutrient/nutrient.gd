@tool
class_name Nutrient extends Resource

signal quantity_changed(val: float)

@export var stats: NutrientStats
@export var amount: float = 0:
	get: return amount
	set(v): 
		amount = v
		_update_resource_name()
		quantity_changed.emit(v)

func _to_string() -> String:
	return resource_name

func _make_string() -> String:
	if stats == null:
		return "invalid nutrient(%d)" % [amount]
	return "%s(%d)" % [stats.name, amount]

func _update_resource_name() -> void:
	if not Engine.is_editor_hint():
		return
	resource_name = _make_string()
	notify_property_list_changed()
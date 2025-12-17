@tool
class_name Nutrient extends Resource

signal quantity_changed(val: float)

@export var stats: NutrientStats
@export var amount: float = 0:
	get: return amount
	set(v): 
		amount = v
		quantity_changed.emit(v)

func _to_string() -> String:
	resource_name = _make_string()
	return resource_name

func _make_string() -> String:
	if stats == null:
		return "invalid stats: %d" % [amount]
	return "%s: %d" % [stats.name, amount]
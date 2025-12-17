@tool
class_name NutrientStats extends Resource

@export var name: StringName = "?":
	set(v): 
		name = v
		resource_name = _make_string()

@export var full_name: StringName = "unknown"

func _to_string() -> String:
	resource_name = _make_string()
	return resource_name

func _make_string() -> String:
	return name
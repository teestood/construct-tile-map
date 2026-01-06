@tool
class_name NutrientStats extends Resource

@export var name: StringName = "?":
	set(v): 
		name = v
		resource_name = _make_string()

@export var full_name: StringName = "unknown"
@export var color: Color = Color.WHITE

func _to_string() -> String:
	if Engine.is_editor_hint():
		set_deferred("resource_name", _make_string())
	return resource_name

func _make_string() -> String:
	return name
@tool
class_name ResetConstructPlan extends ConstructPlan

@export_tool_button("CopyConstruct", "Callable")
@warning_ignore("unused_private_class_variable")
var _copy_construct_action = copy_construct

func _ready() -> void:
	if Engine.is_editor_hint():
		self_modulate = Color(1, 1, 1, 1.)
		collision_enabled = false
		navigation_enabled = false
		return
	self_modulate = Color(1, 1, 1, 0.2)

func copy_construct():
	if ground == null:
		push_warning("ground is null")
		return
	tile_map_data = ground.tile_map_data
	var cells = get_used_cells()

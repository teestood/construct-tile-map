@tool
class_name ResetTileMapPlan extends ConstructTileMapPlan

@export_tool_button("CopyConstruct", "Callable")
@warning_ignore("unused_private_class_variable")
var _copy_construct_action = copy_construct

func copy_construct():
	if ground == null:
		push_warning("ground is null")
		return
	tile_map_data = ground.tile_map_data
	var cells = get_used_cells()

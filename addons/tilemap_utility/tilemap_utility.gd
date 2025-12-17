@tool
extends EditorPlugin

var plugin

func _enter_tree() -> void:
	plugin = preload("res://addons/tilemap_utility/terrain_template.gd").new()
	add_inspector_plugin(plugin)


func _exit_tree() -> void:
	if is_instance_valid(plugin):
		remove_inspector_plugin(plugin)
	else:
		printerr("TileMapUtility plugin inspector is invalid on removing")
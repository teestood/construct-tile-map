@tool
extends EditorPlugin

var plugin

func _enter_tree() -> void:
	pass
	#plugin = preload("res://addons/living_field/field_template.gd").new()
	#add_inspector_plugin(plugin)


func _exit_tree() -> void:
	pass
	#if is_instance_valid(plugin):
	#	remove_inspector_plugin(plugin)
	#else:
	#	printerr("LivingField plugin inspector is invalid on removing")
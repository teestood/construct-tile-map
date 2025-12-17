@tool
class_name FieldEditorSetting extends Resource

signal view_type_changed

enum ViewType{
	NONE,
	CONSTRUCT_WITH_GHOST_PLAN,
	ONLY_PLAN,
	ONLY_CONSTRUCT,
}

@export_tool_button("refresh", "Callable")
var _refresh_action = _refresh

@export var view_type: ViewType = ViewType.CONSTRUCT_WITH_GHOST_PLAN:
	set(vt):
		view_type = vt
		view_type_changed.emit()

@export var ghost_color: Color = Color8(255, 255, 255, 80)

func _refresh():
	view_type_changed.emit()

func apply(field: Fields):
	pass
	#kview_type_changed.connect(apply_view_type.bind(field))

func remove(field: Fields):
	pass
	#view_type_changed.disconnect(apply_view_type.bind(field))

#func apply_view_type(field: Fields):
#	for plan in field.plans:
#		match view_type:
#			ViewType.CONSTRUCT_WITH_GHOST_PLAN:
#				plan.self_modulate = ghost_color
#				plan.instance.self_modulate = Color.WHITE
#			ViewType.ONLY_PLAN:
#				plan.self_modulate = Color.WHITE
#				plan.instance.self_modulate = Color.TRANSPARENT
#			ViewType.ONLY_CONSTRUCT:
#				plan.self_modulate = Color.TRANSPARENT
#				plan.instance.self_modulate = Color.WHITE
#

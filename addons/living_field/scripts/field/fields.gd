@tool
class_name Fields extends Node2D

@export var editor_setting: FieldEditorSetting
@export var setting: FieldSetting

@export var field_enviroment: FieldEnviroment

@onready var plans_container: Node2D = %Plans

var _is_instance_updated = true
signal instance_updated()

func _ready() -> void:
	if Engine.is_editor_hint():
		if editor_setting != null:
			editor_setting.apply(self)
		return
	for child in get_children():
		if child is GroundField:
			var ground := child as GroundField
			ground.collision_updated.connect(set.bind(&"_is_instance_updated", true), CONNECT_DEFERRED)
	
	reset()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _is_instance_updated:
		instance_updated.emit()
		_is_instance_updated = false


func reset():
	pass

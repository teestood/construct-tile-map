@tool
class_name Fields extends Node2D

@export var editor_setting: FieldEditorSetting
@export var setting: FieldSetting

@export var field_enviroment: FieldEnviroment

var _is_instance_updated = false
signal instance_updated()

var plans: Array[ConstructTileMapPlan] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		if editor_setting != null:
			editor_setting.apply(self)
		return
	for child in get_children():
		if child is ConstructTileMapPlan:
			var plan := child as ConstructTileMapPlan
			plans.append(child)
			setting.initialize(plan)

			plan.instance_updated.connect(set.bind(&"_is_instance_updated", true))
	
	reset()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _is_instance_updated:
		instance_updated.emit()
		_is_instance_updated = false


func reset():
	pass

func try_construct_at(pos: Vector2i):
	for plan in plans:
		var coords = plan.local_to_map(pos)

		var tile = plan.apply_to_instance(coords)
		if tile == null:
			break # フィールド外
		
		if not plan.is_planned_tile(coords):
			# 完全に計画タイル化していなければ土台として不完全なので建築を終了
			break

func try_construct_at_cursor():
	try_construct_at(get_local_mouse_position())


func global_to_map(plan: ConstructTileMapPlan, gpos: Vector2) -> Vector2i:
	return plan.local_to_map(plan.to_local(gpos))

func clear():
	for plan in plans:
		plan.clear_instance()

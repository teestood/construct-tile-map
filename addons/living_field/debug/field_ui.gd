@tool
class_name FieldUI extends PanelContainer

@export_tool_button("Refresh", "Callable")
@warning_ignore("unused_private_class_variable")
var _refresh_action = _refresh

@export var target_field: GroundField

@onready var ui_nutrients: VBoxContainer = %Nutrients
@onready var ui_soils: VBoxContainer = %Soils
@onready var ui_speed: Label = %Speed

var _soil_dicts: Dictionary[StringName, Label] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if target_field == null:
		queue_free()
		return
	if not target_field.is_node_ready():
		await target_field.ready
	_refresh()


func _refresh():
	ui_speed.text = str(1. / target_field.challenge_rate)
	_clear_children(ui_nutrients)

	var nutrients = target_field.capacity.nutrients
	for key in nutrients.keys():
		var nut = nutrients[key]
		var ui_line = UINutrientLine.instantiate(nut, target_field.get_reserve(nut.stats.name))
		ui_nutrients.add_child(ui_line)

		if Engine.is_editor_hint():
			_fill_owner(ui_line, get_tree().edited_scene_root)

		ui_line.name = nut.stats.name
	
	_soil_dicts = {}
	_clear_children(ui_soils)
	target_field.recalc_soils()
	var soils = target_field.cells_by_soil
	for key in soils.keys():
		var ui_soilline = UISoilLine.instantiate(key, len(soils[key]))
		ui_soils.add_child(ui_soilline)
		_soil_dicts[key] = ui_soilline.get_node_or_null("Length")
		if Engine.is_editor_hint():
			_fill_owner(ui_soilline, get_tree().edited_scene_root)

	if not Engine.is_editor_hint():
		target_field.soils_changed.connect(_on_GroundField_soils_changed)
		
		target_field.capacity.nutrient_added.connect(func(key):
			var ui_line = UINutrientLine.instantiate(target_field.get_nutrient(key), target_field.get_reserve(key))
			ui_nutrients.add_child(ui_line)
			ui_line.name = key 
		)
		
		target_field.capacity.nutrient_changed.connect(_on_Nutrient_changed.bind(false))
		target_field.storage.nutrient_changed.connect(_on_Nutrient_changed.bind(true))

func _on_Nutrient_changed(key: StringName, amount: float, is_storage: bool):
	if is_storage:
		var ui_storage: Label = ui_nutrients.get_node_or_null(key + "/Reserve")
		if ui_storage != null:
			ui_storage.text = str(amount)
	else:
		var ui_capacity: SpinBox = ui_nutrients.get_node_or_null(key + "/Quantity")
		if ui_capacity != null:
			_on_Nutrient_quantity_changed(ui_capacity, amount)



func _on_GroundField_soils_changed(from: StringName, to: StringName, _coords: Vector2i):
	print("SOIL CHANGED:", from, "->", to)
	_soil_dicts[from].text = str(len(target_field.cells_by_soil[from]))
	if not _soil_dicts.has(to):
		var ui_tileline = UISoilLine.instantiate(to, len(target_field.cells_by_soil[to]))
		ui_soils.add_child(ui_tileline)
		_soil_dicts[to] = ui_tileline.get_node_or_null("Length")
		if Engine.is_editor_hint():
			_fill_owner(ui_tileline, get_tree().edited_scene_root)

	_soil_dicts[to].text = str(len(target_field.cells_by_soil[to]))


func _on_Nutrient_quantity_changed(ui_capacity: SpinBox, val: float):
	if ui_capacity.value == val:
		return
	ui_capacity.value = val 

static func _clear_children(node: Node):
	if not is_instance_valid(node):
		push_warning("tried to clean an invalid node")
		return
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


static func _fill_owner(node: Node, owner_node):
	if not is_instance_valid(node):
		push_warning("tried to fill an invalid node")
		return
	for child in node.get_children():
		child.owner = owner_node
		_fill_owner(child, owner_node)

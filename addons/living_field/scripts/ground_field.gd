@tool
class_name GroundField extends TileMapLayer

# Utility #

@export_tool_button("SetupNode", "Callable")
@warning_ignore("unused_private_class_variable")
var _setup_node_action = func():
	timer = get_node_or_null("Timer")
	if timer == null:
		print("ADD TIMER")
		timer = Timer.new()
		add_child(timer)
		timer.owner = get_tree().edited_scene_root
		timer.name = "Timer"
@export_tool_button("RecalcSoils", "Callable")
@warning_ignore("unused_private_class_variable")
var _recalc_soils_action = recalc_soils


#signal built
signal soils_changed(from: StringName, to: StringName, coords: Vector2i)

@export var challenge_rate = .1
@export var nutrition: Nutrition # 栄養素
@export var storage: NutrientStorage
@export var soils: Dictionary[StringName, Array] = {}

@onready var timer: Timer = $Timer
@onready var resources: ResourcePreloader = $ResourcePreloader
var _start_map_data: PackedByteArray
var _fctx: FieldContext

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	initialize()

	recalc_soils()
	_start_map_data = tile_map_data

	_fctx = FieldContext.create(nutrition, soils)
	storage.initialize()

func recalc_soils():
	soils = {}
	for coords in get_used_cells():
		var soil = Soil.from_tiledata(get_cell_tile_data(coords))
		if not is_instance_valid(soil):
			push_warning("soil is not found at: ", coords)
			continue
		if not soils.has(soil.name):
			var l: Array[Vector2i] = []
			soils[soil.name] = l
		soils[soil.name].append(coords)

	
func initialize():
	timer.timeout.connect(_on_soil_process)
	timer.start(challenge_rate)

func _on_soil_process():
	var cells = get_used_cells()
	@warning_ignore("integer_division")
	for i in range(len(cells) / 10):
		if len(cells) == 0:
			return
		var target_coords = _select_coords(cells)

		var td = get_cell_tile_data(target_coords)
		var soil: Soil = td.get_custom_data_by_layer_id(0)
		if not is_instance_valid(soil):
			push_warning(target_coords, " is invalid coords at ", name)
			return

		var to = soil.try_transition(self, target_coords)
		if to != soil.name: # 土壌変化成功
			transition_soil(soil.name, to, target_coords)

# soil移行機会を実行する座標を選択する
func _select_coords(cells: Array[Vector2i]) -> Vector2i:
	var selected_idx: int = randi_range(0, len(cells)-1)
	return cells[selected_idx]


func has_point(pos: Vector2) -> bool:
	var coords = local_to_map(pos)
	return get_cell_source_id(coords) != -1

func transition_soil(from: StringName, to: StringName, coords: Vector2i):
	soils[from].erase(coords)
	if not soils.has(to):
		soils[to] = []
	soils[to].append(coords)
	soils_changed.emit(from, to, coords)

func reset():
	tile_map_data = _start_map_data
	recalc_soils()

## Nutrientヘルパー関数

func get_nutrient(key: StringName) -> Nutrient:
	return storage.get_nutrient(nutrition, key)
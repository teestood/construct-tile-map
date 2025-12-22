@tool
class_name GroundField extends TileMapLayer

# Utility #

@export_tool_button("SetupNode", "Callable")
@warning_ignore("unused_private_class_variable")
var _setup_node_action = func():
	timer = get_node_or_null("Timer")
	if timer == null:
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
@export var max_challenge: int = 100 # フレームごとの最大土壌変化試行回数
@export var nutrition: NutrientPreloader # 栄養素
@export var storage: NutrientStorage
@export var reserve: NutrientStorage # storageの内、タイル分の栄養素を表す
@export var cells_by_soil: Dictionary[StringName, Array] = {}

@onready var timer: Timer = $Timer
@onready var resources: ResourcePreloader = $SoilPreloader
var _start_map_data: PackedByteArray
var _fctx: FieldContext
var _terrain_cache: Dictionary[StringName, PackedInt32Array] = {}

## タイル上に存在するノードリスト
var _tile_dicts: Dictionary[Vector2i, Array] = {}

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	initialize()

	recalc_soils()
	_start_map_data = tile_map_data

	_fctx = FieldContext.create(nutrition, cells_by_soil)
	storage.initialize()

func recalc_soils():
	cells_by_soil = {}
	for coords in get_used_cells():
		var soil = Soil.from_tiledata(get_cell_tile_data(coords))
		if not is_instance_valid(soil):
			push_warning("soil is not found at: ", coords)
			continue
		if not cells_by_soil.has(soil.name):
			var l: Array[Vector2i] = []
			cells_by_soil[soil.name] = l
		cells_by_soil[soil.name].append(coords)

	
func initialize():
	timer.timeout.connect(_on_soil_process)
	timer.start(challenge_rate)

# 土壌変化処理を実行する
func _on_soil_process():
	var is_changed := false
	var cells = get_used_cells()
	@warning_ignore("integer_division")
	for i in range(min(len(cells) / 10, max_challenge)):
		if len(cells) == 0:
			return
		var target_coords = _select_coords(cells)

		var td = get_cell_tile_data(target_coords)
		var soil: Soil = td.get_custom_data_by_layer_id(0)
		if not is_instance_valid(soil):
			push_warning(target_coords, " is invalid coords at ", name)
			return

		var to = try_soil_transition(soil, target_coords)
		if to != soil.name: # 土壌変化成功
			replace_soil(soil.name, to, target_coords)
			is_changed = true
	if is_changed:
		notify_runtime_tile_data_update()

# soil移行機会を実行する座標を選択する
func _select_coords(cells: Array[Vector2i]) -> Vector2i:
	var selected_idx: int = randi_range(0, len(cells)-1)
	return cells[selected_idx]


func has_point(pos: Vector2) -> bool:
	var coords = local_to_map(pos)
	return get_cell_source_id(coords) != -1

#region Soilヘルパーメソッド

## 指定した座標の土壌をfromからtoへ置き換える
func replace_soil(from: StringName, to: StringName, coords: Vector2i):
	cells_by_soil[from].erase(coords)
	if not cells_by_soil.has(to):
		cells_by_soil[to] = []
	cells_by_soil[to].append(coords)
	soils_changed.emit(from, to, coords)
	if not _tile_dicts.has(coords):
		return # リスナーがいない
	for node in _tile_dicts[coords]:
		if node.has_signal("soil_changed"):
			node.emit_signal("soil_changed", from, to)

## 指定した座標をsoilに基づいて変化する
func try_soil_transition(soil: Soil, coords: Vector2i) -> StringName:
	if soil.transition == null:
		return soil.name
	# タイル変化を試みる
	var to = soil.transition.challenge(self, coords)
	if to != SoilTransition.TRANSITION_NONE:
		var terrain = get_terrain(to)
		if len(terrain) == 2:
			self.set_cells_terrain_connect([coords], terrain[0], terrain[1])

			return to
	return soil.name

func can_grow_soil(soil: Soil) -> bool:
	if soil.require == null:
		return true
	return soil.require.can_growth(self, soil)

## 指定した土壌名に対応するSoilリソースを取得する
func get_soil(soilname: StringName) -> Soil:
	return resources.get_resource(soilname)

## 指定した土壌名に対応するTerrain情報を取得する
func get_terrain(key: StringName) -> PackedInt32Array:
	if _terrain_cache.has(key):
		return _terrain_cache[key]
	for setid in range(tile_set.get_terrain_sets_count()):
		for id in range(tile_set.get_terrains_count(setid)):
			if key == tile_set.get_terrain_name(setid, id):
				_terrain_cache[key] = PackedInt32Array([setid, id])
	return _terrain_cache.get(key, PackedInt32Array())

## 指定した座標が指定した地形かどうかを取得する
func is_terrain(coords: Vector2i, name: StringName) -> bool:
	var tiledata = get_cell_tile_data(coords)
	if tiledata == null:
		return false
	var terrain = get_terrain(name)
	if len(terrain) != 2:
		return false
	return tiledata.terrain_set == terrain[0] and tiledata.terrain == terrain[1]
#endregion

func reset():
	tile_map_data = _start_map_data
	recalc_soils()

## Nutrientヘルパー関数

func get_nutrient(key: StringName) -> Nutrient:
	return storage.get_nutrient(nutrition, key)


# Groundタイル変更時にイベントを受け取りたいノードを追加する
# nodeはsignal "soil_changed(from: StringName, to: StringName)"を実装する必要がある
func listen_soil(node: Node2D) -> void:
	var coords = to_local_coords(node.global_position)
	if not _tile_dicts.has(coords):
		_tile_dicts[coords] = []
	var l = _tile_dicts[coords]
	l.append(node)

func unlisten_soil(node: Node2D) -> void:
	var l = _tile_dicts[to_local_coords(node.global_position)]
	l.erase(node)

func to_local_coords(global_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(global_pos))

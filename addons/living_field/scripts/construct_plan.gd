@tool
## ConstructTileMapの最終生成パターンを定義するクラス
class_name ConstructPlan extends TileMapLayer

@export_tool_button("InstantConstruct", "Callable")
var instant_construct_action = instant_construct

@export_tool_button("AdvanceBuild", "Callable")
var advance_build_action = advance_build

@export var ground: GroundField 
@export var default_tile: int = -1
@export_group("Debug")
@export var debug: bool = false
@export_group("")

var _progress_cells: Array[Vector2i] = []
var progress_cells: Array[Vector2i]:
	get:
		return _progress_cells

func _ready() -> void:
	if Engine.is_editor_hint():
		self_modulate = Color(1, 1, 1, 1.)
		collision_enabled = false
		navigation_enabled = false
		return
	self_modulate = Color(1, 1, 1, 0.2)

	assert(is_instance_valid(ground), "construct_tile_map must be valid")
	_update_progress_cells()

func _update_progress_cells():
	if debug:
		print("ConstructPlan: UpdateProgressCells")
	_progress_cells = []
	var cells = get_used_cells()
	var invalid_cells: Array[Vector2i] = []
	for coords in cells:
		if ground.get_cell_source_id(coords) == -1:
			invalid_cells.append(coords)
			continue ## 
		if is_built_tile(coords):
			continue
		_progress_cells.append(coords)
	if 0 < invalid_cells.size():
		push_warning("ground has not tile at: ", invalid_cells)

	if debug:
		print("ConstructPlan: UpdateProgressCells finished")
	
var _tmp_progress: Dictionary = {}

## 建設可能なタイルの座標を1つ返す。存在しない場合は空のDictionaryを返す
func try_get_progress() -> Dictionary:
	_tmp_progress.clear()
	if _progress_cells.size() == 0:
		return _tmp_progress
	_tmp_progress ["coords"] = _progress_cells[0]
	return _tmp_progress

## Checks if construction can be started. Returns true if at least one buildable tile exists.
func can_construct() -> bool:
	var cells = get_used_cells()
	for coords in cells:
		if get_cell_source_id(coords) == -1:
			continue
		var tiledata = get_cell_tile_data(coords)
		if tiledata == null:
			continue
		var soil = tiledata.get_custom_data("Soil")
		if soil != null and ground.storage.can_pay(soil.cost):
			return true
	return false

func can_construct_at(coords: Vector2i) -> bool:
	if get_cell_source_id(coords) == -1:
		return false
	var tiledata = get_cell_tile_data(coords)
	if tiledata == null:
		return false
	var soil = tiledata.get_custom_data("Soil")
	if soil == null or not ground.storage.can_pay(soil.cost):
		return false
	return true

## 即座に完成図を建築に適用する
func instant_construct():
	if debug:
		print("ConstructPlan: InstantConstruct")
	var cells = get_used_cells()

	var terrain_cells: Dictionary[PackedInt32Array, Array]
	for coords in cells:
		var td = get_cell_tile_data(coords)
		var key: PackedInt32Array = [td.terrain_set, td.terrain]

		if terrain_cells.has(key):
			terrain_cells[key].append(coords)
		else:
			terrain_cells[key] = [coords]
	
	for key in terrain_cells.keys():
		ground.set_cells_terrain_connect(terrain_cells[key], key[0], key[1])

	if debug:
		print("ConstructPlan: InstantConstruct finished")

func advance_build() -> bool:
	if _progress_cells.size() == 0:
		_update_progress_cells()
		if _progress_cells.size() == 0:
			return true
	
	var l = len(_progress_cells)
	var coords = _progress_cells[randi_range(0, l-1)]
	var to = get_cell_tile_data(coords)
	
	apply_to_ground(coords)
	return false

## 指定した座標の建築状況を進める
func apply_to_ground(coords: Vector2i) -> Soil:
	if progress_cells.has(coords) == false:
		return null
	var id = get_cell_source_id(coords)
	if id == -1:# 空タイル
		return null
	var to = get_cell_tile_data(coords)

	if to == null:
		push_warning(coords, "ConstructTileが未設定")
		return null

	ground.update_terrain(to, coords)
	_progress_cells.erase(coords)


	return Soil.from_tiledata(to)

## 建築完了しているかどうかを判定する
func is_built_tile(coords: Vector2i) -> bool:
	return get_cell_source_id(coords) == ground.get_cell_source_id(coords)

## 期待したタイルかどうかを判定する
## 建築完了していてかつ周囲のタイルも同じである場合にtrueを返す
func is_planned_tile(coords: Vector2i) -> bool:
	return is_built_tile(coords) and \
		get_cell_atlas_coords(coords) == ground.get_cell_atlas_coords(coords)

func map_to_global(coords: Vector2i) -> Vector2:
	return to_global(map_to_local(coords))

@tool
## ConstructTileMapの最終生成パターンを定義するクラス
class_name ConstructTileMapPlan extends TileMapLayer

signal ground_updated

@export_tool_button("InstantConstruct", "Callable")
var instant_construct_action = instant_construct

@export var ground: GroundField

@export var default_tile: int = -1

var _offset: Vector2i # ground_mapとの差

func _ready() -> void:
	if Engine.is_editor_hint():
		self_modulate = Color(1, 1, 1, 0.5)
		collision_enabled = false
		navigation_enabled = false
		return
	self_modulate = Color(1, 1, 1, 0.2)

	assert(is_instance_valid(ground), "construct_tile_map must be valid")


func setup_target(newtarget: GroundField) -> bool:
	if newtarget.tile_set != tile_set:
		return false
	
	ground = newtarget
	return true
	
## Checks if construction can be started. Returns true if construction can be started.
func can_construct() -> bool:
	var cells = get_used_cells()
	for coords in cells:
		if get_cell_source_id(coords) != -1:
			continue
		var tiledata = get_cell_tile_data(coords)
		var parts = tiledata.get_custom_data("Soil")
		if parts == null:
			continue

	return false

## 即座に完成図を建築に適用する
func instant_construct():
	var cells = get_used_cells()

	var terrain_cells: Dictionary[PackedInt32Array, Array]
	for coords in cells:
		var td = get_cell_tile_data(coords)
		var key:PackedInt32Array = [td.terrain_set, td.terrain]

		if terrain_cells.has(key):
			terrain_cells[key].append(coords)
		else:
			terrain_cells[key] = [coords]
	
	for key in terrain_cells.keys():
		ground.set_cells_terrain_connect(terrain_cells[key], key[0], key[1])

	ground_updated.emit()

## 指定した座標の建築状況を進める
func apply_to_ground(coords: Vector2i) -> Soil:
	var id = get_cell_source_id(coords)
	if id == -1:# 空タイル
		return null
	var td = get_cell_tile_data(coords)

	if td == null:
		push_warning(coords, "ConstructTileが未設定")
		return null

	# planのセルをgroundに適用する
	if not is_planned_tile(coords):
		ground.set_cells_terrain_connect([coords], td.terrain_set, td.terrain)
		print("[ApplyToGround]:%s[%s(%s)]@%s" % [name, td.terrain_set, td.terrain, coords])
		if is_planned_tile(coords):
			ground_updated.emit()
			notify_runtime_tile_data_update()

	return td.get_custom_data_by_layer_id(0) as Soil

func is_planned_tile(coords: Vector2i):
	return get_cell_source_id(coords) == ground.get_cell_source_id(coords) and \
		get_cell_atlas_coords(coords) == ground.get_cell_atlas_coords(coords)

# 自身の座標をground_map上に一致する座標に変換
func at_ground(coords: Vector2i):
	return coords - _offset

func clear_ground():
	var cells = get_used_cells()
	ground.tile_map_data = []
	if default_tile != -1:
		ground.set_cells_terrain_connect(cells, 0, default_tile, false)

	ground_updated.emit()
	ground.notify_runtime_tile_data_update()

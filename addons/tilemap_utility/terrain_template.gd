@tool
extends EditorInspectorPlugin

var TERRAINS: Array[Dictionary] = [
	{
		"pos": Vector2i(0, 0),
		"peer": TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	},{
		"pos": Vector2i(1, 0),
		"peer": TileSet.CELL_NEIGHBOR_TOP_SIDE,
	},{
		"pos": Vector2i(2, 0),
		"peer": TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	},{
		"pos": Vector2i(0, 1),
		"peer": TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	},{
		"pos": Vector2i(2, 1),
		"peer": TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
	},{
		"pos": Vector2i(0, 2),
		"peer": TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	},{
		"pos": Vector2i(1, 2),
		"peer": TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
	},{
		"pos": Vector2i(2, 2),
		"peer": TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
	}
]

const TileSetInspector = preload("res://addons/tilemap_utility/tile_set_inspector.gd")
var _tile_set_inspector_pack = preload("res://addons/tilemap_utility/tile_set_inspector.tscn")

func _can_handle(object: Object) -> bool:
	return object is TileSet

func _parse_begin(object: Object) -> void:
	var tileset := object as TileSet
	if not is_instance_valid(tileset):
		error("invalid tileset", object)
		return

	var inspector = _tile_set_inspector_pack.instantiate() as TileSetInspector
	add_custom_control(inspector)

	if not inspector.is_node_ready():
		await inspector.ready # for onready variables on inspector


	# Set up AtlasSourceTexture
	#inspector.ui_source_id.max_value = tileset.get_source_count() - 1
	inspector.ui_source_id.value_changed.connect(update_source_texture.bind(tileset, inspector))
	update_source_texture(inspector.source_id, object, inspector)

	# Set up TerrainSet
	inspector.ui_terrain_set_id.max_value = tileset.get_terrain_sets_count() - 1
	inspector.ui_terrain_set_id.value_changed.connect(update_terrain_set.bind(tileset, inspector))
	update_terrain_set(inspector.terrain_set_id, tileset, inspector)

	# Set up Terrain
	var ui_center_id = inspector.ui_center.get_node("ID")
	var ui_edge_id = inspector.ui_edge.get_node("ID")

	ui_center_id.value_changed.connect(update_terrain.bind(inspector.ui_center, object, inspector))
	ui_edge_id.value_changed.connect(update_terrain.bind(inspector.ui_edge, object, inspector))
	update_terrain(ui_center_id.value, inspector.ui_center, object, inspector)
	update_terrain(ui_edge_id.value, inspector.ui_edge, object, inspector)

	# Set up Apply Button
	inspector.ui_apply.pressed.connect(_on_activate_terrain_template.bind(inspector, object as TileSet))


func _on_activate_terrain_template(inspector: TileSetInspector, tileset: TileSet):
	var source_id = inspector.get_node("%SourceID").value
	var terrain_set_id = inspector.get_node("%TerrainSetID").value

	var source := tileset.get_source(source_id) as TileSetAtlasSource
	if not is_instance_valid(source):
		error("invalid source: ", source)
		return
	
	# color mapping
	var center_color = inspector.ui_center.get_node("Color/From").color
	var center_id = inspector.ui_center.get_node("ID").value
	var edge_color = inspector.ui_edge.get_node("Color/From").color
	var edge_id = inspector.ui_edge.get_node("ID").value
	
	var colormap = {
		center_color: center_id,
		edge_color: edge_id,
	}

	# load a TerrainPeeringBits template image
	var imgmap = get_image_map(inspector)
	for tile_idx in range(source.get_tiles_count()):
		var tile_id := source.get_tile_id(tile_idx) as Vector2i
 
		var tiledata := source.get_tile_data(tile_id, 0) as TileData

		var img := imgmap[tile_id] as Image
		if img == null:
			printerr("invalid image")

			
		var center_terrain_id = colormap[img.get_pixelv(Vector2i(1,1))]
		tiledata.terrain_set = terrain_set_id 
		tiledata.terrain = center_terrain_id
		for terrain in TERRAINS:
			var terrain_id = colormap[img.get_pixelv(terrain.pos)]
			tiledata.set_terrain_peering_bit(terrain["peer"], terrain_id)




func update_source_texture(src_id: int, tileset: TileSet, inspector: TileSetInspector):
	var source := tileset.get_source(src_id) as TileSetAtlasSource
	var src_tex := inspector.ui_source_texture
	if source == null:
		src_tex.texture = null
		return
	src_tex.texture = source.texture

func update_terrain_set(terrain_set_id: int, tileset: TileSet, inspector: TileSetInspector):
	var ui_center_id = inspector.ui_center.get_node("ID")
	ui_center_id.max_value = tileset.get_terrains_count(inspector.ui_terrain_set_id.value) - 1
	var ui_edge_id = inspector.ui_edge.get_node("ID")
	ui_edge_id.max_value = tileset.get_terrains_count(inspector.ui_terrain_set_id.value) - 1
	update_terrain(-1, inspector.ui_edge, tileset, inspector)
	update_terrain(0, inspector.ui_center, tileset, inspector)

func update_terrain(terrain_idx: int, ui_box: Control, tileset: TileSet, inspector: TileSetInspector):
	var terrain_set_id = inspector.terrain_set_id
	if terrain_idx == -1:
		ui_box.get_node("Color/Name").text = "empty"
		ui_box.get_node("Color/To").color = Color.TRANSPARENT
	else:
		ui_box.get_node("Color/Name").text = tileset.get_terrain_name(terrain_set_id, terrain_idx)
		ui_box.get_node("Color/To").color = tileset.get_terrain_color(terrain_set_id, terrain_idx)

# 変換先Terrainのマッピングデータを取得する
func get_image_map(inspector: TileSetInspector) -> Dictionary:
	var selector := inspector.ui_terrain_template_selector as OptionButton
	var img := selector.get_item_icon(selector.selected).get_image() as Image

	var size = img.get_size()
	if size != Vector2i(12*3, 4*3):
		error("invalid image_size", size)
		return {}

	var dicts := {}
	for y in range(4):
		for x in range(12):
			var img3x3 = img.get_region(Rect2i(x*3, y*3, 3, 3))
			dicts[Vector2i(x, y)] = img3x3
	return dicts


func error(str: Variant, obj: Variant):
	printerr(str, obj)
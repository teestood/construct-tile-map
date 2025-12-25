## TileBuildAnimation
## Animation played when a tile is built.
class_name TileBuildAnimation extends Sprite2D

signal finished ## Emitted when the animation is finished.

## Setup the animation with the given tilemap and coords.
func setup(tilemap: TileMapLayer, coords: Vector2i) -> void:
	var id = tilemap.get_cell_source_id(coords)
	if id == -1:
		push_warning(coords, "Cannot setup TileBuildAnimation with empty tile")
		return
	var src = tilemap.tile_set.get_source(id) as TileSetAtlasSource
	if src == null:
		push_warning(coords, "Tile source is not AtlasSource")
		return
	
	var tiledata = tilemap.get_cell_tile_data(coords)
	offset = -tiledata.texture_origin
	texture = src.texture
	position = tilemap.map_to_local(coords)
	z_index = tiledata.z_index

	region_enabled = true
	region_rect = Rect2(
		Vector2(tilemap.get_cell_atlas_coords(coords)) * Vector2(tilemap.tile_set.tile_size),
		src.texture_region_size,
	)

## Instantiate a TileBuildAnimation at the given tilemap and coords.
static func instantiate(tilemap: TileMapLayer, coords: Vector2i, duration: float = .5) -> TileBuildAnimation:
	var anim = TileBuildAnimation.new()
	anim.setup(tilemap, coords)

	var tw = anim.create_tween()
	anim.scale = Vector2(.1, .1)
	anim.self_modulate = Color.GRAY
	tw.tween_property(anim, "scale", Vector2.ONE*1.05, duration).set_trans(Tween.TRANS_BOUNCE)
	tw.parallel().tween_property(anim, "self_modulate", Color.WHITE, duration)
	tw.tween_callback(func():
		anim.finished.emit()
		anim.queue_free()
	)
	return anim
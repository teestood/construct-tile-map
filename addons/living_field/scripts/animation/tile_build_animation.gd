## TileBuildAnimation
## Animation played when a tile is built.
class_name TileBuildAnimation extends Node2D

signal finished ## Emitted when the animation is finished.

@export var sprite: Sprite2D
@export var audio: AudioStreamPlayer2D

## Setup the animation with the given tilemap and coords.
func setup(tilemap: TileMapLayer, coords: Vector2i) -> void:
	if sprite == null or audio == null:
		push_warning("TileBuildAnimation missing sprite or audio node")
		return
	var id = tilemap.get_cell_source_id(coords)
	if id == -1:
		push_warning(coords, "Cannot setup TileBuildAnimation with empty tile")
		return
	var src = tilemap.tile_set.get_source(id) as TileSetAtlasSource
	if src == null:
		push_warning(coords, "Tile source is not AtlasSource")
		return

	var tiledata = tilemap.get_cell_tile_data(coords)
	if tiledata == null:
		push_warning(coords, "Tile data is null")
		return
	sprite.offset = -tiledata.texture_origin
	sprite.texture = src.texture
	position = tilemap.map_to_local(coords)
	z_index = tiledata.z_index


	sprite.region_enabled = true
	sprite.region_rect = Rect2(
		Vector2(tilemap.get_cell_atlas_coords(coords)) * Vector2(tilemap.tile_set.tile_size),
		src.texture_region_size,
	)

	var soil = Soil.from_tiledata(tiledata)
	if soil != null:
		audio.stream = soil.building_sound
	else:
		audio.stream = null

func play(duration: float = .5) -> void:
	var tw = create_tween()
	scale = Vector2(.1, .1)
	self_modulate = Color.GRAY
	tw.tween_property(self, "scale", Vector2.ONE*1.05, duration).set_trans(Tween.TRANS_BOUNCE)
	tw.parallel().tween_property(self, "self_modulate", Color.WHITE, duration)
	tw.tween_callback(func():
		finished.emit()
		queue_free()
	)

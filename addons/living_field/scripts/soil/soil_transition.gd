class_name SoilTransition extends Resource

@export var to: StringName = &"dirt"

func challenge(ground: GroundField, coords: Vector2i) -> bool:
	return _challenge(ground, coords)

func _challenge(_ground: GroundField, _coords: Vector2i) -> bool:
	return true

func get_next_terrain(tilemap: TileMapLayer) -> PackedInt32Array:
	var tset = tilemap.tile_set
	for setid in range(tset.get_terrain_sets_count()):
		for id in range(tset.get_terrains_count(setid)):
			if to == tset.get_terrain_name(setid, id):
				return [setid, id]
	return []

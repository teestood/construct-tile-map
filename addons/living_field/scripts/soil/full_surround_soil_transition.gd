class_name FullSurroundSoilTransition extends SoilTransition


func _challenge(ground: GroundField, coords: Vector2i) -> bool:
	var atlas_coords = ground.get_cell_atlas_coords(coords)

	return atlas_coords == Vector2i(12, 3)
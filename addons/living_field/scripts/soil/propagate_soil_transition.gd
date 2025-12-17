class_name PropagateSoilTransition extends SoilTransition

@export var probability: float = 1.

func _challenge(ground: GroundField, coords: Vector2i) -> bool:
	var prob = 0.
	var terrain = get_next_terrain(ground)
	var cells = ground.get_surrounding_cells(coords)
	for c in cells:
		var tiledata = ground.get_cell_tile_data(c)
		if tiledata == null:
			continue
		if tiledata.terrain_set == terrain[0] and tiledata.terrain == terrain[1]:
			prob += probability / len(cells)
	if prob == 0:
		return false
	return randf() < prob
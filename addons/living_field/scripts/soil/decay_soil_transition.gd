# タイルが増殖上限に到達している場合に劣化する
class_name DecaySoilTransition extends SoilTransition

func _challenge(ground: GroundField, coords: Vector2i) -> bool:
	var td = ground.get_cell_tile_data(coords)
	var soil = Soil.from_tiledata(td)
	return soil.check_decay(ground)
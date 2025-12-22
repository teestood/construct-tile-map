# タイルが増殖上限に到達している場合に劣化する
class_name SoilTransitionDecay extends SoilTransition

@export var to: StringName = &"dirt"

func challenge(ground: GroundField, coords: Vector2i) -> StringName:
	var td = ground.get_cell_tile_data(coords)
	var soil = Soil.from_tiledata(td)
	
	if soil.require.can_decay(ground, soil):
		return to
	return SoilTransition.TRANSITION_NONE

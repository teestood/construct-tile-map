class_name SoilTransitionFullSurround extends SoilTransition

@export var to: StringName = &"dirt"

func _challenge(ground: GroundField, coords: Vector2i) -> StringName:
	var atlas_coords = ground.get_cell_atlas_coords(coords)

	if atlas_coords == Vector2i(12, 3):
		return to
	return &""
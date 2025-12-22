class_name SoilTransitionPropagate extends SoilTransition

@export var to: StringName = &"dirt"
@export var probability: float = 1.

func _challenge(ground: GroundField, coords: Vector2i) -> StringName:
	var prob = 0.
	var cells = ground.get_surrounding_cells(coords)
	for c in cells:
		if ground.is_terrain(c, to):
			prob += probability / len(cells)
	if prob != 0 and randf() < prob and ground.can_grow_soil(ground.get_soil(to)):
		return to
	return SoilTransition.TRANSITION_NONE

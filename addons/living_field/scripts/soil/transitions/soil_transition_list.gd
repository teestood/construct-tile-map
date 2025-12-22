class_name SoilTransitionList extends SoilTransition

@export var transitions: Array[SoilTransition] = []

func _challenge(_ground: GroundField, _coords: Vector2i) -> StringName:
	for transitions in transitions:
		var result = transitions.challenge(_ground, _coords)
		if result != SoilTransition.TRANSITION_NONE:
			return result
	return SoilTransition.TRANSITION_NONE
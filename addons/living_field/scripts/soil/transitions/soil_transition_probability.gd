## 確率で移行する
class_name SoilTransitionProbability extends SoilTransition

@export var to: StringName = &"dirt"
@export var probability: float = .5

func _challenge(ground: GroundField, _coords: Vector2i) -> StringName:
	if randf() < probability and ground.can_growth(ground.get_soil(to)):
		return to
	return SoilTransition.TRANSITION_NONE
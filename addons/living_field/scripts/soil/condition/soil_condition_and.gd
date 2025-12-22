extends SoilCondition

@export var conditions: Array[SoilCondition]

func _can_growth(ground: GroundField, soil: Soil) -> bool:
	for condition in conditions:
		if not condition.can_growth(ground, soil):
			return false
	return true

func _can_decay(ground: GroundField, soil: Soil) -> bool:
	for condition in conditions:
		if not condition.can_decay(ground, soil):
			return false
	return true

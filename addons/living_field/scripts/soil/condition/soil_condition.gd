class_name SoilCondition extends Resource

func can_growth(ground: GroundField, soil: Soil) -> bool:
	return _can_growth(ground, soil)

func _can_growth(_ground: GroundField, _soil: Soil) -> bool:
	return false

func can_decay(ground: GroundField, soil: Soil) -> bool:
	return _can_decay(ground, soil)

func _can_decay(ground: GroundField, soil: Soil) -> bool:
	return not _can_growth(ground, soil)

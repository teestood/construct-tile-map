## 栄養状態が現在のタイルより多くを養えることを検査する
class_name SoilConditionNutrition extends SoilCondition

@export var nutrient_name: StringName
@export var multiply: float = 1.
@export var threshold: float = 10. # Decay

func _can_growth(ground: GroundField, soil: Soil) -> bool:
	var current = len(ground.cells_by_soil[soil.name])
	return current < _get_tolerance(ground.get_nutrient(nutrient_name))

func _to_string() -> String:
	return "require %s(*%d)" % [nutrient_name, multiply]

func _can_decay(ground: GroundField, soil: Soil) -> bool:
	var current = len(ground.cells_by_soil[soil.name])
	return _get_tolerance(ground.get_nutrient(nutrient_name)) + threshold < current

func _get_tolerance(nut: Nutrient) -> float:
	return nut.amount * multiply

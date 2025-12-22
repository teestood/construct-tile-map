@tool
class_name NutrientStorage extends Resource

signal nutrients_count_changed
signal nutrient_added


@export var _defaults: Array[Nutrient]

var nutrients: Dictionary[StringName, Nutrient]

func initialize():
	nutrients.clear()
	for nut in _defaults:
		nutrients[nut.stats.name] = nut.duplicate()

func get_nutrient(nutrition: NutrientPreloader, key: StringName) -> Nutrient:
	if not nutrients.has(key):
		nutrients[key] = nutrition.create(key, 0)
		nutrient_added.emit(key)
		nutrients_count_changed.emit()
	return nutrients[key]

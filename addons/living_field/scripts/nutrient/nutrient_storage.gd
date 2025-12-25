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

func get_or_add(nutrition: NutrientPreloader, key: StringName) -> Nutrient:
	if not nutrients.has(key):
		nutrients[key] = nutrition.create(key, 0)
		nutrient_added.emit(key)
		nutrients_count_changed.emit()
	return nutrients[key]

func invert() -> void:
	for key in nutrients.keys():
		var nut = nutrients[key]
		nut.amount = -nut.amount

func is_empty() -> bool:
	return nutrients.size() == 0

func can_pay(cost: NutrientStorage) -> bool:
	for key in cost.nutrients.keys():
		var req = cost.nutrients[key]
		if not nutrients.has(key):
			return false
		if nutrients[key].amount < req.amount:
			return false
	return true

static func merge(storages: Array[NutrientStorage]) -> NutrientStorage:
	var newstorage := NutrientStorage.new()
	for storage in storages:
		for key in storage.nutrients.keys():
			var nut = storage.nutrients[key]
			if not newstorage.nutrients.has(key):
				newstorage.nutrients[key] = nut.duplicate()
			else:
				newstorage.nutrients[key].amount += nut.amount
	return newstorage
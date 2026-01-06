@tool
class_name NutrientStorage extends Resource

signal nutrients_count_changed
signal nutrient_added
signal nutrient_changed(key: StringName, amount: float)


@export var debug: bool = false

func _init() -> void:
	resource_local_to_scene = true

@export var nutrients: Dictionary[StringName, Nutrient] = {}

func clear() -> void:
	nutrients.clear()
	emit_changed()

## Config からの初期化用内部メソッド（カプセル化）
func _set_nutrient_internal(key: StringName, nutrient: Nutrient) -> void:
	nutrients[key] = nutrient

func get_or_add(nutrition: NutrientPreloader, key: StringName) -> Nutrient:
	add_nutrient(nutrition.create(key, 0), 0)
	return nutrients[key]

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

func sub(cost: NutrientStorage, n: int = 1) -> void:
	for key in cost.nutrients.keys():
		var req = cost.nutrients[key]
		add_nutrient(req, -req.amount * n, false)
	emit_changed()

func add(gain: NutrientStorage, n: int = 1) -> void:
	for key in gain.nutrients.keys():
		var req = gain.nutrients[key]
		add_nutrient(req, req.amount * n, false)
	emit_changed()

func merge_storages(storages: Array[NutrientStorage]) -> void:
	var logs: PackedStringArray = []
	if debug:
		print("[NutrientStorage.merge_storages]: Merge ", storages)
	
	for storage in storages:
		for key in storage.nutrients.keys():
			var nut = storage.nutrients[key]
			add_nutrient(nut, nut.amount, false)
			logs.append(" %s: %+d" % [key, nut.amount])
	
	if debug and 0 < logs.size():
		print("[NutrientStorage.merge_storages]: Merged storages:", ", ".join(logs))
	
	emit_changed()

## ある栄養素の量をamount分追加させる
func add_nutrient(nut: Nutrient, amount: float, _emit: bool = true) -> float:
	if not nutrients.has(nut.stats.name):
		nutrients[nut.stats.name] = nut.duplicate()
		nutrient_added.emit(nut.stats.name)
		nutrients_count_changed.emit()
	else:
		nutrients[nut.stats.name].amount += amount

	var new_amount = nutrients[nut.stats.name].amount
	
	if debug:
		print("[NutrientStorage.add_nutrient]: %s amount changed to %d" % [nut.stats.name, new_amount])
	
	nutrient_changed.emit(nut.stats.name, new_amount)
	
	if _emit:
		emit_changed()
	
	return new_amount

func clone() -> NutrientStorage:
	var newstorage := NutrientStorage.new()
	for key in nutrients.keys():
		newstorage.nutrients[key] = nutrients[key].duplicate()
	return newstorage

func _to_string() -> String:
	if nutrients.is_empty():
		return "NutrientStorage{empty}"
	var parts: Array[String] = []
	for key in nutrients.keys():
		var nut = nutrients[key]
		parts.append("%s: %d" % [key, nut.amount])
	return "NutrientStorage{%s}" % ", ".join(parts)


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

static func invert(storage: NutrientStorage) -> NutrientStorage:
	var inverted = storage.clone()
	for key in inverted.nutrients.keys():
		var nut = inverted.nutrients[key]
		nut.amount = -nut.amount
	return inverted
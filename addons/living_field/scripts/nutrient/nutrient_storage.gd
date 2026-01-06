@tool
class_name NutrientStorage extends NutrientContainer
"""実行時の栄養素プール（辞書ベース）

動的な栄養素の増減、支払い判定を行う。
高速なルックアップのため辞書構造を使用。"""

signal nutrients_count_changed
signal nutrient_added
signal nutrient_changed(key: StringName, amount: float)

@export var debug: bool = false
var nutrients: Dictionary[StringName, Nutrient] = {}

func _init() -> void:
	resource_local_to_scene = true

func get_nutrients() -> Array[Nutrient]:
	var result: Array[Nutrient] = []
	result.assign(nutrients.values())
	return result

func add_nutrient(key: StringName, amount: float) -> void:
	if not nutrients.has(key):
		push_warning("[NutrientStorage.add_nutrient]: Nutrient '%s' not found" % key)
		return
	
	nutrients[key].amount += amount
	
	if debug:
		print("[NutrientStorage.add_nutrient]: %s += %d (now: %d)" % [key, amount, nutrients[key].amount])
	
	nutrient_changed.emit(key, nutrients[key].amount)
	emit_changed()

func clear() -> void:
	nutrients.clear()
	emit_changed()

## 初期化用内部メソッド（カプセル化）
func _set_nutrient_internal(key: StringName, nutrient: Nutrient) -> void:
	nutrients[key] = nutrient
	if debug:
		print("[NutrientStorage._set_nutrient_internal]: Set %s = %d" % [key, nutrient.amount])

func get_or_add(nutrition: NutrientPreloader, key: StringName) -> Nutrient:
	if not nutrients.has(key):
		nutrients[key] = nutrition.create(key, 0)
		nutrient_added.emit(key)
		nutrients_count_changed.emit()
	return nutrients[key]

func is_empty() -> bool:
	return nutrients.size() == 0

func can_pay(cost: NutrientContainer) -> bool:
	if cost == null:
		return true
	for nut in cost.get_nutrients():
		if not nutrients.has(nut.stats.name):
			return false
		if nutrients[nut.stats.name].amount < nut.amount:
			return false
	return true

func sub(cost: NutrientContainer, n: float = 1.0) -> void:
	if cost == null:
		return 
	for nut in cost.get_nutrients():
		add_nutrient(nut.stats.name, -nut.amount * n)

func add(gain: NutrientContainer, n: float = 1.0) -> void:
	if gain == null:
		return 
	for nut in gain.get_nutrients():
		add_nutrient(nut.stats.name, nut.amount * n)

## NutrientAmountをStorageに直接追加
func add_amount(amount: NutrientAmount, multiplier: float = 1.0) -> void:
	if amount == null:
		return
	amount.apply_to(self, multiplier)

func merge_storages(storages: Array) -> void:
	if debug:
		print("[NutrientStorage.merge_storages]: Merging ", storages.size(), " storages")
	
	for storage in storages:
		if storage is NutrientContainer:
			add_container(storage)
		else:
			push_warning("[NutrientStorage.merge_storages]: Invalid storage type")


func clone() -> NutrientStorage:
	var newstorage := NutrientStorage.new()
	for key in nutrients.keys():
		newstorage.nutrients[key] = nutrients[key].duplicate()
	return newstorage


## 複数のNutrientContainerをマージして新しいStorageを作成
static func merge(containers: Array) -> NutrientStorage:
	var result = NutrientStorage.new()
	var nutrient_sums: Dictionary = {}
	
	for container in containers:
		if container == null:
			continue
		if not container is NutrientContainer:
			push_warning("[NutrientStorage.merge]: Invalid container type")
			continue
		
		for nut in container.get_nutrients():
			var key = nut.stats.name
			if not nutrient_sums.has(key):
				nutrient_sums[key] = nut.duplicate()
			else:
				nutrient_sums[key].amount += nut.amount
	
	for key in nutrient_sums:
		result._set_nutrient_internal(key, nutrient_sums[key])
	
	return result

static func invert(storage: NutrientStorage) -> NutrientStorage:
	var inverted = storage.clone()
	for key in inverted.nutrients.keys():
		var nut = inverted.nutrients[key]
		nut.amount = -nut.amount
	return inverted
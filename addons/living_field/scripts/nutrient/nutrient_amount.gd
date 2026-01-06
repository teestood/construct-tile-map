@tool
class_name NutrientAmount extends NutrientContainer
"""栄養素の量を表す値オブジェクト（配列ベース）

コスト、報酬、初期値などの静的な数量表現に使用。
インスペクタでの編集に最適化された配列構造。"""

@export var nutrients: Array[Nutrient] = []

func get_nutrients() -> Array[Nutrient]:
	return nutrients

func add_nutrient(key: StringName, amount: float) -> void:
	for nut in nutrients:
		if nut.stats.name == key:
			nut.amount += amount
			return
	push_warning("[NutrientAmount.add_nutrient]: Nutrient '%s' not found" % key)

## NutrientStorageに変換（実行時の辞書ベースコンテナへ）
func to_storage() -> NutrientStorage:
	var storage = NutrientStorage.new()
	for nut in nutrients:
		storage._set_nutrient_internal(nut.stats.name, nut.duplicate())
	return storage

## 反転したコピーを作成（コスト減算用）
func invert() -> NutrientAmount:
	var result = NutrientAmount.new()
	for nut in nutrients:
		var inverted = nut.duplicate()
		inverted.amount = -inverted.amount
		result.nutrients.append(inverted)
	return result

## 指定の対象に適用（multiplierで倍率指定可能）
func apply_to(target: NutrientContainer, multiplier: float = 1.0) -> void:
	for nut in nutrients:
		target.add_nutrient(nut.stats.name, nut.amount * multiplier)

## 新しいNutrientStorageインスタンスを作成（後方互換性のため残す）
func create() -> NutrientStorage:
	return to_storage()

## 複数のNutrientAmountをマージして新しいインスタンスを作成
static func merge(amounts: Array) -> NutrientAmount:
	var result = NutrientAmount.new()
	var nutrient_sums: Dictionary = {}
	
	for container in amounts:
		if container == null:
			continue
		if not container is NutrientContainer:
			push_warning("[NutrientAmount.merge]: Invalid container type")
			continue
		
		for nut in container.get_nutrients():
			var key = nut.stats.name
			if not nutrient_sums.has(key):
				nutrient_sums[key] = nut.duplicate()
			else:
				nutrient_sums[key].amount += nut.amount
	
	for nut in nutrient_sums.values():
		result.nutrients.append(nut)
	
	return result

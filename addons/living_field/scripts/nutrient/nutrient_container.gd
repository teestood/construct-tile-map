@tool
class_name NutrientContainer extends Resource
"""栄養素コンテナの基底クラス - 加算/減算操作を統一

NutrientAmountとNutrientStorageの共通インターフェース。
異なるデータ構造（配列 vs 辞書）を統一的に扱える。"""

## サブクラスで実装: 栄養素のイテレータを返す
func get_nutrients() -> Array[Nutrient]:
	push_error("get_nutrients() must be implemented in subclass")
	return []

## 別のコンテナの栄養素を加算
func add_container(other: NutrientContainer) -> void:
	for nut in other.get_nutrients():
		add_nutrient(nut.stats.name, nut.amount)

## 別のコンテナの栄養素を減算
func sub_container(other: NutrientContainer) -> void:
	for nut in other.get_nutrients():
		sub_nutrient(nut.stats.name, nut.amount)

## サブクラスで実装: 個別の栄養素操作
func add_nutrient(key: StringName, amount: float) -> void:
	push_error("add_nutrient() must be implemented in subclass")

func sub_nutrient(key: StringName, amount: float) -> void:
	add_nutrient(key, -amount)

## 文字列表現（デバッグ用）
func _to_string() -> String:
	if get_nutrients().is_empty():
		return "%s{empty}" % get_class()
	var parts: PackedStringArray = []
	for nut in get_nutrients():
		if nut.stats != null:
			parts.append("%s:%d" % [nut.stats.name, nut.amount])
	return "%s{%s}" % [get_class(), ", ".join(parts)]

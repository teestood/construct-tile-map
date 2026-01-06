@tool
class_name NutrientStorageConfig extends Resource

## 初期栄養素定義
@export var defaults: Array[Nutrient] = []

## 新しいストレージを作成して初期化
func create() -> NutrientStorage:
	var storage: NutrientStorage = NutrientStorage.new()
	apply_defaults(storage)
	return storage

func invert() -> NutrientStorage:
	return NutrientStorage.invert(create())

## ストレージをクリアして栄養素のみ初期化（defaults なし）
func apply_nutrition(storage: NutrientStorage, nutrition: NutrientPreloader) -> NutrientStorage:
	# nutrition プリローダーから栄養素を追加
	if nutrition != null:
		for key in nutrition.get_resource_list():
			storage._set_nutrient_internal(key, nutrition.create(key, 0))

	if storage.debug:
		print("[NutrientStorageConfig.apply_nutrition]: Initialized with %d nutrients" % storage.nutrients.size())

	storage.emit_changed()

	return storage

## 設定リソースから初期化
func apply_defaults(storage: NutrientStorage) -> void:
	# config から初期値をコピー
	if defaults.size() > 0:
		for nut in defaults:
			storage._set_nutrient_internal(nut.stats.name, nut.duplicate())

	if storage.debug:
		print("[NutrientStorageConfig.apply]: Initialized with %d nutrients" % storage.nutrients.size())

	storage.emit_changed()

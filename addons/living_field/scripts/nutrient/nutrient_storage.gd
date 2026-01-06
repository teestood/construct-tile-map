@tool
class_name NutrientStorage extends NutrientContainer
"""実行時の栄養素プール（辞書ベース）

動的な栄養素の増減、支払い判定を行う。
高速なルックアップのため辞書構造を使用。"""

signal nutrients_count_changed
signal nutrient_added
signal nutrient_changed(key: StringName, amount: float)

@export var debug: bool = false
@export var initial_amount: NutrientAmount  # 初期値（カプセル化）
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

func clear() -> void:
	nutrients.clear()

## 初期値から栄養素を設定（GroundFieldの初期化統合）
func initialize_from_amount(amount: NutrientAmount, preloader: NutrientPreloader = null) -> void:
	"""initial_amountまたは指定したNutrientAmountから栄養素を初期化"""
	clear()
	
	# プリローダーから栄養素の種類を初期化
	if preloader != null:
		for key in preloader.get_resource_list():
			_set_nutrient_internal(key, preloader.create(key, 0))
	
	# 初期値を適用
	var target_amount = amount if amount != null else initial_amount
	if target_amount != null:
		target_amount.apply_to(self)

func reset_to_initial(preloader: NutrientPreloader = null) -> void:
	"""initial_amountに基づいて栄養素をリセット"""
	initialize_from_amount(initial_amount, preloader)
	emit_changed()

## 初期化用内部メソッド（カプセル化）
func _set_nutrient_internal(key: StringName, nutrient: Nutrient) -> void:
	nutrients[key] = nutrient
	if debug:
		print("[NutrientStorage._set_nutrient_internal]: Set %s = %d" % [key, nutrient.amount])

## _ready() 時に呼ぶ初期化メソッド
func initialize_nutrient(nutrition: NutrientPreloader, key: StringName, initial_amount: float = 0.0) -> Nutrient:
	"""新しい栄養素を初期化"""
	if nutrients.has(key):
		push_warning("[NutrientStorage.initialize_nutrient]: '%s' already initialized" % key)
		return nutrients[key]
	
	nutrients[key] = nutrition.create(key, initial_amount)
	nutrient_added.emit(key)
	nutrients_count_changed.emit()
	
	if debug:
		print("[NutrientStorage.initialize_nutrient]: Initialized %s = %d" % [key, initial_amount])
	
	return nutrients[key]

## シンプルなルックアップ
func get_nutrient(key: StringName) -> Nutrient:
	"""既存の栄養素を取得"""
	if not nutrients.has(key):
		push_warning("[NutrientStorage.get_nutrient]: Nutrient '%s' not found" % key)
		return null
	return nutrients[key]

## 後方互換性のため
func get_or_add(nutrition: NutrientPreloader, key: StringName) -> Nutrient:
	"""非推奨：initialize_nutrient() または get_nutrient() を使用"""
	if not nutrients.has(key):
		return initialize_nutrient(nutrition, key, 0)
	return nutrients[key]

func is_empty() -> bool:
	return nutrients.size() == 0

func can_pay(cost: NutrientContainer) -> bool:
	"""指定コストを支払えるか判定"""
	if cost == null or cost.get_nutrients().is_empty():
		return true  # コストなし = 支払い可能
	
	for nut in cost.get_nutrients():
		if not nutrients.has(nut.stats.name):
			if debug:
				print("[NutrientStorage.can_pay]: Missing nutrient '%s'" % nut.stats.name)
			return false
		if nutrients[nut.stats.name].amount < nut.amount:
			if debug:
				print("[NutrientStorage.can_pay]: Insufficient '%s' (need: %d, have: %d)" % [nut.stats.name, nut.amount, nutrients[nut.stats.name].amount])
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

## 複数のStorageを現在のStorageに追加（in-place）
func add_storages(storages: Array[NutrientStorage]) -> void:
	"""複数のStorageを現在のStorageに追加"""
	if debug:
		print("[NutrientStorage.add_storages]: Adding ", storages.size(), " storages")
	
	for storage in storages:
		if storage is NutrientStorage:
			add_container(storage)
		else:
			push_warning("[NutrientStorage.add_storages]: Invalid storage type: %s" % storage.get_class())


func clone() -> NutrientStorage:
	"""現在のStorageを複製（各Nutrientを独立として複製）"""
	var newstorage := NutrientStorage.new()
	for key in nutrients.keys():
		# 各Nutrientを個別に複製
		newstorage.nutrients[key] = nutrients[key].duplicate()
	return newstorage


## 複数のNutrientContainerをマージして新しいStorageを作成
static func merge(containers: Array[NutrientContainer]) -> NutrientStorage:
	"""複数のContainerをマージして新しいStorageを作成"""
	var result = NutrientStorage.new()
	var nutrient_sums: Dictionary = {}
	
	for container in containers:
		if container == null:
			continue
		if not container is NutrientContainer:
			push_warning("[NutrientStorage.merge]: Invalid container type: %s" % container.get_class())
			continue
		
		for nut in container.get_nutrients():
			var key = nut.stats.name
			if not nutrient_sums.has(key):
				# 各Nutrientを複製して独立を確保
				nutrient_sums[key] = nut.duplicate()
			else:
				nutrient_sums[key].amount += nut.amount
	
	for key in nutrient_sums:
		# さらに複製してStorage保存時の独立性を確保
		result._set_nutrient_internal(key, nutrient_sums[key].duplicate())
	
	return result

## 内容を反転した新しいStorageを作成して返す
func invert() -> NutrientStorage:
	"""現在のStorageを反転（コスト計算用に負の値に変換）"""
	var inverted = self.clone()
	for key in inverted.nutrients.keys():
		inverted.nutrients[key].amount = -inverted.nutrients[key].amount
	return inverted
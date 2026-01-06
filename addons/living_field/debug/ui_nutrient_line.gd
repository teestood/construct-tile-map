@tool
class_name UINutrientLine extends HBoxContainer

const DefaultScene = preload("res://addons/living_field/debug/ui_nutrient_line.tscn")

@onready var ui_title: Label = $Title
@onready var ui_quantity: SpinBox = $Quantity
@onready var ui_reserve: Label = $Reserve

func set_quantity(val: float):
	if ui_quantity.value == val:
		return

	ui_quantity.value = val

static func instantiate(nut: Nutrient, reserve: Nutrient) -> UINutrientLine:
	var ui_nutrient :UINutrientLine = DefaultScene.instantiate()
	ui_nutrient.get_node("Title").text = nut.stats.name + ":"

	var ui_quantity: SpinBox = ui_nutrient.get_node("Quantity")
	ui_quantity.value = nut.amount
	ui_quantity.value_changed.connect(func(val):
		if nut.amount == val:
			return
		nut.amount = val
	)

	var ui_reserve: Label = ui_nutrient.get_node("Reserve")
	ui_reserve.text = str(reserve.amount)
	reserve.quantity_changed.connect(func(val):
		ui_reserve.text = str(val)
	)

	return ui_nutrient

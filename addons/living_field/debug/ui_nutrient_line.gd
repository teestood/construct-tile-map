@tool
class_name UINutrientLine extends HBoxContainer

const DefaultScene = preload("res://addons/living_field/debug/ui_nutrient_line.tscn")

@onready var ui_title: Label = $Title
@onready var ui_capacity: SpinBox = $Capacity
@onready var ui_amount: SpinBox = $Amount

func set_quantity(val: float):
	if ui_amount.value == val:
		return

	ui_amount.value = val

static func instantiate(capacity: Nutrient, amount: Nutrient) -> UINutrientLine:
	var ui_nutrient :UINutrientLine = DefaultScene.instantiate()
	ui_nutrient.get_node("Title").text = capacity.stats.name + ":"

	var ui_capacity: SpinBox = ui_nutrient.get_node("Capacity")
	ui_capacity.value = capacity.amount
	ui_capacity.value_changed.connect(func(val):
		if capacity.amount == val:
			return
		capacity.amount = val
	)

	var ui_amount: SpinBox = ui_nutrient.get_node("Amount")
	ui_amount.value = amount.amount
	ui_amount.value_changed.connect(func(val):
		if amount.amount == val:
			return
		amount.amount = val
	)
	var ui_title = ui_nutrient.get_node("Title")
	ui_title.add_theme_color_override("font_color", amount.stats.color)

	return ui_nutrient
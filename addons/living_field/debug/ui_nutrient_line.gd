@tool
class_name UINutrientLine extends HBoxContainer

const DefaultScene = preload("res://addons/living_field/debug/ui_nutrient_line.tscn")

@onready var ui_title: Label = $Title
@onready var ui_quantity: SpinBox = $Quantity

func set_quantity(val: float):
	if ui_quantity.value == val:
		return

	ui_quantity.value = val

static func instantiate(nut: Nutrient) -> UINutrientLine:
	var ui_nutrient :UINutrientLine = DefaultScene.instantiate()
	ui_nutrient.get_node("Title").text = nut.stats.name + ":"
	var ui_quantity: SpinBox = ui_nutrient.get_node("Quantity")
	ui_quantity.value = nut.amount
	ui_quantity.value_changed.connect(func(val):
		if nut.amount == val:
			return
		nut.amount = val
	)
	nut.quantity_changed.connect(ui_quantity.set_value_no_signal)

	return ui_nutrient

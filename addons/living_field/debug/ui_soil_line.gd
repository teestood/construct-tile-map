@tool
class_name UISoilLine extends HBoxContainer

const DefaultScene = preload("res://addons/living_field/debug/ui_soil_line.tscn")

@onready var title: Label = $Title
@onready var length: Label = $Length

func set_length(val: int):
	var s = str(val)
	if length.text == s:
		return
	length.text = s


static func instantiate(title: StringName, length: int) -> UISoilLine:
	var ui_soil :UISoilLine= DefaultScene.instantiate()
	ui_soil.get_node("Title").text = title + ":"
	ui_soil.get_node("Length").text = str(length)

	return ui_soil
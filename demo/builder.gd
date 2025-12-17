extends Node

@export var field: Fields


var hold: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if hold:
		field.try_construct_at_cursor()

func _input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.is_pressed():
				hold = true
			elif ev.is_released():
				hold = false

	#get_viewport().set_input_as_handled()

func clear():
	field.clear()

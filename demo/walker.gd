extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: Sprite2D = $Sprite2D

var chase_cursor: bool = false

func _physics_process(_delta: float) -> void:
	if NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return

	if chase_cursor:
		var prev = agent.target_position
		agent.target_position = get_global_mouse_position()
		if not agent.is_target_reachable():
			agent.target_position = prev

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
		
	
	var pos = agent.get_next_path_position()
	velocity = velocity * .8 + global_position.direction_to(pos) * SPEED
	move_and_slide()
	sprite.flip_h =  0 < velocity.x

func _input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_RIGHT:
			if ev.is_pressed():
				chase_cursor = true
			elif ev.is_released():
				chase_cursor = false

#	#get_viewport().set_input_as_handled()

class_name Worker extends RigidBody2D

@export var plan: ConstructPlan
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

@export var tileshape: RectangleShape2D

enum State{
	IDLE,
	MOVE,
	WORK,
}

var state: Worker.State

var target_coords: Vector2i

func _ready() -> void:
	agent.target_desired_distance = 16.0
	agent.path_max_distance = 1024.0
	timer.start(.5)
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(_delta: float) -> void:
	if NavigationServer2D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return

	if agent.is_navigation_finished():
		if state == Worker.State.MOVE:
			if not agent.is_target_reachable():
				state = Worker.State.IDLE
				print("target is not reachable: ", target_coords)

			if not plan.progress_cells.has(target_coords):
				print("target cell is already built: ", target_coords)
				state = Worker.State.IDLE
				return

			_build_tile()
		return
		
	
	var pos = agent.get_next_path_position()

	var decay_distance_sqr = 30^2
	var speed = 300
	var distance_sqr = global_position.distance_squared_to(pos)
	if distance_sqr < decay_distance_sqr:
		speed = speed * distance_sqr / decay_distance_sqr
	apply_central_force(global_position.direction_to(pos) * speed)

	sprite.flip_h =  0 < linear_velocity.x

## 計画地形を適用する建設作業を実行する
func _build_tile():
	# 建設予定地内のオブジェクトをどかせる
	var target_pos = plan.map_to_global(target_coords)
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.transform = Transform2D(0, target_pos)
	query.shape = tileshape
	for result in space.intersect_shape(query):
		if result.collider is RigidBody2D:
			var node = result.collider as RigidBody2D
			var diff = node.global_position - target_pos
			print("apply impulse to: ", result.collider.name, "@", diff.normalized() * 200)
			node.apply_impulse(diff.normalized() * 200, diff)
	
	state = Worker.State.WORK

	# 建設アニメーションを再生し、完了後に地形を適用する
	var anim = TileBuildAnimation.instantiate(plan, target_coords)
	plan.ground.add_child(anim)

	await anim.finished
	print("applying to ground at: ", target_coords)
	plan.apply_to_ground(target_coords)
	state = Worker.State.IDLE

func _on_timer_timeout() -> void:
	if state != Worker.State.IDLE:
		return
	var l = len(plan.progress_cells)
	if l == 0:
		return
	target_coords = plan.progress_cells[randi_range(0, l-1)]
	print("[Worker] destination: ", plan.map_to_global(target_coords), ":@", target_coords)
	agent.target_position = plan.map_to_global(target_coords)
	state = Worker.State.MOVE

class_name Entities extends Node2D

@export var spawners: Array[PlantSpawner]
@export var ground: GroundField

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for spawner in spawners:
		spawner.queued.connect(_on_Spawner_queued.bind(spawner))
	
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)

func _on_child_entered_tree(child: Node) -> void:
	if child.has_method(&"join_ground"):
		child.join_ground(ground)

func _on_child_exiting_tree(child: Node) -> void:
	if child.has_method(&"leave_ground"):
		child.leave_ground()

func _on_Spawner_queued(req: PlantSpawnRequest, spawner: PlantSpawner) -> void:
	var coords = _pick_rand(ground.cells_by_soil[&"grass"])
	var plant = req.pack.instantiate() as Plant
	var newposition = ground.map_to_local(coords) + _rand_vec(8.)
	plant.position = newposition

	assert(coords == ground.to_local_coords(plant.global_position), "coords mismatch: %s vs %s" % [coords, ground.to_local_coords(plant.global_position)])

	add_child(plant)

	spawner.accept_spawn(plant)

func _pick_rand(l: Array) -> Vector2i:
	var idx = randi() % l.size()
	return l[idx]

func _rand_vec(magnitude: float) -> Vector2:
	var angle = randf() * TAU
	return Vector2(cos(angle), sin(angle)) * magnitude
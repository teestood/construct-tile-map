@tool
class_name PlantSpawner extends DirectoryResourcePreloader

@export var plants: Array[Plant]
## packのspawnをリクエストする、成功すればinstantiatedが呼ばれる
signal queued(req: PlantSpawnRequest)
## spawnが完了したときに呼ばれる
signal instantiated(node: Node2D)

@export var interval: float = 5.0
@export var ground: GroundField

@onready var timer: Timer = $Timer


var exists: Dictionary[Vector2i, Node] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(_spawn_random)
	timer.start(interval)


func _spawn_random() -> void:
	if not queue(PlantSpawnRequest.random(&"plant")):
		push_error("Failed to queue plant spawn request")


func queue(req: PlantSpawnRequest) -> bool:
	if not has_resource(req.key):
		return false

	var scene = get_resource(req.key)
	if scene == null:
		return false
	req.pack = scene
	queued.emit(req)
	return true

# accept_spawn called when queued signal is processed and node is instantiated
func accept_spawn(node: Plant):
	plants.append(node)
	node.tree_exited.connect(func():
		plants.erase(node)
	)
	instantiated.emit(node)

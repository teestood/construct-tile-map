class_name PlantSpawner extends Node2D

@onready var preloader: ResourcePreloader = $ResourcePreloader
@onready var spawn_timer: Timer = $SpawnTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer.timeout.connect(_on_SpawnTimer_timeout)

func _on_SpawnTimer_timeout():
	for n in preloader.get_resource_list():
		preloader.get_resource(n)
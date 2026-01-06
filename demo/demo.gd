extends Node2D

@export var field: Fields
@export var region: NavigationRegion2D

@export var time_scale: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	field.instance_updated.connect(func():
		region.bake_navigation_polygon()
	)

	if time_scale != 1.0:
		Engine.time_scale = time_scale

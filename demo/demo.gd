extends Node2D

@export var field: Fields
@export var region: NavigationRegion2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	field.instance_updated.connect(func():
		print("INSTANCE UPDATE")
		region.bake_navigation_polygon()
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

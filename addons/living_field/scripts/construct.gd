## 建築物の主要な機能を管理するクラス
class_name Construct extends StaticBody2D

@export var priority: int = 0
#@onready var tilemap_plan: ConstructTileMapPlan = $ConstructTileMapPlan
#@onready var tilemap: GroundField = $GroundField


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
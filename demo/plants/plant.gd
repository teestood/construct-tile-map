class_name Plant extends Node2D

@warning_ignore("unused_signal")
signal soil_changed(from: StringName, to: StringName)

var ground: GroundField
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.frame_coords = Vector2i(0, 0)
	var tw := create_tween()
	tw.tween_property(sprite, "frame_coords", Vector2i(15, 0), 0.5).set_trans(Tween.TRANS_QUAD)

	soil_changed.connect(_on_soil_changed)

func _on_soil_changed(from: StringName, to: StringName) -> void:
	print("Plant %s detected soil change from %s to %s" % [name, from, to])
	queue_free()


# グラウンド参加イベント
func join_ground(newground: GroundField) -> void:
	ground = newground
	ground.listen_soil(self)

func leave_ground() -> void:
	print("LEAVE GROUND")
	if ground == null:
		print("LEAVE GROUND with null")
		return
	ground.unlisten_soil(self)
	ground = null

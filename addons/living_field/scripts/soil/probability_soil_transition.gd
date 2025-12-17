## 確率で移行する
class_name ProbabilitySoilTransition extends SoilTransition

@export var probability: float = .5

func _challenge(_tilemap: TileMapLayer, _coords: Vector2i) -> bool:
	return randf() < probability
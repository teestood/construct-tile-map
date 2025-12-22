class_name PlantSpawnRequest extends Resource

enum Setup{
	DEFAULT,
	RANDOM,
}

@export var pack: PackedScene
@export var key: String
@export var setup: Setup

@export var position: Vector2
@export var rotation: Vector2

static func create(name: String, pos: Vector2, rot: Vector2) -> PlantSpawnRequest:
	var req = PlantSpawnRequest.new()
	req.key = name
	req.position = pos
	req.rotation = rot
	return req

static func random(name: String) -> PlantSpawnRequest:
	var req = PlantSpawnRequest.new()
	req.key = name
	req.setup = Setup.RANDOM
	return req
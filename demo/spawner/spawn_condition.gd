class_name SpawnCondition extends Resource

func select_position(ctx: Dictionary[StringName, Variant]) -> Vector2i:
	var ground = ctx[&"ground"] as GroundField

	var grasses = ground.cells_by_soil["grass"] as Array[Vector2i]
	if grasses.size() == 0:
		return Vector2i.ZERO

	var coords = grasses[randi_range(0, len(grasses)-1)]
	return coords

func can_spawn_at(ctx: Dictionary[StringName, Variant], pos: Vector2i) -> bool:
	var exists = ctx[&"exists"] as Array[Vector2i]
	return not exists.has(pos)

func can_spawn(ctx: Dictionary[StringName, Variant]) -> bool:
	var pos = select_position(ctx)
	return can_spawn_at(ctx, pos)
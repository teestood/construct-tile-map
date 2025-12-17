@tool
class_name Soil extends Resource

@export var name: StringName
@export var requires: Array[SoilCondition]
@export var transitions: Array[SoilTransition]

func check_require(ground: GroundField) -> bool:
	for require in requires:
		if not require.can_growth(ground, self):
			return false
	return true

func check_decay(ground: GroundField) -> bool:
	for require in requires:
		if not require.can_decay(ground, self):
			return false
	return true

# 土壌変化を試みる、成功すれば移行先の名前、そうでなければ現在の名前を返す
func try_transition(ground: GroundField, coords: Vector2i) -> StringName:
	for transition in transitions:
		var dest_soil = Soil.from_name(ground, transition.to)
		if not dest_soil.check_require(ground):
			continue # 変化先のタイルの作成条件を満たしていない

		# タイル変化を試みる
		if transition.challenge(ground, coords):
			var terrain = transition.get_next_terrain(ground)
			if len(terrain) == 2:
				ground.set_cells_terrain_connect([coords], terrain[0], terrain[1])

				return transition.to
	return name

func _to_string() -> String:
	if resource_name != name:
		resource_name = _make_string()
	return resource_name

func _make_string() -> String:
	return name


static func from_tiledata(td: TileData) -> Soil:
	return td.get_custom_data_by_layer_id(0) as Soil

static func from_name(ground: GroundField, soilname: StringName) -> Soil:
	return ground.resources.get_resource(soilname)

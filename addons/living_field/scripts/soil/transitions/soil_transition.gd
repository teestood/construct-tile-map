class_name SoilTransition extends Resource

const TRANSITION_NONE: StringName = &"_no_transition"

## groundの指定した座標に対して土壌変化を試みる
## 変化した場合、変化後の土壌名を返す。
func challenge(ground: GroundField, coords: Vector2i) -> StringName:
	return SoilTransition.TRANSITION_NONE
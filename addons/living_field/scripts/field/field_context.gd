class_name FieldContext extends RefCounted

var nutrition: Nutrition
var soils: Dictionary[StringName, Array]

static func create(nutrition: Nutrition, soils: Dictionary[StringName, Array]) -> FieldContext:
	var ctx = FieldContext.new()
	ctx.nutrition = nutrition
	ctx.soils = soils
	return ctx
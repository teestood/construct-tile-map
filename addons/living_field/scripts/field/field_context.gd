class_name FieldContext extends RefCounted

var nutrition: NutrientPreloader
var soils: Dictionary[StringName, Array]

static func create(nutrition: NutrientPreloader, soils: Dictionary[StringName, Array]) -> FieldContext:
	var ctx = FieldContext.new()
	ctx.nutrition = nutrition
	ctx.soils = soils
	return ctx
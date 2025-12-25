@tool
class_name NutrientPreloader extends DirectoryResourcePreloader

@export var template: Nutrient

func create(key: StringName, amount: float = 0) -> Nutrient:
	assert(template != null)
	var instance = template.duplicate()
	assert(has_resource(key))
	instance.stats = get_resource(key)
	instance.amount = amount
	return instance

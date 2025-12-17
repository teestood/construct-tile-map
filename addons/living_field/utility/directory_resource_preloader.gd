@tool
class_name DirectoryResourcePreloader extends ResourcePreloader

@export_group("Directory")
@export_tool_button("Refresh", "Callable")
@warning_ignore("unused_private_class_variable")
var _refresh_action = _load_file

@export_dir var dir_path: String
@export_group("")

func _load_file():
	clear()

	var dir := DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var path = dir_path + "/" + file_name
				var res = ResourceLoader.load(path)
				if res:
					var key = file_name.get_basename()  # "carbon" from "carbon.tres"
					if not has_resource(key):
						add_resource(key, res)
			file_name = dir.get_next()
		dir.list_dir_end()

func clear():
	for key in get_resource_list():
		remove_resource(key)
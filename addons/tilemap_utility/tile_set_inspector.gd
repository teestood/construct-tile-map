@tool
extends Control

@onready var ui_terrain_template_selector: OptionButton = %TerrainTemplateSelector
@onready var ui_source_texture: TextureRect = %SourceTexture

@onready var ui_source_id: SpinBox = %SourceID
var source_id: int:
	get: return ui_source_id.value
@onready var ui_terrain_set_id: SpinBox = %TerrainSetID
var terrain_set_id: int:
	get: return ui_terrain_set_id.value

@onready var ui_edge: Control = %Edge
@onready var ui_center: Control = %Center

@onready var ui_apply: Button = %Apply
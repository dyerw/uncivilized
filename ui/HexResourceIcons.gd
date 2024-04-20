extends Node2D

@onready var resource_row = $"ResourceIconRowContainer"

func add_resource(resource_id: String):
	var texture_rect: TextureRect = TextureRect.new()
	resource_row.add_child(texture_rect)
	var texture = load(GameConfig.get_resource_value(resource_id, GameConfig.ICON_PATH))
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL

extends Node2D

@onready var wheat_texture = preload("res://assets/plants/wheat_icon.png")

func place_flora_icons(wheat_map: Array):
	var size = wheat_map.size()
	for x in range(size):
		for y in range(size):
			if wheat_map[x][y]:
				place_wheat_icon(Vector2i(x, y))

func place_wheat_icon(pos: Vector2i):
	var sprite = Sprite2D.new()
	add_child(sprite)
	sprite.texture = wheat_texture
	sprite.position = HexUtil.hex_to_pixel_center(pos, 256, 256)
	sprite.scale = Vector2(0.1, 0.1)

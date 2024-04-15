extends Node2D

@onready var huts_texture = preload("res://assets/units/huts_icon.png")

func draw_polity(polity: Polity):
	var sprite = Sprite2D.new()
	add_child(sprite)
	sprite.texture = huts_texture
	sprite.scale = Vector2(0.2, 0.2)
	sprite.position = HexUtil.hex_to_pixel_center(polity.position, 256, 256)
	sprite.centered = true

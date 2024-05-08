extends Node2D

@onready var huts_texture = preload("res://assets/units/huts_icon.png")

var player_polity_sprite: Sprite2D

var tween_ref: Tween = null

func draw_polity(polity: Polity):
	var sprite = Sprite2D.new()
	player_polity_sprite = sprite
	add_child(sprite)
	sprite.texture = huts_texture
	sprite.scale = Vector2(0.2, 0.2)
	sprite.position = HexUtil.hex_to_pixel_center(polity.position)
	sprite.centered = true

func move_polity(pos: Vector2i, ticks: int):
	var new_pos = HexUtil.hex_to_pixel_center(pos)
	print("UnitLayer: tweening to hex %s (pixel pos %s -> %s) for %s seconds" % [pos, player_polity_sprite.position, new_pos, ticks])
	if tween_ref != null:
		tween_ref.kill()
	tween_ref = create_tween()
	tween_ref.tween_property(player_polity_sprite, "position", Vector2(new_pos.x, new_pos.y), ticks)

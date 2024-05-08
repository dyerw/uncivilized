extends Node2D

signal player_move(pos: Vector2i)

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var global_pixel_coords = get_global_mouse_position()
		var hex_pos = HexUtil.pixel_to_hex(global_pixel_coords)
		player_move.emit(hex_pos)

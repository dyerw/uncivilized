extends Node2D

var center: Vector2i:
	set(value):
		center = value
		queue_redraw()

var radius: int:
	set(value):
		radius = value
		queue_redraw()

# Draws lines around the hex area
func _draw():
	if radius == null or center == null:
		return
	
	var pixel_center = HexUtil.hex_to_pixel_center(center)
	var points: Array[Vector2i] = []
	for side in range(5):
		

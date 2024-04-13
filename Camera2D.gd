extends Camera2D

func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		position -= event.relative
	if Input.is_action_pressed("zoom_in"):
		print("zoom in")
		zoom += Vector2(0.1, 0.1)
	if Input.is_action_pressed("zoom_out"):
		print("zoom in")
		zoom -= Vector2(0.1, 0.1)


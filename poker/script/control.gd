extends Control

var dragging = false

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			dragging = true
		else:
			dragging = false
			
func _process(delta):
	if dragging:
		global_position = get_global_mouse_position()

extends Node2D

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		var window = 0
		var mode = DisplayServer.window_get_mode(window)
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(window, DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(window, DisplayServer.WINDOW_MODE_FULLSCREEN)

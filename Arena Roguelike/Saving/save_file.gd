extends Button

func _on_save_file_pressed():
	print(pressed)
	if pressed:
		get_parent().get_parent().reset_selected()
		pressed = true
		get_parent().get_parent().selected_file = text
	else:
		get_parent().get_parent().selected_file = null


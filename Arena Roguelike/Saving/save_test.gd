extends Node2D



func save():
	var data = {
		"filename":filename,
		"parent":get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
	}
	return data

extends KinematicBody2D




func _physics_process(delta):
	global_position = get_global_mouse_position()

func die():
	queue_free()
	

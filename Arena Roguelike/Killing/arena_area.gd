extends Area2D


onready var splash = preload("res://Killing/splash.tscn")
onready var test = preload("res://test.tscn")


func _ready():
	set_process_input(false)


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		var instance = test.instance()
		instance.global_position = get_global_mouse_position()
		owner.add_child(instance)


func _on_arena_area_body_exited(body):
	if body.has_method("die"):
		var instance = splash.instance()
		body.add_child(instance)


func _on_arena_area_body_entered(body):
	#print(body,"Entered")
	pass

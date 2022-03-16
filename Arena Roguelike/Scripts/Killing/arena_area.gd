extends Area2D


onready var splash = preload("res://Scripts/Killing/splash.tscn")


func _ready():
	set_process_input(false)


func _on_arena_area_body_exited(body):
	if body.has_method("kill") and !body.is_in_group("flying"):
		var instance = splash.instance()
		body.add_child(instance)

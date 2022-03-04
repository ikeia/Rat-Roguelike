extends Node2D


onready var player = preload("res://Player/Player_Controller.tscn")
onready var enemey = preload("res://enemies/Enemy.tscn")


func _ready():
	#var p = player.instance()
	#p.global_position = $player_spawn.global_position
	#add_child(p)
	pass

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_accept"):
		var inst = enemey.instance()
		inst.global_position = Vector2(350,34)
		add_child(inst)

extends Node2D


onready var player = preload("res://Scenes/Entities/Player/Player_Controller.tscn")
onready var enemey = load("res://Scenes/Entities/enemies/EyeGuy.tscn")


func _ready():
	GM.world = self

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_accept"):
		var inst = enemey.instance()
		inst.global_position = Vector2(350,34)
		add_child(inst)

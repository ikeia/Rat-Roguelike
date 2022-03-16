extends Node2D


onready var player = preload("res://Scenes/Entities/Player/Player_Controller.tscn")
onready var eye = load("res://Scenes/Entities/enemies/EyeGuy/EyeGuy.tscn")
onready var zombie = load("res://Scenes/Entities/enemies/Zombo/Zombo.tscn")
onready var buttons = [get_node("DebugButtons/DebugButtons/XP"),get_node("DebugButtons/DebugButtons/eye"),get_node("DebugButtons/DebugButtons/zombie")]

var instancing = false

func _ready():
	GM.world = self
	for button in buttons:
		button.toggle_mode = true

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and !event.pressed:
			yield(get_tree().create_timer(0.1),"timeout")
			for button in buttons:
				button.pressed = false
	if event is InputEventKey:
			var button = null
			match event.scancode:
				KEY_1:
					button = buttons[0]
					if event.pressed:xp()
				KEY_2:
					button = buttons[1]
					if event.pressed:eye()
				KEY_3:
					button = buttons[2]
					if event.pressed:zomb()
			if button != null:
				button.pressed = event.pressed
				instancing = event.pressed
	
	#print(instancing)
					
		
				
			
func xp():
	UI.add_experience(1,position)
	

func eye():
	var inst = eye.instance()
	inst.global_position = Vector2(350,34)
	add_child(inst)

func zomb():
	var inst = zombie.instance()
	inst.global_position = Vector2(350,34)
	add_child(inst)

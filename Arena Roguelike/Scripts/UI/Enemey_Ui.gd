extends Node2D


onready var blood_drop = preload("res://Scenes/Entities/enemies/Blood_Drop.tscn")
onready var enemy_ref = get_parent()

var blood_drops:Array = []

func _ready():
	pass # Replace with function body.


func set_bleed():
	if blood_drops.size() == GM.Player.bleed: return false
	var drop = blood_drop.instance()
	$Bleed_Bar.add_child(drop)
	blood_drops.push_front(drop)
	drop.connect("bled",enemy_ref,"bleed")
	drop.connect("bled",self,"start_next")
	if blood_drops.size() == 1:
		drop.start()
	return true

func start_next():
	blood_drops.resize(blood_drops.size()-1)
	if blood_drops.size() != 0:
		blood_drops[-1].start()

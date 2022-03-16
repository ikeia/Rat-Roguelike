extends RigidBody2D

onready var blood = preload("res://Scripts/Killing/blood.tscn")
onready var sprite:Sprite = get_node("Sprite")
onready var healthBar:ProgressBar = get_node("Enemey_Ui/Health_Bar")
onready var BloodBar:HBoxContainer = get_node("Enemey_Ui/Bleed_Bar")
onready var anim:AnimationPlayer = get_node("AnimationPlayer")
onready var effect_anim:AnimationPlayer = get_node("Enemey_Ui/UI_Anim")

export(Array, NodePath) var STATES
var current_state:Node
var previous_state:Node
var states:Dictionary

var bleed:int = 0
var dead = false
var vel = Vector2(0,0)

export(int) var experience_gain = 5
export(int) var agression = 5
export(int) var vision = 5
export(int) var speed = 5
export(int) var power = 5
export(float) var Health = 100
export(float) var Max_Health = 100


func _ready():
	set_physics_process(false)
	healthBar.max_value = Max_Health
	healthBar.visible = false
	if has_node("STATES") and states.size() == 0:
		STATES = get_node("STATES").get_children()
	if current_state == null:
		current_state = STATES[0]
		previous_state = current_state
	for state in STATES:
		states[state.name] = state
		state.body = self
	current_state.call_deferred("enter")
	set_physics_process(true)
	
	
func _physics_process(delta):
	current_state = current_state._update(delta)
	if current_state != previous_state:
		previous_state.exit()
		current_state.enter()
	previous_state = current_state
	
func kill():
	set_physics_process(false)
	if !dead:
		dead = true
		for x in range(0,5):
			var ang = x*72
			emit_blood(ang,false)
		anim.play("death")
		UI.add_experience(experience_gain,global_position)

func emit_blood(angle,one_shot=true):
	var inst = blood.instance() 
	inst.rotation = angle + 180
	inst.one_shot = one_shot
	add_child(inst)

func bleed():
	var damage = GM.Player.flat_damage/5
	emit_blood(rotation)
	if !take_damage(damage):kill()

func Hit(angle,_vel,damage):
	$Enemey_Ui.set_bleed()
	damage += (abs(_vel.x) + abs(_vel.y))/1000
	emit_blood(angle)
	if !take_damage(damage):kill()

func take_damage(amount):
	healthBar.visible = true
	Health = clamp(Health - amount,0,Max_Health)
	$Tween.interpolate_property(healthBar,"value",healthBar.value,Health,0.3,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.start()
	return bool(Health)	

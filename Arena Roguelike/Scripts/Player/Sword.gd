extends RigidBody2D


onready var hitBox = get_node("Sprite/Hitbox")
onready var sprite = get_node("Sprite")

var force = Vector2(0,0)

var flatDamage = 10

var crit_chance = 10
var crit_mult = 2
var bleed = 1
var bleed_rate = 1.5

var knockback = 50000

func _ready():
	sprite.scale = Vector2(0.2,0.2)
	hitBox.scale = Vector2(1,1)
	custom_integrator = true
	set_process_input(false)
	#$swordArea.modulate.a = 0

func make_primary():
	$swordArea.connect("area_entered",GM.Player,"in_sword",[true])
	$swordArea.connect("area_exited",GM.Player,"in_sword",[false])
	set_process_input(true)
	return self
	
#func _input(event):
	#if event is InputEventMouseButton:
		#event.pressed = false

func update_stats(Player = GM.Player):
	flatDamage = Player.flat_damage/(Player.split+1)
	bleed = Player.bleed
	bleed_rate = Player.bleed_rate
	crit_chance = Player.crit_chance
	crit_mult = Player.crit_mult

func _integrate_forces(state):
	linear_velocity = force
	if GM.Player != null:
		$Trail2D.visible = GM.Player.swinging
		sprite.use_parent_material = !GM.Player.swinging
	#$Trail2D.scale = $Sprite.scale + Vector2(0.6,0.6)
	$Drag.emitting = !GM.Player.swinging and GM.Player.global_position.distance_to(GM.Player.primSword.sprite.global_position) > GM.Player.tail_anchor_range+10 or GM.Player.sprinting


func _on_Hitbox_body_entered(body):
	if body.is_in_group("knock"):
		linear_velocity = Vector2.ZERO
		var vel = linear_velocity
		if vel == null: vel = Vector2.ZERO
		
		var ang = get_angle_to(body.global_position)
		hitBox.launch_angle = ang
		hitBox.strength = 250
		var launch = hitBox.get_launch_vector(ang,knockback)
		body.apply_impulse(Vector2.ZERO,launch+(linear_velocity*2))
		#apply_impulse(Vector2.ZERO,-launch/2)
		var chance = rand_range(0,clamp(100 - crit_chance,0,100))
		if chance <= crit_chance: 
			body.Hit(ang,vel,flatDamage*crit_mult-1)
			print("CRITICAL STRIKE")
			$AnimationPlayer.play("Crit")
		else:
			$AnimationPlayer.play("Hit")
			
		if body != null: body.Hit(ang,vel,flatDamage)
					
			
			

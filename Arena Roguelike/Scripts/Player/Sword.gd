extends RigidBody2D


onready var hitBox = get_node("Sprite/Hitbox")

var force = Vector2(0,0)

var flatDamage = 10

var crit_chance = 10
var crit_mult = 2
var bleed = 1
var bleed_rate = 1.5

func _ready():
	hitBox.scale = Vector2(1,1)
	custom_integrator = true

func update_stats():
	flatDamage = GM.Player.flat_damage/(GM.Player.split+1)
	bleed = GM.Player.bleed
	bleed_rate = GM.Player.bleed_rate
	crit_chance = GM.Player.crit_chance
	crit_mult = GM.Player.crit_mult

func _integrate_forces(state):
	linear_velocity = force


func _on_Hitbox_body_entered(body):
	if body.is_in_group("knock"):
		var vel = linear_velocity
		if vel == null: vel = Vector2.ZERO
		
		var ang = get_angle_to(body.global_position)
		hitBox.launch_angle = ang
		hitBox.strength = 250
		var launch = hitBox.get_launch_vector(ang,3000)
		body.apply_impulse(Vector2.ZERO,launch)
		$Sprite/Hit_Box.apply_impulse(Vector2.ZERO,-launch*900)
		
		if rand_range(0,clamp(100 - crit_chance,0,100)) <= crit_chance: 
			body.Hit(ang,vel,flatDamage*crit_mult-1)
			print("CRITICAL STRIKE")
			
		if body != null: body.Hit(ang,vel,flatDamage)

		#var currentBleed = body.bleed
		#if bleed > 0:
		#	body.bleed = true
		#	body.bleed += bleed-currentBleed
		#for bleed_hit in range(bleed-currentBleed):
		#	body.bleed -= 1
			
		#	yield(get_tree().create_timer(bleed_rate),"timeout")
		#	if !body.dead: body.Hit(ang,vel,flatDamage/5)
			
				
			
			

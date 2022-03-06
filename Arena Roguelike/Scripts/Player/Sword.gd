extends RigidBody2D


var force = Vector2(0,0)

var flatDamage = 10

var crit_chance = 10
var crit_mult = 2
var bleed = 1
var bleed_rate = 1.5

func _ready():
	GM.Weapon = self
	$Sprite/Hit_Box.scale = Vector2(1,1)
	print("sword instanced")
	custom_integrator = true


func _integrate_forces(state):
#	$Sprite/Hit_Box.scale = Vector2(1,1)
	linear_velocity = force
	#print(force)


func _on_Hitbox_body_entered(body):
	if body.is_in_group("knock"):
		var vel = linear_velocity
		if vel == null: vel = Vector2.ZERO
		
		var ang = get_angle_to(body.global_position)
		$Sprite/Hitbox.launch_angle = ang
		$Sprite/Hitbox.strength = 250
		var launch = $Sprite/Hitbox.get_launch_vector(ang,3000)
		body.apply_impulse(Vector2.ZERO,launch)
		
		if rand_range(0,clamp(100 - crit_chance,0,100)) <= crit_chance: 
			body.Hit(ang,vel,flatDamage*crit_mult-1)
			print("CRITICAL STRIKE")
			
		if body != null: body.Hit(ang,vel,flatDamage)
		#apply_impulse(Vector2.ZERO,-launch*10)
		var currentBleed = body.bleed
		if bleed > 0:
			body.bleed = true
			body.bleed += bleed-currentBleed
		for bleed_hit in range(bleed-currentBleed):
			body.bleed -= 1
			
			yield(get_tree().create_timer(bleed_rate),"timeout")
			if body.bleeding: body.Hit(ang,vel,flatDamage/5)
				
			
			

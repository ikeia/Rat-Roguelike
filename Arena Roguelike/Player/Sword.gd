extends RigidBody2D


var force = Vector2(0,0)

func _ready():
	$Sprite/Hit_Box.scale = Vector2(1,1)
	print("sword instanced")
	custom_integrator = true


func _integrate_forces(state):
#	$Sprite/Hit_Box.scale = Vector2(1,1)
	linear_velocity = force
	#print(force)


func _on_Hitbox_body_entered(body):
	if body.is_in_group("knock"):
		#$Sprite/Hit_Box.scale = Vector2(1,1)
		var ang = get_angle_to(body.global_position)
		$Sprite/Hitbox.launch_angle = ang
		$Sprite/Hitbox.strength = 250
		var launch = $Sprite/Hitbox.get_launch_vector(ang,3000)
		body.apply_impulse(Vector2.ZERO,launch)
		body.stagger(ang,linear_velocity)
		#apply_impulse(Vector2.ZERO,-launch*10)

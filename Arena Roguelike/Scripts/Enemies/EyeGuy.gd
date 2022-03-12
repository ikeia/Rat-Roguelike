extends enemy
	
func init():
	rotation_speed = 4
	vel = Vector2(20000,0)

func check_attack():
	#if detect([ray],500) and !anim.is_playing():
		#return true
	return false

func attack():
	anim.play("attack")
	
func movement():
	if detect(Rays,9000) and !anim.is_playing():
		linear_velocity = Vector2.ZERO
		anim.play("walk")

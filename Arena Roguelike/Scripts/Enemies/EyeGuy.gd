extends enemy
	
func init():
	rotation_speed = 3
	vel = Vector2(3000,0)

func check_attack():
	#if detect([ray],500) and !anim.is_playing():
		#return true
	return false

func attack():
	anim.play("attack")
	
func movement():
	if detect([ray],9000) and !anim.is_playing():
		anim.play("walk")

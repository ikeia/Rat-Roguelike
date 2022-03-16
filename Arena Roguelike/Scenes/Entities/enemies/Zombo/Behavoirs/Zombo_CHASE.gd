extends EnemyBehavoir
	
	
func init():
	target_player()
	rotation_speed = 4
	
func enter():
	self.speed = 210
	body.angular_damp = 1
	body.linear_damp = 5
	body.mass = 30
	body.anim.playback_speed = 2.5
	
func _update(delta):
	look(target.global_position, delta,0)
	movement()
	return self
	
func movement():
	var speed_mult = (1+(1-body.Health/body.Max_Health))
	if detect(Rays,100) and !body.anim.is_playing():
		set_constant_speed(speed*1.5*speed_mult)
	else:
		set_constant_speed(speed*speed_mult)

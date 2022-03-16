extends EnemyBehavoir
	
	
func init():
	target_player()
	rotation_speed = 4
	
func enter():
	body.anim.play("walk")
	self.speed = 100
	body.angular_damp = 1
	body.linear_damp = 5
	body.mass = 100
	body.anim.playback_speed = 1
	
func _update(delta):
	look(target.global_position, delta,0)
	movement()
	if body.Health <= body.Max_Health/2:
		return body.states.Chase
	return self
	
func movement():
	pass
	var speed_mult = (1+(1-body.Health/body.Max_Health))
	if detect(Rays,100) and !body.anim.is_playing():
		set_constant_speed(speed*1.5*speed_mult)
	else:
		set_constant_speed(speed*speed_mult)

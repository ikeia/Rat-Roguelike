extends EnemyBehavoir
	

var fly_dir:Vector2
var startingPos:Vector2	
	
func init():
	target_player()
	rotation_speed = 4
	
func enter():
	self.speed = 35000
	body.angular_damp = 1
	body.linear_damp = 1
	body.mass = 100
	body.anim.playback_speed = 1.5
	
func _update(delta):
	look(target.global_position, delta,0)
	movement()
	return self
	
func movement():
	if detect(Rays,9000) and !body.anim.is_playing():
		body.linear_velocity/=1.5
		body.anim.play("walk")

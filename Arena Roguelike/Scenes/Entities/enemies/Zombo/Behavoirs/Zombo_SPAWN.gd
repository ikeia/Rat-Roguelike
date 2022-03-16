extends EnemyBehavoir
	
var spawned = false
	
func init():
	detection = DETECTION.raycast
	rotation_speed = 10
	
func enter():
	spawned = false
	body.anim.play("spawn")
	body.global_position = GM.world.global_position + GM.RandDirection()*Vector2(600,300)
	look(GM.Player.global_position)
	yield(body.anim,"animation_finished")
	spawned = true
	
func _update(delta):
	if spawned:
		return body.states.Follow
	return self
	

		
		

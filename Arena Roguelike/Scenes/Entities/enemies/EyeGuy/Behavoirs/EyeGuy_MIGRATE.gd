extends EnemyBehavoir
	

var fly_dir:Vector2
var startingPos:Vector2	
var dir = Vector2.ZERO
var set_rot
	
func init():
	detection = DETECTION.raycast
	rotation_speed = 10
	
func enter():
	self.speed = 85000
	body.angular_damp = 50
	body.linear_damp = 2
	body.mass = 200
	body.anim.playback_speed = 2
	start_migration()

func start_migration():
	body.linear_velocity = Vector2.ZERO
	can_move = false
	dir = GM.RandDirection()*Vector2(2000,1200)
	body.global_position = GM.world.global_position + Vector2(dir)
	set_rot = look(GM.Player.global_position)
	yield(get_tree().create_timer(0.3),"timeout")
	can_move = true
	
func _update(delta):
	body.rotation = 0
	if can_move:
		if set_rot != null:
			body.sprite.rotation = set_rot
		movement()
		if body.Health <= body.Max_Health/2:
			return body.states.Follow
	return self
	
func movement():
	if !body.anim.is_playing():
		body.anim.play("walk")
	if detect(Rays,200,"Border"):
		start_migration()
		
		

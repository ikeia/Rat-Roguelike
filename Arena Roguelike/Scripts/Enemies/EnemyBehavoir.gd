extends Node
class_name EnemyBehavoir

var body setget initbody

var Rays:Array
var Areas:Array
enum DETECTION {raycast,area,none}
export(DETECTION) var detection = DETECTION.raycast

export(NodePath) var detection_parent = "Sprite"

export(float) var rotation_speed = 2
export(float) var speed = 3000 setget set_speed

var can_move = true

var target
export(bool) var self_update = false

#Override Methods
func init(): target_player()
func enter(): pass
func exit(): pass
func _update(delta): pass
func check_attack(): return false
func attack(): pass
func movement(): pass


func _ready():
	set_physics_process(self_update)
	init()

func set_speed(value):
	speed = value
	body.vel.x = speed

func initbody(value):
	body = value
	match detection:
		DETECTION.raycast:
			if body.has_node(String(detection_parent)+"/rays"): Rays = body.get_node(String(detection_parent)+"/rays").get_children()
			elif body.has_node(String(detection_parent)+"/RayCast2D"): Rays.append(body.get_node(String(detection_parent)+"/RayCast2D"))
		DETECTION.area:
			if body.has_node(String(detection_parent)+"/areas"): Areas = body.get_node(String(detection_parent)+"/rays").get_children()
			elif body.has_node(String(detection_parent)+"/Area2D"): Areas.append(body.get_node(String(detection_parent)+"/RayCast2D"))

func target_player(): target = GM.Player
		
func pulse():
	body.apply_impulse(Vector2.ZERO, body.vel.rotated(body.sprite.rotation+89.5))
	
func set_constant_speed(_speed:int):
	body.vel.x  = _speed
	body.linear_velocity = body.vel.rotated(body.sprite.rotation+89.5)

func look(pos:Vector2,delta=1,damping:float=1,rotSpeed=rotation_speed):
	if body !=  null:
		var angle = pos.angle_to_point(body.position)-89.5
		if delta != 1:
			body.rotation*=damping
			body.sprite.rotation = lerp_angle(body.sprite.rotation,angle,delta*rotSpeed)
		else:
			body.sprite.rotation = angle
		return angle

func detect(rays:Array,detect_range:float,group="Player"):
	for r in rays:
		if r is RayCast2D:
			r.cast_to = Vector2(0,detect_range)
			r.force_raycast_update()
			if r.is_colliding():
				if r.get_collider().is_in_group(group):
					return true
	return false

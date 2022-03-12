extends RigidBody2D
class_name enemy

onready var blood = preload("res://Scripts/Killing/blood.tscn")
onready var sprite:Sprite = get_node("Sprite")
onready var Rays:Array = get_node("Sprite/rays").get_children()
onready var healthBar:ProgressBar = get_node("Enemey_Ui/Health_Bar")
onready var anim:AnimationPlayer = get_node("AnimationPlayer")
onready var effect_anim:AnimationPlayer = get_node("effects_anim")

export(int) var agression = 5
export(int) var vision = 5
export(int) var speed = 5
export(int) var power = 5
export(float) var Health = 10
export(float) var Max_Health = 100
export(int) var experience_gain = 5


export(float) var rotation_speed = 2
export(float) var Idle_Spawn_Time = 1


var can_move = true
var bleed:int = 0
var dead = false

var vel = Vector2(3000,0)

var target

func _ready():
	healthBar.max_value = Max_Health
	healthBar.visible = false
	yield(get_tree().create_timer(Idle_Spawn_Time),"timeout")
	target_player()
	init()

func init():
	pass

func _update(delta):
	look(target.global_position, delta)
	movement()
	if check_attack(): attack()

func check_attack():
	return false

func attack():
	pass
	
func movement():
	pass

func target_player():
	target = GM.Player

func die():
	dead = true
	for x in range(0,5):
		var ang = x*72
		blood(ang,false)
	anim.play("death")
	UI.add_experience(experience_gain,global_position)

func blood(angle,one_shot=true):
	var inst = blood.instance() 
	inst.rotation = angle + 180
	inst.one_shot = one_shot
	add_child(inst)

func bleed():
	var damage = GM.Player.flat_damage/5
	damage += (abs(vel.x) + abs(vel.y))/1000
	blood(rotation)
	if !take_damage(damage):die()

func Hit(angle,vel,damage):
	$Enemey_Ui.set_bleed()
	damage += (abs(vel.x) + abs(vel.y))/1000
	blood(angle)
	if !take_damage(damage):die()

func take_damage(amount):
	healthBar.visible = true
	var Health = clamp(healthBar.value - amount,0,Max_Health)
	$Tween.interpolate_property(healthBar,"value",healthBar.value,Health,0.3,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.start()
	return bool(Health)
		
func pulse():
	apply_impulse(Vector2.ZERO, vel.rotated(sprite.rotation+89.5))
	
func set_constant_speed(speed:int):
	linear_velocity = vel.rotated(sprite.rotation+89.5)

func look(pos:Vector2,delta):
	rotation = 0
	sprite.rotation = lerp_angle(sprite.rotation,pos.angle_to_point(position)-89.5,delta*rotation_speed)

func detect(rays:Array,detect_range:float):
	for r in rays:
		if r is RayCast2D:
			r.cast_to = Vector2(0,detect_range)
			r.force_raycast_update()
			if r.is_colliding():
				if r.get_collider().is_in_group("Player"):
					return true
	return false

func _physics_process(delta):
	if target != null:
		_update(delta)

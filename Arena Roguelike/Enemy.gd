extends RigidBody2D
class_name enemy

onready var blood = preload("res://Killing/blood.tscn")

export(int) var agression = 5
export(int) var vision = 5
export(int) var speed = 5
export(int) var power = 5
export(int) var Health = 10


var can_move = true

var vel = Vector2(2500,0)

var target

var state_que = []
var current_state

func _ready():
	$Enemey_Ui/Health_Bar.max_value = Health * 10
	$Enemey_Ui/Health_Bar.visible = false
	yield(get_tree().create_timer(3),"timeout")
	target = Global.player
#detect --> follow

#follow/detect --> attack
#follow/detect --> avoid

#follow/lose --> search

#search --> wander

func die():
	for x in range(0,5):
		var ang = x*72
		blood(ang,false)
	$AnimationPlayer.play("death")

		

func blood(angle,one_shot=true):
	var inst = blood.instance() 
	inst.rotation = angle + 180
	inst.one_shot = one_shot
	add_child(inst)

func stagger(angle,vel):
	var damage = (abs(vel.x) + abs(vel.y))/1000*rand_range(0.5,5)
	blood(angle)
	if take_damage(damage):
		$AnimationPlayer.stop(false)
		$effects_anim.play("stagger")
		yield(get_tree().create_timer(0.3),"timeout")
		$AnimationPlayer.play("walk")
	else:
		die()

func take_damage(amount):
	var healthBar= $Enemey_Ui/Health_Bar
	healthBar.visible = true
	var target_value = healthBar.value - amount
	if target_value <= 0:
		target_value = 0
	$Enemey_Ui/Tween.interpolate_property(healthBar,"value",healthBar.value,target_value,0.3,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Enemey_Ui/Tween.start()
	#while true:
		#if healthBar.value == target_value:
			#break
		#healthBar.value = move_toward(healthBar.value,target_value,healthBar.step)
	Health = healthBar.value
	print(bool(Health)," ENEMEY NOT DEAD")
	return bool(Health)
		

	

func pulse():
	apply_impulse(Vector2.ZERO, vel.rotated($Sprite.rotation+89.5))

func _physics_process(delta):
	$Sprite/RayCast2D.force_raycast_update()
	if $Sprite/RayCast2D.is_colliding():
		if $Sprite/RayCast2D.get_collider().is_in_group("Player"):
			$AnimationPlayer.playback_speed = 2
	else:
		$AnimationPlayer.playback_speed = 1.15
	rotation = 0
	var player = get_parent().get_node("Player_Controller").global_position
	$Sprite.look_at(player)
	$Sprite.rotation -= 89.5

func detect():
	if current_state == "wander" or current_state == "search":
		state_que.append("follow")
		
	elif current_state == "follow":
		
		state_que.append("attack")

	

extends KinematicBody2D


#NODE REFERENCES
onready var tail_sec = preload("res://Player/Tail_Piece.tscn")
onready var sword = preload("res://Player/Sword.tscn")
onready var top = preload("res://Player/Top_Level.tscn")

#TAIL STUFF
export(int) var tail_length = 1 setget change_tail_length
export(float) var tail_width = 10 setget change_tail_width
const tail_sec_margin = 0.0
var tail_exists = false
var previous_points = []
var tail = null
var tail_strenth = 2000
export(float) var swing_cooldown = 0
export(int) var stamina_rec = 2
export(float) var stamina_dep = 0.5

#MOVEMENT STUFF
var direction:Vector2 = Vector2.ZERO
var prev_direction:Vector2 = Vector2.ZERO
var bounce_direction:Vector2 = Vector2.ZERO
var speed = 500
var accelertion = 100
var friction = 200
var current_velocity = Vector2.ZERO
var bounce_velocity = Vector2.ZERO
var current_speed = 0

#PLAYER STATES
var cooling_down = false
var bouncing = false
var swinging = false
var dead = false

var sword_pos:Vector2 = Vector2(0,0)


var to_spawn:Vector2 = Vector2(0,0)

func save():
	var data = {
		"is_instance":true,
		"file_name":filename,
		"parent":get_parent().get_path(),
		#"pos_x" : global_position.x, # Vector2 is not supported by JSON
		#"pos_y" : global_position.y,
		"player_pos" : global_position,
		"tail_length" : tail_length,
		"tail_width" : tail_width
		#"sword_pos_x" : $Top_Level/Sword.position.x,
		#"sword_pos_y" : $Top_Level/Sword.position.y
	}
	return data

func despawn():
	#for child in $Top_Level.get_children():
		#child.queue_free()
	if get_node("Top_Level") != null:
		$Top_Level.queue_free()
	queue_free()

func _ready():
	Global.player = self
	$UI.set_as_toplevel(true)
	#position = Vector2.ZERO
	set_physics_process(false)
	print("Resetting maybe?")
	#$Top_Level.set_as_toplevel(true)
	#$Top_Level.global_position = global_position
	#if sword_pos == Vector2.ZERO:
	call_deferred("change_tail_length",tail_length)	
	call_deferred("change_tail_width",tail_width)	
	
	yield(get_tree().create_timer(0.5),"timeout")
	set_physics_process(true)

func change_tail_length(length):
	#print("fuck gthis")
	#if to_spawn != Vector2.ZERO:
	#	to_spawn = position
	#position = Vector2.ZERO
	print(length," Length")

	if tail != null:
		print("Deleting old")
		remove_child(tail)
	tail_exists = false
	var t = top.instance()
	#t.global_position = Vector2.ZERO
	add_child(t)
	t.set_as_toplevel(true)
	tail = t
	#t.position = Vector2.ZERO
	#if false:
		#for x in range(tail_length):
		#	var child = $Top_Level.get_node(String(x))
		#	if child == null:
		#		break
		#	child.queue_free()
		#if get_node("Top_Level/Sword") != null:
			#$Top_Level/Sword.queue_free()
		#$Top_Level.add_child(sword.instance())
	#if sword_pos != Vector2(0,0):
		#$Top_Level/Sword.global_position = sword_pos
		#sword_pos = Vector2.ZERO
	tail_length = length
	if length == 0:
		length = 1
	for x in range(length):
		var sec = tail_sec.instance()
		sec.global_position = Vector2(global_position.x,global_position.y+tail_sec_margin*(length-x))
		sec.name = String(x)
		if x == 0:
			$Top_Level/Sword.global_position = sec.global_position + Vector2(0,160)
			sec.get_node("PinJoint2D").node_b = get_node("Top_Level/Sword").get_path()
		else:
			sec.get_node("PinJoint2D").node_b = get_node("Top_Level/"+String(x-1)).get_path()
		$Top_Level.add_child(sec)
		if x == length-1:
			$tail_body_joint.node_b = sec.get_path()
	#yield(get_tree().create_timer(1),"timeout")
	tail_exists = true
	#position = to_spawn
	#to_spawn = Vector2.ZERO

func change_tail_width(width):
	tail_width = width
	print("Strength: ",tail_strenth)
	print("Width: ",tail_width)
	$Top_Level/tail.width = width

			
func check_input():
	var v = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_just_pressed("ui_left"):
		self.tail_length += 1
	if Input.is_action_just_pressed("ui_right"):
		self.tail_length -= 1
	if Input.is_action_just_pressed("ui_up"):
		self.tail_strenth += 125
		self.tail_width += 1
	if Input.is_action_just_pressed("ui_down"):
		self.tail_strenth -= 125
		self.tail_width -= 1
		#get_parent().get_node("ColorRect").material.set_shader_param("global_position",global_position+$Camera2D.global_position)
	return v

func move_sword():
	var dir
	var min_dist = 0.6
	#var strenth = 1350
	var force = Vector2(tail_strenth,tail_strenth)
	#var angle = get_angle_to(get_global_mouse_position())
	#var dir = Vector2(cos(angle),sin(angle)).normalized()
	dir = (get_global_mouse_position() - $Top_Level/Sword.global_position).normalized()
	#print(dir)
	if false:
		if dir.x < min_dist and dir.x > -min_dist:
			force.x/=10
		if dir.y < min_dist and dir.y > -min_dist:
			force.y/=10
	dir = (get_global_mouse_position() - global_position).normalized()
	$Top_Level/Sword.force= force * dir


#Vector2(-44,57)
func turn_body():
	#look_at(direction*100+global_position)
	look_at(get_global_mouse_position())
	rotation_degrees += 270
	if !swinging:
		$Top_Level/Sword.apply_impulse(Vector2.ZERO,tail_strenth*prev_direction)
		$Top_Level/Sword/Sprite.rotation_degrees = rotation_degrees
	#$Top_Level/Sword.rotation_degrees = rotation_degrees
	prev_direction = direction
	
func rotate_sword():
	$Top_Level/Sword/Sprite.look_at(get_global_mouse_position())
	$Top_Level/Sword/Sprite.rotation_degrees += 270
	rotation_degrees+= 270
	
func body_col():
	return false
	if get_slide_count() != 0:
		var col = get_last_slide_collision().collider
		#var angle = get_angle_to(col.global_position)#+180
		#var dir = Vector2(cos(angle),sin(angle)).normalized()
		#if abs(dir.x) > abs(dir.y):
		#	dir.y = 0
		#else:
		#	dir.x = 0
		#bounce_velocity = current_speed*2
		#move_and_slide(bounce_velocity*dir)
		#bounce_direction = dir
		return true
	return false

func draw_tail():
	if tail_exists and get_node("Top_Level/Sword") != null:
		var points = [$Top_Level/Sword/Sprite.global_position]
		for x in range(tail_length):
			var point = get_node("Top_Level/"+String(x))
			if point != null:
				points.append(point.global_position)
		points.append(global_position)
		$Top_Level/tail.points = points
	#print(points)
	#print($Top_Level/tail.points)

func trajectory(state):
	if tail_exists:
		var line = get_node("Top_Level/trajectory")
		if line != null:
			if state:
				line.visible = true	
				line.points[0] = $Top_Level/Sword/Sprite/drag_point.global_position #+ Vector2(72,335)
				line.points[1] = get_global_mouse_position() #+ Vector2(-2475,-1000)#Vector2(460,2800)
			elif !state:
				line.visible = false
	
func _physics_process(delta):
	$UI.rect_global_position = global_position
	if Input.is_action_pressed("swing") and $UI/Bars/Swing.value > 0 and !cooling_down:
		$UI/Bars/Swing.visible = true
		swinging = true
		$UI/Bars/Swing.value -= stamina_dep
		if $UI/Bars/Swing.value == 0:
			cooling_down = true
			$Timer.start(swing_cooldown)
		if tail_exists:
			move_sword()
			rotate_sword()
			trajectory(true)
	else:
		swinging = false
		if cooling_down:
			$UI/AnimationPlayer.queue("cooldown_pulse")
		trajectory(false)
		if $UI/Bars/Swing.value == $UI/Bars/Swing.max_value:
			$UI/Bars/Swing.visible = false
		else:
			$UI/Bars/Swing.value += stamina_rec
		
	if tail_exists:
		draw_tail()
	
	direction = check_input()
	turn_body()
	if direction == prev_direction*-1:
		current_speed/=3
	if direction != Vector2.ZERO:
		current_speed = move_toward(current_speed,speed,accelertion)
	else:
		current_speed = move_toward(current_speed,0,friction)
	if current_speed != 0:
		if bouncing:
			current_velocity = move_and_slide(bounce_velocity*bounce_direction)
			bounce_velocity = move_toward(bounce_velocity,0,20)
			if bounce_velocity <= 3:
				bouncing = false
			#print(bounce_velocity)
		elif body_col():
			bouncing = true
			#$Timer.start(0.5)
		current_velocity = move_and_slide(current_speed*prev_direction)
			
func kill():
	var healthBar= $UI/Bars/Health
	$Tween.stop_all()
	#yield(get_tree().create_timer(1),"timeout")
	dead = true
	global_position = get_parent().get_node("player_spawn").global_position
	scale = Vector2(1,1)
	#$UI/Bars/Health.value = $UI/Bars/Health.max_value
	$Tween.interpolate_property(healthBar,"value",healthBar.value,healthBar.max_value,0.5,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.start()
	$HitBox/CollisionShape2D.disabled = false
	$Sprite.modulate.a = 1
	current_speed = 0
	set_physics_process(true)
	z_index = 0
	yield(get_tree().create_timer(0.5),"timeout")
	dead = false

func die():
	pass


func _on_Timer_timeout():
	cooling_down = false
	$UI/AnimationPlayer.clear_queue()
	$UI/AnimationPlayer.play("RESET")

func take_damage(amount):
	if !dead:
		var healthBar= $UI/Bars/Health
		healthBar.visible = true
		var target_value = healthBar.value - amount
		if target_value <= 0:
			target_value = 0
			kill()
		$Tween.interpolate_property(healthBar,"value",healthBar.value,target_value,0.3,Tween.TRANS_EXPO,Tween.EASE_IN)
		$Tween.start()
		$UI/AnimationPlayer.play("damage")
	

func _on_HitBox_body_entered(body):
	if body.is_in_group("damage"):
		take_damage(10)
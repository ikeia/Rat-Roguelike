extends KinematicBody2D


#NODE REFERENCES
onready var tail_sec = preload("res://Scenes/Entities/Player/Tail_Piece.tscn")
onready var sword = preload("res://Scenes/Entities/Player/Sword.tscn")
onready var top = preload("res://Scenes/Entities/Player/Top_Level.tscn")
onready var top_player_joint = preload("res://Scenes/Entities/Player/tail_body_joint.tscn")
onready var Staminabar = get_node("UI/Bars/Swing")
onready var UIanim = get_node("UI/AnimationPlayer")
onready var sprite  = get_node("Sprite")
var mouseDrag:Area2D
onready var hitbox = get_node("Sprite/HitBox")

#TAIL STUFF
export(int) var tail_length = 1 setget change_tail_length
export(float) var tail_width = 10 setget change_tail_width
const tail_sec_margin = 0.0
var tail_exists = false
var previous_points = []
var tails:Array = []
var primSword
var tail_anchor_range = 200



#MOVEMENT STUFF
var direction:Vector2 = Vector2.ZERO
var prev_direction:Vector2 = Vector2.ZERO
var bounce_direction:Vector2 = Vector2.ZERO
var accelertion = 100
var friction = 200
var current_velocity = Vector2.ZERO
var bounce_velocity = Vector2.ZERO
var current_speed = 0
var swordTarget
var inside_sword = false

#PLAYER STATES
var cooling_down = false
var bouncing = false
var swinging = false setget set_swing_state
var dead = false
var sprinting

#STATS
var Stamina:float = 100
var Health:float = 100

#EXPORT STATS
export(float) var Max_Health = 100
export(float) var Max_Stamina = 150 setget setMaxStam
export(float) var speed = 500

export(int) var split = 3 setget set_split, getSplit
export(float) var swing_cooldown = 0
export(int) var stamina_rec = 2
export(float) var stamina_dep = 0.5
export(float) var tail_strength = 1500 setget change_tail_strength, getStrength

export(float) var flat_damage = 10
export(int) var bleed = 1
export(float) var bleed_rate = 1.5
export(float) var crit_chance = 10
export(float) var crit_mult = 2

var sword_pos:Vector2 = Vector2(0,0)
var to_spawn:Vector2 = Vector2(0,0)

func _ready():
	GM.Player = self
	Health = Max_Health
	Stamina = Max_Stamina
	UI.maxHealth = Max_Health
	UI.maxStamina = Max_Stamina
	tail_sec = load("res://Scenes/Entities/Player/Tail_Piece.tscn")
	sword = load("res://Scenes/Entities/Player/Sword.tscn")
	top = preload("res://Scenes/Entities/Player/Top_Level.tscn")
	#$UI.set_as_toplevel(true)
	set_physics_process(false)
	self.split = split
	yield(get_tree().create_timer(0.5),"timeout")
	set_physics_process(true)
	mouseDrag = get_node("Mouse_Drag_Area")
	mouseDrag.set_as_toplevel(true)

func save():
	var data = {
		"is_instance":true,
		"file_name":filename,
		"parent":get_parent().get_path(),
		"wave_number":UI.wave,
		"level" : tail_length,
		"tail_width" : tail_width
	}
	return data
	
func update_sword():
	for tail in tails:
		tail.get_node("Sword").update_stats()

func despawn():
	for child in tails:
		child.queue_free()
	queue_free()

func set_split(amount):
	split = amount
	change_tail_length(tail_length,split)

func change_tail_length(length = tail_length, amount = split):
	#print("LENGTH: ",length)
	tail_length = length
	split = amount
	tail_exists = false
	for child in tails:
		child.queue_free()
	tails.clear()
	GM.Weapons.clear()
	
	for i in range(amount+1):
		var weapon = add_tail(length).get_node("Sword")
		weapon.update_stats(self)
		GM.Weapons.append(weapon)
	
	tail_exists = true
	
func add_tail(length):
	tail_sec = load("res://Scenes/Entities/Player/Tail_Piece.tscn")
	top = load("res://Scenes/Entities/Player/Top_Level.tscn")
	top_player_joint = load("res://Scenes/Entities/Player/tail_body_joint.tscn")
	
	var t = top.instance()
	add_child(t)
	t.set_as_toplevel(true)
	tails.append(t)
	if length == 0:
		length = 1
	for x in range(length):
		var sec = tail_sec.instance()
		sec.global_position = Vector2(global_position.x,global_position.y+tail_sec_margin*(length-x))
		sec.name = String(x)
		if x == 0:
			primSword = tails[-1].get_node("Sword").make_primary()
			primSword.global_position = sec.global_position + Vector2(0,160)
			sec.get_node("PinJoint2D").node_b = tails[-1].get_node("Sword").get_path()
		else:
			sec.get_node("PinJoint2D").node_b = tails[-1].get_node(String(x-1)).get_path()
		tails[-1].add_child(sec)
		if x == length-1:
			var sec_to_player = top_player_joint.instance()
			sec_to_player.name = sec_to_player.name+String(tails.size()-1)
			self.add_child(sec_to_player)
			sec_to_player.node_a = self.get_path()
			sec_to_player.node_b = sec.get_path()
	return t

func change_tail_width(width):
	tail_width = width
	#print("Strength: ",tail_strength)
	#print("Width: ",tail_width)
	for tail in tails:
		tail.get_node("tail").width = width

func change_tail_strength(strength):
	tail_strength = strength
	#self.tail_width += strength*0.001
			
func check_input():
	var v = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_just_pressed("swing") and Staminabar.value > 0 and !cooling_down and !sprinting:
		self.swinging = true
		#$Tween.interpolate_property(primSword.sprite,"scale",primSword.sprite.scale,Vector2(0.301,0.301),0.2)
		#$Tween.start()
	elif swinging:
		if Input.is_action_just_released("swing") or cooling_down:
			#for sword in GM.Weapons:
				#sword.force = Vector2.ZERO
			self.swinging = false
			#$Tween.interpolate_property(primSword.sprite,"scale",primSword.sprite.scale,Vector2(0.2,0.2),0.2)
			#$Tween.start()
	sprinting = Input.is_action_pressed("dash") and Staminabar.value > 0 and !cooling_down and !swinging
	if Input.is_action_just_pressed("dash"):
		for sword in GM.Weapons:
				sword.force = Vector2.ZERO
	return v

func move_sword():
	var dir
	var min_dist = 0.6
	var force = Vector2(tail_strength,tail_strength)
	var xAng = 0
	var mod = 1
	for tail in tails:
		var sword = tail.get_node("Sword")
		if false:
			if dir.x < min_dist and dir.x > -min_dist:
				force.x/=10
			if dir.y < min_dist and dir.y > -min_dist:
				force.y/=10
		dir = (swordTarget - global_position).normalized()
		sword.force = force * dir.rotated(deg2rad(xAng* mod)) * (1+tail_length*0.22)
		xAng += 15
		mod = -mod
		
func turn_body(delta):
	var angle = deg2rad((rad2deg(sprite.global_position.angle_to_point(get_global_mouse_position()))+270))
	var easeMult = delta*8
	sprite.rotation = lerp_angle(sprite.rotation,angle,easeMult)
	prev_direction = direction

#Rotate all sword instances while accounting for spread and symmetry
func rotate_sword(delta,dir=null,easeMult:float=5):
	#Store angle offset and base reversal mod
	var xAng = 270
	var mod = 1
	#Cycle through all tail instances
	for tail in tails.size():
		#Store sword
		var sword = tails[tail].get_node("Sword")
		#Spread for multiple swords
		if mod == -1: xAng += 0.5
		var angle
		if dir != null:
			angle = dir
		else:
			angle = (swordTarget*1).angle_to_point(sword.position)
		#ROTATE the SWORD
		#Hilt
		sword.rotation = lerp_angle(sword.rotation,angle-89.5 +(xAng * mod),delta*easeMult)
		#Sword Joint
		#tails[tail].get_node("0").rotation = sword.rotation
		#Player Joint
		get_node("tail_body_joint"+String(tail)).rotation = sword.rotation	
		#Reverse angle to keep swords symmetrical
		mod = -mod

#Draws a tail from the player to every joint leading up to the sword hilt
func draw_tail(tail):	
	#Stores sword hilt position
	var points = [tail.get_node("Sword/Sprite").global_position]	
	
	if !swinging:
		points.append(sprite.global_position)	
		tail.get_node("tail").points = points
		return
	#Cycles through and stores tail hinge joint positions
	for x in range(tail_length):
		var point = tail.get_node(String(x))
		#apply more damp to joints if not swinging

		if point != null:
			points.append(point.global_position)		
	#Store player butt position
	points.append(sprite.global_position)
	#Give stored positions for the that specifc tail's line 2D to draw
	tail.get_node("tail").points = points

func trajectory(state, origin:Vector2 = GM.Weapons[0].get_node("drag_point").global_position):
	if tail_exists:
		var tail = GM.Weapons[0].get_parent()
		var line = tail.get_node("trajectory")
		if line != null:
			if state:
				line.visible = true	
				line.points[0] = origin #+ Vector2(72,335)
				line.points[1] = get_global_mouse_position() #+ Vector2(-2475,-1000)#Vector2(460,2800)
			elif !state:
				line.visible = false

func clamp_vector(vector, clamp_origin, clamp_length):
	var offset = vector - clamp_origin
	return clamp_origin + offset.clamped(clamp_length)

func _physics_process(delta):
	direction = check_input()
	$dust.emitting = sprinting
	turn_body(delta)
	if sprinting:
		var s = (speed+(speed*0.5))
		var sprint_speed = Vector2(s,s)
		current_velocity = move_and_slide(sprint_speed.rotated(sprite.rotation-90))
	else:
		if direction == prev_direction*-1:
			current_speed/=3
		if direction != Vector2.ZERO:
			current_speed = move_toward(current_speed,speed,accelertion)
		else:
			current_speed = move_toward(current_speed,0,friction)
		if current_speed != 0:
			current_velocity = move_and_slide(current_speed*prev_direction)
	
	if tail_exists:
		if !inside_sword:
			swordTarget = get_global_mouse_position()
		else:
			swordTarget = GM.Weapons[0].get_node("temp_point").global_position
		#Cycle through tail instances
		for tail in tails:
			draw_tail(tail)
			if !swinging and !sprinting:
				var sword = tail.get_node("Sword")
				sword.mass = 500
				sword.linear_velocity = Vector2.ZERO
				#global_position = clamp_vector(global_position,sword.sprite.global_position, 200*tail_length)
				#sword.apply_impulse(Vector2.ZERO,-current_velocity*2)
			else:
				var sword = tail.get_node("Sword")
				if sprinting:
					sword.mass = 25
				else:
					sword.mass = 6
				
		if swinging:
			mouseDrag.global_position = get_global_mouse_position()
			move_sword()
			update_stamina(true)
			if !inside_sword:
				rotate_sword(delta)
			trajectory(true)
		else:
			
			if update_stamina(sprinting,0.6): 
				trajectory(true,sprite.get_node("drag_point").global_position)
				rotate_sword(delta,deg2rad(sprite.rotation_degrees+120),3)
				global_position = lerp(global_position,clamp_vector(global_position,primSword.sprite.global_position, tail_anchor_range*tail_length*1.3),delta*10)
			else:
				trajectory(false)
				if global_position.distance_to(primSword.sprite.global_position) > tail_anchor_range+10 and current_speed > speed*0.5:
					rotate_sword(delta,(-direction).angle(),1)
				global_position = lerp(global_position,clamp_vector(global_position,primSword.sprite.global_position, tail_anchor_range*tail_length),delta*10)


func update_stamina(is_using:bool,mult:float=1):	
	if is_using:
		Staminabar.visible = true
		Staminabar.value -= (stamina_dep*mult)
		if Staminabar.value == 0:
			cooling_down = true
			$Timer.start(swing_cooldown)
	else:
		if cooling_down:
			UIanim.queue("cooldown_pulse")
		if Staminabar.value == Staminabar.max_value:
			Staminabar.visible = false
		elif !sprinting:
			Staminabar.value += stamina_rec
	return is_using
		
func kill():
	$Tween.stop_all()
	dead = true
	Health = 0
	if Health == 0:
		UI.reset()
		get_tree().reload_current_scene()
	self.swinging = false
	#yield(get_tree().create_timer(1),"timeout")
	global_position = get_parent().get_node("player_spawn").global_position
	scale = Vector2(1,1)
	hitbox.get_node("CollisionShape2D").disabled = false
	sprite.modulate.a = 1
	current_speed = 0
	set_physics_process(true)
	z_index = 0
	yield(get_tree().create_timer(0.5),"timeout")
	dead = false

func _on_Timer_timeout():
	cooling_down = false
	UIanim.clear_queue()
	UIanim.play("RESET")

func take_damage(amount):
	Staminabar.value += amount*3
	if !dead:
		Health = clamp(Health-amount,0,Max_Health)
		UI.health = Health
		if Health == 0:
			kill()
	UIanim.play("damage")
	
func _on_HitBox_body_entered(body):
	if body.is_in_group("damage"):
		take_damage(10)

func getSplit():
	return split

func getStrength():
	return tail_strength

func setMaxStam(value):
	Max_Stamina = value
	Staminabar.max_value = value

func in_sword(area:Area2D,state):
	if area == mouseDrag:
		inside_sword = state

func set_swing_state(value):
	swinging = value
	if swinging:
		for sword in GM.Weapons:
			if sword.sprite != null:
				$Tween.interpolate_property(sword.sprite,"scale",sword.sprite.scale,Vector2(0.301,0.301),0.2)
	else:
		for sword in GM.Weapons:
			if sword.sprite != null:
				$Tween.interpolate_property(sword.sprite,"scale",sword.sprite.scale,Vector2(0.2,0.2),0.2)
				sword.force = Vector2.ZERO
	$Tween.start()

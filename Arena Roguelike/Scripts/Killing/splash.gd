extends CPUParticles2D

export(Vector2) var set_scale = Vector2(1,1)
onready var sprite = get_parent().get_node("Sprite")
onready var body =  get_parent()
var scale_ref

func _ready():
	#print("Dead")
	body.set_physics_process(false)
	body.z_index = -1
	scale_ref = sprite.scale
	#sprite.z_index = -1
	#body.z_as_relative = false
	#print(body.z_index)
	
func _physics_process(delta):
	
	if sprite.scale <= scale_ref/2:
		if !emitting:
			if !one_shot:
				one_shot = true
				emitting = true
			else:
				yield(get_tree().create_timer(1),"timeout")
				if body.has_method("kill"):
					body.kill()
					sprite.scale = scale_ref
					queue_free()
				else:
					body.queue_free()
		global_position = get_parent().global_position
		sprite.modulate.a = move_toward(sprite.modulate.a,0,0.1)
		
	else:
		sprite.global_position += Vector2(0,1)
		sprite.scale -= Vector2(0.015,0.015)
	scale = set_scale + (Vector2(1,1)-sprite.scale)

extends CPUParticles2D



func _ready():
	emitting = true


func _on_blood_hide():
	print("Gone")
	queue_free()

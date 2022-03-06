extends RigidBody2D


var vel = Vector2(10,0)

func _physics_process(delta):
	look_at(GM.Player.global_position)
	apply_impulse(Vector2.ZERO, vel.rotated(rotation))

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		UI.ExperienceBar.add_experience(1)
		queue_free()

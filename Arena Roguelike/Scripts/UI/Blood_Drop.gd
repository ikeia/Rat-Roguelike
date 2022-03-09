extends TextureProgress

signal bled

func start():
	$Tween.interpolate_property(self,"value",self.max_value,0,GM.Player.bleed_rate,Tween.TRANS_QUAD)
	$Tween.start()

func _on_Tween_tween_all_completed():
	emit_signal("bled")
	queue_free()

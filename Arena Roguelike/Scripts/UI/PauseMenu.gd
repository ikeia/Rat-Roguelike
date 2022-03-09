extends Control

func _ready():
	UI.set(name,self)
	visible = false
	modulate.a = 0
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.as_text() == "Escape" and event.pressed:
			if visible:
				UI.close()
			elif UI.currentMenu == null:
				UI.open(name)

func open():
	visible = true
	$Tween.stop_all()
	$Tween.interpolate_property(self,"modulate",modulate,Color(1,1,1,1),0.3)
	$Tween.start()
	get_tree().paused = true
	UI.StatPanel.open()

func close():
	$Tween.stop_all()
	$Tween.interpolate_property(self,"modulate",modulate,Color(1,1,1,0),0.1)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	visible = false
	get_tree().paused = false
	UI.StatPanel.close()

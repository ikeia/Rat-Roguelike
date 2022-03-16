extends Control

var init_pos_con
var offset = Vector2(0,500)

func _ready():
	UI.set(name,self)
	visible = false
	modulate.a = 0
	init_pos_con = $controls.rect_position
	
	
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
	$Tween.interpolate_property($controls,"rect_position",init_pos_con+offset,init_pos_con,0.4,Tween.TRANS_QUAD)
	$Tween.start()
	get_tree().paused = true
	UI.StatPanel.open(true)

func close():
	$Tween.stop_all()
	$Tween.interpolate_property(self,"modulate",modulate,Color(1,1,1,0),0.1)
	$Tween.interpolate_property($controls,"rect_position",init_pos_con,init_pos_con+offset,0.3,Tween.TRANS_QUAD)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	visible = false
	get_tree().paused = false
	UI.StatPanel.close()

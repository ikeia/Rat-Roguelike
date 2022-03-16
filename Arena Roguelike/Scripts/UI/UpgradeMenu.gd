extends Control

onready var choices:Array = get_node("Choices").get_children()
onready var info = get_node("InfoPanel/Info")
onready var upgradeName = get_node("InfoPanel/Name")

var offset = Vector2(0,2000)

var openDuration = 5

var upgradeSelection:Array = [GM.UpgradeType.CRIT]

var choosen = true

func _ready(): 
	$AnimationPlayer.play("begin")
	visible = false
	UI.set(name,self)
	setInfo(-1)
	for choice in choices:
		choice.connect("button_up", self, "ChooseUpgrade", [choice])
		choice.connect("mouse_entered", self, "setInfo", [choice])
		choice.connect("mouse_exited", self, "exitButton")

func open():
	if $Tween.is_active():
		yield($Tween,"tween_all_completed")
	get_tree().paused = true
	$Title.self_modulate.a = 1
	#GM.Player.tail_length = clamp(UI.level-2,1,10)
	$Text/TailLegnth.text = String(GM.Player.tail_length)
	$Text/Level.text = String(UI.level)
	generateUpgrades()
	$Tween.interpolate_property($Title,"rect_position",$Title.rect_position+offset,$Title.rect_position, openDuration*0.7, Tween.TRANS_ELASTIC)
	$Tween.interpolate_property($Panel,"rect_position",$Panel.rect_position+offset,$Panel.rect_position, openDuration*0.6, Tween.TRANS_ELASTIC)
	$Tween.interpolate_property($Text,"rect_position",$Text.rect_position+offset,$Text.rect_position, openDuration*0.7, Tween.TRANS_ELASTIC)
	
	$Tween.interpolate_property($Choices,"rect_position",$Choices.rect_position+offset,$Choices.rect_position, openDuration*0.8, Tween.TRANS_ELASTIC)
	#for i in range(choices.size()):
	#	$Tween.interpolate_property(choices[i],"rect_position",choices[i].rect_position+offset,choices[i].rect_position+offset, openDuration+i/1.5, Tween.TRANS_ELASTIC)
	$Tween.interpolate_property($InfoPanel,"rect_position",$InfoPanel.rect_position+offset,$InfoPanel.rect_position, openDuration*1, Tween.TRANS_ELASTIC)
	$Title.rect_position.y += offset.y
	$Panel.rect_position.y += offset.y
	$Text.rect_position.y += offset.y
	$Choices.rect_position.y += offset.y
	$InfoPanel.rect_position.y += offset.y
	visible = true
	$Tween.start()
	UI.StatPanel.open()
	yield($Tween,"tween_all_completed")
	$AnimationPlayer2.play("begin")
	choosen = false

	

func close():
	get_tree().paused = false
	$AnimationPlayer.stop(false)
	UI.StatPanel.close()
	GM.Player.swinging = Input.is_action_pressed("swing")
	#$AnimationPlayer.play("begin")
	$Tween.stop_all()
	$Tween.interpolate_property($Title,"rect_position",$Title.rect_position,$Title.rect_position-offset, openDuration*1, Tween.TRANS_ELASTIC)
	$Tween.interpolate_property($Panel,"rect_position",$Panel.rect_position,$Panel.rect_position-offset, openDuration*0.6, Tween.TRANS_ELASTIC)
	$Tween.interpolate_property($Text,"rect_position",$Text.rect_position,$Text.rect_position-offset, openDuration*0.7, Tween.TRANS_ELASTIC)
	$Tween.interpolate_property($Choices,"rect_position",$Choices.rect_position,$Choices.rect_position-offset, openDuration*0.8, Tween.TRANS_ELASTIC)
	$Tween.interpolate_property($InfoPanel,"rect_position",$InfoPanel.rect_position,$InfoPanel.rect_position-offset, openDuration*0.5, Tween.TRANS_ELASTIC)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	visible = false
	for choice in choices:
		choice.rect_position.y = 0
		choice.modulate.a = 1
	$AnimationPlayer.play("begin")
	$Title.self_modulate.a = 0
	

func generateUpgrades():
	randomize()
	upgradeSelection.clear()
	var options = GM.UpgradeType.keys().duplicate()
	options.shuffle()
	for i in range(3):
		upgradeSelection.append(options.pop_front())
	print(upgradeSelection)
	presentUpgrades()
	
func setInfo(choice:int):
	if choice == -1:
		info.bbcode_text = ""
		upgradeName.text = ""
		if UI.StatPanel != null:
			UI.StatPanel.reset_mods()
		return
	UI.StatPanel.set_values(GM.UpgradeType[upgradeSelection[choice]])
	info.bbcode_text = GM.UpgradeInfo[GM.UpgradeType[upgradeSelection[choice]]] 
	upgradeName.text = GM.UpgradName[GM.UpgradeType[upgradeSelection[choice]]]
	choices[choice].modulate.a = 1
	

func exitButton():
	setInfo(-1)
	UI.StatPanel.reset_mods()
	for choice in choices:
		choice.modulate.a = 0.5

func presentUpgrades():
	for choice in upgradeSelection.size():
		var c = choices[choice]
		c.texture_normal = GM.UpgradeIcons[GM.UpgradeType[upgradeSelection[choice]]]
		c.modulate.a = 0.5

func chooseUpgrade(choice:int):
	if !choosen:
		choosen = true
		if GM.UpgradeType[upgradeSelection[choice]] != null:
			UI.obtainUpgrade(GM.UpgradeType[upgradeSelection[choice]])
			print("Gained ",upgradeSelection[choice],"!")
			$Tween.interpolate_property(choices[choice],"rect_position",choices[choice].rect_position,choices[choice].rect_position-offset,3,Tween.TRANS_ELASTIC)
			$Tween.interpolate_property(choices[choice],"modulate",choices[choice].modulate,choices[choice].modulate-Color(0,0,0,1),3,Tween.TRANS_QUAD)
			$Tween.start()
			yield($Tween,"tween_all_completed")
			UI.close()
		else: printerr("The upgrade: ",choice," does not exist!")


func _on_Tween_tween_completed(object, key):
	if object == $Title:
		$AnimationPlayer.play("Idle")

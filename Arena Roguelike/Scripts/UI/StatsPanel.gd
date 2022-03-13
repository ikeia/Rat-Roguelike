extends Control

onready var Keys_ref:RichTextLabel = $Stats/Keys
onready var Values_ref:RichTextLabel = $Stats/Values
onready var edit_button = $edit_button

var Keys:Array
var Key_Mods:Dictionary = {
				  "speed":{"color":"#ffc24d", "waveAmp":"0"},
				  "Max_Health":{"color":"#ffc24d", "waveAmp":"0"},
						
				  "Max_Stamina":{"color":"#ffc24d", "waveAmp":"0"},
				  "stamina_rec":{"color":"#ffc24d", "waveAmp":"0"},
				  "stamina_dep":{"color":"#ffc24d", "waveAmp":"0"}, 

				  "tail_strength":{"color":"#ffc24d", "waveAmp":"0"}, 

				  "flat_damage":{"color":"#ffc24d", "waveAmp":"0"}, 

				  "crit_chance":{"color":"#ffc24d", "waveAmp":"0"}, 
				  "crit_mult":{"color":"#ffc24d", "waveAmp":"0"},

				  "bleed":{"color":"#ffc24d", "waveAmp":"0"}, 
				  "bleed_rate":{"color":"#ffc24d", "waveAmp":"0"},
				
				  "split":{"color":"#ffc24d", "waveAmp":"0"}
				}

var Values:Array
var Value_Mods:Dictionary = {
				  "speed":{"color":"#ffffff", "waveAmp":"0", "change":0},
				  "Max_Health":{"color":"#ffffff", "waveAmp":"0", "change":0},
						
				  "Max_Stamina":{"color":"#ffffff", "waveAmp":"0", "change":0},
				  "stamina_rec":{"color":"#ffffff", "waveAmp":"0", "change":0},
				  "stamina_dep":{"color":"#ffffff", "waveAmp":"0", "change":0}, 

				  "tail_strength":{"color":"#ffffff", "waveAmp":"0", "change":0}, 

				  "flat_damage":{"color":"#ffffff", "waveAmp":"0", "change":0}, 

				  "crit_chance":{"color":"#ffffff", "waveAmp":"0", "change":0}, 
				  "crit_mult":{"color":"#ffffff", "waveAmp":"0", "change":0},

				  "bleed":{"color":"#ffffff", "waveAmp":"0", "change":0}, 
				  "bleed_rate":{"color":"#ffffff", "waveAmp":"0", "change":0},
				
				  "split":{"color":"#ffffff", "waveAmp":"0", "change":0}
				}

var offset = Vector2(0,1000)

var edit_color
var confirm_color = Color(1,0.4,0.4)

func _ready():
	
	$edit.visible = false
	edit_color = edit_button.modulate
	_update()
	UI.StatPanel= self
	visible = false

func set_values(upgrade):
	var changes = GM.UpgradeEffects[upgrade]
	for change in changes.keys():
		increase_value(change,changes[change])
	_update()
	
func increase_value(valueName:String,changeAmount:float = 0):
	var value_color = "#ffffff"
	var key_color = "#ffffff"
	var value_amp = "0"
	var key_amp = "0"
	
	if changeAmount != 0:
		value_color =  "#7bf977"
		key_color =  "#7bf977"
		key_amp = "50"
		value_amp = "50"
	Key_Mods[valueName].color = key_color
	Key_Mods[valueName].waveAmp = key_amp
	Value_Mods[valueName].color =  value_color
	Value_Mods[valueName].waveAmp = value_amp
	Value_Mods[valueName].change = changeAmount
	
func _update():
	update_Keys()
	update_Values()

func reset_mods():
	for mods in Value_Mods.values():
		mods.color = "#ffffff"
		mods.waveAmp = "0"
		mods.change = 0
	for mods in Key_Mods.values():
		mods.color = "#ffc24d"
		mods.waveAmp = "0"
	_update()

func update_Keys():
	var mods = Key_Mods.values()
	Keys = [
				  "[table=<1>][cell][wave amp="+mods[0].waveAmp+" freq=2][color="+mods[0].color+"]Max Speed :[/color][/wave][/cell]",
				  "[cell][wave amp="+mods[1].waveAmp+" freq=2][color="+mods[1].color+"]Max Health :[/color][/wave][/cell]",
						
				  "[cell][wave amp="+mods[2].waveAmp+" freq=2][color="+mods[2].color+"]Max Stamina :[/color][/wave][/cell]",
				  "[cell][wave amp="+mods[3].waveAmp+" freq=2][color="+mods[3].color+"]Recharge Rate :[/color][/wave][/cell]",
				  "[cell][wave amp="+mods[4].waveAmp+" freq=2][color="+mods[4].color+"]Usage Rate :[/color][/wave][/cell]", 

				  "[cell][wave amp="+mods[5].waveAmp+" freq=2][color="+mods[5].color+"]Swing Speed :[/color][/wave][/cell]", 

				  "[cell][wave amp="+mods[6].waveAmp+" freq=2][color="+mods[6].color+"]Flat Damage :[/color][/wave][/cell]", 

				  "[cell][wave amp="+mods[7].waveAmp+" freq=2][color="+mods[7].color+"]Crit Chance :[/color][/wave][/cell]", 
				  "[cell][wave amp="+mods[8].waveAmp+" freq=2][color="+mods[8].color+"]Crit Multiplier :[/color][/wave][/cell]",

				  "[cell][wave amp="+mods[9].waveAmp+" freq=2][color="+mods[9].color+"]Bleed Stacks :[/color][/wave][/cell]", 
				  "[cell][wave amp="+mods[10].waveAmp+" freq=2][color="+mods[10].color+"]Bleed Rate :[/color][/wave][/cell]",
				
				  "[cell][wave amp="+mods[10].waveAmp+" freq=2][color="+mods[10].color+"]Tail Split :[/color][/wave][/cell][/table]"
			]
	Keys_ref.bbcode_text = ""
	for key in Keys:
		Keys_ref.bbcode_text += key

func update_Values():
		var mods = Value_Mods.values()
		var keys = Value_Mods.keys()
		Values = [
				  "[table=<1>][cell][wave amp="+mods[0].waveAmp+" freq=2][color="+mods[0].color+"]"+String(GM.Player.speed+mods[0].change)+"[/color][/wave][/cell]",
				  "[cell][wave amp="+mods[1].waveAmp+" freq=2][color="+mods[1].color+"]"+String(GM.Player.Max_Health+mods[1].change)+"[/color][/wave][/cell]",
						
				  "[cell][wave amp="+mods[2].waveAmp+" freq=2][color="+mods[2].color+"]"+String(100+mods[2].change)+"[/color][/wave][/cell]",
				  "[cell][wave amp="+mods[3].waveAmp+" freq=2][color="+mods[3].color+"]+"+String(GM.Player.stamina_rec+mods[3].change)+"/second[/color][/wave][/cell]",
				  "[cell][wave amp="+mods[4].waveAmp+" freq=2][color="+mods[4].color+"]-"+String(GM.Player.stamina_dep+mods[4].change)+"/second[/color][/wave][/cell]", 

				  "[cell][wave amp="+mods[5].waveAmp+" freq=2][color="+mods[5].color+"]"+String((GM.Player.tail_strength+mods[5].change)/100)+"mph[/color][/wave][/cell]", 

				  "[cell][wave amp="+mods[6].waveAmp+" freq=2][color="+mods[6].color+"]"+String(GM.Player.flat_damage+mods[6].change)+"[/color][/wave][/cell]", 

				  "[cell][wave amp="+mods[7].waveAmp+" freq=2][color="+mods[7].color+"]"+String(GM.Player.crit_chance+mods[7].change)+"%[/color][/wave][/cell]", 
				  "[cell][wave amp="+mods[8].waveAmp+" freq=2][color="+mods[8].color+"]"+String(GM.Player.crit_mult+mods[8].change)+"X[/color][/wave][/cell]",

				  "[cell] [wave amp="+mods[9].waveAmp+" freq=2][color="+mods[9].color+"]"+String(GM.Player.bleed+mods[9].change)+"X[/color][/wave][/cell]", 
				  "[cell][wave amp="+mods[10].waveAmp+" freq=2][color="+mods[10].color+"]"+String(1/(GM.Player.bleed_rate+mods[10].change))+"/second[/color][/wave][/cell]",
				
				  "[cell][wave amp="+mods[10].waveAmp+" freq=2][color="+mods[10].color+"]"+String(GM.Player.split+mods[10].change)+" tails[/color][/wave][/cell][/table]"
			]
		Values_ref.bbcode_text = ""
		for value in Values:
			Values_ref.bbcode_text += value
			
func open(can_edit:bool = false):
	edit_button.visible = can_edit
	if $Tween.is_active(): yield($Tween,"tween_all_completed")
	reset_mods()
	$Tween.interpolate_property(self,"rect_position",Vector2.ZERO-offset,Vector2.ZERO,1.75,Tween.TRANS_ELASTIC)
	rect_position.y = 0-offset.y
	visible = true
	$Tween.start()

func close():
	reset_mods()
	$Tween.interpolate_property(self,"rect_position",Vector2.ZERO,Vector2.ZERO-offset,1.2,Tween.TRANS_ELASTIC)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	visible = false
	rect_position.y = 0
	
func edit():
	if $edit.visible:
		confirm_edit()
		return
	for value in $edit.get_children():
		value.text = String(GM.Player.get(value.name))
	$edit.visible = true
	Values_ref.visible = false
	edit_button.text = "Confirm"
	$edit_button.modulate = confirm_color

func confirm_edit():
	$edit.visible = false
	Values_ref.visible = true
	for value in $edit.get_children():
		GM.Player.set(value.name,float(value.text))
	_update()
	edit_button.text = "Edit"
	$edit_button.modulate = edit_color

extends Control

var extra:float
export(float) var current_experience
var max_experience
var current_level = 1

func _ready(): 
	UI.set(name,self)
	$Fill.value = 0
	current_experience = $Fill.value
	
func add_experience(amount:float):
	$Fill.value += amount
	if current_experience + amount >= $Fill.max_value:
		extra = (current_experience+amount)-$Fill.max_value
		$XP_anim.play("Level Up")
		yield($XP_anim,"animation_finished")
		add_experience(extra)
		UI.level_up()
	else: current_experience = $Fill.value

func add_level():
	current_level += 1
	var level:String
	if current_level < 10: level = " "
	level += String(current_level)
	$Level.text = level
	UI.level = current_level

	

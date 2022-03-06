extends Control

func _ready(): UI.set(name,self)

func set_maxHealth(amount:float):
	$FastFill.max_value = amount
	$SlowFill.max_value = amount
	$FastFill.value = amount
	$SlowFill.value = amount

func set_health(amount:float):
	$FastFill.value = amount
	$Tween.interpolate_property($SlowFill,"value",$SlowFill.value,amount,1,Tween.EASE_OUT)
	$Tween.start()

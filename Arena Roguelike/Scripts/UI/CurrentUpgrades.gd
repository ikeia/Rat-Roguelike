extends Control

func _ready(): UI.set(name,self)

func add(upgrade):
	var icon:TextureRect
	var upgrades = $upgrades.get_children()
	icon = upgrades[-1]
	$upgrades.add_child(icon.duplicate())
	icon.texture = GM.UpgradeIcons[upgrade]

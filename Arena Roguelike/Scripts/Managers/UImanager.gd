extends Control

var HealthBar:Control setget initHealth, getHealthBar
var ExperienceBar:Control
var UpgradeMenu:Control
var PauseMenu:Control
var CurrentUpgrades:Control
var StatPanel:Control

var XP = load("res://Scenes/Entities/XP.tscn")

var upgradesObtained:Array setget obtainUpgrade, GetCurrentUpgrades

var currentMenu:Node

var health:float setget set_health, get_health
var maxHealth:float setget set_maxHealth, get_maxHealth

var stamina:float setget set_stamina
var maxStamina:float setget set_maxStamina

var experience:float
var experience_goal:float = 28
var experience_goal_increase:float = 2
var level = 1

var wave

func obtainUpgrade(upgrade):
	if upgradesObtained.size() != level-1:
		upgradesObtained.append(upgrade)
		GM.applyUpgrade(upgrade)
		CurrentUpgrades.add(upgrade)

func GetCurrentUpgrades():
	return upgradesObtained

func initHealth(bar:Control):
	HealthBar = bar
	HealthBar.set_maxHealth(GM.Player.Max_Health)
	HealthBar.set_health(GM.Player.Health)

func getHealthBar():
	return HealthBar
	
func set_health(value:float):
	health = clamp(value,0,maxHealth)
	if HealthBar != null: HealthBar.set_health(health)

func get_maxHealth():
	return maxHealth

func get_health():
	return health
	
func set_maxHealth(value:float):
	maxHealth = value
	if HealthBar != null: HealthBar.set_maxHealth(value)

func set_stamina(value:float):
	stamina = clamp(value,0,maxStamina)
	
func set_maxStamina(value:float):
	maxStamina = value
	GM.Player

func add_experience(amount:float,position:Vector2 = Vector2.ZERO):
	experience = clamp(ExperienceBar.current_experience+amount,0,experience_goal)
	if ExperienceBar != null: 
		for i in range(amount):
			var xp = XP.instance()
			xp.global_position = position
			GM.world.add_child(xp)
			#ExperienceBar.add_experience(amount)

func level_up():
	open("UpgradeMenu")
	experience_goal *= experience_goal_increase
	#GM.Player.tail_length += 1

func open(menuName:String):
	if currentMenu != null:
		printerr("Close ",currentMenu.name," before opening a new menu")
		return false
	currentMenu = get(menuName)
	currentMenu.open()
	return true

func close():
	if currentMenu != null:
		currentMenu.close()
		currentMenu = null
		return true
	return false

extends Node

var Wave
var Player
var Weapons:Array
var world

enum EntityType{
	PLAYER,
	ENEMY,
}

enum EnemyType{
	MINO,
	EYE,
	CHUB,
	SKULL,
	LURKER
}

enum UpgradeClass{
	SWORD,
	STAT,
	ACTIVE
}



enum UpgradeType{
	#STAT (increase a stat variable)
	CRIT, #Chance to CRIT
	#[MAX ~]
	SHARPNESS, #flatDamage #bleedOverTime
	#[MAX ~]
	STRENGTH, #swingSpeed playerSpeed flatDamage
	#[MAX ~]
	ENDURANCE, #maxHealth maxStamina staminaDrain staminaGain
	#[MAX ~]
	#ACTIVELEVEL, #If you have an active you can choose to upgrade or get a new one(upgrades persists between actives)
	#[MAX 3]
	#DASH, #Gives you an additional dash, extends safe window	
	#[MAX 4]
	
	#SWORD (special sword effects)
	SPLIT, #1 additional tail (total flatDamage is distrubuted)
	
	#ACTIVES (Mutually Exclusive with cooldown)
	#HOMING, #Land a guranteed hit (chains on upgrade)
	#FLAMING, #Make a trail of fire (Fire lasts longer and does slightly more on upgrade)
	#FLOWING, #Move super quickly and accurately (Lasts longer and moves faster on upgrade)
	#LEECH, #Give lifesteal (gives more health on upgrade)
	#BLOCK, #Become your weapon (lasts longer on upgrade)
}

var NumCol = "#ff5656"

var UpgradeInfo:Dictionary = {
	UpgradeType.CRIT: "[table=<2>] [cell][color="+NumCol+"]+10[/color] %Chance to crit[/cell] [cell]     [color="+NumCol+"]+0.1[/color] crit multiplier[/cell] [/table]",
	UpgradeType.SHARPNESS: "[table=<2>] [cell][color="+NumCol+"]+5[/color] Flat damage[/cell] [cell]     [color="+NumCol+"]+2[/color] Bleed over time[/cell] [/table]",
	UpgradeType.STRENGTH: "[table=<2>] [cell][color="+NumCol+"]+5[/color] Swing speed[/cell]   [cell]     [color="+NumCol+"]+5[/color] Flat damage[/cell]  [cell][color="+NumCol+"]+3[/color] Player speed[/cell]",
	UpgradeType.ENDURANCE: "[table=<2>] [cell][color="+NumCol+"]+30[/color] Max health[/cell] [cell]     [color="+NumCol+"]+10[/color] Max stamina[/cell] [cell][color="+NumCol+"]-0.05[/color] Stamina drain[/cell] [cell]     [color="+NumCol+"]-0.1[/color] Stamina recharge[/cell][/table]",
	#UpgradeType.ACTIVELEVEL: "- OR - |UPGRADE exsisting active|",
	#UpgradeType.DASH: "[color="+NumCol+"]+1[/color] addtional dash",
	
	UpgradeType.SPLIT: "[color="+NumCol+"]+1[/color] additional tail/weapon and disperses flat damage between them",
	
	#UpgradeType.HOMING: "|Land a guranteed hit that can chain on UPGRADE|",
	#UpgradeType.FLAMING: "|Leave behind a firey trail that lingers longer on UPGRADE|",
	#UpgradeType.FLOWING: "|Move quickly and accurately with increased speed and duration on UPGRADE|",
	#UpgradeType.LEECH: "|Gain health on attack giving more health on UPGRADE|",
	#UpgradeType.BLOCK: "|Become invunerable giving a longer duration on UPGRADE|",
}

var UpgradName:Dictionary = {
	UpgradeType.CRIT: "Critical Strike",
	UpgradeType.SHARPNESS: "Sharpness",
	UpgradeType.STRENGTH: "Strength",
	UpgradeType.ENDURANCE: "Endurance",
	#UpgradeType.ACTIVELEVEL: "- OR - |UPGRADE exsisting active|",
	#UpgradeType.DASH: "Dash",
	
	UpgradeType.SPLIT: "Split",
	
	#UpgradeType.HOMING: "|Land a guranteed hit that can chain on UPGRADE|",
	#UpgradeType.FLAMING: "|Leave behind a firey trail that lingers longer on UPGRADE|",
	#UpgradeType.FLOWING: "|Move quickly and accurately with increased speed and duration on UPGRADE|",
	#UpgradeType.LEECH: "|Gain health on attack giving more health on UPGRADE|",
	#UpgradeType.BLOCK: "|Become invunerable giving a longer duration on UPGRADE|",
}

var UpgradeIcons:Dictionary = {
	UpgradeType.CRIT: load("res://Assets/Upgrades/crit.png"),
	UpgradeType.SHARPNESS: load("res://Assets/Upgrades/Sharpness.png"),
	UpgradeType.STRENGTH: load("res://Assets/Upgrades/strength.png"),
	UpgradeType.ENDURANCE: load("res://Assets/Upgrades/endurance.png"),
	#UpgradeType.ACTIVELEVEL: load(), #Some kind of PLUS icon
	#UpgradeType.DASH: load("res://Assets/Upgrades/dash.png"),
	
	UpgradeType.SPLIT: load("res://Assets/Upgrades/dash.png"),
	
	#UpgradeType.HOMING: load(),
	#UpgradeType.FLAMING: load(),
	#UpgradeType.FLOWING: load(),
	#UpgradeType.LEECH: load(),
	#UpgradeType.BLOCK: load(),
}

var UpgradeEffects:Dictionary = {
	UpgradeType.CRIT: {"crit_chance":10,"crit_mult":0.25},
	UpgradeType.SHARPNESS: {"flat_damage":5,"bleed":2,"bleed_rate":-0.1},
	UpgradeType.STRENGTH: {"tail_strength":500,"flat_damage":5,"speed":50},
	UpgradeType.ENDURANCE: {"Max_Health":30,"stamina_rec":-0.5,"stamina_dep":-0.03},
	#UpgradeType.ACTIVELEVEL: load(), #Some kind of PLUS icon
	#UpgradeType.DASH: load("res://Assets/Upgrades/dash.png"),
	UpgradeType.SPLIT: {"flat_damage":-5,},
	
	#UpgradeType.HOMING: load(),
	#UpgradeType.FLAMING: load(),
	#UpgradeType.FLOWING: load(),
	#UpgradeType.LEECH: load(),
	#UpgradeType.BLOCK: load(),
}

func applyUpgrade(upgrade):
	match upgrade:
		UpgradeType.CRIT:
			Player.crit_chance += 10
			Player.crit_mult += 0.25
			Player.update_sword()
		UpgradeType.STRENGTH:
			Player.flat_damage += 5
			Player.tail_strength += 500
			Player.speed += 50
			Player.update_sword()
		UpgradeType.SHARPNESS:
			Player.flat_damage += 5
			Player.bleed += 2
			Player.bleed_rate -= 0.1
			Player.update_sword()
		UpgradeType.ENDURANCE:
			Player.Max_Health += 30
			Player.stamina_rec -= 0.5
			Player.stamina_dep -= 0.03
		#UpgradeType.DASH:
			#printerr("DASH NOT IMPLEMENTED!")
		UpgradeType.SPLIT:
			#Player.split += 1
			Player.set_split(1)
		#UpgradeType.HOMING:
			#pass
		#UpgradeType.FLAMING:
			#pass
		#UpgradeType.FLOWING: 
			#pass
		#UpgradeType.LEECH: 
			#pass
		#UpgradeType.BLOCK: 
			#pass

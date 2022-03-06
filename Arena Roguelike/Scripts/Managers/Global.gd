
enum EntityType{
	PLAYER,
	ENEMY,
	HURT,
	TRIGGER
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
	ACTIVELEVEL, #If you have an active you can choose to upgrade or get a new one(upgrades persists between actives)
	#[MAX 3]
	DASH, #Gives you an additional dash, extends safe window	
	#[MAX 4]
	
	#SWORD (special sword effects)
	SPLIT, #1 additional tail (total flatDamage is distrubuted)
	
	#ACTIVES (Mutually Exclusive with cooldown)
	HOMING, #Land a guranteed hit (chains on upgrade)
	FLAMING, #Make a trail of fire (Fire lasts longer and does slightly more on upgrade)
	FLOWING, #Move super quickly and accurately (Lasts longer and moves faster on upgrade)
	LEECH, #Give lifesteal (gives more health on upgrade)
	BLOCK, #Become your weapon (lasts longer on upgrade)
}

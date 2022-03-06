extends TextureButton

var upgradeType

func updateChoice():
	if GM.UpgradeType.has(GM.UpgradeType[upgradeType]):
		texture_normal = GM.UpgradeIcons[GM.UpgradeType[upgradeType]]
		



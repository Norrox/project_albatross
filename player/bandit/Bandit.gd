extends "res://player/Player.gd"

func _rotate_gun(rotation):
	$Pivot/Rifle.rotation = rotation
	
	if check_flip():
		$Sprite.flip_h = true
		$Pivot/Rifle.flip_v = true
	else:
		$Sprite.flip_h = false
		$Pivot/Rifle.flip_v = false

extends "res://player/human/weapons/rifle/Rifle.gd"

const Bullet = preload("res://player/skeleton/weapon/WandBullet.tscn")

func _shoot(bullet_pos, bullet_rot, bullet_dir):
	var bullet = Bullet.instance()
	add_child(bullet)
	bullet.z_index = 1
	bullet.rotation = bullet_rot
	bullet.global_position = bullet_pos
	bullet.direction = bullet_dir
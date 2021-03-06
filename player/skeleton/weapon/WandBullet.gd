extends "res://player/human/weapons/bullet/Bullet.gd"

const muzzle_flash = preload("res://player/skeleton/weapon/Wand_Flash.tscn")
const on_hit_particle = preload("res://player/skeleton/Red_Hit_Particle.tscn")

func _ready():
	SPEED = 200
	FORWARD_AMT = 27

func _physics_process(delta):		
	if !collided:
		position += direction * SPEED * delta
		var scale = 1.015
		$Hitbox.scale *= scale
		$Sprite.scale *= scale

func _on_Lifetime_timeout():
	._on_Lifetime_timeout()

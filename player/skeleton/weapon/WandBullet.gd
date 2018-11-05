extends "res://weapons/bullet/Bullet.gd"

const muzzle_flash = preload("res://player/skeleton/weapon/Wand_Flash.tscn")
const on_hit_particle = preload("res://weapons/bullet/Red_Hit_Particle.tscn")

const ROT_AMT = 10

func _ready():
	._ready()
	SPEED = 250
	FORWARD_AMT = 15

func _physics_process(delta):
	if can_rotate:
		rotate(delta)
	if !collided:
		position += direction * SPEED * delta
		var scale = 1.015
		$Hitbox.scale *= scale
		$Sprite.scale *= scale

func _on_Lifetime_timeout():
	._on_Lifetime_timeout()
	
func rotate(delta):
	rotation += ROT_AMT * delta

extends "res://weapons/bullet/Bullet.gd"

const muzzle_flash = preload("res://player/bandit/Pistol_Flash.tscn")
const on_hit_particle = preload("res://weapons/bullet/Hit_Particle.tscn")
const shell = preload("res://player/bandit/GrayShell.tscn")

func _ready():
	SPEED = 400
	FORWARD_AMT = 27

func _physics_process(delta):		
	if !collided:
		position += direction * SPEED * delta

func _on_Lifetime_timeout():
	._on_Lifetime_timeout()

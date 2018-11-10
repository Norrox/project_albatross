extends Area2D

const HIT_DELAY = 15

var SPEED = 500
var DAMAGE = 5
var FORWARD_AMT = 35

const on_hit_particle = preload("res://player/human/weapons/bullet/Hit_Particle.tscn")
const muzzle_flash = preload("res://player/human/weapons/bullet/Muzzle_Flash.tscn")
const shell = preload("res://player/human/weapons/bullet/Shell.tscn")

var direction = 0
var player = null
var collided = false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	set_as_toplevel(true)
	var muzzle_flash_obj = muzzle_flash.instance()
	
	if "Bullet" in name:
		var shell_obj = shell.instance()
		shell_obj.global_position = global_position
		$'/root/'.add_child(shell_obj)
	
	get_parent().add_child(muzzle_flash_obj)
	$BulletSound.play()
	player = $'../../../'

func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	if !collided:
		position += direction * SPEED * delta

func _on_body_entered(body):
	if body.is_a_parent_of(self):
		return
	$HitSound.play()
	if body.is_in_group('players') and !body.rolling:	
		#OS.delay_msec(HIT_DELAY)
		body.damage(DAMAGE)
		destroy(body)
	elif 'Chest' in body.name:
		#OS.delay_msec(HIT_DELAY)
		body.open(player)
	elif 'Destructable' in body.name or 'Crate' in body.name:
		#OS.delay_msec(HIT_DELAY)
		body.hit()
		destroy(body)
	if !$Hitbox.disabled:
		destroy(body)
	
func destroy(body):
	hide_and_remove()
	
func hide_and_remove():
	collided = true
	for child in get_children():
		if child.has_method('hide'):
			child.hide()
	$Hitbox.disabled = true
	var on_hit_particle_obj = on_hit_particle.instance()
	add_child(on_hit_particle_obj)
	on_hit_particle_obj.global_position = get_collision_point()
	on_hit_particle_obj.rotation = randi()%361+1
	var particle_anim = on_hit_particle_obj.get_node('AnimationPlayer')
	particle_anim.play('hit')
	yield(particle_anim, 'animation_finished')
	queue_free()
	
func get_collision_point():
	#fix with more accurate
	return (global_position + direction * FORWARD_AMT)

func _on_Lifetime_timeout():
	hide_and_remove()

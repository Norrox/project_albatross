extends Area2D

const HIT_DELAY = 20

export(float) var SPEED = 750
export(float) var DAMAGE = 5

onready var on_hit_particle = preload("res://weapons/bullet/Hit_Particle.tscn")
onready var muzzle_flash = preload("res://weapons/bullet/Muzzle_Flash.tscn")
onready var shell = preload("res://weapons/bullet/Shell.tscn")

var direction = 0
var player = null
var collided = false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	set_as_toplevel(true)
	var muzzle_flash_obj = muzzle_flash.instance()
	var shell_obj = shell.instance()
	shell_obj.global_position = global_position
	$'/root/'.add_child(shell_obj)
	get_parent().add_child(muzzle_flash_obj)
	$AudioStreamPlayer2D.play()
	player = $'../../'
	yield(get_tree().create_timer(1), "timeout")
	queue_free()

func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	if !collided:
		position += direction * SPEED * delta

func _on_body_entered(body):
	if body.is_a_parent_of(self):
		return
	elif body.is_in_group('players') and !body.rolling:	
		OS.delay_msec(HIT_DELAY)
		body.damage(DAMAGE)
		destroy(body)
	elif 'Chest' in body.name:
		OS.delay_msec(HIT_DELAY)
		body.open(player)
	elif 'Crate' in body.name:
		OS.delay_msec(HIT_DELAY)
		destroy(body)
		if body.hit < 2:
			body.hit += 1
			body.get_node('AnimationPlayer').play('hit' + str(body.hit))
			yield(body.get_node('AnimationPlayer'), 'animation_finished')
			if body.hit == 2:
				body.queue_free()
	if !$CollisionShape2D.disabled:
		destroy(body)
	
func destroy(body):
	collided = true
	$Sprite.hide()
	$CollisionShape2D.disabled = true
	var on_hit_particle_obj = on_hit_particle.instance()
	add_child(on_hit_particle_obj)
	on_hit_particle_obj.global_position = get_collision_point(body)
	on_hit_particle_obj.rotation = rotation
	var particle_anim = on_hit_particle_obj.get_node('AnimationPlayer')
	particle_anim.play('hit')
	yield(particle_anim, 'animation_finished')
	queue_free()
	
func get_collision_point(body):
	#fix with more accurate
	return (global_position + direction * 23)
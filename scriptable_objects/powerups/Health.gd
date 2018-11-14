extends KinematicBody2D

const WAIT_TO_SPAWN = 0.6
const MOVE_SPEED = 3
const MOVE_DIST_Y = 40
const MIN_MOVE_DIST = 1
const STAY_TIME = 0.5
const HEALTH = 50

onready var particle = preload("res://player/human/weapons/bullet/Hit_Particle.tscn")

var ready = false
var spawned = false
var target_loc = Vector2()
var intended_player = null

func _ready():
	hide()
	target_loc = global_position
	target_loc.y -= MOVE_DIST_Y
	yield(get_tree().create_timer(WAIT_TO_SPAWN), 'timeout')
	show()
	ready = true

func _physics_process(delta):
	if !spawned or !ready:
		return
	
	var dist_to_target = global_position.distance_to(target_loc)
	if dist_to_target > MIN_MOVE_DIST:
		move_and_slide((target_loc - global_position) * MOVE_SPEED)
	else:
		if intended_player != null:
			intended_player.lives += 1
			if intended_player.lives > 3:
				intended_player.lives = 3
			intended_player.update_ui_hearts(intended_player.lives)
			
		self.set_physics_process(false)
		yield(get_tree().create_timer(STAY_TIME), "timeout")
		hide()
		$PowerupSound.play()
		var particle_obj = particle.instance()
		get_parent().add_child(particle_obj)
		particle_obj.get_node('Sprite').scale = Vector2(1.0,1.0)
		particle_obj.global_position = global_position
		particle_obj.global_position.y += -MOVE_DIST_Y
		yield($PowerupSound,"finished")
		particle_obj.queue_free()
		queue_free()
	
	
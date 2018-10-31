extends KinematicBody2D

const WAIT_TO_SPAWN = 0.6
const MOVE_SPEED = 3
const MOVE_DIST_Y = 25
const MIN_MOVE_DIST = 1
const STAY_TIME = 1
const HEALTH = 50

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
		if intended_player.is_master:
			if intended_player.health_points + HEALTH >= 100:
				intended_player.health_points = 100
			else:
				intended_player.health_points += HEALTH
			intended_player.update_reliable('update_player_health')
			intended_player._update_health_bar(intended_player.health_points)
			
		self.set_physics_process(false)
		yield(get_tree().create_timer(STAY_TIME), "timeout")
		queue_free()
	
	
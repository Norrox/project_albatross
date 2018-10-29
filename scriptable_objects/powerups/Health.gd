extends KinematicBody2D

const MOVE_SPEED = 3
const MOVE_DIST_Y = 40
const MIN_MOVE_DIST = 1
const STAY_TIME = 1
const HEALTH = 50

var spawned = false
var target_loc = Vector2()
var intended_player = null

func _ready():
	target_loc = global_position
	target_loc.y -= MOVE_DIST_Y

func _physics_process(delta):
	if !spawned:
		return
	
	var dist_to_target = global_position.distance_to(target_loc)
	if dist_to_target > MIN_MOVE_DIST:
		move_and_slide((target_loc - global_position) * MOVE_SPEED)
	else:
		if intended_player.health_points + HEALTH >= 100:
			intended_player.health_points = 100
		else:
			intended_player.health_points += HEALTH
		if intended_player.is_master:
			intended_player.update_reliable('update_player_health')
		intended_player._update_health_bar(intended_player.health_points)
			
		self.set_physics_process(false)
		yield(get_tree().create_timer(STAY_TIME), "timeout")
		queue_free()
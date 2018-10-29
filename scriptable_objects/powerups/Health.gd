extends KinematicBody2D

const MOVE_SPEED = 3
const MOVE_DIST_Y = 40
const MIN_MOVE_DIST = 1
const STAY_TIME = 1

var spawned = false
var target_loc = Vector2()

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
		self.set_physics_process(false)
		yield(get_tree().create_timer(STAY_TIME), "timeout")
		queue_free()
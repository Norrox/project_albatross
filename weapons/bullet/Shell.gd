extends KinematicBody2D

const SHOW_TIME = 2
const MIN_MOVE_DIST = 1
const MAX_MOVE_DIST = 100
const EXTRA_FORCE_Y = -50
const MAX_ROTATE_SPEED = 5

var target_pos = Vector2()
var rotate_dir = -1
var rotate_speed = MAX_ROTATE_SPEED

func _ready():
	randomize()
	rotate_dir = randi()%1-1
	rotate_speed = randi()%MAX_ROTATE_SPEED-MAX_ROTATE_SPEED
	target_pos = global_position
	target_pos += Vector2(randi()%MAX_MOVE_DIST-MAX_MOVE_DIST, randi()%MAX_MOVE_DIST-MAX_MOVE_DIST)
	target_pos.y += EXTRA_FORCE_Y
	$AnimationPlayer.play('idle')
	yield(get_tree().create_timer(SHOW_TIME),'timeout')
	queue_free()
	
func _physics_process(delta):
	if global_position.distance_to(target_pos) > MIN_MOVE_DIST:
		move_and_slide(target_pos - global_position)
		rotation += rotate_dir * delta * rotate_speed
	else:
		$AnimationPlayer.play('on_ground')
		set_physics_process(false)
		
extends KinematicBody2D

const MIN_MOVE_DIST = 1
const MAX_MOVE_DIST = 60
const EXTRA_FORCE_Y = 25
const MAX_ROTATE_SPEED = 5

var target_pos = Vector2()
var rotate_dir = -1
var rotate_speed = MAX_ROTATE_SPEED

var shrink = false

func _ready():
	var player = $'/root'.get_node(Network.self_data.name)
	randomize()
	rotate_dir = randi()%3-1
	rotate_speed = randi()%MAX_ROTATE_SPEED+1
	target_pos = global_position
	if !player.get_node('Sprite').flip_h:
		target_pos += Vector2(-randi()%MAX_MOVE_DIST+1, -randi()%MAX_MOVE_DIST+1)
	else:
		target_pos += Vector2(randi()%MAX_MOVE_DIST+1, -randi()%MAX_MOVE_DIST+1)
	target_pos.y += EXTRA_FORCE_Y
	$AnimationPlayer.play('idle')
	
func _physics_process(delta):
	if shrink:
		scale *= 0.9
	if scale.x < 0.3:
		queue_free()
	if global_position.distance_to(target_pos) > MIN_MOVE_DIST:
		move_and_slide((target_pos - global_position) * 5) 
		rotation += rotate_dir * delta * rotate_speed
	else:
		$AnimationPlayer.play('on_ground')
		#set_physics_process(false)
		

func _on_Lifetime_timeout():
	queue_free()

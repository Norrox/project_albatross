extends KinematicBody2D

const ORIG_POS = Vector2(576,-282)
const TARGET_POS = Vector2(576, 282)
const MOVE_SPEED = 3

var move_up = false

func _ready():
	hide()

func _physics_process(delta):
	if !visible:
		show()	
	if global_position.distance_to(TARGET_POS) > 1:
		move_and_slide((TARGET_POS - global_position) * MOVE_SPEED)


